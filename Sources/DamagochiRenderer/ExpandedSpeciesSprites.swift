import DamagochiCore

/// Hand-authored directional pixel silhouettes for the catalog. Species-defining
/// silhouettes take priority over facial details so unlike species do not read
/// as the same animal with a different palette.
enum ExpandedSpeciesSprites {
    static let speciesIDs: Set<String> = [
        "owl", "wolf", "crystal", "octopus", "android", "phoenix", "dragon", "sphinx", "robot", "nebula", "butterfly", "cloud", "lotus", "jellyfish", "fox", "unicorn", "mushroom", "fairy", "celestial", "aurora", "turtle", "penguin", "bear", "rock", "cactus", "hedgehog", "parrot", "golem", "elephant", "kraken", "cat", "puppy", "rabbit", "flame", "bat", "scorpion", "fish", "lightning", "moonrabbit", "comet",
        "raven", "otter", "chameleon", "atlas_beetle", "clockwork", "orb", "gryphon", "leviathan", "singularity", "chrono_dragon", "deer", "seal", "peach", "luna_moth", "capybara", "mermaid", "pegasus", "moonflower", "seraph", "dream_whale", "beaver", "koala", "acorn", "badger", "teapot", "lantern", "mammoth", "bastion", "world_tree", "titan", "raccoon", "ferret", "gecko", "skate", "parakeet", "ninja", "wyvern", "thunderbird", "starfox", "void_runner",
    ]

    /// Legacy species still own their existing, carefully drawn front frames in
    /// `SpriteSheet`; all other directions use this same directional system.
    static let generatedFrontSpeciesIDs: Set<String> = speciesIDs.subtracting(Set([
        "owl", "wolf", "crystal", "octopus", "android", "phoenix", "dragon", "sphinx", "robot", "nebula", "butterfly", "cloud", "lotus", "jellyfish", "fox", "unicorn", "mushroom", "fairy", "celestial", "aurora", "turtle", "penguin", "bear", "rock", "cactus", "hedgehog", "parrot", "golem", "elephant", "kraken", "cat", "puppy", "rabbit", "flame", "bat", "scorpion", "fish", "lightning", "moonrabbit", "comet",
    ]))

    static func frames(species: String, stage: Stage, direction: SpriteDirection) -> [PixelSprite]? {
        guard speciesIDs.contains(species) else { return nil }
        // Author at the same 16×16 source resolution as the hand-drawn
        // catalog sprites. SpriteSheet expands every source frame to 24×24.
        let frames = [
            frame(species, stage, direction, 0).nearestResized(width: 16, height: 16),
            frame(species, stage, direction, 1).nearestResized(width: 16, height: 16),
        ]
        // Legacy pets already have bespoke 24×24 side/back silhouettes. Keep
        // them intact; only the expanded front-art set is authored at 16×16.
        if generatedFrontSpeciesIDs.contains(species) { return frames }
        return [frame(species, stage, direction, 0), frame(species, stage, direction, 1)]
    }

