import Foundation
import SwiftUI
import DamagochiCore
import DamagochiRenderer

struct BattleView: View {
    @ObservedObject var battleVM: BattleViewModel
    @ObservedObject var petVM: PetViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            content
        }
        .onAppear {
            battleVM.syncPetState()
            battleVM.activateDiscovery()
        }
        .onDisappear { battleVM.deactivateDiscovery() }
        .onChange(of: petVM.state.phase.rawValue) { _, _ in battleVM.syncPetState() }
        .onChange(of: petVM.state.species) { _, _ in battleVM.syncPetState() }
        .onChange(of: petVM.state.name) { _, _ in battleVM.syncPetState() }
    }

    private var header: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Text("배틀").font(.headline)
                Spacer()
                switch battleVM.phase {
                case .browsing where battleVM.canBattle:
                    statusPill("탐색 중", progress: true)
                case .connecting:
                    statusPill("연결 중", progress: true)
                case .inBattle:
                    statusPill("진행 중", progress: false)
                default:
                    EmptyView()
                }
            }
            Picker("배틀 방식", selection: Binding(
                get: { battleVM.mode },
                set: { battleVM.setMode($0) }
            )) {
                ForEach(BattleMode.allCases, id: \.self) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .disabled(battleVM.phase != .browsing)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private func statusPill(_ title: String, progress: Bool) -> some View {
        HStack(spacing: 4) {
            if progress {
                ProgressView().scaleEffect(0.55)
            } else {
                Circle().fill(.green).frame(width: 6, height: 6)
            }
            Text(title).font(.caption2.bold()).foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var content: some View {
        if !battleVM.canBattle {
            battleLockedView
        } else {
            switch battleVM.phase {
            case .browsing, .connecting:
                browsingView
            case .inBattle:
                if let state = battleVM.battleState { battleView(state: state) }
            case .finished(let won):
                resultView(won: won)
            }
        }
    }

    private var battleLockedView: some View {
        VStack(spacing: 12) {
            Spacer()
            AnimatedPetView(frames: petVM.baseFrames, scale: 10.0 / 3.0, interval: 0.55)
                .accessibilityHidden(true)
            VStack(spacing: 5) {
                Text(lockTitle).font(.headline)
                Text(lockMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
        .padding(.horizontal, 28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }

    private var lockTitle: String {
        if battleVM.mode == .team { return "토너먼트 배틀에는 펫 2마리가 필요해요" }
        switch petVM.state.phase {
        case .egg: return "아직 배틀할 수 없어요"
        case .dead: return "배틀에 참여할 펫이 없어요"
        case .alive: return "펫 정보를 준비하고 있어요"
        }
    }

    private var lockMessage: String {
        if battleVM.mode == .team { return "부화한 펫을 2마리 이상 보유하면 팀 전체가 순서대로 출전해요." }
        switch petVM.state.phase {
        case .egg: return "알이 부화하면 다른 펫과 배틀할 수 있어요."
        case .dead: return "새로운 펫과 다시 시작하면 배틀이 열려요."
        case .alive: return "잠시 후 다시 시도해 주세요."
        }
    }

    private var browsingView: some View {
        VStack(spacing: 9) {
            myStatsCard.padding(.horizontal, 10).padding(.top, 8)
            Divider().padding(.horizontal, 10)

            if case .connecting(let peerId) = battleVM.phase {
                connectionWaitingView(peerId: peerId)
            } else if battleVM.foundPeers.isEmpty {
                VStack(spacing: 8) {
                    Spacer()
                    Image(systemName: "dot.radiowaves.left.and.right")
                        .font(.system(size: 28)).foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                    Text("같은 Wi-Fi의 상대를 찾는 중...")
                        .font(.caption).foregroundStyle(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 6) {
                        ForEach(battleVM.foundPeers) { peer in peerRow(peer) }
                    }
                    .padding(.horizontal, 10)
                }
            }

            if let errorMessage = battleVM.errorMessage {
                HStack(spacing: 6) {
                    Text(errorMessage).font(.caption2).foregroundStyle(.red).lineLimit(2)
                    Button("다시 시도") { battleVM.retryBrowsing() }.controlSize(.mini)
                }
                .padding(.horizontal, 10).padding(.bottom, 4)
            }
        }
    }

    @ViewBuilder
    private var myStatsCard: some View {
        if battleVM.mode == .team {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("내 팀 · 전원 출전").font(.subheadline.bold())
                    Spacer()
                    Text("\(battleVM.teamProfiles.count)마리").font(.caption).foregroundStyle(.secondary)
                }
                TeamProfileGrid(profiles: battleVM.teamProfiles, activeID: nil, tint: .teal)
                Text("펫이 쓰러지면 다음 생존 펫이 자동으로 출전합니다.")
                    .font(.system(size: 9)).foregroundStyle(.secondary)
            }
            .padding(8)
            .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 8))
        } else if let profile = BattleProfile.from(petVM.state) {
            VStack(spacing: 4) {
                HStack {
                    Text(profile.petName).font(.subheadline.bold()).lineLimit(1)
                    rarityBadge(profile.speciesRarity)
                    Spacer()
                    Text("Lv.\(petVM.state.level)").font(.caption).foregroundStyle(.secondary)
                }
                statGrid(profile.stats)
            }
            .padding(8)
            .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 8))
        }
    }

    private func connectionWaitingView(peerId: String) -> some View {
        let peerName = battleVM.foundPeers.first(where: { $0.id == peerId })?.name ?? "상대방"
        return VStack(spacing: 12) {
            Spacer()
            ProgressView().controlSize(.small)
            VStack(spacing: 3) {
                Text("\(peerName)님의 응답을 기다리는 중").font(.subheadline.bold())
                Text("연결이 지연되면 언제든 취소할 수 있어요.")
                    .font(.caption2).foregroundStyle(.secondary)
            }
            Button("요청 취소") { battleVM.cancelConnection() }
                .buttonStyle(.bordered).controlSize(.small)
            Spacer()
        }
        .frame(maxWidth: .infinity).padding(.horizontal, 16)
    }

    private func peerRow(_ peer: BattleViewModel.FoundPeer) -> some View {
        HStack(spacing: 7) {
            Image(systemName: "shield.lefthalf.filled").foregroundStyle(.blue)
                .accessibilityHidden(true)
            Text(peer.name).font(.subheadline).lineLimit(1)
            Spacer()
            Button("배틀") { battleVM.invitePeer(peer) }
                .buttonStyle(.borderedProminent).controlSize(.mini)
        }
        .padding(8)
        .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 8))
    }

    private func battleView(state: BattleState) -> some View {
        let presentation = battleVM.battlePresentation
        return VStack(spacing: 5) {
            if let team = battleVM.teamBattleState {
                HStack(spacing: 6) {
                    TeamProfileGrid(profiles: team.myTeam, activeID: team.myActiveProfile.id, tint: .teal)
                    Text("vs").font(.caption.bold()).foregroundStyle(.secondary)
                    TeamProfileGrid(profiles: team.opponentTeam, activeID: team.opponentActiveProfile.id, tint: .purple)
                }
                .padding(.horizontal, 8)
            }
            BattleArena(
                myProfile: state.myProfile,
                opponentProfile: state.opponentProfile,
                presentationTrigger: presentation.map { String(describing: $0.id) } ?? "",
                myDamage: presentation?.myDamage ?? 0,
                opponentDamage: presentation?.opponentDamage ?? 0,
                reduceMotion: reduceMotion
            )
            .frame(height: 154)
            battleMessage(state.log).frame(height: 38)
            skillCommandPanel(state: state)
        }
        .padding(.horizontal, 8).padding(.vertical, 6)
    }

    private func battleMessage(_ log: [String]) -> some View {
        let message = log.reversed().first(where: { !$0.hasPrefix("===") })?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            ?? "상대의 움직임을 살피고 스킬을 선택하세요."
        return HStack(spacing: 7) {
            Image(systemName: "text.bubble.fill").font(.caption).foregroundStyle(.cyan)
                .accessibilityHidden(true)
            Text(message).font(.system(size: 10, weight: .medium)).lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading).id(message)
        }
        .padding(.horizontal, 9)
        .background(RoundedRectangle(cornerRadius: 8).fill(.quaternary.opacity(0.45)))
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.18), value: message)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("전투 메시지").accessibilityValue(message)
    }

    private func skillCommandPanel(state: BattleState) -> some View {
        let skills = BattleSkill.skills(for: state.myProfile.mbtiGroup)
        let isSelecting = battleVM.turnPhase == .selectingSkill
        return VStack(spacing: 5) {
            HStack(spacing: 5) {
                Text("턴 \(state.turn)").font(.caption.bold())
                commandStatus
                Spacer()
                Button("항복") { battleVM.forfeit() }
                    .buttonStyle(.plain).font(.caption2).foregroundStyle(.secondary)
            }
            .frame(height: 18)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 5), GridItem(.flexible())], spacing: 5) {
                ForEach(Array(skills.enumerated()), id: \.element.id) { index, skill in
                    skillButton(skill: skill, index: index, isSelecting: isSelecting)
                }
            }
        }
    }

    @ViewBuilder
    private var commandStatus: some View {
        switch battleVM.turnPhase {
        case .selectingSkill:
            HStack(spacing: 3) {
                Image(systemName: "timer")
                Text("\(battleVM.selectionSecondsRemaining)초 후 자동 선택").monospacedDigit()
            }
            .font(.caption2)
            .foregroundStyle(battleVM.selectionSecondsRemaining <= 3 ? .orange : .secondary)
        case .waitingForOpponent:
            HStack(spacing: 3) {
                ProgressView().scaleEffect(0.5)
                Text("상대 선택 대기")
            }
            .font(.caption2).foregroundStyle(.secondary)
        case .resolving:
            Text("스킬 발동!").font(.caption2.bold()).foregroundStyle(.cyan)
        }
    }

    private func skillButton(skill: BattleSkill, index: Int, isSelecting: Bool) -> some View {
        let isSelected = battleVM.selectedSkillId == skill.id
        return Button {
            if isSelecting { battleVM.selectSkill(skill.id) }
        } label: {
            HStack(spacing: 5) {
                Text(skill.icon).font(.system(size: 15)).accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 0) {
                    Text(skill.name).font(.caption.bold()).lineLimit(1)
                    Text(skill.isAttack ? "공격" : "지원")
                        .font(.system(size: 8)).foregroundStyle(.secondary)
                }
                Spacer(minLength: 2)
                if isSelected {
                    Image(systemName: "checkmark.circle.fill").font(.caption).foregroundStyle(.cyan)
                }
            }
            .padding(.horizontal, 7).frame(height: 34)
            .background(RoundedRectangle(cornerRadius: 7)
                .fill(isSelected ? Color.cyan.opacity(0.16) : Color.primary.opacity(0.055)))
            .overlay(RoundedRectangle(cornerRadius: 7)
                .stroke(isSelected ? Color.cyan : Color.primary.opacity(0.08), lineWidth: 1))
            .scaleEffect(isSelected && !reduceMotion ? 1.02 : 1)
        }
        .buttonStyle(.plain)
        .keyboardShortcut(KeyEquivalent(Character(String(index + 1))), modifiers: [])
        .disabled(!isSelecting)
        .opacity(isSelecting || isSelected ? 1 : 0.55)
        .animation(reduceMotion ? nil : .spring(response: 0.2, dampingFraction: 0.7), value: isSelected)
        .accessibilityLabel("\(skill.name), \(skill.isAttack ? "공격" : "지원")")
        .accessibilityHint("숫자 \(index + 1) 키로 선택")
    }

    private func resultView(won: Bool) -> some View {
        VStack(spacing: 12) {
            Spacer()
            Text(won ? "🏆 승리!" : "💀 패배").font(.title.bold())
                .foregroundStyle(won ? .yellow : .secondary)
            if let turns = battleVM.battleState?.turn {
                Text("\(max(0, turns - 1))턴 만에 종료").font(.caption).foregroundStyle(.secondary)
            }
            if let reward = battleVM.lastReward {
                VStack(spacing: 6) {
                    Text("✨ XP +\(reward.xpGained)").font(.subheadline.bold())
                    if let item = reward.droppedEquipment {
                        HStack(spacing: 4) {
                            rarityBadge(item.rarity)
                            Text("\(item.name) 획득!").font(.caption)
                        }
                        .padding(6).background(.yellow.opacity(0.2), in: RoundedRectangle(cornerRadius: 6))
                    }
                }
                .padding().background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 10))
            }
            Spacer()
            Button("돌아가기") { battleVM.reset() }
                .buttonStyle(.borderedProminent).padding(.bottom)
        }
        .padding()
    }

    private func statGrid(_ stats: BattleStats) -> some View {
        HStack(spacing: 0) {
            statItem("ATK", stats.atk); statItem("INT", stats.int_); statItem("HP", stats.maxHp)
            statItem("SPD", stats.spd); statItem("DEF", stats.def)
        }
    }

    private func statItem(_ label: String, _ value: Int) -> some View {
        VStack(spacing: 1) {
            Text(label).font(.system(size: 8)).foregroundStyle(.secondary)
            Text("\(value)").font(.system(size: 10, design: .monospaced).bold())
        }
        .frame(maxWidth: .infinity)
    }

    private func rarityBadge(_ rarity: Rarity) -> some View {
        Text(rarity.shortLabel).font(.system(size: 8).bold()).foregroundStyle(rarity.color)
            .padding(.horizontal, 4).padding(.vertical, 1)
            .background(rarity.color.opacity(0.15), in: Capsule())
    }
}

