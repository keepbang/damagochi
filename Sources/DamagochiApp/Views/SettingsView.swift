import SwiftUI
import DamagochiCore

struct SettingsView: View {
    @ObservedObject var viewModel: PetViewModel
    @State private var showReleaseConfirm = false
    @State private var showImportConfirm = false
    @State private var commandCopied = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("설정")
                    .font(.headline)
                Spacer()
                Text("v\(appVersion)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if viewModel.isCheckingUpdate || viewModel.isUpdating {
                    ProgressView()
                        .scaleEffect(0.6)
                        .padding(.leading, 4)
                } else if viewModel.hasUpdate, let latest = viewModel.latestVersion {
                    Text("v\(latest) 업데이트 가능")
                        .font(.caption.bold())
                        .foregroundStyle(.green)
                        .padding(.leading, 4)
                } else {
                    Button(action: { viewModel.checkForUpdate() }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 4)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider()

            ScrollView {
                VStack(spacing: 12) {
                    hookSection
                    activityStatsSection
                    notificationSection
                    petInfoSection
                    if viewModel.state.phase == .alive || viewModel.state.phase == .egg {
                        releaseSection
                    }
                    migrationSection
                    appInfoSection
                }
                .padding(12)
            }
        }
        .onAppear { viewModel.checkForUpdate() }
        .confirmationDialog(
            "펫을 방생하시겠습니까?",
            isPresented: $showReleaseConfirm,
            titleVisibility: .visible
        ) {
            Button("방생하기", role: .destructive) { viewModel.release() }
            Button("취소", role: .cancel) {}
        } message: {
            Text("현재 펫은 묘지에 기록되고 새로운 알이 생성됩니다.")
        }
        .confirmationDialog(
            "이사오기",
            isPresented: $showImportConfirm,
            titleVisibility: .visible
        ) {
            Button("이사오기", role: .destructive) { viewModel.importPet() }
            Button("취소", role: .cancel) {}
        } message: {
            Text("기존 캐릭터가 있으면 방생되고 가져온 캐릭터로 교체됩니다.")
        }
    }

    // MARK: - Hook Section

    private var hookSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("코딩 에이전트 연동", systemImage: "link.circle.fill")
                .font(.caption.bold())

            hookRow(
                name: "Claude Code",
                installed: viewModel.claudeHookInstalled,
                install: viewModel.installClaudeHooks,
                uninstall: viewModel.uninstallClaudeHooks
            )
            hookRow(
                name: "Codex",
                installed: viewModel.codexHookInstalled,
                install: viewModel.installCodexHooks,
                uninstall: viewModel.uninstallCodexHooks
            )

            Text("Codex Hook 설치 후 Codex에서 /hooks를 열어 새 Hook을 신뢰해야 실행됩니다.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 8).fill(.quaternary.opacity(0.3)))
    }

    private func hookRow(
        name: String,
        installed: Bool,
        install: @escaping () -> Void,
        uninstall: @escaping () -> Void
    ) -> some View {
        HStack {
            Circle()
                .fill(installed ? .green : .red)
                .frame(width: 8, height: 8)
            Text(name)
                .font(.caption)
            Text(installed ? "설치됨" : "미설치")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Spacer()
            Button(installed ? "제거" : "설치") {
                installed ? uninstall() : install()
            }
            .buttonStyle(.bordered)
            .controlSize(.mini)
            .tint(installed ? .red : .accentColor)
        }
    }

    // MARK: - Activity Stats

    private var activityStatsSection: some View {
        let account = viewModel.accountActivityStats

        return VStack(alignment: .leading, spacing: 8) {
            Label("활동 통계", systemImage: "chart.bar.fill")
                .font(.caption.bold())

            statsHeader
            activityStatsRow("계정 전체", stats: account)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 8).fill(.quaternary.opacity(0.3)))
    }

    private var statsHeader: some View {
        HStack {
            Text("출처")
            Spacer()
            Text("프롬프트").frame(width: 50, alignment: .trailing)
            Text("도구").frame(width: 38, alignment: .trailing)
            Text("세션").frame(width: 38, alignment: .trailing)
        }
        .font(.caption2)
        .foregroundStyle(.secondary)
    }

    private func activityStatsRow(_ source: String, stats: ActivityStats) -> some View {
        HStack {
            Text(source)
            Spacer()
            Text("\(stats.prompts)").frame(width: 50, alignment: .trailing)
            Text("\(stats.toolUses)").frame(width: 38, alignment: .trailing)
            Text("\(stats.sessions)").frame(width: 38, alignment: .trailing)
        }
        .font(.caption.monospacedDigit())
    }

    // MARK: - Notification Section

    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("알림", systemImage: "bell.fill")
                .font(.caption.bold())

            Toggle(isOn: $viewModel.notificationsEnabled) {
                Text("시스템 알림")
                    .font(.caption)
            }
            .toggleStyle(.switch)
            .controlSize(.mini)

            Text("레벨업, 부화, 장비 획득, 사망 위험 등을 알려줍니다")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 8).fill(.quaternary.opacity(0.3)))
    }

    // MARK: - Pet Info

    private var petInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("펫별 정보 · 능력치", systemImage: "person.3.fill")
                .font(.caption.bold())

            ForEach(Array(viewModel.pets.enumerated()), id: \.offset) { index, pet in
                Button(action: { viewModel.selectPet(at: index) }) {
                    petInfoCard(pet, index: index)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 8).fill(.quaternary.opacity(0.3)))
    }

    private func petInfoCard(_ pet: PetState, index: Int) -> some View {
        let profile = viewModel.battleProfile(for: pet)
        return VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 5) {
                Text("슬롯 \(index + 1)").font(.system(size: 9, weight: .bold)).foregroundStyle(.secondary)
                Text(pet.name ?? pet.species.map { speciesName($0) } ?? "알")
                    .font(.caption.bold()).lineLimit(1)
                Spacer()
                Text(pet.phase == .alive ? "Lv.\(pet.level)" : phaseText(for: pet))
                    .font(.caption2).foregroundStyle(.secondary)
            }
            HStack(spacing: 7) {
                Text("HP \(pet.hp)")
                Text("XP \(pet.totalXp)")
                Text("MBTI \(pet.personality ?? "미확정")")
            }
            .font(.system(size: 9, design: .monospaced)).foregroundStyle(.secondary)
            if let profile {
                Text("ATK \(profile.stats.atk) · INT \(profile.stats.int_) · DEF \(profile.stats.def) · SPD \(profile.stats.spd)")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundStyle(.teal)
            }
        }
        .padding(6)
        .background(index == viewModel.selectedPetIndex ? Color.accentColor.opacity(0.12) : Color.primary.opacity(0.035), in: RoundedRectangle(cornerRadius: 6))
    }

    // MARK: - Release

    private var releaseSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("방생", systemImage: "bird.fill")
                .font(.caption.bold())

            Text("현재 펫을 자연으로 돌려보내고 새로운 알을 받습니다.\n펫은 묘지에 기록됩니다.")
                .font(.caption2)
                .foregroundStyle(.secondary)

            Button(action: { showReleaseConfirm = true }) {
                Label("펫 방생하기", systemImage: "arrow.up.heart.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .tint(.teal)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 8).fill(.quaternary.opacity(0.3)))
    }

    // MARK: - Migration

    private var migrationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("이사하기 / 이사오기", systemImage: "arrow.left.arrow.right.circle.fill")
                .font(.caption.bold())

            Text("다른 PC로 캐릭터를 옮기거나 다른 계정의 캐릭터를 가져옵니다.")
                .font(.caption2)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                Button(action: { viewModel.exportPet() }) {
                    Label("이사하기", systemImage: "tray.and.arrow.up.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .tint(.blue)

                Button(action: { showImportConfirm = true }) {
                    Label("이사오기", systemImage: "tray.and.arrow.down.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .tint(.orange)
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 8).fill(.quaternary.opacity(0.3)))
    }

    // MARK: - App Info

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
    }

    private var appInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("앱 정보 · v\(appVersion)", systemImage: "app.badge.fill")
                .font(.caption.bold())

            infoRow("이름", value: "Damagochi")
            infoRow("버전", value: appVersion)
            infoRow("플랫폼", value: "macOS 14+")

            if viewModel.isUpdating {
                HStack {
                    ProgressView()
                        .scaleEffect(0.7)
                    Text("Homebrew로 업데이트 중...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            } else if let error = viewModel.updateError {
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                        .font(.caption)
                    Text(error)
                        .font(.caption2)
                        .foregroundStyle(.orange)
                        .lineLimit(3)
                    Spacer()
                }
            } else if viewModel.hasUpdate, let latest = viewModel.latestVersion {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundStyle(.green)
                            .font(.caption)
                        Text("v\(latest) 업데이트 가능 — 터미널에서 실행하세요")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                    HStack(spacing: 6) {
                        Text(brewUpdateCommand)
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(6)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(RoundedRectangle(cornerRadius: 5).fill(.black.opacity(0.08)))
                        Button(action: copyCommand) {
                            Image(systemName: commandCopied ? "checkmark" : "doc.on.doc")
                                .font(.caption)
                                .foregroundStyle(commandCopied ? .green : .secondary)
                        }
                        .buttonStyle(.plain)
                        .frame(width: 24)
                    }
                }
            }

            HStack {
                Spacer()
                Text("Claude Code / Codex 사용량 기반 가상 펫")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Spacer()
            }

            Divider()

            Button(action: { NSApplication.shared.terminate(nil) }) {
                Label("앱 종료", systemImage: "power")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .tint(.red)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 8).fill(.quaternary.opacity(0.3)))
    }

    // MARK: - Helpers

    private var brewUpdateCommand: String {
        "brew update && brew upgrade --cask damagochi && osascript -e 'quit app \"Damagochi\"' 2>/dev/null; sleep 1 && open -a Damagochi"
    }

    private func copyCommand() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(brewUpdateCommand, forType: .string)
        commandCopied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            commandCopied = false
        }
    }

    private func infoRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.caption.monospacedDigit())
        }
    }

    private var phaseText: String {
        phaseText(for: viewModel.state)
    }

    private func phaseText(for pet: PetState) -> String {
        switch pet.phase {
        case .egg:   return "알"
        case .alive: return "생존"
        case .dead:  return "사망"
        }
    }

    private var stageText: String {
        switch viewModel.state.stage {
        case .stage1: return "Stage 1 (아기)"
        case .stage2: return "Stage 2 (성장)"
        case .stage3: return "Stage 3 (완전체)"
        }
    }

    private func speciesName(_ id: String) -> String {
        Species.allSpecies.first(where: { $0.id == id })?.name ?? id
    }
}
