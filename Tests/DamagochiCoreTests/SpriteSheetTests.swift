import Testing
import DamagochiCore
@testable import DamagochiRenderer

private func alphaMask(_ sprite: PixelSprite) -> String {
    sprite.pixels
        .flatMap { $0 }
        .map { $0.isTransparent ? "0" : "1" }
        .joined()
}

private func pixelFingerprint(_ sprite: PixelSprite) -> String {
    sprite.pixels
        .flatMap { $0 }
        .map { String($0.rawValue, radix: 16) }
        .joined(separator: ",")
}

@Test func everyCatalogSpeciesHasTwo48PixelFramesForEachDirection() {
    for species in Species.allSpecies {
        for direction in SpriteDirection.allCases {
            let frames = SpriteSheet.frames(species: species.id, stage: .stage2, phase: .alive, direction: direction)
            #expect(frames.count >= 2, "\(species.id) \(direction)")
            #expect(frames.allSatisfy { $0.width == 48 && $0.height == 48 }, "\(species.id) \(direction)")
            #expect(frames.allSatisfy { $0.visibleBounds != nil }, "\(species.id) \(direction)")
        }
    }
}

@Test func sideDirectionalFramesAndEquipmentUseThe48PixelGrid() throws {
    let right = try #require(SpriteSheet.frames(species: "cat", stage: .stage2, phase: .alive, direction: .sideRight).first)
    let left = try #require(SpriteSheet.frames(species: "cat", stage: .stage2, phase: .alive, direction: .sideLeft).first)
    let item = try #require(EquipmentDropper.itemPool.first(where: { $0.slot == .head }))
    let overlays = SpriteSheet.equippedOverlays(
        equipped: EquippedItems(head: item.id),
        inventory: [item]
    )

    #expect(left.width == right.width)
    #expect(left.height == right.height)
    #expect(overlays.first?.sprite.width == 48)
    #expect(overlays.first?.sprite.height == 48)
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

@Test func allCatalogSpeciesHaveDistinctStageThreeAlphaSilhouettes() {
    let idsByMask = Dictionary(grouping: Species.allSpecies, by: { species in
        alphaMask(
            SpriteSheet.frames(species: species.id, stage: .stage3, phase: .alive, direction: .front)
                .first!
        )
    }).values.map { $0.map(\.id) }.filter { $0.count > 1 }
    let duplicateNames = idsByMask
        .map { $0.joined(separator: ", ") }
        .joined(separator: " | ")
    #expect(
        idsByMask.isEmpty,
        "정면 외곽선이 겹치는 펫: \(duplicateNames)"
    )
}

@Test func legacySpeciesAlsoUseIndependentDirectionalArtwork() throws {
    let front = try #require(SpriteSheet.frames(species: "cat", stage: .stage3, phase: .alive, direction: .front).first)
    let back = try #require(SpriteSheet.frames(species: "cat", stage: .stage3, phase: .alive, direction: .back).first)
    let left = try #require(SpriteSheet.frames(species: "cat", stage: .stage3, phase: .alive, direction: .sideLeft).first)
    let right = try #require(SpriteSheet.frames(species: "cat", stage: .stage3, phase: .alive, direction: .sideRight).first)

    #expect(front.pixels != back.pixels)
    #expect(left.pixels != right.pixels)
    #expect(left.pixels != right.mirrored().pixels)
}

@Test func mermaidAndSkateKeepSignatureSilhouettesAcrossAllFourDirections() throws {
    func frame(_ species: String, _ direction: SpriteDirection) throws -> PixelSprite {
        try #require(
            SpriteSheet.frames(species: species, stage: .stage3, phase: .alive, direction: direction).first,
            "\(species) \(direction)"
        )
    }

    func contains(_ sprite: PixelSprite, _ color: PixelColor) -> Bool {
        sprite.pixels.contains { row in row.contains(color) }
    }

    for species in ["mermaid", "skate"] {
        let front = try frame(species, .front)
        let back = try frame(species, .back)
        let left = try frame(species, .sideLeft)
        let right = try frame(species, .sideRight)

        #expect(front.pixels != back.pixels, "\(species)의 앞·뒤 원화가 달라야 합니다.")
        #expect(front.pixels != left.pixels && front.pixels != right.pixels, "\(species)의 정면과 프로필 원화가 달라야 합니다.")
        #expect(back.pixels != left.pixels && back.pixels != right.pixels, "\(species)의 후면과 프로필 원화가 달라야 합니다.")
        #expect(left.pixels != right.pixels, "\(species)의 좌·우 원화가 달라야 합니다.")
        #expect(left.pixels != right.mirrored().pixels, "\(species)의 좌·우 프로필은 단순 반전이 아니어야 합니다.")
    }

    let mermaid = try frame("mermaid", .front)
    let mermaidBounds = try #require(mermaid.visibleBounds)
    #expect(mermaidBounds.height > mermaidBounds.width, "인어는 세로로 이어지는 사람+꼬리 실루엣을 유지해야 합니다.")
    #expect(contains(mermaid, .pink) && contains(mermaid, .peach) && contains(mermaid, .teal) && contains(mermaid, .mint))

    let skate = try frame("skate", .front)
    let skateBounds = try #require(skate.visibleBounds)
        #expect(skateBounds.width > skateBounds.height, "가오리는 넓고 둥근 날개 실루엣을 유지해야 합니다.")
    #expect(contains(skate, .teal) && contains(skate, .blue) && contains(skate, .darkBlue))
}