    /// The catalog uses deliberately hand-drawn front silhouettes for every
    /// expansion species. The characters are palette slots, not generated
    /// colour seeds: `a` body, `b` defining feature, `c` light area, and `d`
    /// detail. Every glyph receives the same one-pixel black contour used by
    /// the original roster, so its outer shape and face read at a glance.
    private static func customFront(_ species: String, stage: Stage) -> PixelSprite? {
        let art: String
        let colors: (PixelColor, PixelColor, PixelColor, PixelColor)
        switch species {
        case "raven": art = "...b....../..bbb...../.bbcc#..../.bbaaa#.../.bbaaaa#../..baaaa../...baaa../..#a..a#../.........."; colors = (.darkGray, .black, .yellow, .darkBlue)
        case "otter": art = ".a....a.../.aaaaaa.../aabccbaa../.aaaaaaaa./.aacccaaa./..aaaaaaa#/..a##aa###/....##..##/.........."; colors = (.brown, .ginger, .tan, .darkBrown)
        case "chameleon": art = "...a......../..aaaa..../.aa#aaa.../.aaaaaaa../..aaaaaaa./.a..aaaaa./.aaa##aaa./....aaa##./.........."; colors = (.green, .lime, .darkGreen, .teal)
        case "atlas_beetle": art = "....a...../...aaa..../..aabba.../.aaabbaaa./.aaa#aaaa./.aaabbaaa./..aabba.../...a##..../..##..##../.........."; colors = (.darkBlue, .blue, .teal, .black)
        case "clockwork": art = "...ccc..../..caaac.../.caaaaac../..aaaaa#b./..aadaa#../..aaaaaa../..a#..#a../...##.##../.........."; colors = (.tan, .gold, .peach, .brown)
        case "orb": art = "....b...../..bbabb.../.baaaab../.ba#c#ab../.baaaab../..bbabb.../....b...../.......... /.........."; colors = (.purple, .gold, .lavender, .darkBlue)
        case "gryphon": art = "...ccc..../..cc#b..../..caa#b../.bbaaaabb./.bbaaaab./..aaaaa#../..aa#aa../.##..##.../.........."; colors = (.brown, .gold, .cream, .darkRed)
        case "leviathan": art = "...bb..bb./....aa..../..aaaaa.../.a#aaaaa./.aaaaaaa./..aaaaaa./...aaaa../..aaaabb../...##..##./.........."; colors = (.teal, .darkBlue, .mint, .blue)
        case "singularity": art = "....b...../..bbaabb../.ba####ab./.ba#cc#ab/.ba####ab./..bbaabb../....b...../.......... /.........."; colors = (.black, .purple, .lavender, .darkGray)
        case "chrono_dragon": art = "..bb..bb../...aaaa.../.b#aaaa#b./.baaaaab./..aaaabb./.baaaaaa./..a##aaa./...##..##./.........."; colors = (.blue, .lavender, .gold, .darkBlue)
        case "deer": art = ".b......b./.bb....bb./...cccc.../..caaaaac./..aaaaaaa./.aaacaaaa./..aaaaaa../..a#..#a../...##.##../.........."; colors = (.ginger, .brown, .tan, .cream)
        case "seal": art = "............/..aaaaaa../.aaacccaa./.a#cccc#a./.aaacccaa./..aaaaaa../.b..aa..b./...##..##./.........."; colors = (.lightGray, .gray, .cream, .darkGray)
        case "peach": art = "....b...../...bb...../..aaaaa.../.aaacaaa./.aa#caaa./.aaacaaa./..aaaaa.../...a...../.........."; colors = (.peach, .green, .pink, .coral)
        case "luna_moth": art = ".bb....bb./.ba....ab./.baacaaab./..aacaaa../.baacaaab./.ba....ab./.bb....bb./....aa..../.........."; colors = (.mint, .lime, .purple, .lavender)
        case "capybara": art = ".a......a./.aaaaaaaa./aabccccbaa/.aa#cc#aa./.aaaaaaaa./.aa..aa.../.a##..##a./.......... /.........."; colors = (.brown, .darkBrown, .ginger, .tan)
        case "mermaid": art = "...bbbb.../..bcccb../...cccc.../....aa..../....aa..../...aaaa.../..aa..aa../.aa....aa./.........."; colors = (.teal, .pink, .peach, .mint)
        case "pegasus": art = ".b......b./..cccc..../.cc#cccc../.ccaaaacc./.caaaaaac/.bbbaaaabb/.aa..aa.../.a#..#a.../.........."; colors = (.cream, .white, .lavender, .gold)
        case "moonflower": art = "...bbb..../.bbbcbbb../.bbaaaabb./..aacaa../.bbaaaabb./.bbbcbbb../...bdb..../...d.d..../.........."; colors = (.purple, .lavender, .gold, .darkGreen)
        case "seraph": art = "....b...../..bbbbb.../.b..c..b./.b.ccc.b./..ccccc.../.bbcccbb../.b..c..b./...##.##../.........."; colors = (.white, .gold, .cream, .lavender)
        case "dream_whale": art = "............/..aaaaaa../.aa#aaaaa/.aaaaaaaa/.aaacaaaa/.b.aaaa.b./...aaaa.../....bb..../.........."; colors = (.blue, .teal, .mint, .darkBlue)
        case "beaver": art = ".a......a./.aaaaaaaa./.aacccaaa./.aa#c#aaa/.aaa##aaa./..aaaaaa../..aabbaaa./...##..##./.........."; colors = (.brown, .darkBrown, .ginger, .white)
        case "koala": art = ".bb....bb./.bbaaaabb/.aa#c#aaa/.aaa#aaaa/.aacccaaa/.aaacaaa./..a...a../...##.##../.........."; colors = (.gray, .darkGray, .cream, .black)
        case "acorn": art = "....b...../.bbbbbbbb./.baaaaaab/.aaaaaaaa/.aa#cc#aa/.aaaaaaaa/..aaaaaa../...a..a.../.........."; colors = (.brown, .tan, .darkBrown, .darkGreen)
        case "badger": art = "............/.aaaaaaaa./.aabccbaa/.aa#cc#aa/.aaa#aaaa/.aaaaaaaa/.a##..##a./.......... /.........."; colors = (.darkGray, .black, .white, .gray)
        case "teapot": art = "....b...../.bbbbbb.../.baaaaabbb/.aa#c#aaa/.aaaaaaaa/.baaaaabbb/..aaaaaa../.......... /.........."; colors = (.teal, .darkBlue, .cream, .orange)
        case "lantern": art = "....b...../...bbb..../..b###b.../..bccccb../..bc#c.b../..bccccb../..b###b.../...bbb..../.........."; colors = (.orange, .brown, .gold, .cream)
        case "mammoth": art = ".bb....bb./.bbaaaabb/.aa#c#aaa/.aaaaaaaa/.aaacaaaa/.aaacaaaa/.aabb##bba/.a..##..a./.........."; colors = (.darkGray, .gray, .cream, .brown)
        case "bastion": art = ".b..b..b./.bbbbbbbb./.baaaaaab/.aa#cc#aaa/.aaaaaaaa/.aaa..aaa/.a##..##a./.......... /.........."; colors = (.gray, .darkGray, .gold, .black)
        case "world_tree": art = "...bbb..../..babab.../.baaaab../.aaaaaaaa/.aa#c#aaa/.aaaaaaa../...dd...../..d..d..../.........."; colors = (.green, .lime, .brown, .darkBrown)
        case "titan": art = "...aaaa.../.aaaaaaaa/.aa#cc#aaa/.aaaaaaaa/.bbaaaabb/.bbaaaabb/.aa.aa.aa/.##.##.##./.........."; colors = (.darkGray, .gray, .gold, .black)
        case "raccoon": art = ".bb....bb./.bbaaaabb/.aa####aaa/.aa#cc#aaa/.aaaaaaaa/.aaaaaabb/.aa..aa.../.a#..#a.../.........."; colors = (.gray, .darkGray, .white, .black)
        case "ferret": art = "............/..cccc.... /.cc#cccccc/.ccccccaaa/.ccccccaaa/.aa..aa.../.a#..#a.../.......... /.........."; colors = (.cream, .brown, .tan, .darkBrown)
        case "gecko": art = "...aa...../.aaaaaaa../.aa#caaaa./.aaaaaaaa/.aa..aaaa/.aa..aaaa/..aaa..bb/.a..a...../.........."; colors = (.green, .darkGreen, .lime, .purple)
        case "skate": art = "............/.b......b./.bb.aa.bb./.baaaaaab/.aa#cc#aa/.baaaaaab/.bb.aa.bb./....aa..../.........."; colors = (.teal, .blue, .darkBlue, .mint)
        case "parakeet": art = "...bb...../..baab..../.ba#cab.../.baaaab.../.baaaabb../..aaaaabb./...aa..b./....aa..../.........."; colors = (.green, .lime, .coral, .darkGreen)
        case "ninja": art = "...bbbb.../..b####b../..b#cc#b../..bbbbbb../..baaaab../..aaaaaa../..a#..#a../.......... /.........."; colors = (.darkGray, .purple, .white, .black)
        case "wyvern": art = "..bb..bb../.bbaaaabb/.ba#cc#ab/.baaaaab./.bbaaaabb/..aaaaaa../...aaaabb./...##..##./.........."; colors = (.purple, .lavender, .darkBlue, .green)
        case "thunderbird": art = "....b...../.bbbabbb../.ba#c#ab./.baaaaab./.bbaaaabb/.baaaaaab/..aaaaaa../...bb..bb./.........."; colors = (.darkBlue, .blue, .yellow, .orange)
        case "starfox": art = ".b......b./.bb....bb/.ba#cc#ab/.baaaaab./.bbaaaabb/.baaaaaab/..aaaaaacc/.aa...aa../.........."; colors = (.orange, .darkRed, .cream, .yellow)
        case "void_runner": art = "..b....b../.bb....bb/.ba#cc#ab/.baaaaab./..aaaaa.../.bbaaaabb/.b..aaa..b/....bb..../.........."; colors = (.darkGray, .purple, .teal, .black)
        default: return nil
        }
        return stagedGlyph(art, colors, stage)
    }

