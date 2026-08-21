import SwiftUI
import DamagochiCore
import DamagochiNetwork

struct BattleView: View {
    @ObservedObject var battleVM: BattleViewModel
    @ObservedObject var petVM: PetViewModel

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            content
        }
        .onAppear { battleVM.activateDiscovery() }
        .onDisappear { battleVM.deactivateDiscovery() }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("배틀")
                .font(.headline)
            Spacer()
            if case .browsing = battleVM.phase {
                HStack(spacing: 4) {
                    ProgressView().scaleEffect(0.6)
                    Text("탐색 중").font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - Content Router

    @ViewBuilder
    private var content: some View {
        switch battleVM.phase {
        case .browsing, .connecting:
            browsingView
        case .inBattle:
            if let state = battleVM.battleState {
                battleView(state: state)
            }
        case .finished(let won):
            resultView(won: won)
        }
    }

    // MARK: - Browsing View

    private var browsingView: some View {
        VStack(spacing: 10) {
            myStatsCard
                .padding(.horizontal, 10)
                .padding(.top, 8)

            Divider().padding(.horizontal, 10)

            if battleVM.foundPeers.isEmpty {
                Spacer()
                VStack(spacing: 8) {
                    Text("👥").font(.system(size: 32))
                    Text("같은 Wi-Fi의 상대를 찾는 중...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 6) {
                        ForEach(battleVM.foundPeers) { peer in
                            peerRow(peer)
                        }
                    }
                    .padding(.horizontal, 10)
                }
            }

            if let err = battleVM.errorMessage {
                HStack(spacing: 6) {
                    Text(err)
                        .font(.caption)
                        .foregroundStyle(.red)
                    Button("다시 시도") { battleVM.retryBrowsing() }
                        .controlSize(.mini)
                }
                .padding(.horizontal)
            }
        }
    }

    private var myStatsCard: some View {
        guard let profile = BattleProfile.from(petVM.state) else {
            return AnyView(Text("펫이 없습니다").font(.caption).foregroundStyle(.secondary))
        }
        return AnyView(
            VStack(spacing: 4) {
                HStack {
                    Text(profile.petName).font(.subheadline.bold())
                    rarityBadge(profile.speciesRarity)
                    Spacer()
                    Text("Lv.\(petVM.state.level)").font(.caption).foregroundStyle(.secondary)
                }
                statGrid(profile.stats)
            }
            .padding(8)
            .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 8))
        )
    }

    private func peerRow(_ peer: BattleViewModel.FoundPeer) -> some View {
        let isConnecting: Bool
        if case .connecting(let id) = battleVM.phase, id == peer.id {
            isConnecting = true
        } else {
            isConnecting = false
        }

        return HStack {
            Text("⚔️")
            Text(peer.name).font(.subheadline)
            Spacer()
            if isConnecting {
                ProgressView().scaleEffect(0.7)
            } else {
                Button("배틀") { battleVM.invitePeer(peer) }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.mini)
            }
        }
        .padding(8)
        .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Battle View

    private func battleView(state: BattleState) -> some View {
        VStack(spacing: 0) {
            // 상대방
            combatantRow(
                name: state.opponentProfile.petName,
                rarity: state.opponentProfile.speciesRarity,
                currentHp: state.opponentProfile.stats.currentHp,
                maxHp: state.opponentProfile.stats.maxHp,
                isOpponent: true
            )
            .padding(.horizontal, 10)
            .padding(.top, 6)

            // 배틀 로그
            battleLog(state.log)
                .frame(height: 70)
                .padding(.horizontal, 10)

            // 나
            combatantRow(
                name: state.myProfile.petName,
                rarity: state.myProfile.speciesRarity,
                currentHp: state.myProfile.stats.currentHp,
                maxHp: state.myProfile.stats.maxHp,
                isOpponent: false
            )
            .padding(.horizontal, 10)

            Divider().padding(.vertical, 4)

            // 스킬 선택
            skillGrid(state: state)
                .padding(.horizontal, 10)
                .padding(.bottom, 6)

            // 항복 버튼
            Button("항복") { battleVM.forfeit() }
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.bottom, 4)
        }
    }

    private func combatantRow(name: String, rarity: Rarity, currentHp: Int, maxHp: Int, isOpponent: Bool) -> some View {
        VStack(spacing: 3) {
            HStack {
                if isOpponent { Text("👾") } else { Text("🐾") }
                Text(name).font(.caption.bold())
                rarityBadge(rarity)
                Spacer()
                Text("\(currentHp)/\(maxHp)").font(.caption2.monospacedDigit()).foregroundStyle(.secondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(.quaternary)
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(hpColor(current: currentHp, max: maxHp))
                        .frame(width: geo.size.width * CGFloat(currentHp) / CGFloat(max(1, maxHp)), height: 6)
                        .animation(.easeInOut(duration: 0.3), value: currentHp)
                }
            }
            .frame(height: 6)
        }
        .padding(6)
        .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 8))
    }

    private func battleLog(_ log: [String]) -> some View {
        let startIndex = max(0, log.count - 8)
        return ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(Array(log.suffix(8).enumerated()), id: \.offset) { i, line in
                        Text(line)
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .id(startIndex + i)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(6)
            }
            .background(.quaternary.opacity(0.2), in: RoundedRectangle(cornerRadius: 6))
            .onChange(of: log.count) { _, _ in
                let lastId = log.count - 1
                if lastId >= 0 { proxy.scrollTo(lastId, anchor: .bottom) }
            }
        }
    }

    private func skillGrid(state: BattleState) -> some View {
        let skills = BattleSkill.skills(for: state.myProfile.mbtiGroup)
        let isSelecting = battleVM.turnPhase == .selectingSkill

        return VStack(spacing: 5) {
            if battleVM.turnPhase == .waitingForOpponent {
                HStack(spacing: 4) {
                    ProgressView().scaleEffect(0.6)
                    Text("상대방 선택 대기 중...").font(.caption).foregroundStyle(.secondary)
                }
                .frame(height: 20)
            } else {
                Text("턴 \(state.turn) — 스킬을 선택하세요").font(.caption2).foregroundStyle(.secondary)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 5) {
                ForEach(skills, id: \.id) { skill in
                    skillButton(skill: skill, isSelecting: isSelecting)
                }
            }
        }
    }

    private func skillButton(skill: BattleSkill, isSelecting: Bool) -> some View {
        let isSelected = battleVM.selectedSkillId == skill.id
        return Button(action: {
            if isSelecting { battleVM.selectSkill(skill.id) }
        }) {
            HStack(spacing: 4) {
                Text(skill.icon).font(.system(size: 14))
                VStack(alignment: .leading, spacing: 1) {
                    Text(skill.name).font(.caption.bold()).lineLimit(1)
                    Text(skill.isAttack ? "공격" : "버프").font(.system(size: 8)).foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(
                isSelected ? Color.blue.opacity(0.3) : Color.gray.opacity(0.15),
                in: RoundedRectangle(cornerRadius: 6)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(!isSelecting)
        .opacity(isSelecting ? 1.0 : 0.5)
    }

    // MARK: - Result View

    private func resultView(won: Bool) -> some View {
        VStack(spacing: 12) {
            Spacer()

            Text(won ? "🏆 승리!" : "💀 패배")
                .font(.title.bold())
                .foregroundStyle(won ? .yellow : .secondary)

            if let turns = battleVM.battleState?.turn {
                Text("\(turns - 1)턴 만에 종료").font(.caption).foregroundStyle(.secondary)
            }

            if let reward = battleVM.lastReward {
                VStack(spacing: 6) {
                    HStack {
                        Text("✨ XP +\(reward.xpGained)").font(.subheadline.bold())
                    }
                    if let item = reward.droppedEquipment {
                        HStack(spacing: 4) {
                            rarityBadge(item.rarity)
                            Text("\(item.name) 획득!").font(.caption)
                        }
                        .padding(6)
                        .background(.yellow.opacity(0.2), in: RoundedRectangle(cornerRadius: 6))
                    }
                }
                .padding()
                .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 10))
            }

            Spacer()

            Button("돌아가기") { battleVM.reset() }
                .buttonStyle(.borderedProminent)
                .padding(.bottom)
        }
        .padding()
    }

    // MARK: - Helpers

    private func statGrid(_ stats: BattleStats) -> some View {
        HStack(spacing: 0) {
            statItem(label: "ATK", value: stats.atk)
            statItem(label: "INT", value: stats.int_)
            statItem(label: "HP", value: stats.maxHp)
            statItem(label: "SPD", value: stats.spd)
            statItem(label: "DEF", value: stats.def)
        }
    }

    private func statItem(label: String, value: Int) -> some View {
        VStack(spacing: 1) {
            Text(label).font(.system(size: 8)).foregroundStyle(.secondary)
            Text("\(value)").font(.system(size: 10, design: .monospaced).bold())
        }
        .frame(maxWidth: .infinity)
    }

    private func rarityBadge(_ rarity: Rarity) -> some View {
        Text(rarity.shortLabel)
            .font(.system(size: 8).bold())
            .foregroundStyle(rarity.color)
            .padding(.horizontal, 4)
            .padding(.vertical, 1)
            .background(rarity.color.opacity(0.15), in: Capsule())
    }

    private func hpColor(current: Int, max: Int) -> Color {
        let ratio = Double(current) / Double(Swift.max(1, max))
        if ratio > 0.5 { return .green }
        if ratio > 0.25 { return .yellow }
        return .red
    }
}

// MARK: - Rarity Display

extension Rarity {
    var shortLabel: String {
        switch self {
        case .common:    return "C"
        case .rare:      return "R"
        case .legendary: return "L"
        case .mythic:    return "M"
        }
    }

    var color: Color {
        switch self {
        case .common:    return .gray
        case .rare:      return .blue
        case .legendary: return .purple
        case .mythic:    return .orange
        }
    }
}