@Test func everyCatalogPetHasFourIndependentDirectionalFirstFrames() throws {
    for species in Species.allSpecies {
        func frame(_ direction: SpriteDirection) throws -> PixelSprite {
            try #require(
                SpriteSheet.frames(species: species.id, stage: .stage3, phase: .alive, direction: direction).first,
                "\(species.id) \(direction)"
            )
        }

        let front = try frame(.front)
        let back = try frame(.back)
        let left = try frame(.sideLeft)
        let right = try frame(.sideRight)

        let frames = [front, back, left, right].map(pixelFingerprint)
        #expect(
            Set(frames).count == 4,
            "\(species.id)의 정면·후면·좌·우는 실제 부속물·표정·색면을 포함한 독립 원화여야 합니다."
        )
    }
}

@Test func namedPetsKeepCategoryAppropriateBodyProportions() throws {
    for id in ["owl", "cactus", "world_tree", "mermaid", "lightning"] {
        let sprite = try #require(SpriteSheet.frames(species: id, stage: .stage3, phase: .alive, direction: .front).first)
        let silhouette = try #require(sprite.visibleBounds)
        #expect(silhouette.height > silhouette.width, "\(id)는 세로형 이름/체형을 유지해야 합니다.")
    }

    for id in ["wolf", "ferret", "teapot", "bastion", "dream_whale", "skate"] {
        let sprite = try #require(SpriteSheet.frames(species: id, stage: .stage3, phase: .alive, direction: .front).first)
        let silhouette = try #require(sprite.visibleBounds)
        #expect(silhouette.width > silhouette.height, "\(id)는 가로형 이름/체형을 유지해야 합니다.")
    }
}

@Test func representativePetsUseLayeredCharacterPalettes() throws {
    // A friendly pixel character needs more than a flat silhouette: material
    // colour, softer outline, light/shadow or a face cue must remain visible.
    for id in ["wolf", "owl", "octopus", "atlas_beetle", "android", "teapot", "world_tree", "dragon", "mermaid", "skate", "ninja", "lightning"] {
        let sprite = try #require(
            SpriteSheet.frames(species: id, stage: .stage3, phase: .alive, direction: .front).first,
            "\(id)"
        )
        let colors = Set(
            sprite.pixels
                .flatMap { $0 }
                .filter { !$0.isTransparent }
                .map { $0.rawValue }
        )
        #expect(colors.count >= 4, "\(id)는 평면 아이콘이 아닌 다층 캐릭터 팔레트를 유지해야 합니다.")
    }
}

