import SwiftUI
import DamagochiCore
import DamagochiRenderer

/// Renders the pet with each equipped item overlaid.
/// Pass `highlightedSlot` to draw a dashed selection border around that slot's item.
struct EquippedPetView: View {
    @ObservedObject var viewModel: PetViewModel
    let scale: CGFloat
    let interval: TimeInterval
    var direction: SpriteDirection = .front
    var highlightedSlot: EquipmentSlot? = nil

    var body: some View {
        let baseFrames = viewModel.baseFrames(direction: direction)
        let effectiveScale = scale * SpriteSheet.pointScale
        let baseWidth = CGFloat(baseFrames.first?.width ?? 16) * effectiveScale
        let baseHeight = CGFloat(baseFrames.first?.height ?? 16) * effectiveScale
        let overlays = viewModel.equippedOverlays

        let effectOverlay = overlays.first(where: { $0.slot == .effect })
        let otherOverlays = overlays.filter { $0.slot != .effect }

        ZStack {
            AnimatedPetView(frames: baseFrames, scale: scale, interval: interval)

            ForEach(otherOverlays, id: \.slot) { overlay in
                StaticEquipmentOverlay(
                    viewModel: viewModel,
                    overlay: overlay,
                    scale: scale,
                    isHighlighted: highlightedSlot == overlay.slot
                )
            }

            // Effect renders on top visually
            if let effect = effectOverlay {
                StaticEquipmentOverlay(
                    viewModel: viewModel,
                    overlay: effect,
                    scale: scale,
                    isHighlighted: highlightedSlot == effect.slot
                )
            }
        }
        .frame(width: baseWidth, height: baseHeight)
    }
}

// MARK: - Static Overlay

private struct StaticEquipmentOverlay: View {
    @ObservedObject var viewModel: PetViewModel
    let overlay: SpriteSheet.EquippedOverlay
    let scale: CGFloat
    var isHighlighted: Bool = false

    var body: some View {
        let off = viewModel.equipmentOffset(for: overlay.slot)
        let sprite = overlay.sprite
        let bounds = sprite.visibleBounds
            ?? CGRect(x: 0, y: 0, width: sprite.width, height: sprite.height)
        let scaledBounds = CGRect(
            x: bounds.minX * scale,
            y: bounds.minY * scale,
            width: bounds.width * scale,
            height: bounds.height * scale
        )

        PixelArtView(sprite: sprite, scale: scale)
            .overlay(
                OverlayHitShape(rect: scaledBounds)
                    .stroke(
                        Color.accentColor.opacity(isHighlighted ? 0.9 : 0),
                        style: StrokeStyle(lineWidth: 1.5, dash: [4, 2])
                    )
                    .allowsHitTesting(false)
            )
            .offset(
                x: CGFloat(off.x) * scale * SpriteSheet.gridScale,
                y: CGFloat(off.y) * scale * SpriteSheet.gridScale
            )
            .allowsHitTesting(false)
    }
}

// MARK: - Shape

private struct OverlayHitShape: Shape {
    let rect: CGRect
    func path(in _: CGRect) -> Path { Path(rect) }
}