private struct TeamProfileGrid: View {
    let profiles: [BattleProfile]
    let activeID: String?
    let tint: Color

    var body: some View {
        HStack(spacing: 3) {
            ForEach(profiles) { profile in
                let isActive = activeID == profile.id
                let fainted = profile.stats.currentHp <= 0
                VStack(spacing: 1) {
                    Text(profile.petName).font(.system(size: 8, weight: isActive ? .bold : .regular)).lineLimit(1)
                    Text("\(max(0, profile.stats.currentHp))/\(profile.stats.maxHp)")
                        .font(.system(size: 7, design: .monospaced))
                }
                .foregroundStyle(fainted ? .secondary : .primary)
                .opacity(fainted ? 0.42 : 1)
                .padding(.horizontal, 4).padding(.vertical, 3)
                .background(isActive ? tint.opacity(0.22) : Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 4))
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(isActive ? tint : .clear, lineWidth: 1))
            }
        }
    }
}

private struct BattleArena: View {
    let myProfile: BattleProfile
    let opponentProfile: BattleProfile
    let presentationTrigger: String
    let myDamage: Int
    let opponentDamage: Int
    let reduceMotion: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient(colors: [
                    Color(red: 0.08, green: 0.11, blue: 0.23),
                    Color(red: 0.16, green: 0.10, blue: 0.28),
                    Color(red: 0.05, green: 0.20, blue: 0.24),
                ], startPoint: .topLeading, endPoint: .bottomTrailing))
            BattleGrid().clipShape(RoundedRectangle(cornerRadius: 12)).accessibilityHidden(true)
            arenaPlatform(color: .cyan).offset(x: 72, y: -29)
            arenaPlatform(color: .purple).offset(x: -67, y: 47)

            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 4) {
                    CombatantHUD(profile: opponentProfile, isOpponent: true).frame(width: 132)
                    Spacer(minLength: 0)
                    BattlePetSprite(profile: opponentProfile, trigger: presentationTrigger,
                                    damage: opponentDamage, direction: 1, reduceMotion: reduceMotion)
                        .frame(width: 64, height: 62)
                }
                Spacer(minLength: 0)
                HStack(alignment: .bottom, spacing: 4) {
                    BattlePetSprite(profile: myProfile, trigger: presentationTrigger,
                                    damage: myDamage, direction: -1, reduceMotion: reduceMotion)
                        .frame(width: 64, height: 62)
                    Spacer(minLength: 0)
                    CombatantHUD(profile: myProfile, isOpponent: false).frame(width: 132)
                }
            }
            .padding(8)
        }
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.12), lineWidth: 1))
    }

    private func arenaPlatform(color: Color) -> some View {
        Ellipse().fill(color.opacity(0.18))
            .overlay(Ellipse().stroke(color.opacity(0.35), lineWidth: 1))
            .frame(width: 88, height: 21).accessibilityHidden(true)
    }
}

