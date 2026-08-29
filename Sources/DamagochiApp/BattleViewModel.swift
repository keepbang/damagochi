import Foundation
import SwiftUI
import Combine
import DamagochiCore
import DamagochiNetwork

struct BattlePresentation: Identifiable, Equatable {
    let id: UUID
    let myDamage: Int
    let opponentDamage: Int

    init(id: UUID = UUID(), myDamage: Int, opponentDamage: Int) {
        self.id = id
        self.myDamage = myDamage
        self.opponentDamage = opponentDamage
    }
}

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
    @Published var selectionSecondsRemaining = Int(BattleTimeout.skillSelectSeconds)
    @Published var battlePresentation: BattlePresentation?

    struct FoundPeer: Identifiable {
        let id: String
        let name: String
    }

    // MARK: - Private

    private let transport: any BattleTransport
    private weak var petViewModel: PetViewModel?
    private var opponentSkillId: String?
    private var mySkillId: String?
    private var eventTask: Task<Void, Never>?
    private var connectTask: Task<Void, Never>?
    private var connectionTimeoutTask: Task<Void, Never>?
    private var selectionTimeoutTask: Task<Void, Never>?
    private var opponentResponseTask: Task<Void, Never>?
    private var finishTask: Task<Void, Never>?
    private var stateSubscription: AnyCancellable?
    private var myNonce: String = ""
    private var opponentCommitHash: String?
    private var myCommitSent = false
    private var myRevealSent = false
    private var activeDiscoveryViews = 0
    private var isBrowsing = false
    private var activePeerId: String?
    private var ignoredPeerIds: Set<String> = []

    // MARK: - Init

    convenience init(petViewModel: PetViewModel) {
        let displayName = Self.displayName(for: petViewModel.state)
        let transport = LocalNetworkTransport(
            peerId: petViewModel.state.machineId,
            displayName: displayName
        )
        self.init(petViewModel: petViewModel, transport: transport)
    }

    init(petViewModel: PetViewModel, transport: any BattleTransport) {
        self.petViewModel = petViewModel
        self.transport = transport
        startListening()
        stateSubscription = petViewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handlePetStateChange(state)
            }
    }

    deinit {
        eventTask?.cancel()
        connectTask?.cancel()
        connectionTimeoutTask?.cancel()
        selectionTimeoutTask?.cancel()
        opponentResponseTask?.cancel()
        finishTask?.cancel()
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
        guard canBattle else { return }
        guard !isBrowsing else { return }
        transport.updateDisplayName(Self.displayName(for: petViewModel?.state))
        isBrowsing = true
        transport.startBrowsing()
        foundPeers = []
    }

    func stopBrowsing() {
        guard isBrowsing else { return }
        isBrowsing = false
        transport.stopBrowsing()
    }

    func retryBrowsing() {
        guard case .browsing = phase else { return }
        errorMessage = nil
        stopBrowsing()
        startBrowsing()
    }

    /// Re-evaluates eligibility and the advertised pet name when the battle UI
    /// observes a pet-state change.
    func syncPetState() {
        guard let state = petViewModel?.state else { return }
        handlePetStateChange(state)
    }

    func invitePeer(_ peer: FoundPeer) {
        guard canBattle else {
            errorMessage = "알이 부화한 뒤 배틀할 수 있습니다"
            return
        }
        guard case .browsing = phase else { return }
        ignoredPeerIds.remove(peer.id)
        activePeerId = peer.id
        phase = .connecting(peerId: peer.id)
        errorMessage = nil
        startConnectionTimeout(peerId: peer.id)
        connectTask?.cancel()
        connectTask = Task { [weak self] in
            guard let self else { return }
            do {
                try await self.transport.connect(to: peer.id)
            } catch {
                guard !Task.isCancelled else { return }
                guard self.activePeerId == peer.id else { return }
                self.recoverToBrowsing(message: error.localizedDescription, ignoreActivePeer: true)
            }
        }
    }

    func cancelConnection() {
        guard case .connecting = phase else { return }
        recoverToBrowsing(message: nil, ignoreActivePeer: true)
    }

    func selectSkill(_ skillId: String) {
        guard phase == .inBattle,
              turnPhase == .selectingSkill,
              let state = battleState,
              BattleSkill.skills(for: state.myProfile.mbtiGroup).contains(where: { $0.id == skillId })
        else { return }

        selectionTimeoutTask?.cancel()
        selectionTimeoutTask = nil
        selectionSecondsRemaining = 0
        mySkillId = skillId
        selectedSkillId = skillId
        turnPhase = .waitingForOpponent

        // Commit-Reveal Step 1: commit 전송
        myNonce = CommitReveal.makeNonce()
        let hash = CommitReveal.commit(skillId: skillId, nonce: myNonce)
        do {
            try transport.send(.skillCommit(hash: hash, turn: state.turn))
            myCommitSent = true
        } catch {
            turnPhase = .selectingSkill
            errorMessage = "스킬 전송 실패: \(error.localizedDescription)"
            mySkillId = nil
            selectedSkillId = nil
            startSelectionCountdown()
            return
        }

        // 상대방 commit이 이미 도착한 경우 reveal 전송
        if opponentCommitHash != nil {
            sendReveal()
        }
        startOpponentResponseTimeout(turn: state.turn)
    }

    func forfeit() {
        cancelSessionTasks()
        try? transport.send(.forfeit)
        transport.disconnect()
        activePeerId = nil
        phase = .finished(won: false)
        applyReward(won: false)
    }

    func reset() {
        cancelSessionTasks()
        if let activePeerId { ignoredPeerIds.insert(activePeerId) }
        stopBrowsing()
        transport.disconnect()
        activePeerId = nil
        battleState = nil
        clearTurnState()
        battlePresentation = nil
        lastReward = nil
        errorMessage = nil
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

    var canBattle: Bool {
        guard let state = petViewModel?.state else { return false }
        return BattleProfile.from(state) != nil
    }

    // MARK: - Event Listener

    private func startListening() {
        let events = transport.events
        eventTask = Task { [weak self] in
            for await event in events {
                guard let self else { return }
                self.handleEvent(event)
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
            ignoredPeerIds.remove(id)

        case .connected(let peerId):
            if ignoredPeerIds.remove(peerId) != nil {
                transport.disconnect()
                return
            }
            guard canBattle else {
                transport.disconnect()
                return
            }
            switch phase {
            case .connecting(let expectedPeerId):
                guard expectedPeerId == peerId else {
                    transport.disconnect()
                    return
                }
            case .browsing:
                activePeerId = peerId
                phase = .connecting(peerId: peerId)
                startConnectionTimeout(peerId: peerId)
            case .inBattle:
                guard activePeerId == peerId else { transport.disconnect(); return }
                return
            case .finished:
                transport.disconnect()
                return
            }
            stopBrowsing()
            sendMyProfile()

        case .disconnected(let peerId):
            if ignoredPeerIds.remove(peerId) != nil { return }
            guard activePeerId == peerId else { return }
            activePeerId = nil
            cancelSessionTasks()
            if phase == .inBattle {
                errorMessage = "상대방 연결이 끊어졌습니다"
                phase = .finished(won: true)
                applyReward(won: true)
            } else if case .connecting = phase {
                recoverToBrowsing(message: "상대방과 연결하지 못했습니다")
            }

        case .messageReceived(let msg):
            handleMessage(msg)

        case .error(let err):
            if case .browsing = phase {
                stopBrowsing()
                errorMessage = err.localizedDescription
            } else {
                recoverToBrowsing(message: err.localizedDescription, ignoreActivePeer: true)
            }
        }
    }

    private func handleMessage(_ message: BattleMessage) {
        switch message {
        case .profile(let profile):
            guard case .connecting = phase,
                  activePeerId != nil,
                  let myState = petViewModel?.state,
                  let myProfile = BattleProfile.from(myState)
            else {
                recoverToBrowsing(message: "배틀 가능한 펫 프로필이 없습니다", ignoreActivePeer: true)
                return
            }
            connectionTimeoutTask?.cancel()
            connectionTimeoutTask = nil
            connectTask?.cancel()
            connectTask = nil
            battleState = BattleState(me: myProfile, opponent: profile)
            phase = .inBattle
            turnPhase = .selectingSkill
            clearTurnState()
            startSelectionCountdown()

        case .skillCommit(let hash, let turn):
            guard phase == .inBattle,
                  battleState?.turn == turn,
                  opponentCommitHash == nil
            else { return }
            opponentCommitHash = hash
            // 내 commit이 이미 전송된 경우 reveal 전송
            if myCommitSent {
                sendReveal()
            }

        case .skillReveal(let skillId, let nonce, let turn):
            guard phase == .inBattle,
                  let state = battleState,
                  state.turn == turn,
                  let commitHash = opponentCommitHash,
                  BattleSkill.skills(for: state.opponentProfile.mbtiGroup).contains(where: { $0.id == skillId })
            else { return }
            // Commit-Reveal 검증: nonce로 해시 재계산하여 commit과 일치하는지 확인
            let expectedHash = CommitReveal.commit(skillId: skillId, nonce: nonce)
            if expectedHash != commitHash {
                errorMessage = "상대방 스킬 검증 실패: 커밋 해시 불일치"
                return
            }
            opponentSkillId = skillId
            tryResolveTurn()

        case .battleEnd:
            break

        case .forfeit:
            guard phase == .inBattle else { return }
            cancelSessionTasks()
            transport.disconnect()
            activePeerId = nil
            phase = .finished(won: true)
            applyReward(won: true)
        }
    }

    // MARK: - Commit-Reveal

    private func sendReveal() {
        guard !myRevealSent,
              let skillId = mySkillId,
              let turn = battleState?.turn
        else { return }
        do {
            try transport.send(.skillReveal(skillId: skillId, nonce: myNonce, turn: turn))
            myRevealSent = true
        } catch {
            errorMessage = "스킬 공개 실패: \(error.localizedDescription)"
        }
    }

    // MARK: - Turn Resolution

    private func tryResolveTurn() {
        guard let myId = mySkillId, let opId = opponentSkillId,
              var state = battleState else { return }

        opponentResponseTask?.cancel()
        opponentResponseTask = nil
        selectionTimeoutTask?.cancel()
        selectionTimeoutTask = nil
        turnPhase = .resolving

        let myHpBefore = state.myProfile.stats.currentHp
        let opponentHpBefore = state.opponentProfile.stats.currentHp
        BattleEngine.resolveTurn(state: &state, mySkillId: myId, opponentSkillId: opId)
        battleState = state
        battlePresentation = BattlePresentation(
            myDamage: max(0, myHpBefore - state.myProfile.stats.currentHp),
            opponentDamage: max(0, opponentHpBefore - state.opponentProfile.stats.currentHp)
        )

        clearTurnState()

        if state.status != .ongoing {
            let won = state.status == .victory
            let result = BattleResult(
                winnerId: won ? state.myProfile.id : state.opponentProfile.id,
                loserId: won ? state.opponentProfile.id : state.myProfile.id,
                turns: state.turn,
                log: state.log
            )
            try? transport.send(.battleEnd(result: result))
            let presentationId = battlePresentation?.id
            finishTask?.cancel()
            finishTask = Task { [weak self] in
                try? await Task.sleep(for: .milliseconds(650))
                guard !Task.isCancelled, let self else { return }
                guard self.phase == .inBattle,
                      self.battlePresentation?.id == presentationId,
                      self.battleState?.status != .ongoing
                else { return }
                self.phase = .finished(won: won)
                self.applyReward(won: won)
            }
        } else {
            turnPhase = .selectingSkill
            startSelectionCountdown()
        }
    }

    // MARK: - Profile Exchange

    private func sendMyProfile() {
        guard let myState = petViewModel?.state,
              let profile = BattleProfile.from(myState)
        else {
            recoverToBrowsing(message: "알이 부화한 뒤 배틀할 수 있습니다", ignoreActivePeer: true)
            return
        }
        do {
            try transport.send(.profile(profile))
        } catch {
            recoverToBrowsing(message: "프로필 전송 실패: \(error.localizedDescription)", ignoreActivePeer: true)
        }
    }

    // MARK: - Timeouts and Recovery

    private func startConnectionTimeout(peerId: String) {
        connectionTimeoutTask?.cancel()
        connectionTimeoutTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(BattleTimeout.connectionSeconds))
            guard !Task.isCancelled, let self else { return }
            guard case .connecting(let expectedPeerId) = self.phase,
                  expectedPeerId == peerId,
                  self.activePeerId == peerId
            else { return }
            self.recoverToBrowsing(message: "상대방이 응답하지 않았습니다", ignoreActivePeer: true)
        }
    }

    private func startSelectionCountdown() {
        selectionTimeoutTask?.cancel()
        guard phase == .inBattle,
              turnPhase == .selectingSkill,
              let state = battleState
        else { return }

        let turn = state.turn
        let seconds = Int(BattleTimeout.skillSelectSeconds)
        selectionSecondsRemaining = seconds
        selectionTimeoutTask = Task { [weak self] in
            guard let self else { return }
            for remaining in stride(from: seconds - 1, through: 0, by: -1) {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                guard self.phase == .inBattle,
                      self.turnPhase == .selectingSkill,
                      self.battleState?.turn == turn
                else { return }
                self.selectionSecondsRemaining = remaining
            }

            guard let group = self.battleState?.myProfile.mbtiGroup else { return }
            self.selectSkill(BattleTimeout.defaultSkillId(for: group))
        }
    }

    private func startOpponentResponseTimeout(turn: Int) {
        opponentResponseTask?.cancel()
        let peerId = activePeerId
        opponentResponseTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(BattleTimeout.opponentResponseSeconds))
            guard !Task.isCancelled, let self else { return }
            guard self.phase == .inBattle,
                  self.turnPhase == .waitingForOpponent,
                  self.battleState?.turn == turn,
                  self.activePeerId == peerId
            else { return }
            self.recoverToBrowsing(message: "상대방의 스킬 응답이 없어 배틀을 종료했습니다", ignoreActivePeer: true)
        }
    }

    private func recoverToBrowsing(message: String?, ignoreActivePeer: Bool = false) {
        if ignoreActivePeer, let activePeerId {
            ignoredPeerIds.insert(activePeerId)
        }
        cancelSessionTasks()
        stopBrowsing()
        transport.disconnect()
        activePeerId = nil
        battleState = nil
        battlePresentation = nil
        clearTurnState()
        lastReward = nil
        foundPeers = []
        phase = .browsing
        startBrowsing()
        errorMessage = message
    }

    private func clearTurnState() {
        opponentSkillId = nil
        mySkillId = nil
        selectedSkillId = nil
        opponentCommitHash = nil
        myCommitSent = false
        myRevealSent = false
        myNonce = ""
    }

    private func cancelSessionTasks() {
        connectTask?.cancel()
        connectionTimeoutTask?.cancel()
        selectionTimeoutTask?.cancel()
        opponentResponseTask?.cancel()
        finishTask?.cancel()
        connectTask = nil
        connectionTimeoutTask = nil
        selectionTimeoutTask = nil
        opponentResponseTask = nil
        finishTask = nil
    }

    private func handlePetStateChange(_ state: PetState) {
        transport.updateDisplayName(Self.displayName(for: state))
        if BattleProfile.from(state) == nil {
            stopBrowsing()
            if phase != .browsing {
                recoverToBrowsing(message: "알이 부화한 뒤 배틀할 수 있습니다", ignoreActivePeer: true)
            }
        } else if phase == .browsing, activeDiscoveryViews > 0 {
            startBrowsing()
        }
    }

    private static func displayName(for state: PetState?) -> String {
        guard let state else { return "Damagochi" }
        if let name = state.name, !name.isEmpty { return name }
        if let speciesId = state.species,
           let species = Species.allSpecies.first(where: { $0.id == speciesId }) {
            return species.name
        }
        return state.machineId
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
        _ = awardSharedXP(reward.xpGained)
        if let item = reward.droppedEquipment {
            state.inventory.append(item)
        }
        save()
    }
}
