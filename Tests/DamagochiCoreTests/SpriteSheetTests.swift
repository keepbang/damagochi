import Testing
import DamagochiCore
@testable import DamagochiRenderer

@Test func everyCatalogSpeciesHasTwo24PixelFramesForEachDirection() {
    for species in Species.allSpecies {
        for direction in SpriteDirection.allCases {
            let frames = SpriteSheet.frames(species: species.id, stage: .stage2, phase: .alive, direction: direction)
            #expect(frames.count >= 2, "\(species.id) \(direction)")
            #expect(frames.allSatisfy { $0.width == 24 && $0.height == 24 }, "\(species.id) \(direction)")
            #expect(frames.allSatisfy { $0.visibleBounds != nil }, "\(species.id) \(direction)")
        }
    }
}

@Test func sideDirectionalFramesAndEquipmentUseThe24PixelGrid() throws {
    let right = try #require(SpriteSheet.frames(species: "cat", stage: .stage2, phase: .alive, direction: .sideRight).first)
    let left = try #require(SpriteSheet.frames(species: "cat", stage: .stage2, phase: .alive, direction: .sideLeft).first)
    let item = try #require(EquipmentDropper.itemPool.first(where: { $0.slot == .head }))
    let overlays = SpriteSheet.equippedOverlays(
        equipped: EquippedItems(head: item.id),
        inventory: [item]
    )

    #expect(left.width == right.width)
    #expect(left.height == right.height)
    #expect(overlays.first?.sprite.width == 24)
    #expect(overlays.first?.sprite.height == 24)
}

@Test func expandedSpeciesHaveIndependentFrontBackAndSideArtwork() throws {
    let front = try #require(SpriteSheet.frames(species: "raven", stage: .stage3, phase: .alive, direction: .front).first)
    let back = try #require(SpriteSheet.frames(species: "raven", stage: .stage3, phase: .alive, direction: .back).first)
    let left = try #require(SpriteSheet.frames(species: "raven", stage: .stage3, phase: .alive, direction: .sideLeft).first)
    let right = try #require(SpriteSheet.frames(species: "raven", stage: .stage3, phase: .alive, direction: .sideRight).first)

    #expect(front.pixels != back.pixels)
    #expect(left.pixels != right.pixels)
    #expect(left.pixels != right.mirrored().pixels)
}