private struct BattleGrid: View {
    var body: some View {
        Canvas { context, size in
            var path = Path()
            for x in stride(from: 0.0, through: size.width, by: 18) {
                path.move(to: CGPoint(x: x, y: 0)); path.addLine(to: CGPoint(x: x, y: size.height))
            }
            for y in stride(from: 0.0, through: size.height, by: 18) {
                path.move(to: CGPoint(x: 0, y: y)); path.addLine(to: CGPoint(x: size.width, y: y))
            }
            context.stroke(path, with: .color(.white.opacity(0.045)), lineWidth: 0.5)
        }
        .allowsHitTesting(false)
    }
}

private struct CombatantHUD: View {
    let profile: BattleProfile
    let isOpponent: Bool

    private var ratio: Double {
        min(1, max(0, Double(profile.stats.currentHp) / Double(max(1, profile.stats.maxHp))))
    }
    private var color: Color { ratio > 0.5 ? .green : (ratio > 0.25 ? .yellow : .red) }

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 4) {
                Text(profile.petName).font(.system(size: 10, weight: .bold)).lineLimit(1)
                Text(profile.speciesRarity.shortLabel).font(.system(size: 7, weight: .bold))
                    .foregroundStyle(profile.speciesRarity.color)
                if let battleLevel = profile.battleLevel {
                    Text("Lv.\(battleLevel)")
                        .font(.system(size: 7, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.72))
                }
                Spacer(minLength: 0)
                Text("\(profile.stats.currentHp)/\(profile.stats.maxHp)")
                    .font(.system(size: 8, design: .monospaced)).foregroundStyle(.white.opacity(0.78))
            }
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.13))
                    Capsule().fill(color).frame(width: geometry.size.width * ratio)
                        .animation(.easeOut(duration: 0.35), value: profile.stats.currentHp)
                }
            }
            .frame(height: 7)
        }
        .foregroundStyle(.white).padding(.horizontal, 7).padding(.vertical, 6)
        .background(.black.opacity(0.48), in: RoundedRectangle(cornerRadius: 7))
        .overlay(RoundedRectangle(cornerRadius: 7).stroke(.white.opacity(0.1), lineWidth: 0.5))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(isOpponent ? "상대" : "내") 펫 \(profile.petName)")
        .accessibilityValue("체력 \(profile.stats.currentHp) / \(profile.stats.maxHp)")
    }
}

