import DamagochiCore

/// 24×24 directional artwork for the forty expanded catalog species. The
/// profiles are deterministic and retain a species-specific palette, silhouette
/// and asymmetric ornament across front, back, and both side views.
enum ExpandedSpeciesSprites {
    private enum Trait: CaseIterable {
        case beast, winged, aquatic, botanical, horned, mechanical, orb
    }

    static let speciesIDs: Set<String> = [
        // Legacy front sprites keep their original artwork, while these
        // profiles supply independent back and side artwork for every one.
        "owl", "wolf", "crystal", "octopus", "android", "phoenix", "dragon", "sphinx", "robot", "nebula",
        "butterfly", "cloud", "lotus", "jellyfish", "fox", "unicorn", "mushroom", "fairy", "celestial", "aurora",
        "turtle", "penguin", "bear", "rock", "cactus", "hedgehog", "parrot", "golem", "elephant", "kraken",
        "cat", "puppy", "rabbit", "flame", "bat", "scorpion", "fish", "lightning", "moonrabbit", "comet",
        "raven", "otter", "chameleon", "atlas_beetle", "clockwork", "orb", "gryphon", "leviathan", "singularity", "chrono_dragon",
        "deer", "seal", "peach", "luna_moth", "capybara", "mermaid", "pegasus", "moonflower", "seraph", "dream_whale",
        "beaver", "koala", "acorn", "badger", "teapot", "lantern", "mammoth", "bastion", "world_tree", "titan",
        "raccoon", "ferret", "gecko", "skate", "parakeet", "ninja", "wyvern", "thunderbird", "starfox", "void_runner",
    ]

    /// The original forty species have hand-authored front frames in
    /// SpriteSheet. New catalog species use this full 4-direction sheet.
    static let generatedFrontSpeciesIDs: Set<String> = speciesIDs.subtracting(Set([
        "owl", "wolf", "crystal", "octopus", "android", "phoenix", "dragon", "sphinx", "robot", "nebula",
        "butterfly", "cloud", "lotus", "jellyfish", "fox", "unicorn", "mushroom", "fairy", "celestial", "aurora",
        "turtle", "penguin", "bear", "rock", "cactus", "hedgehog", "parrot", "golem", "elephant", "kraken",
        "cat", "puppy", "rabbit", "flame", "bat", "scorpion", "fish", "lightning", "moonrabbit", "comet",
    ]))

    static func frames(species: String, stage: Stage, direction: SpriteDirection) -> [PixelSprite]? {
        guard speciesIDs.contains(species) else { return nil }
        return [makeFrame(species: species, stage: stage, direction: direction, step: 0),
                makeFrame(species: species, stage: stage, direction: direction, step: 1)]
    }

    private static func makeFrame(species: String, stage: Stage, direction: SpriteDirection, step: Int) -> PixelSprite {
        let seed = stableSeed(species)
        let palette: [PixelColor] = [.blue, .teal, .green, .purple, .pink, .orange, .brown, .lavender, .mint, .ginger, .coral, .lime]
        let primary = palette[seed % palette.count]
        let accent = palette[(seed / 7 + 3) % palette.count]
        let trait = Trait.allCases[(seed / 13) % Trait.allCases.count]
        var grid = Array(repeating: Array(repeating: PixelColor.clear, count: 24), count: 24)

        let dimensions: (bodyW: Int, bodyH: Int, headW: Int, headH: Int, top: Int)
        switch stage {
        case .stage1: dimensions = (10, 10, 6, 5, 9)
        case .stage2: dimensions = (13, 13, 7, 5, 7)
        case .stage3: dimensions = (16, 15, 8, 6, 5)
        }
        let d = dimensions
        let bounce = step == 0 ? 0 : -1
        let bodyX = (24 - d.bodyW) / 2
        let bodyY = d.top + d.headH + bounce
        let headY = d.top + bounce

        drawFilledRect(&grid, x: bodyX, y: bodyY, width: d.bodyW, height: d.bodyH, color: primary)
        drawOutline(&grid, x: bodyX, y: bodyY, width: d.bodyW, height: d.bodyH)

        switch direction {
        case .front:
            drawFilledRect(&grid, x: (24 - d.headW) / 2, y: headY, width: d.headW, height: d.headH, color: accent)
            drawOutline(&grid, x: (24 - d.headW) / 2, y: headY, width: d.headW, height: d.headH)
            set(&grid, x: 10, y: headY + 2, color: .black)
            set(&grid, x: 13, y: headY + 2, color: .black)
        case .back:
            drawFilledRect(&grid, x: (24 - d.headW) / 2, y: headY, width: d.headW, height: d.headH, color: accent)
            drawOutline(&grid, x: (24 - d.headW) / 2, y: headY, width: d.headW, height: d.headH)
            // An asymmetric crest is deliberately placed on the back, not a
            // mirrored front-eye treatment.
            drawFilledRect(&grid, x: bodyX + d.bodyW - 3, y: bodyY + 2, width: 2, height: max(2, d.bodyH / 2), color: accent)
        case .sideLeft, .sideRight:
            let facingLeft = direction == .sideLeft
            let headX = facingLeft ? bodyX - 1 : bodyX + d.bodyW - d.headW + 1
            drawFilledRect(&grid, x: headX, y: headY + 1, width: d.headW, height: d.headH, color: accent)
            drawOutline(&grid, x: headX, y: headY + 1, width: d.headW, height: d.headH)
            let eyeX = facingLeft ? headX + 1 : headX + d.headW - 2
            set(&grid, x: eyeX, y: headY + 3, color: .black)
            let tailX = facingLeft ? bodyX + d.bodyW : bodyX - 2
            drawFilledRect(&grid, x: tailX, y: bodyY + d.bodyH - 4, width: 2, height: 2, color: accent)
        }

        drawTrait(&grid, trait: trait, direction: direction, bodyX: bodyX, bodyY: bodyY, bodyW: d.bodyW, bodyH: d.bodyH, accent: accent, step: step)
        drawLimbs(&grid, direction: direction, bodyX: bodyX, bodyY: bodyY, bodyW: d.bodyW, bodyH: d.bodyH, step: step)
        return PixelSprite(width: 24, height: 24, pixels: grid)
    }

