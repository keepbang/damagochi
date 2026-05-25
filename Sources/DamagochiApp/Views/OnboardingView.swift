import SwiftUI

struct OnboardingView: View {
    @ObservedObject var viewModel: PetViewModel
    @Binding var showOnboarding: Bool

    var body: some View {
        VStack(spacing: 12) {
            Spacer(minLength: 8)

            Image(systemName: "egg.fill")
                .font(.system(size: 40))
                .foregroundStyle(.orange)

            Text("Damagochi에 오신 걸 환영합니다!")
                .font(.headline)
                .multilineTextAlignment(.center)

            Text("Claude Code 또는 Codex를 사용하면\n경험치가 쌓이고 가상 펫이 성장합니다.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)

            Divider()
                .padding(.horizontal, 20)

            VStack(alignment: .leading, spacing: 8) {
                stepRow(number: 1, text: "Claude Code와 Codex Hook을 설치합니다")
                stepRow(number: 2, text: "코딩 에이전트를 사용하면 XP가 쌓입니다")
                stepRow(number: 3, text: "100 XP에 알이 부화합니다")
                stepRow(number: 4, text: "펫을 키우고 장비를 모으세요!")
            }
            .padding(.horizontal, 16)

            Spacer(minLength: 8)

            VStack(spacing: 8) {
                if !viewModel.anyHookInstalled {
                    Button(action: {
                        viewModel.installAllHooks()
                    }) {
                        Label("두 Hook 설치하기", systemImage: "link.badge.plus")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                } else {
                    Label("Hook 설치 완료!", systemImage: "checkmark.circle.fill")
                        .font(.caption.bold())
                        .foregroundStyle(.green)
                }

                Button(action: {
                    UserDefaults.standard.set(true, forKey: "onboardingCompleted")
                    showOnboarding = false
                }) {
                    Text(viewModel.anyHookInstalled ? "시작하기" : "나중에 설치하기")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .frame(width: 280, height: 420)
    }

    private func stepRow(number: Int, text: String) -> some View {
        HStack(spacing: 8) {
            Text("\(number)")
                .font(.caption2.bold())
                .frame(width: 18, height: 18)
                .background(Circle().fill(.blue))
                .foregroundStyle(.white)
            Text(text)
                .font(.caption)
        }
    }
}
