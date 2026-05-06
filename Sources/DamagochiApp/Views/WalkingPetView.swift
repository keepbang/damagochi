import SwiftUI
import DamagochiCore
import DamagochiRenderer

struct WalkingPetView: View {
    @ObservedObject var viewModel: PetViewModel

    var body: some View {
        VStack(spacing: 6) {
            // Fixed-height reservation for speech bubble — prevents window resize
            ZStack(alignment: .top) {
                Color.clear
                if let bubble = viewModel.walkSpeechBubble {
                    speechBubble(text: bubble)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .frame(height: 56)

            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(.ultraThinMaterial)
                    .shadow(radius: 6)

                VStack(spacing: 8) {
                    EquippedPetView(
                        viewModel: viewModel,
                        scale: 6.0,
                        interval: 0.5
                    )
                    .frame(width: 96, height: 96)

                    Button(action: { viewModel.stopWalk() }) {
                        Label("산책 종료", systemImage: "xmark.circle.fill")
                            .font(.caption.bold())
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .tint(.red)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 8)
                }
                .padding(.top, 20)
            }
            .frame(width: 130)
        }
        .animation(.spring(duration: 0.3), value: viewModel.walkSpeechBubble != nil)
        .padding(6)
    }

    private func speechBubble(text: String) -> some View {
        HStack(alignment: .top, spacing: 4) {
            Text(text)
                .font(.caption2)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            Button(action: { viewModel.dismissSpeechBubble() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(8)
        .frame(maxWidth: 160, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.separator, lineWidth: 0.5)
        )
        .shadow(radius: 3)
    }
}