private struct BattlePetSprite: View {
    let profile: BattleProfile
    let trigger: String
    let damage: Int
    let direction: CGFloat
    let reduceMotion: Bool

    @State private var shake: CGFloat = 0
    @State private var flash = false
    @State private var effectScale: CGFloat = 0.2
    @State private var effectOpacity = 0.0
    @State private var labelOpacity = 0.0
    @State private var labelOffset: CGFloat = 0
    @State private var shownDamage = 0

    var body: some View {
        ZStack(alignment: .top) {
            ImpactEffect(scale: effectScale, opacity: effectOpacity, healing: shownDamage < 0)
            ZStack {
                AnimatedPetView(frames: SpriteSheet.frames(species: profile.speciesId,
                                                           stage: profile.stage ?? .stage1,
                                                           phase: .alive,
                                                           direction: direction < 0 ? .back : .front),
                                scale: 13.0 / 6.0, interval: 0.45)
                BattleEquipmentOverlays(profile: profile, scale: 13.0 / 6.0)
            }
            .offset(x: shake).brightness(flash ? 0.7 : 0)
            if labelOpacity > 0 {
                Text(shownDamage < 0 ? "+\(abs(shownDamage))" : "-\(shownDamage)")
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundStyle(shownDamage < 0 ? .green : .yellow)
                    .shadow(color: .black, radius: 1, y: 1)
                    .offset(y: -12 + labelOffset).opacity(labelOpacity)
            }
        }
        .accessibilityHidden(true)
        .task(id: trigger) { await playImpact() }
    }