    private static func drawTrait(_ grid: inout [[PixelColor]], trait: Trait, direction: SpriteDirection, bodyX: Int, bodyY: Int, bodyW: Int, bodyH: Int, accent: PixelColor, step: Int) {
        switch trait {
        case .beast:
            set(&grid, x: bodyX + 1, y: bodyY - 2, color: accent)
            set(&grid, x: bodyX + bodyW - 2, y: bodyY - 2, color: accent)
        case .winged:
            drawFilledRect(&grid, x: bodyX - 2, y: bodyY + 3, width: 2, height: max(3, bodyH / 2), color: accent)
            drawFilledRect(&grid, x: bodyX + bodyW, y: bodyY + 2 + step, width: 2, height: max(3, bodyH / 2), color: accent)
        case .aquatic:
            drawFilledRect(&grid, x: bodyX + bodyW / 2 - 1, y: bodyY - 2, width: 3, height: 2, color: accent)
            drawFilledRect(&grid, x: bodyX + bodyW - 1, y: bodyY + bodyH / 2, width: 2, height: 3, color: accent)
        case .botanical:
            drawFilledRect(&grid, x: bodyX + bodyW / 2, y: bodyY - 3, width: 1, height: 3, color: accent)
            set(&grid, x: bodyX + bodyW / 2 - 1, y: bodyY - 2, color: accent)
            set(&grid, x: bodyX + bodyW / 2 + 1, y: bodyY - 1, color: accent)
        case .horned:
            set(&grid, x: bodyX + 2, y: bodyY - 3, color: accent)
            set(&grid, x: bodyX + bodyW - 3, y: bodyY - 3, color: accent)
        case .mechanical:
            drawFilledRect(&grid, x: bodyX + bodyW / 2 - 1, y: bodyY + bodyH / 2, width: 3, height: 2, color: accent)
        case .orb:
            set(&grid, x: bodyX + bodyW / 2, y: bodyY + bodyH / 2, color: .white)
            set(&grid, x: bodyX + bodyW / 2 + 1, y: bodyY + bodyH / 2, color: accent)
        }
    }

    private static func drawLimbs(_ grid: inout [[PixelColor]], direction: SpriteDirection, bodyX: Int, bodyY: Int, bodyW: Int, bodyH: Int, step: Int) {
        let left = bodyX + 2
        let right = bodyX + bodyW - 3
        let footY = bodyY + bodyH
        let shift = step == 0 ? 0 : 1
        switch direction {
        case .front, .back:
            set(&grid, x: left, y: footY, color: .black)
            set(&grid, x: right, y: footY + shift, color: .black)
        case .sideLeft:
            set(&grid, x: bodyX + 2, y: footY + shift, color: .black)
            set(&grid, x: bodyX + bodyW - 3, y: footY, color: .black)
        case .sideRight:
            set(&grid, x: bodyX + 2, y: footY, color: .black)
            set(&grid, x: bodyX + bodyW - 3, y: footY + shift, color: .black)
        }
    }

    private static func drawFilledRect(_ grid: inout [[PixelColor]], x: Int, y: Int, width: Int, height: Int, color: PixelColor) {
        for row in y..<(y + height) {
            for column in x..<(x + width) { set(&grid, x: column, y: row, color: color) }
        }
    }

    private static func drawOutline(_ grid: inout [[PixelColor]], x: Int, y: Int, width: Int, height: Int) {
        for column in x..<(x + width) {
            set(&grid, x: column, y: y, color: .black)
            set(&grid, x: column, y: y + height - 1, color: .black)
        }
        for row in y..<(y + height) {
            set(&grid, x: x, y: row, color: .black)
            set(&grid, x: x + width - 1, y: row, color: .black)
        }
    }

    private static func set(_ grid: inout [[PixelColor]], x: Int, y: Int, color: PixelColor) {
        guard grid.indices.contains(y), grid[y].indices.contains(x) else { return }
        grid[y][x] = color
    }

    private static func stableSeed(_ value: String) -> Int {
        let seed = value.utf8.reduce(UInt(17)) { ($0 &* 31) &+ UInt($1) }
        return Int(seed & 0x7FFF_FFFF)
    }
}