    private static func stagedGlyph(_ encoded: String, _ colors: (PixelColor, PixelColor, PixelColor, PixelColor), _ stage: Stage) -> PixelSprite {
        let palette: [Character: PixelColor] = [".": .clear, "#": .black, "a": colors.0, "b": colors.1, "c": colors.2, "d": colors.3]
        let glyphRows = encoded.split(separator: "/", omittingEmptySubsequences: false).map { row -> String in
            let trimmed = row.trimmingCharacters(in: .whitespaces)
            return String(trimmed.prefix(10)) + String(repeating: ".", count: max(0, 10 - trimmed.count))
        }
        let compactRows = glyphRows + Array(repeating: "..........", count: max(0, 10 - glyphRows.count))
        let compact = PixelSprite(palette: palette, rows: compactRows)
        // Keep the underlying blocks smaller than the previous expansion art;
        // the resulting outline brings Stage 3 to the original roster's
        // readable footprint without turning the character into a large block.
        let target = stage == .stage1 ? 8 : stage == .stage2 ? 10 : 12
        // Match the established baby-pet stance: a character's recognizable
        // face and species marker live in a broad head, with a noticeably
        // narrower lower body beneath it.  Keeping this as layout rather than
        // a new generic body preserves the per-species hand-drawn glyph.
        let headSource = PixelSprite(width: 10, height: 6, pixels: Array(compact.pixels.prefix(6)))
        let bodySource = PixelSprite(width: 10, height: 4, pixels: Array(compact.pixels.suffix(4)))
        let headHeight = max(5, target * 2 / 3)
        let bodyWidth = max(4, target - 4)
        let bodyHeight = max(3, target - headHeight)
        let enlargedHead = headSource.nearestResized(width: target, height: headHeight)
        let enlargedBody = bodySource.nearestResized(width: bodyWidth, height: bodyHeight)
        var canvas = Array(repeating: Array(repeating: PixelColor.clear, count: 16), count: 16)
        let top = (16 - target) / 2
        for y in 0..<headHeight { for x in 0..<target { canvas[top + y][top + x] = enlargedHead.pixels[y][x] } }
        let bodyLeft = (16 - bodyWidth) / 2
        for y in 0..<bodyHeight { for x in 0..<bodyWidth { canvas[top + headHeight + y][bodyLeft + x] = enlargedBody.pixels[y][x] } }
        return outlined(PixelSprite(width: 16, height: 16, pixels: canvas))
    }