    @MainActor
    private func playImpact() async {
        guard !trigger.isEmpty, damage != 0 else { return }
        shownDamage = damage; labelOffset = 0; labelOpacity = 1
        effectScale = 0.2; effectOpacity = 0.9; flash = true
        if reduceMotion {
            try? await Task.sleep(for: .milliseconds(150))
            withAnimation(.easeOut(duration: 0.15)) { flash = false; effectOpacity = 0; labelOpacity = 0 }
            return
        }
        withAnimation(.easeOut(duration: 0.07)) {
            shake = 5 * direction; effectScale = 1.05; labelOffset = -3
        }
        try? await Task.sleep(for: .milliseconds(70)); guard !Task.isCancelled else { return }
        withAnimation(.linear(duration: 0.07)) {
            shake = -4 * direction; flash = false; effectScale = 1.35
            effectOpacity = 0.45; labelOffset = -7
        }
        try? await Task.sleep(for: .milliseconds(70)); guard !Task.isCancelled else { return }
        withAnimation(.linear(duration: 0.07)) { shake = 3 * direction }
        try? await Task.sleep(for: .milliseconds(70)); guard !Task.isCancelled else { return }
        withAnimation(.easeOut(duration: 0.2)) {
            shake = 0; effectScale = 1.7; effectOpacity = 0; labelOffset = -14; labelOpacity = 0
        }
    }
}

