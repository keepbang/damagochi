import Foundation
import SwiftUI
import DamagochiCore
import DamagochiNetwork

@MainActor
final class BattleViewModel: ObservableObject {

    // MARK: - Phase

    enum Phase: Equatable {
        case browsing
        case connecting(peerId: String)
        case inBattle
        case finished(won: Bool)
    }

    enum TurnPhase {
        case selectingSkill
        case waitingForOpponent
        case resolving
    }

    // MARK: - Published

    @Published var phase: Phase = .browsing
    @Published var foundPeers: [FoundPeer] = []
    @Published var battleState: BattleState?
    @Published var turnPhase: TurnPhase = .selectingSkill
    @Published var lastReward: BattleReward?
    @Published var errorMessage: String?
    @Published var selectedSkillId: String?

    struct FoundPeer: Identifiable {
        let id: String
        let name: String
    }

    // MARK: - Private

    private let transport: LocalNetworkTransport
    private weak var petViewModel: PetViewModel?
    private var opponentSkillId: String?
    private var mySkillId: String?
    private var eventTask: Task<Void, Never>?
    private var timeoutTask: Task<Void, Never>?
    private var myNonce: String = ""
    private var opponentCommitHash: String?
    private var myCommitSent = false
    private var activeDiscoveryViews = 0
    private var isBrowsing = false

    // MARK: - Init

    init(petViewModel: PetViewModel) {
        self.petViewModel = petViewModel
        let name = petViewModel.state.name
            ?? petViewModel.state.species
            ?? petViewModel.state.machineId
        self.transport = LocalNetworkTransport(displayName: name)
        startListening()
    }

    deinit {
        eventTask?.cancel()
        timeoutTask?.cancel()
    }

    // MARK: - Actions

    /// Tracks every visible battle view. The app has both a main window and a
    /// menu bar popover, so discovery stops only after both have disappeared.
    func activateDiscovery() {
        activeDiscoveryViews += 1
        guard activeDiscoveryViews == 1 else { return }
        guard case .browsing = phase else { return }
        startBrowsing()
    }

    func deactivateDiscovery() {
        guard activeDiscoveryViews > 0 else { return }
        activeDiscoveryViews -= 1
        guard activeDiscoveryViews == 0 else { return }
        stopBrowsing()
    }

    func startBrowsing() {
        guard case .browsing = phase else { return }
        guard !isBrowsing else { return }
        isBrowsing = true
        transport.startBrowsing()
        foundPeers = []
        errorMessage = nil
    }

    func stopBrowsing() {
        guard isBrowsing else { return }
        isBrowsing = false
        transport.stopBrowsing()
    }

    func retryBrowsing() {
        guard case .browsing = phase else { return }
        stopBrowsing()
        startBrowsing()
    }

    func invitePeer(_ peer: FoundPeer) {
        phase = .connecting(peerId: peer.id)
        do {
            try transport.invite(peer.id)
        } catch {
            errorMessage = error.localizedDescription
            phase = .browsing
        }
    }

    func selectSkill(_ skillId: String) {
        guard turnPhase == .selectingSkill else { return }
        mySkillId = skillId
        selectedSkillId = skillId
        turnPhase = .waitingForOpponent

        // Commit-Reveal Step 1: commit 전송
        myNonce = CommitReveal.makeNonce()
        let hash = CommitReveal.commit(skillId: skillId, nonce: myNonce)
        do {
            try transport.send(.skillCommit(hash: hash, turn: battleState?.turn ?? 1))
            myCommitSent = true
        } catch {
            turnPhase = .selectingSkill
            errorMessage = "스킬 전송 실패: \(error.localizedDescription)"
            mySkillId = nil
            selectedSkillId = nil
            return
        }

        // 상대방 commit이 이미 도착한 경우 reveal 전송
        if opponentCommitHash != nil {
            sendReveal()
        }
        startTurnTimeout()
    }

    func forfeit() {
        try? transport.send(.forfeit)
        transport.disconnect()
        phase = .finished(won: false)
        applyReward(won: false)
    }

    func reset() {
        transport.disconnect()
        battleState = nil
        opponentSkillId = nil
        mySkillId = nil
        selectedSkillId = nil
        lastReward = nil
        errorMessage = nil
        opponentCommitHash = nil
        myCommitSent = false
        myNonce = ""
        phase = .browsing
        foundPeers = []
        startBrowsing()
    }

    // MARK: - Skills for current character

    var mySkills: [BattleSkill] {
        if let group = battleState?.myProfile.mbtiGroup {
            return BattleSkill.skills(for: group)
        }
        guard let speciesId = petViewModel?.state.species,
              let species = Species.allSpecies.first(where: { $0.id == speciesId })
        else { return [] }
        return BattleSkill.skills(for: species.group)
    }

    // MARK: - Event Listener

    private func startListening() {
        eventTask = Task { [weak self] in
            guard let self else { return }
            for await event in self.transport.events {
                await MainActor.run {
                    self.handleEvent(event)
                }
            }
        }
    }