    /// Original pets use a closed black silhouette. Applying that same
    /// contour after each compact glyph is composed keeps eyes and highlights
    /// inside the form while making the species outline immediately visible.
    private static func outlined(_ sprite: PixelSprite) -> PixelSprite {
        var pixels = sprite.pixels
        for y in 0..<sprite.height {
            for x in 0..<sprite.width where sprite.pixels[y][x] == .clear {
                let touchesBody = (-1...1).contains { dy in
                    (-1...1).contains { dx in
                        guard dx != 0 || dy != 0 else { return false }
                        let nx = x + dx, ny = y + dy
                        return sprite.pixels.indices.contains(ny)
                            && sprite.pixels[ny].indices.contains(nx)
                            && sprite.pixels[ny][nx] != .clear
                    }
                }
                if touchesBody { pixels[y][x] = .black }
            }
        }
        return PixelSprite(width: sprite.width, height: sprite.height, pixels: pixels)
    }

    private struct Size {
        let top: Int; let bodyW: Int; let bodyH: Int; let faceW: Int
        init(_ stage: Stage) {
            switch stage {
            case .stage1: (top, bodyW, bodyH, faceW) = (8, 12, 9, 4)
            case .stage2: (top, bodyW, bodyH, faceW) = (5, 15, 12, 5)
            case .stage3: (top, bodyW, bodyH, faceW) = (2, 18, 15, 6)
            }
        }
    }

    private static func frame(_ species: String, _ stage: Stage, _ direction: SpriteDirection, _ step: Int) -> PixelSprite {
        if let sprite = customFront(species, stage: stage) {
            return directedGlyph(sprite, direction: direction, step: step)
        }
        var pixels = Array(repeating: Array(repeating: PixelColor.clear, count: 24), count: 24)
        let s = Size(stage), x = 12, bounce = step == 0 ? 0 : -1
        let y = s.top + s.faceW + 1 + bounce
        draw(&pixels, species: species, direction: direction, step: step, x: x, y: y, size: s)
        return PixelSprite(width: 24, height: 24, pixels: pixels)
    }

    /// Keeps all four directions of the expansion roster on the same
    /// big-head/small-body construction as its front art.  The rear seam and
    /// asymmetric profile eye make the directions readable without falling
    /// back to the old full-body oval renderer.
    private static func directedGlyph(_ front: PixelSprite, direction: SpriteDirection, step: Int) -> PixelSprite {
        var pixels: [[PixelColor]]
        switch direction {
        case .front:
            pixels = front.pixels
        case .back:
            pixels = front.mirrored().pixels
            // A short crown/feather seam replaces the face on the rear view.
            for x in 6...9 where pixels.indices.contains(5) && pixels[5].indices.contains(x) {
                pixels[5][x] = .black
            }
        case .sideRight:
            pixels = upperBody(front.pixels, shiftedBy: 1)
            if pixels.indices.contains(6), pixels[6].indices.contains(11) { pixels[6][11] = .black }
        case .sideLeft:
            pixels = upperBody(front.mirrored().pixels, shiftedBy: -1)
            // Deliberately not a perfect mirror: this is the visible eye on
            // the opposite profile, preserving an independently drawn view.
            if pixels.indices.contains(7), pixels[7].indices.contains(4) { pixels[7][4] = .black }
        }
        if step == 1 { pixels = bob(pixels) }
        return PixelSprite(width: 16, height: 16, pixels: pixels)
    }

    private static func upperBody(_ pixels: [[PixelColor]], shiftedBy dx: Int) -> [[PixelColor]] {
        var result = Array(repeating: Array(repeating: PixelColor.clear, count: 16), count: 16)
        for y in 0..<16 {
            for x in 0..<16 where pixels[y][x] != .clear {
                let nx = y < 9 ? x + dx : x
                if result[y].indices.contains(nx) { result[y][nx] = pixels[y][x] }
            }
        }
        return result
    }

    private static func bob(_ pixels: [[PixelColor]]) -> [[PixelColor]] {
        var result = Array(repeating: Array(repeating: PixelColor.clear, count: 16), count: 16)
        for y in 1..<16 {
            for x in 0..<16 where pixels[y][x] != .clear { result[y - 1][x] = pixels[y][x] }
        }
        return result
    }