private struct BattleEquipmentOverlays: View {
    let profile: BattleProfile
    let scale: CGFloat

    var body: some View {
        let overlays = SpriteSheet.equippedOverlays(
            equipped: profile.equippedItems ?? EquippedItems(),
            inventory: profile.equippedEquipment ?? EquipmentDropper.itemPool
        )
        let offsets = profile.equipmentOffsets ?? EquipmentOffsets()
        ZStack {
            ForEach(overlays, id: \.slot) { overlay in
                PixelArtView(sprite: overlay.sprite, scale: scale)
                    .offset(
                        x: CGFloat(offsets.offset(for: overlay.slot).x) * scale * SpriteSheet.gridScale,
                        y: CGFloat(offsets.offset(for: overlay.slot).y) * scale * SpriteSheet.gridScale
                    )
                    .allowsHitTesting(false)
            }
        }
    }
}

private struct ImpactEffect: View {
    let scale: CGFloat
    let opacity: Double
    let healing: Bool
    var body: some View {
        ZStack {
            Circle().stroke(healing ? Color.green : Color.cyan, lineWidth: 2)
                .frame(width: 36, height: 36)
            ForEach(0..<8, id: \.self) { index in
                Capsule().fill(healing ? Color.green : (index.isMultiple(of: 2) ? Color.cyan : Color.yellow))
                    .frame(width: 3, height: 12).offset(y: -27)
                    .rotationEffect(.degrees(Double(index) * 45))
            }
        }
        .scaleEffect(scale).opacity(opacity)
    }
}

extension Rarity {
    var shortLabel: String {
        switch self { case .common: return "C"; case .rare: return "R"; case .legendary: return "L"; case .mythic: return "M" }
    }
    var color: Color {
        switch self { case .common: return .gray; case .rare: return .blue; case .legendary: return .purple; case .mythic: return .orange }
    }
}