    private func handleEvent(_ event: BattleTransportEvent) {
        switch event {
        case .peerFound(let id, let name):
            if !foundPeers.contains(where: { $0.id == id }) {
                foundPeers.append(FoundPeer(id: id, name: name))
            }

        case .peerLost(let id):
            foundPeers.removeAll { $0.id == id }

        case .connected:
            stopBrowsing()
            sendMyProfile()

        case .disconnected:
            if phase == .inBattle {
                errorMessage = "상대방 연결이 끊어졌습니다"
                phase = .finished(won: true)
                applyReward(won: true)
            } else if case .connecting = phase {
                errorMessage = "상대방과 연결하지 못했습니다"
                phase = .browsing
                if activeDiscoveryViews > 0 {
                    startBrowsing()
                }
            }

        case .messageReceived(let msg):
            handleMessage(msg)

        case .error(let err):
            stopBrowsing()
            errorMessage = err.localizedDescription
        }
    }

    private func handleMessage(_ message: BattleMessage) {
        switch message {
        case .profile(let profile):
            guard let myState = petViewModel?.state,
                  let myProfile = BattleProfile.from(myState)
            else { return }
            battleState = BattleState(me: myProfile, opponent: profile)
            phase = .inBattle
            turnPhase = .selectingSkill

        case .skillCommit(let hash, _):
            opponentCommitHash = hash
            // 내 commit이 이미 전송된 경우 reveal 전송
            if myCommitSent {
                sendReveal()
            }

        case .skillReveal(let skillId, let nonce, _):
            // Commit-Reveal 검증: nonce로 해시 재계산하여 commit과 일치하는지 확인
            if let commitHash = opponentCommitHash {
                let expectedHash = CommitReveal.commit(skillId: skillId, nonce: nonce)
                if expectedHash != commitHash {
                    errorMessage = "상대방 스킬 검증 실패: 커밋 해시 불일치"
                    return
                }
            }
            opponentSkillId = skillId
            tryResolveTurn()

        case .battleEnd:
            break

        case .forfeit:
            phase = .finished(won: true)
            applyReward(won: true)
        }
    }

    // MARK: - Commit-Reveal

    private func sendReveal() {
        guard let skillId = mySkillId else { return }
        do {
            try transport.send(.skillReveal(skillId: skillId, nonce: myNonce, turn: battleState?.turn ?? 1))
        } catch {
            errorMessage = "스킬 공개 실패: \(error.localizedDescription)"
        }
    }

    // MARK: - Turn Resolution

    private func tryResolveTurn() {
        guard let myId = mySkillId, let opId = opponentSkillId,
              var state = battleState else { return }

        timeoutTask?.cancel()
        turnPhase = .resolving

        BattleEngine.resolveTurn(state: &state, mySkillId: myId, opponentSkillId: opId)
        battleState = state

        mySkillId = nil
        opponentSkillId = nil
        selectedSkillId = nil
        opponentCommitHash = nil
        myCommitSent = false

        if state.status != .ongoing {
            let won = state.status == .victory
            let result = BattleResult(
                winnerId: won ? state.myProfile.id : state.opponentProfile.id,
                loserId: won ? state.opponentProfile.id : state.myProfile.id,
                turns: state.turn,
                log: state.log
            )
            try? transport.send(.battleEnd(result: result))
            phase = .finished(won: won)
            applyReward(won: won)
        } else {
            turnPhase = .selectingSkill
        }
    }

    private func startTurnTimeout() {
        timeoutTask?.cancel()
        timeoutTask = Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(for: .seconds(BattleTimeout.skillSelectSeconds))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                if self.opponentSkillId == nil {
                    guard let group = self.battleState?.opponentProfile.mbtiGroup else { return }
                    let defaultSkillId = BattleTimeout.defaultSkillId(for: group)
                    self.opponentSkillId = defaultSkillId
                    // 타임아웃 시: 상대방에게 기본 스킬로 reveal 전송
                    try? self.transport.send(.skillReveal(skillId: self.mySkillId ?? BattleTimeout.defaultSkillId(for: self.battleState?.myProfile.mbtiGroup ?? group), nonce: self.myNonce, turn: self.battleState?.turn ?? 1))
                    self.tryResolveTurn()
                }
            }
        }
    }

    // MARK: - Profile Exchange

    private func sendMyProfile() {
        guard let myState = petViewModel?.state,
              let profile = BattleProfile.from(myState) else { return }
        do {
            try transport.send(.profile(profile))
        } catch {
            errorMessage = "프로필 전송 실패: \(error.localizedDescription)"
        }
    }

    // MARK: - Reward

    private func applyReward(won: Bool) {
        guard let vm = petViewModel,
              let opRarity = battleState?.opponentProfile.speciesRarity else { return }

        let allEquip = EquipmentDropper.itemPool
        let reward = BattleEngine.calcReward(
            won: won,
            myLevel: vm.state.level,
            opponentRarity: opRarity,
            allEquipment: allEquip
        )
        lastReward = reward
        vm.applyBattleReward(reward)
    }
}

// MARK: - PetViewModel 확장

extension PetViewModel {
    func applyBattleReward(_ reward: BattleReward) {
        state.xp += reward.xpGained
        state.totalXp += reward.xpGained
        if let item = reward.droppedEquipment {
            state.inventory.append(item)
        }
        save()
    }
}