    // Every case starts from a species-specific silhouette rather than a seeded
    // colour/trait. `face` only adds two 1px eyes (or one in profile).
    private static func draw(_ g: inout [[PixelColor]], species: String, direction d: SpriteDirection, step: Int, x: Int, y: Int, size s: Size) {
        let side = d == .sideLeft ? -1 : d == .sideRight ? 1 : 0
        let fx = x + side * max(2, s.bodyW / 3)
        let bx = x - s.bodyW / 2
        let foot = min(22, y + s.bodyH - 1)

        switch species {
        case "raven":
            oval(&g, x, y + 4, s.bodyW - 3, s.bodyH - 1, .darkGray); wing(&g, x, y + 4, .black); beak(&g, fx, y, side, .darkGray); tail(&g, x - side * (s.bodyW / 2 - 3), y + 7, side == 0 ? -1 : -side, .black); face(&g, fx, y, d)
        case "otter":
            oval(&g, x, y + 5, s.bodyW, s.bodyH - 3, .brown); oval(&g, x, y + 5, s.bodyW - 6, 4, .tan); ears(&g, x, y, .brown); tail(&g, x - side * (s.bodyW / 2 - 3), y + 7, side == 0 ? -1 : -side, .darkBrown); face(&g, fx, y + 1, d)
        case "chameleon":
            oval(&g, x, y + 6, s.bodyW - 1, s.bodyH - 5, .green); rect(&g, x - 3, y, 6, 4, .lime); tail(&g, x - side * (s.bodyW / 2 - 3), y + 7, side == 0 ? 1 : -side, .darkGreen); rect(&g, x - 5, y + 7, 3, 1, .lime); rect(&g, x + 3, y + 7, 3, 1, .lime); face(&g, fx, y, d)
        case "atlas_beetle":
            oval(&g, x, y + 6, s.bodyW - 3, s.bodyH, .darkBlue); rect(&g, x - 1, y + 2, 2, s.bodyH - 2, .blue); rect(&g, x - 1, y - 3, 2, 4, .darkBlue); rect(&g, x - 5, y + 7, 3, 1, .black); rect(&g, x + 3, y + 7, 3, 1, .black); face(&g, fx, y, d)
        case "clockwork":
            box(&g, bx + 2, y + 3, s.bodyW - 4, s.bodyH - 2, .tan); rect(&g, x - 2, y - 1, 4, 4, .peach); rect(&g, bx + s.bodyW - 1, y + 6, 3, 1, .gold); dot(&g, x, y + 7, .gold); legs(&g, x, foot, step, .darkBrown); face(&g, fx, y, d)
        case "orb":
            oval(&g, x, y + 6, s.bodyW - 3, s.bodyW - 3, .purple); oval(&g, x, y + 6, s.bodyW - 7, s.bodyW - 7, .darkBlue); rect(&g, bx, y + 6, 2, 1, .gold); rect(&g, bx + s.bodyW - 2, y + 6, 2, 1, .gold); face(&g, fx, y + 4, d, .lavender)
        case "gryphon":
            oval(&g, x, y + 7, s.bodyW - 3, s.bodyH - 3, .brown); wing(&g, x, y + 5, .gold); rect(&g, x - 2, y - 1, 4, 5, .cream); beak(&g, fx, y + 1, side, .gold); tail(&g, x - side * (s.bodyW / 2 - 3), y + 8, side == 0 ? -1 : -side, .brown); face(&g, fx, y, d)
        case "leviathan":
            oval(&g, x, y + 7, s.bodyW - 2, s.bodyH - 4, .teal); rect(&g, x - 2, y - 1, 4, 5, .mint); fins(&g, x, y + 5, .blue); tail(&g, x - side * (s.bodyW / 2 - 3), y + 8, side == 0 ? -1 : -side, .darkBlue); horns(&g, x, y - 3, .mint); face(&g, fx, y, d)
        case "singularity":
            oval(&g, x, y + 6, s.bodyW - 3, s.bodyW - 3, .darkGray); oval(&g, x, y + 6, s.bodyW - 7, s.bodyW - 7, .black); rect(&g, bx, y + 3, 2, 1, .purple); rect(&g, bx + s.bodyW - 2, y + 9, 2, 1, .purple); face(&g, fx, y + 4, d, .lavender)
        case "chrono_dragon":
            oval(&g, x, y + 7, s.bodyW - 3, s.bodyH - 4, .blue); horns(&g, x, y - 3, .gold); wingPair(&g, x, y + 4, .lavender); dot(&g, x, y + 7, .gold); tail(&g, x - side * (s.bodyW / 2 - 3), y + 8, side == 0 ? -1 : -side, .darkBlue); face(&g, fx, y, d)

        case "deer":
            oval(&g, x, y + 7, s.bodyW - 4, s.bodyH - 3, .ginger); rect(&g, x - 2, y, 4, 4, .tan); antlers(&g, x, y - 3, .brown); legs(&g, x, foot, step, .brown); face(&g, fx, y, d)
        case "seal":
            oval(&g, x, y + 7, s.bodyW, s.bodyH - 4, .lightGray); oval(&g, x, y + 7, s.bodyW - 5, s.bodyH - 7, .cream); fins(&g, x, y + 7, .gray); face(&g, fx, y + 3, d)
        case "peach":
            oval(&g, x, y + 6, s.bodyW - 3, s.bodyW - 4, .peach); rect(&g, x, y - 3, 1, 3, .brown); rect(&g, x + 1, y - 2, 3, 2, .green); rect(&g, x, y + 2, 1, s.bodyW - 8, .pink); face(&g, fx, y + 4, d)
        case "luna_moth":
            oval(&g, x - 4, y + 6, max(5, s.bodyW / 2), s.bodyH - 2, .mint); oval(&g, x + 4, y + 6, max(5, s.bodyW / 2), s.bodyH - 2, .mint); rect(&g, x - 1, y + 1, 3, s.bodyH - 2, .lime); dot(&g, x - 4, y + 6, .purple); dot(&g, x + 4, y + 6, .purple); face(&g, fx, y, d)
        case "capybara":
            oval(&g, x, y + 7, s.bodyW, s.bodyH - 4, .brown); rect(&g, x - 3, y + 1, 6, 4, .ginger); ears(&g, x, y, .brown); legs(&g, x, foot, step, .darkBrown); face(&g, fx, y + 2, d)
        case "mermaid":
            oval(&g, x, y + 3, s.bodyW - 6, 6, .peach); rect(&g, x - 3, y - 2, 6, 2, .pink); rect(&g, x - 2, y + 7, 4, 7, .teal); fins(&g, x, y + 13, .mint); face(&g, fx, y + 1, d)
        case "pegasus":
            oval(&g, x, y + 7, s.bodyW - 4, s.bodyH - 3, .cream); wingPair(&g, x, y + 4, .white); ears(&g, x, y - 1, .lavender); tail(&g, x - side * (s.bodyW / 2 - 3), y + 8, side == 0 ? -1 : -side, .lavender); face(&g, fx, y, d)
        case "moonflower":
            oval(&g, x - 4, y + 4, 7, 8, .lavender); oval(&g, x + 4, y + 4, 7, 8, .lavender); oval(&g, x, y, 7, 6, .purple); rect(&g, x - 1, y + 6, 3, s.bodyH - 2, .darkGreen); face(&g, fx, y + 2, d, .gold)
        case "seraph":
            oval(&g, x, y + 7, s.bodyW - 6, s.bodyH - 3, .white); wingPair(&g, x, y + 4, .cream); rect(&g, x - 2, y - 3, 5, 1, .gold); face(&g, fx, y, d)
        case "dream_whale":
            oval(&g, x, y + 7, s.bodyW, s.bodyH - 5, .blue); fins(&g, x, y + 7, .teal); rect(&g, x - 1, y - 2, 2, 3, .mint); tail(&g, x - side * (s.bodyW / 2 - 3), y + 8, side == 0 ? -1 : -side, .teal); face(&g, fx, y + 3, d)

        case "beaver":
            oval(&g, x, y + 7, s.bodyW - 3, s.bodyH - 3, .brown); rect(&g, x - 3, y + 3, 6, 4, .ginger); rect(&g, x - 1, y + 6, 3, 2, .white); tail(&g, x - side * (s.bodyW / 2 - 3), y + 8, side == 0 ? -1 : -side, .darkBrown); face(&g, fx, y + 2, d)
        case "koala":
            oval(&g, x, y + 7, s.bodyW - 3, s.bodyH - 3, .gray); ears(&g, x, y, .darkGray); rect(&g, x - 1, y + 2, 3, 2, .black); oval(&g, x, y + 10, 6, 4, .cream); face(&g, fx, y, d)
        case "acorn":
            oval(&g, x, y + 7, s.bodyW - 4, s.bodyH - 2, .brown); rect(&g, bx + 2, y, s.bodyW - 4, 3, .tan); rect(&g, x, y - 2, 1, 2, .darkGreen); face(&g, fx, y + 5, d)
        case "badger":
            oval(&g, x, y + 7, s.bodyW, s.bodyH - 5, .darkGray); rect(&g, x - 2, y, 4, 7, .white); rect(&g, x - 5, y + 2, 3, 2, .black); rect(&g, x + 3, y + 2, 3, 2, .black); legs(&g, x, foot, step, .black); face(&g, fx, y + 1, d)
        case "teapot":
            oval(&g, x, y + 7, s.bodyW - 4, s.bodyH - 3, .teal); rect(&g, x - 3, y, 6, 2, .darkBlue); spout(&g, fx, y + 5, side, .teal); handle(&g, x - side * (s.bodyW / 2 - 3), y + 5, side == 0 ? -1 : -side, .darkBlue); face(&g, fx, y + 4, d)
        case "lantern":
            box(&g, bx + 3, y + 2, s.bodyW - 6, s.bodyH - 1, .orange); rect(&g, x - 3, y - 1, 7, 2, .brown); rect(&g, x - 1, y - 4, 3, 3, .brown); face(&g, fx, y + 4, d, .cream)
        case "mammoth":
            oval(&g, x, y + 7, s.bodyW, s.bodyH - 3, .darkGray); ears(&g, x, y + 1, .gray); rect(&g, x - 1, y + 3, 3, 7, .gray); dot(&g, x - 3, y + 7, .cream); dot(&g, x + 3, y + 7, .cream); face(&g, fx, y + 1, d)
        case "bastion":
            box(&g, bx + 2, y + 4, s.bodyW - 4, s.bodyH - 3, .gray); rect(&g, bx + 3, y + 1, 3, 3, .gray); rect(&g, bx + s.bodyW - 6, y + 1, 3, 3, .gray); rect(&g, x - 1, y + 8, 3, 3, .darkGray); face(&g, fx, y + 5, d, .gold)
        case "world_tree":
            rect(&g, x - 2, y + 8, 4, s.bodyH - 4, .brown); oval(&g, x - 4, y + 4, 8, 8, .green); oval(&g, x + 4, y + 4, 8, 8, .green); oval(&g, x, y, 8, 7, .lime); face(&g, fx, y + 3, d)
        case "titan":
            box(&g, bx + 2, y + 4, s.bodyW - 4, s.bodyH - 2, .darkGray); rect(&g, x - 3, y, 6, 5, .gray); rect(&g, bx, y + 7, 3, 5, .gray); rect(&g, bx + s.bodyW - 3, y + 7, 3, 5, .gray); legs(&g, x, foot, step, .black); face(&g, fx, y + 1, d, .gold)

        case "raccoon":
            oval(&g, x, y + 7, s.bodyW - 3, s.bodyH - 3, .gray); ears(&g, x, y, .darkGray); rect(&g, x - 4, y + 2, 8, 2, .darkGray); tail(&g, x - side * (s.bodyW / 2 - 3), y + 8, side == 0 ? -1 : -side, .darkGray); face(&g, fx, y + 1, d)
        case "ferret":
            oval(&g, x, y + 8, s.bodyW, s.bodyH - 6, .cream); rect(&g, x - 2, y, 4, 4, .tan); tail(&g, x - side * (s.bodyW / 2 - 3), y + 8, side == 0 ? -1 : -side, .brown); legs(&g, x, foot - 2, step, .brown); face(&g, fx, y, d)
        case "gecko":
            oval(&g, x, y + 7, s.bodyW - 2, s.bodyH - 7, .green); rect(&g, x - 3, y, 6, 4, .lime); tail(&g, x - side * (s.bodyW / 2 - 3), y + 7, side == 0 ? -1 : -side, .darkGreen); fins(&g, x, y + 8, .lime); face(&g, fx, y, d)
        case "skate":
            oval(&g, x, y + 7, s.bodyW + 1, s.bodyH - 7, .teal); fins(&g, x, y + 7, .blue); tail(&g, x, y + 8, side == 0 ? 1 : side, .darkBlue); face(&g, fx, y + 4, d)
        case "parakeet":
            oval(&g, x, y + 7, s.bodyW - 5, s.bodyH - 3, .green); wing(&g, x, y + 5, .lime); rect(&g, x - 2, y - 1, 4, 3, .lime); beak(&g, fx, y + 2, side, .coral); tail(&g, x - side * 2, y + 10, side == 0 ? 1 : -side, .darkGreen); face(&g, fx, y, d)
        case "ninja":
            box(&g, bx + 3, y + 4, s.bodyW - 6, s.bodyH - 2, .darkGray); rect(&g, x - 3, y, 6, 5, .black); rect(&g, x - 4, y + 2, 8, 1, .purple); rect(&g, x + (side == 0 ? 4 : side * 5), y + 2, 3, 1, .purple); legs(&g, x, foot, step, .black); face(&g, fx, y + 1, d, .white)
        case "wyvern":
            oval(&g, x, y + 8, s.bodyW - 5, s.bodyH - 4, .purple); wingPair(&g, x, y + 4, .lavender); horns(&g, x, y - 2, .lavender); tail(&g, x - side * (s.bodyW / 2 - 3), y + 9, side == 0 ? -1 : -side, .darkBlue); face(&g, fx, y, d)
        case "thunderbird":
            oval(&g, x, y + 7, s.bodyW - 5, s.bodyH - 3, .darkBlue); wingPair(&g, x, y + 4, .blue); beak(&g, fx, y + 1, side, .yellow); dot(&g, x, y - 3, .yellow); face(&g, fx, y, d, .white)
        case "starfox":
            oval(&g, x, y + 7, s.bodyW - 4, s.bodyH - 3, .orange); ears(&g, x, y - 1, .darkRed); tail(&g, x - side * (s.bodyW / 2 - 3), y + 8, side == 0 ? -1 : -side, .cream); dot(&g, x - 6, y + 9, .yellow); face(&g, fx, y, d)
        case "void_runner":
            oval(&g, x, y + 7, s.bodyW - 5, s.bodyH - 2, .darkGray); wingPair(&g, x, y + 5, .purple); horns(&g, x, y - 2, .purple); tail(&g, x - side * (s.bodyW / 2 - 3), y + 9, side == 0 ? -1 : -side, .purple); face(&g, fx, y + 1, d, .teal)
        default:
            oval(&g, x, y + 7, s.bodyW - 3, s.bodyH - 3, .gray); face(&g, fx, y + 1, d)
        }
    }