@Test func remainingSpeciesKeepActualStructureGroupsAtNativeResolution() throws {
    func front(_ id: String) throws -> PixelSprite {
        try #require(
            SpriteSheet.frames(species: id, stage: .stage3, phase: .alive, direction: .front).first,
            "\(id)의 정면 프레임"
        )
    }

    func contains(_ sprite: PixelSprite, _ colors: [PixelColor]) -> Bool {
        let present = Set(sprite.pixels.flatMap { $0 }.map(\.rawValue))
        return colors.allSatisfy { present.contains($0.rawValue) }
    }

    // 실제 신체 구조가 우선인 종군: 길이·날개폭 같은 공통 비율과
    // 각 종의 골격을 읽게 하는 최소 색상 랜드마크를 함께 고정한다.
    for id in ["phoenix", "penguin", "crystal", "cactus", "lantern", "flame"] {
        let bounds = try #require(try front(id).visibleBounds)
        #expect(bounds.height > bounds.width, "\(id)는 세로 랜드마크를 유지해야 합니다.")
    }

    for id in ["butterfly", "luna_moth", "scorpion", "fish", "seal", "otter", "ferret", "badger", "beaver", "capybara", "cloud", "nebula", "aurora"] {
        let bounds = try #require(try front(id).visibleBounds)
        #expect(bounds.width > bounds.height, "\(id)는 가로로 이어진 실제 몸/날개 구조를 유지해야 합니다.")
    }

    let landmarks: [(String, [PixelColor])] = [
        ("phoenix", [.red, .orange]),
        ("penguin", [.darkGray, .white, .orange]),
        ("butterfly", [.purple, .darkBlue]),
        ("luna_moth", [.mint, .lavender]),
        ("scorpion", [.orange, .darkRed]),
        ("turtle", [.green, .darkGreen]),
        ("chameleon", [.green, .lime]),
        ("fish", [.blue, .teal]),
        ("seal", [.lightGray, .cream]),
        ("clockwork", [.tan, .gold]),
        ("lantern", [.brown, .orange]),
        ("cactus", [.green, .lime]),
        ("moonflower", [.lavender, .gold]),
        ("ninja", [.darkGray, .purple, .teal]),
        ("void_runner", [.darkGray, .teal]),
    ]
    for (id, colors) in landmarks {
        #expect(contains(try front(id), colors), "\(id)는 실제 구조를 구분하는 색상 랜드마크를 유지해야 합니다.")
    }
}

@Test func featuredAnimalRedesignsKeepTheirNameDefiningFeaturesAtNativeResolution() throws {
    func frame(_ id: String) throws -> PixelSprite {
        try #require(
            SpriteSheet.frames(species: id, stage: .stage3, phase: .alive, direction: .front).first,
            "\(id)의 정면 프레임"
        )
    }

    func contains(_ sprite: PixelSprite, _ colors: [PixelColor]) -> Bool {
        let present = Set(sprite.pixels.flatMap { $0 }.map(\.rawValue))
        return colors.allSatisfy { present.contains($0.rawValue) }
    }

    func hasNoBlankRowBetweenTopAndBottom(_ sprite: PixelSprite) -> Bool {
        let occupied = sprite.pixels.map { row in row.contains(where: { !$0.isTransparent }) }
        guard let top = occupied.firstIndex(of: true), let bottom = occupied.lastIndex(of: true) else { return false }
        return occupied[top...bottom].allSatisfy { $0 }
    }

    let rabbit = try frame("rabbit")
    let rabbitBounds = try #require(rabbit.visibleBounds)
    #expect(rabbit.width == 48 && rabbit.height == 48)
    #expect(rabbitBounds.height > rabbitBounds.width, "토끼는 붙어 있는 긴 귀와 세로형 몸을 유지해야 합니다.")
    #expect(hasNoBlankRowBetweenTopAndBottom(rabbit), "토끼 귀와 머리·몸 사이에 빈 줄이 생기면 안 됩니다.")
    #expect(contains(rabbit, [.white, .blush, .mistBlue, .warmGray, .cream, PixelColor(0xFF4D260C)]))

    let bear = try frame("bear")
    #expect(contains(bear, [.brown, .tan, .blush, .cocoa, PixelColor(0xFF4D260C)]))

    let raccoon = try frame("raccoon")
    let raccoonBounds = try #require(raccoon.visibleBounds)
    #expect(raccoonBounds.width > raccoonBounds.height, "너구리는 줄무늬 꼬리가 보이는 가로형 실루엣을 유지해야 합니다.")
    #expect(contains(raccoon, [.gray, .darkGray, .black, .cream, .lightGray]))
}

@Test func mermaidAndSkateKeepTailAndFinsInsideSmallStageCanvases() {
    for species in ["mermaid", "skate"] {
        for stage in [Stage.stage1, .stage2] {
            for direction in SpriteDirection.allCases {
                let frames = SpriteSheet.frames(species: species, stage: stage, phase: .alive, direction: direction)
                for frame in frames {
                    #expect(
                        !frame.pixels[frame.height - 1].contains(where: { !$0.isTransparent }),
                        "\(species) \(stage) \(direction)의 꼬리/지느러미가 캔버스 하단에서 잘리면 안 됩니다."
                    )
                }
            }
        }
    }
}
