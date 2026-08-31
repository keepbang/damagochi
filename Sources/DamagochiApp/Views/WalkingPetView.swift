import SwiftUI
import DamagochiCore
import DamagochiRenderer

struct WalkingPetView: View {
    @ObservedObject var viewModel: PetViewModel
    @State private var motions: [String: ParkPetMotion] = [:]
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Keep the floating walk window compact enough to sit beside a working
    /// desktop without obscuring the active app.
    private let parkSize = CGSize(width: 320, height: 320)
    private let motionEngine = ParkMotionEngine()

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .top) {
                Color.clear
                if let bubble = viewModel.walkSpeechBubble {
                    speechBubble(text: bubble)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .frame(height: 54)

            GeometryReader { geo in
                ZStack {
                    ParkBackground()

                    ForEach(Array(viewModel.walkablePets.enumerated()), id: \.offset) { index, pet in
                        let key = motionKey(for: pet, index: index)
                        let motion = motions[key] ?? fallbackMotion(for: index, in: geo.size)
                        WalkingPetSprite(pet: pet, direction: motion.direction == .left ? .sideLeft : .sideRight)
                            .position(CGPoint(x: motion.targetX, y: motion.targetY))
                            .accessibilityLabel(pet.name ?? pet.species ?? "산책 중인 펫")
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .onAppear { resetPositions(in: geo.size) }
                .onChange(of: viewModel.walkablePets.count) { _, _ in resetPositions(in: geo.size) }
                .onReceive(Timer.publish(every: 2.6, on: .main, in: .common).autoconnect()) { _ in
                    guard !reduceMotion else { return }
                    movePets(in: geo.size)
                }
            }
            .frame(width: parkSize.width, height: parkSize.height)
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.22), lineWidth: 1))

            HStack {
                Text("공원 산책 · \(viewModel.walkablePets.count)마리")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button(action: { viewModel.stopWalk() }) {
                    Label("산책 종료", systemImage: "xmark.circle.fill")
                        .font(.caption.bold())
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .tint(.red)
            }
            .padding(.horizontal, 10)
        }
        .padding(10)
        .animation(.spring(duration: 0.3), value: viewModel.walkSpeechBubble != nil)
    }

    private func motionKey(for pet: PetState, index: Int) -> String {
        pet.petId ?? "legacy-slot-\(index)"
    }

    private func fallbackMotion(for index: Int, in size: CGSize) -> ParkPetMotion {
        motionEngine.initialMotions(count: index + 1, width: size.width, height: size.height)[index]
    }

    private func resetPositions(in size: CGSize) {
        let starts = motionEngine.initialMotions(
            count: viewModel.walkablePets.count,
            width: size.width,
            height: size.height
        )
        motions = Dictionary(uniqueKeysWithValues: zip(viewModel.walkablePets.indices, starts).map { index, motion in
            (motionKey(for: viewModel.walkablePets[index], index: index), motion)
        })
    }

    private func movePets(in size: CGSize) {
        for index in viewModel.walkablePets.indices {
            let pet = viewModel.walkablePets[index]
            let key = motionKey(for: pet, index: index)
            let current = motions[key] ?? fallbackMotion(for: index, in: size)
            let next = motionEngine.nextMotion(from: current, width: size.width, height: size.height)
            withAnimation(.easeInOut(duration: next.speed)) {
                motions[key] = next
            }
        }
    }

    private func speechBubble(text: String) -> some View {
        HStack(alignment: .top, spacing: 4) {
            Text(text)
                .font(.caption2)
                .multilineTextAlignment(.leading)
            Button(action: { viewModel.dismissSpeechBubble() }) {
                Image(systemName: "xmark").font(.system(size: 9))
            }
            .buttonStyle(.plain)
        }
        .padding(8)
        .frame(maxWidth: 260, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
    }
}

private struct WalkingPetSprite: View {
    let pet: PetState
    let direction: SpriteDirection

    private var facesLeft: Bool { direction == .sideLeft }
    private let scale: CGFloat = 2.0

    private var equipmentOverlays: [SpriteSheet.EquippedOverlay] {
        SpriteSheet.equippedOverlays(
            equipped: pet.equippedItems,
            inventory: pet.inventory
        )
    }

    var body: some View {
        ZStack {
            AnimatedPetView(
                frames: SpriteSheet.frames(
                    species: pet.species,
                    stage: pet.stage,
                    phase: pet.phase,
                    // The main pet artwork is the consistently validated front
                    // sheet. Some directional catalog sheets have different
                    // source geometry, which can make a walking pet look torn or
                    // distorted. Mirror the stable frame for leftward movement
                    // instead of switching to that incompatible artwork.
                    direction: .front
                ),
                scale: scale,
                interval: 0.45
            )

            ForEach(equipmentOverlays.filter { $0.slot != .effect }, id: \.slot) { overlay in
                WalkingPetEquipmentOverlay(
                    overlay: overlay,
                    offset: (pet.equipmentOffsets ?? EquipmentOffsets()).offset(for: overlay.slot),
                    scale: scale
                )
            }

            // Effects should remain above the pet and its handheld/head gear,
            // matching the inventory and battle presentations.
            if let effect = equipmentOverlays.first(where: { $0.slot == .effect }) {
                WalkingPetEquipmentOverlay(
                    overlay: effect,
                    offset: (pet.equipmentOffsets ?? EquipmentOffsets()).offset(for: effect.slot),
                    scale: scale
                )
            }
        }
        .frame(width: 48, height: 48)
        .scaleEffect(x: facesLeft ? -1 : 1, y: 1, anchor: .center)
        .shadow(color: .black.opacity(0.18), radius: 3, y: 3)
    }
}

private struct WalkingPetEquipmentOverlay: View {
    let overlay: SpriteSheet.EquippedOverlay
    let offset: PixelOffset
    let scale: CGFloat

    var body: some View {
        PixelArtView(sprite: overlay.sprite, scale: scale)
            .offset(
                x: CGFloat(offset.x) * scale * SpriteSheet.gridScale,
                y: CGFloat(offset.y) * scale * SpriteSheet.gridScale
            )
            .allowsHitTesting(false)
    }
}

private struct ParkBackground: View {
    var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Color(red: 0.31, green: 0.65, blue: 0.34)))
            let path = Path(roundedRect: CGRect(x: 24, y: size.height * 0.42, width: size.width - 48, height: 106), cornerRadius: 50)
            context.fill(path, with: .color(Color(red: 0.83, green: 0.72, blue: 0.48)))
            for x in stride(from: 42.0, through: size.width - 42, by: 88) {
                context.fill(Path(ellipseIn: CGRect(x: x, y: 48 + (x.truncatingRemainder(dividingBy: 3)) * 28, width: 44, height: 28)), with: .color(.green.opacity(0.7)))
            }
            for x in stride(from: 60.0, through: size.width - 60, by: 120) {
                context.fill(Path(ellipseIn: CGRect(x: x, y: size.height - 88, width: 52, height: 34)), with: .color(.mint.opacity(0.7)))
            }
        }
        .background(Color(red: 0.56, green: 0.82, blue: 0.98))
    }
}
