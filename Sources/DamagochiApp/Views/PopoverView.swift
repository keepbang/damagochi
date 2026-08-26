import SwiftUI
import DamagochiCore
import DamagochiRenderer

struct PopoverView: View {
    @ObservedObject var viewModel: PetViewModel
    @ObservedObject private var battleVM: BattleViewModel
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "onboardingCompleted")
    @State private var statsTooltip: String? = nil
    @State private var showNameEditor = false
    @State private var petNameDraft = ""

    init(viewModel: PetViewModel, battleViewModel: BattleViewModel) {
        self.viewModel = viewModel
        self.battleVM = battleViewModel
    }

    var body: some View {
        Group {
            if showOnboarding {
                OnboardingView(viewModel: viewModel, showOnboarding: $showOnboarding)
            } else {
                mainContent
            }
        }
        .alert("펫 이름 짓기", isPresented: $showNameEditor) {
            TextField("이름", text: $petNameDraft)
            Button("취소", role: .cancel) {}
            Button("저장") { viewModel.setPetName(petNameDraft) }
        } message: {
            Text("이름은 최대 12자까지 입력할 수 있습니다. 비워두면 종족 이름이 표시됩니다.")
        }
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            tabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()
            tabBar
        }
        .frame(width: 280, height: 420)
        .overlay(alignment: .top) {
            notificationBanner
        }
    }

    // MARK: - Tab Content

    @ViewBuilder
    private var tabContent: some View {
        switch viewModel.selectedTab {
        case .pet:           petView
        case .inventory:     InventoryView(viewModel: viewModel)
        case .achievements:  AchievementView(viewModel: viewModel)
        case .graveyard:     GraveyardView(viewModel: viewModel)
        case .notifications: NotificationsView(viewModel: viewModel)
        case .battle:        BattleView(battleVM: battleVM, petVM: viewModel)
        case .settings:      SettingsView(viewModel: viewModel)
        }
    }

    // MARK: - Pet View

    private var petView: some View {
        VStack(spacing: 8) {
            Spacer(minLength: 4)

            characterArea
                .padding(.horizontal)

            speechBubble
                .padding(.horizontal)

            nameLevel
                .padding(.horizontal)

            statusBars
                .padding(.horizontal)

            xpBar
                .padding(.horizontal)

            statsRow
                .padding(.horizontal)

            Spacer(minLength: 4)

            if viewModel.canWalk || viewModel.isWalking {
                walkButton
                    .padding(.horizontal)
                    .padding(.bottom, 2)
            }

            if viewModel.state.phase == .dead {
                rebirthButton
                    .padding(.horizontal)
                    .padding(.bottom, 4)
            }
        }
    }

    // MARK: - Character

    private var characterArea: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(.quaternary.opacity(0.3))

            EquippedPetView(
                viewModel: viewModel,
                scale: 8.0,
                interval: 0.5
            )
            .modifier(StateAnimationModifier(state: viewModel.state))

            bugOverlay

            if let popup = viewModel.bugXPPopup {
                Text(popup)
                    .font(.caption.bold())
                    .foregroundStyle(.yellow)
                    .padding(4)
                    .background(.black.opacity(0.6), in: RoundedRectangle(cornerRadius: 6))
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .frame(height: 148)
        .animation(.easeOut(duration: 0.3), value: viewModel.bugXPPopup)
    }

    private var bugOverlay: some View {
        GeometryReader { geo in
            ForEach(viewModel.state.activeBugs) { bug in
                let hash = abs(bug.id.hashValue)
                let x = CGFloat(hash % Int(geo.size.width - 24)) + 12
                let y = CGFloat((hash / 100) % Int(geo.size.height - 24)) + 12
                Button(action: { viewModel.catchBug(bug) }) {
                    Text(bug.type.emoji)
                        .font(.system(size: 18))
                }
                .buttonStyle(.plain)
                .position(x: x, y: y)
                .transition(.scale.combined(with: .opacity))
            }
        }
    }

    // MARK: - Speech Bubble

    private var speechBubble: some View {
        let text = viewModel.petSpeechBubble ?? viewModel.statusMessage
        let isEvent = viewModel.petSpeechBubble != nil
        return HStack(alignment: .top, spacing: 6) {
            Text("💬")
                .font(.caption)
            Text(text)
                .font(.caption)
                .foregroundStyle(isEvent ? .primary : .secondary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            if isEvent {
                Button(action: { viewModel.petSpeechBubble = nil }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 9))
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isEvent ? AnyShapeStyle(.thinMaterial) : AnyShapeStyle(Color.clear))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isEvent ? Color(nsColor: .separatorColor) : Color.clear, lineWidth: 0.5)
                )
        )
        .animation(.easeInOut(duration: 0.2), value: isEvent)
    }

    // MARK: - Name & Level

    private var nameLevel: some View {
        HStack {
            Text(viewModel.state.name ?? speciesName)
                .font(.headline)
            if viewModel.state.phase == .alive {
                Button(action: {
                    petNameDraft = viewModel.state.name ?? ""
                    showNameEditor = true
                }) {
                    Image(systemName: "pencil")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help("펫 이름 변경")
            }
            Spacer()
            if viewModel.state.phase == .alive {
                Text("Lv.\(viewModel.state.level)")
                    .font(.subheadline.bold())
                    .foregroundStyle(.blue)
            }
        }
    }

    private var speciesName: String {
        guard let id = viewModel.state.species else { return "Damagochi" }
        return Species.allSpecies.first(where: { $0.id == id })?.name ?? id
    }

    // MARK: - Status Bars

    private var statusBars: some View {
        VStack(spacing: 3) {
            statusBar(label: "HP", value: viewModel.state.hp, color: .red)
                .help("체력: 활동하면 회복됩니다. 0이 되면 사망합니다.")
            statusBar(label: "배고픔", value: viewModel.state.hunger, color: .orange)
                .help("배고픔: Claude Code 또는 Codex 사용 시 증가합니다. 낮아지면 펫이 약해집니다.")
            statusBar(label: "기분", value: viewModel.state.mood, color: .blue)
                .help("기분: 버그를 잡거나 활발하게 활동하면 올라갑니다.")
        }
    }

    private func statusBar(label: String, value: Int, color: Color) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.caption2)
                .frame(width: 36, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color.opacity(0.15))
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(value) / 100)
                }
            }
            .frame(height: 8)

            Text("\(value)")
                .font(.caption2.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 24, alignment: .trailing)
        }
    }

    // MARK: - XP Bar

    private var xpBar: some View {
        VStack(spacing: 2) {
            HStack {
                Text("XP")
                    .font(.caption2.bold())
                Spacer()
                Text("\(viewModel.displayXp) / \(viewModel.xpNeededForNextLevel)")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            .help("경험치: 프롬프트 입력, 툴 사용, 버그 잡기로 획득합니다. 100XP로 부화, 이후 레벨업합니다.")

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.purple.opacity(0.15))
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.purple)
                        .frame(width: geo.size.width * viewModel.xpProgress)
                }
            }
            .frame(height: 6)
        }
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        VStack(spacing: 4) {
            HStack {
                statItem(icon: "text.bubble", count: viewModel.state.totalPrompts)
                    .onHover { statsTooltip = $0 ? "총 프롬프트 입력 횟수" : nil }
                Spacer()
                statItem(icon: "wrench", count: viewModel.state.totalToolUses)
                    .onHover { statsTooltip = $0 ? "툴 사용 횟수 (Read, Edit, Grep 등)" : nil }
                Spacer()
                statItem(icon: "play.circle", count: viewModel.state.totalSessions)
                    .onHover { statsTooltip = $0 ? "Claude Code / Codex 세션 시작 횟수" : nil }
                Spacer()
                streakItem
                    .onHover { statsTooltip = $0 ? "연속 코딩 일수 (매일 사용 시 유지)" : nil }
            }
            .font(.caption)
            .padding(.top, 2)

            Text(statsTooltip ?? "")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .opacity(statsTooltip != nil ? 1 : 0)
                .animation(.easeInOut(duration: 0.15), value: statsTooltip)
        }
    }

    private var streakItem: some View {
        HStack(spacing: 2) {
            Text("🔥")
                .font(.caption)
            Text("\(viewModel.state.streakDays)일")
                .monospacedDigit()
                .foregroundStyle(streakColor)
        }
    }

    private var streakColor: Color {
        switch viewModel.state.streakDays {
        case 0...2:   return .secondary
        case 3...6:   return .orange
        case 7...13:  return .red
        case 14...29: return .purple
        default:      return .yellow
        }
    }

    private func statItem(icon: String, count: Int) -> some View {
        HStack(spacing: 2) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
            Text("\(count)")
                .monospacedDigit()
        }
    }

    // MARK: - Walk

    private var walkButton: some View {
        Button(action: {
            if viewModel.isWalking { viewModel.stopWalk() } else { viewModel.startWalk() }
        }) {
            Label(
                viewModel.isWalking ? "산책 종료" : "산책 시키기",
                systemImage: viewModel.isWalking ? "xmark.circle.fill" : "figure.walk"
            )
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
        .tint(viewModel.isWalking ? .red : .teal)
        .help(viewModel.isWalking ? "산책을 종료합니다" : "펫을 화면에 꺼내 산책시킵니다 (Stage 2 이상)")
    }

    // MARK: - Rebirth

    private var rebirthButton: some View {
        Button(action: { viewModel.rebirth() }) {
            Label("다시 시작", systemImage: "arrow.counterclockwise.circle.fill")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.small)
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button(action: { viewModel.selectedTab = tab }) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 14))
                            .frame(maxWidth: .infinity, minHeight: 32)
                            .foregroundStyle(viewModel.selectedTab == tab ? .blue : .secondary)

                        if tab == .notifications && viewModel.unreadWalkNotificationCount > 0 {
                            Circle()
                                .fill(.red)
                                .frame(width: 7, height: 7)
                                .offset(x: -6, y: 6)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
    }

    // MARK: - Notification Banner

    @ViewBuilder
    private var notificationBanner: some View {
        if let notification = viewModel.notification {
            HStack(spacing: 6) {
                Image(systemName: notification.icon)
                Text(notification.message)
                    .font(.caption.bold())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.thinMaterial, in: Capsule())
            .padding(.top, 8)
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.spring(duration: 0.3), value: viewModel.notification?.id)
        }
    }
}

// MARK: - State Animation Modifier

struct StateAnimationModifier: ViewModifier {
    let state: PetState

    @State private var bounceOffset: CGFloat = 0
    @State private var wobbleAngle: Angle = .zero

    func body(content: Content) -> some View {
        content
            .offset(y: state.phase == .alive && state.mood > 80 ? bounceOffset : 0)
            .rotationEffect(state.hunger < 20 ? wobbleAngle : .zero)
            .saturation(state.phase == .dead ? 0 : 1)
            .onAppear {
                if state.phase == .alive && state.mood > 80 {
                    withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                        bounceOffset = -4
                    }
                }
                if state.hunger < 20 {
                    withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) {
                        wobbleAngle = .degrees(3)
                    }
                }
            }
    }
}