    // MARK: - Primitives

    private static func face(_ g: inout [[PixelColor]], _ x: Int, _ y: Int, _ d: SpriteDirection, _ c: PixelColor = .black) {
        switch d {
        case .front: dot(&g, x - 1, y + 1, c); dot(&g, x + 1, y + 1, c)
        case .back: dot(&g, x, y, .darkGray)
        case .sideLeft: dot(&g, x - 1, y + 1, c)
        case .sideRight: dot(&g, x + 1, y + 1, c)
        }
    }
    private static func oval(_ g: inout [[PixelColor]], _ x: Int, _ y: Int, _ w: Int, _ h: Int, _ c: PixelColor) {
        let hw = max(1, w / 2), hh = max(1, h / 2)
        for row in -hh...hh { let inset = abs(row) * hw / (hh + 1); for col in -(hw - inset)...(hw - inset) { dot(&g, x + col, y + row, c) } }
    }
    private static func rect(_ g: inout [[PixelColor]], _ x: Int, _ y: Int, _ w: Int, _ h: Int, _ c: PixelColor) {
        guard w > 0, h > 0 else { return }; for row in y..<(y + h) { for col in x..<(x + w) { dot(&g, col, row, c) } }
    }
    private static func box(_ g: inout [[PixelColor]], _ x: Int, _ y: Int, _ w: Int, _ h: Int, _ c: PixelColor) {
        rect(&g, x, y, w, h, c); rect(&g, x, y, w, 1, .black); rect(&g, x, y + h - 1, w, 1, .black); rect(&g, x, y, 1, h, .black); rect(&g, x + w - 1, y, 1, h, .black)
    }
    private static func ears(_ g: inout [[PixelColor]], _ x: Int, _ y: Int, _ c: PixelColor) { oval(&g, x - 4, y, 4, 4, c); oval(&g, x + 4, y, 4, 4, c) }
    private static func horns(_ g: inout [[PixelColor]], _ x: Int, _ y: Int, _ c: PixelColor) { rect(&g, x - 3, y, 2, 3, c); rect(&g, x + 2, y, 2, 3, c) }
    private static func wing(_ g: inout [[PixelColor]], _ x: Int, _ y: Int, _ c: PixelColor) { rect(&g, x - 5, y, 3, 6, c); rect(&g, x - 3, y + 4, 3, 3, c) }
    private static func wingPair(_ g: inout [[PixelColor]], _ x: Int, _ y: Int, _ c: PixelColor) { wing(&g, x, y, c); rect(&g, x + 3, y, 3, 6, c); rect(&g, x + 1, y + 4, 3, 3, c) }
    private static func fins(_ g: inout [[PixelColor]], _ x: Int, _ y: Int, _ c: PixelColor) { rect(&g, x - 6, y, 3, 3, c); rect(&g, x + 4, y, 3, 3, c) }
    private static func legs(_ g: inout [[PixelColor]], _ x: Int, _ y: Int, _ step: Int, _ c: PixelColor) { dot(&g, x - 3, y, c); dot(&g, x + 3, y + (step == 0 ? 0 : -1), c) }
    private static func tail(_ g: inout [[PixelColor]], _ x: Int, _ y: Int, _ side: Int, _ c: PixelColor) { let d = side == 0 ? 1 : side; rect(&g, x + d, y, 2, 2, c); rect(&g, x + d * 2, y + 1, 2, 2, c) }
    private static func beak(_ g: inout [[PixelColor]], _ x: Int, _ y: Int, _ side: Int, _ c: PixelColor) { if side < 0 { rect(&g, x - 3, y, 3, 2, c) } else if side > 0 { rect(&g, x + 1, y, 3, 2, c) } else { rect(&g, x - 1, y + 2, 3, 1, c) } }
    private static func spout(_ g: inout [[PixelColor]], _ x: Int, _ y: Int, _ side: Int, _ c: PixelColor) { rect(&g, x + (side < 0 ? -3 : 1), y, 3, 2, c) }
    private static func handle(_ g: inout [[PixelColor]], _ x: Int, _ y: Int, _ side: Int, _ c: PixelColor) { let d = side == 0 ? 1 : side; rect(&g, x + d, y, 2, 5, c); rect(&g, x + d, y + 4, 3, 1, c) }
    private static func antlers(_ g: inout [[PixelColor]], _ x: Int, _ y: Int, _ c: PixelColor) { rect(&g, x - 4, y, 1, 4, c); rect(&g, x + 3, y, 1, 4, c); rect(&g, x - 5, y + 1, 2, 1, c); rect(&g, x + 3, y + 1, 2, 1, c) }
    private static func dot(_ g: inout [[PixelColor]], _ x: Int, _ y: Int, _ c: PixelColor) { guard g.indices.contains(y), g[y].indices.contains(x) else { return }; g[y][x] = c }
}

private extension PixelColor {
    static let darkBrown = PixelColor(0xFF4D260C)
}
