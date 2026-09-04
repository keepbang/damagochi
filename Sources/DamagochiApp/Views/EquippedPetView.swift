import SwiftUI
import DamagochiCore
import DamagochiRenderer

/// Head and hand equipment affect combat stats only. The effect slot is the
/// sole equipment type rendered above every pet appearance.
struct EquippedPetView: View {
    @ObservedObject var viewModel: PetViewModel
    let scale: CGFloat
    let interval: TimeInterval
    var direction: SpriteDirection = .front

    var body: some View {
        let baseFrames = viewModel.baseFrames(direction: direction)
        let effectiveScale = scale * SpriteSheet.pointScale
        let baseWidth = CGFloat(baseFrames.first?.width ?? 16) * effectiveScale
        let baseHeight = CGFloat(baseFrames.first?.height ?? 16) * effectiveScale
        let effectOverlay = viewModel.equippedOverlays.first

        ZStack {
            AnimatedPetView(frames: baseFrames, scale: scale, interval: interval)

            if let effect = effectOverlay {
                StaticEffectOverlay(overlay: effect, scale: scale)
            }
        }
        .frame(width: baseWidth, height: baseHeight)
    }
}

// MARK: - Static Overlay

private struct StaticEffectOverlay: View {
    let overlay: SpriteSheet.EquippedOverlay
    let scale: CGFloat

    var body: some View {
        PixelArtView(sprite: overlay.sprite, scale: scale)
            .allowsHitTesting(false)
    }
}
