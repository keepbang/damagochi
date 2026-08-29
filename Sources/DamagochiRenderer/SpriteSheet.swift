import DamagochiCore

public enum SpriteDirection: String, Codable, Sendable, CaseIterable {
    case front
    case back
    case sideLeft
    case sideRight
}

public enum SpriteSheet {
    /// The runtime sheet is 24×24. `gridScale` preserves the original on-screen
    /// footprint when a caller lowers its point scale from legacy 16×16 art.
    public static let spriteGridSize = 24
    public static let gridScale = 1.5

    public static func frames(
        species: String?,
        stage: Stage,
        phase: PetPhase,
        direction: SpriteDirection = .front
    ) -> [PixelSprite] {
        if let species,
           (direction != .front || ExpandedSpeciesSprites.generatedFrontSpeciesIDs.contains(species)),
           let expanded = ExpandedSpeciesSprites.frames(species: species, stage: stage, direction: direction) {
            let requiresGridExpansion = ExpandedSpeciesSprites.generatedFrontSpeciesIDs.contains(species)
            switch phase {
            case .alive:
                return requiresGridExpansion ? expanded.map { $0.nearestResized(width: spriteGridSize, height: spriteGridSize) } : expanded
            case .dead:
                return requiresGridExpansion ? expanded.map { $0.grayed().nearestResized(width: spriteGridSize, height: spriteGridSize) } : expanded.map { $0.grayed() }
            case .egg: break
            }
        }
        let base: [PixelSprite]
        switch phase {
        case .egg:
            base = eggFrames
        case .dead:
            base = aliveFrames(species: species, stage: stage).map { $0.grayed() }
        case .alive:
            base = aliveFrames(species: species, stage: stage)
        }
        // The original sheets were front-only. Direction is a first-class API
        // now, with mirrored side frames as a safe compatibility fallback until
        // a species provides bespoke asymmetric artwork.
        let directional: [PixelSprite]
        switch direction {
        case .front, .back, .sideRight:
            directional = base
        case .sideLeft:
            directional = base.map { $0.mirrored() }
        }
        return directional.map {
            $0.nearestResized(width: spriteGridSize, height: spriteGridSize)
        }
    }

    private static func aliveFrames(species: String?, stage: Stage) -> [PixelSprite] {
        guard let species else { return eggFrames }
        switch species {
        case "owl":        return owlFrames(stage)
        case "cat":        return catFrames(stage)
        case "turtle":     return turtleFrames(stage)
        case "butterfly":  return butterflyFrames(stage)
        case "dragon":     return dragonFrames(stage)
        case "wolf":       return wolfFrames(stage)
        case "octopus":    return octopusFrames(stage)
        case "robot":      return robotFrames(stage)
        case "jellyfish":  return jellyfishFrames(stage)
        case "cloud":      return cloudFrames(stage)
        case "fox":        return foxFrames(stage)
        case "mushroom":   return mushroomFrames(stage)
        case "penguin":    return penguinFrames(stage)
        case "rock":       return rockFrames(stage)
        case "cactus":     return cactusFrames(stage)
        case "parrot":     return parrotFrames(stage)
        case "puppy":      return puppyFrames(stage)
        case "flame":      return flameFrames(stage)
        case "bat":        return batFrames(stage)
        case "moonrabbit": return moonrabbitFrames(stage)
        // New species
        case "crystal":   return crystalFrames(stage)
        case "android":   return androidFrames(stage)
        case "phoenix":   return phoenixFrames(stage)
        case "sphinx":    return sphinxFrames(stage)
        case "nebula":    return nebulaFrames(stage)
        case "lotus":     return lotusFrames(stage)
        case "unicorn":   return unicornFrames(stage)
        case "fairy":     return fairyFrames(stage)
        case "celestial": return celestialFrames(stage)
        case "aurora":    return auroraFrames(stage)
        case "bear":      return bearFrames(stage)
        case "hedgehog":  return hedgehogFrames(stage)
        case "golem":     return golemFrames(stage)
        case "elephant":  return elephantFrames(stage)
        case "kraken":    return krakenFrames(stage)
        case "rabbit":    return rabbitFrames(stage)
        case "scorpion":  return scorpionFrames(stage)
        case "fish":      return fishFrames(stage)
        case "lightning": return lightningFrames(stage)
        case "comet":     return cometFrames(stage)
        default:           return defaultFrames(stage)
        }
    }

    // MARK: - Helpers

    private static func s(_ palette: [Character: PixelColor], _ rows: [String]) -> PixelSprite {
        PixelSprite(palette: palette, rows: rows)
    }

    // MARK: - Egg

    private static let eggPalette: [Character: PixelColor] = [
        ".": .clear, "#": .tan, "c": .cream, "y": .gold, "w": .white,
    ]

    static let eggFrames: [PixelSprite] = [
        s(eggPalette, [
            "................",
            ".....######.....",
            "....#cccccc#....",
            "...#cccccccc#...",
            "..#cccccccccc#..",
            "..#ccy##ccccc#..",
            "..#cy####cccc#..",
            "..#cccccccccc#..",
            "..#cccccccccc#..",
            "..#ccccc##ycc#..",
            "..#cccc####yc#..",
            "...#cccccccc#...",
            "....#cccccc#....",
            ".....######.....",
            "................",
            "................",
        ]),
        s(eggPalette, [
            "................",
            "......######....",
            ".....#cccccc#...",
            "....#cccccccc#..",
            "...#cccccccccc#.",
            "...#ccy##ccccc#.",
            "...#cy####cccc#.",
            "...#cccccccccc#.",
            "...#cccccccccc#.",
            "...#ccccc##ycc#.",
            "...#cccc####yc#.",
            "....#cccccccc#..",
            ".....#cccccc#...",
            "......######....",
            "................",
            "................",
        ]),
    ]

    // MARK: - Owl

    private static let owlPalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "b": .brown, "t": .tan,
        "w": .white, "o": .orange, "y": .yellow,
    ]

    private static func owlFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage {
        case .stage1: return owlStage1
        case .stage2: return owlStage2
        case .stage3: return owlStage3
        }
    }

    private static let owlStage1: [PixelSprite] = [
        s(owlPalette, [
            "................",
            "................",
            "................",
            "....#......#....",
            "...##......##...",
            "...##########...",
            "..#bbbbbbbbbb#..",
            "..#bw##bb##wb#..",
            "..#bo##bb##ob#..",
            "..#bbbb##bbbb#..",
            "..#bbb#oo#bbb#..",
            "...#bbttttbb#...",
            "....#bb##bb#....",
            "...##......##...",
            "................",
            "................",
        ]),
        s(owlPalette, [
            "................",
            "................",
            "................",
            "....#......#....",
            "...##......##...",
            "...##########...",
            "..#bbbbbbbbbb#..",
            "..#b##bbbb##b#..",
            "..#bbbbbbbbbb#..",
            "..#bbbb##bbbb#..",
            "..#bbb#oo#bbb#..",
            "...#bbttttbb#...",
            "....#bb##bb#....",
            "...##......##...",
            "................",
            "................",
        ]),
    ]

    private static let owlStage2: [PixelSprite] = [
        s(owlPalette, [
            "................",
            "...#........#...",
            "..##........##..",
            "..############..",
            ".#bbbbbbbbbbbb#.",
            ".#bww##bb##wwb#.",
            ".#bwo##bb##owb#.",
            ".#bbbb####bbbb#.",
            "..#bbb#oo#bbb#..",
            "..#bbbbbbbbbb#..",
            "..#bbttttttbb#..",
            "...#bbbbbbbb#...",
            "...#bb#..#bb#...",
            "..##........##..",
            "................",
            "................",
        ]),
        s(owlPalette, [
            "................",
            "...#........#...",
            "..##........##..",
            "..############..",
            ".#bbbbbbbbbbbb#.",
            ".#b####bb####b#.",
            ".#bbbbbbbbbbbb#.",
            ".#bbbb####bbbb#.",
            "..#bbb#oo#bbb#..",
            "..#bbbbbbbbbb#..",
            "..#bbttttttbb#..",
            "...#bbbbbbbb#...",
            "...#bb#..#bb#...",
            "..##........##..",
            "................",
            "................",
        ]),
    ]

    private static let owlStage3: [PixelSprite] = [
        s(owlPalette, [
            "..#..........#..",
            ".##..........##.",
            ".##############.",
            "#bbbbbbbbbbbbbb#",
            "#bwwww#bb#wwwwb#",
            "#bwwwo#bb#owwwb#",
            "#bbbb######bbbb#",
            "#bbbbb#oo#bbbbb#",
            ".#bbbbbbbbbbbb#.",
            ".#bbttttttttbb#.",
            "..#bttttttttb#..",
            "..#bbbbbbbbbb#..",
            "...#bbb##bbb#...",
            "..##........##..",
            "................",
            "................",
        ]),
        s(owlPalette, [
            "..#..........#..",
            ".##..........##.",
            ".##############.",
            "#bbbbbbbbbbbbbb#",
            "#bwwww####wwwwb#",
            "#bbbbbbbbbbbbbb#",
            "#bbbb######bbbb#",
            "#bbbbb#oo#bbbbb#",
            ".#bbbbbbbbbbbb#.",
            ".#bbttttttttbb#.",
            "..#bttttttttb#..",
            "..#bbbbbbbbbb#..",
            "...#bbb##bbb#...",
            "..##........##..",
            "................",
            "................",
        ]),
    ]

    // MARK: - Cat

    private static let catPalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "o": .ginger,
        "w": .white, "p": .pink, "g": .green,
    ]

    private static func catFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage {
        case .stage1: return catStage1
        case .stage2: return catStage2
        case .stage3: return catStage3
        }
    }

    private static let catStage1: [PixelSprite] = [
        s(catPalette, [
            "................",
            "................",
            "................",
            "....#......#....",
            "...#o#....#o#...",
            "...#oo####oo#...",
            "..#oooooooooo#..",
            "..#ow##oo##wo#..",
            "..#ooo#pp#ooo#..",
            "..#oowwwwwwoo#..",
            "...#oooooooo#...",
            "....#oo##oo#....",
            "...##......##...",
            "................",
            "................",
            "................",
        ]),
        s(catPalette, [
            "................",
            "................",
            "................",
            "....#......#....",
            "...#o#....#o#...",
            "...#oo####oo#...",
            "..#oooooooooo#..",
            "..#o##oooo##o#..",
            "..#ooo#pp#ooo#..",
            "..#oowwwwwwoo#..",
            "...#oooooooo#...",
            "....#oo##oo#....",
            "...##......##...",
            "................",
            "................",
            "................",
        ]),
    ]

    private static let catStage2: [PixelSprite] = [
        s(catPalette, [
            "................",
            "...#........#...",
            "..#o#......#o#..",
            ".#ooo######ooo#.",
            ".#oooooooooooo#.",
            "#oww##oooo##wwo#",
            "#owg##oooo##gwo#",
            "#ooooo#pp#ooooo#",
            ".#oooooooooooo#.",
            ".#oowwwwwwwwoo#.",
            "..#owwwwwwwwo#..",
            "..#oooooooooo#..",
            "...#ooo##ooo#...",
            "..##........##..",
            "................",
            "................",
        ]),
        s(catPalette, [
            "................",
            "...#........#...",
            "..#o#......#o#..",
            ".#ooo######ooo#.",
            ".#oooooooooooo#.",
            "#o####oooo####o#",
            "#oooooooooooooo#",
            "#ooooo#pp#ooooo#",
            ".#oooooooooooo#.",
            ".#oowwwwwwwwoo#.",
            "..#owwwwwwwwo#..",
            "..#oooooooooo#..",
            "...#ooo##ooo#...",
            "..##........##..",
            "................",
            "................",
        ]),
    ]

    private static let catStage3: [PixelSprite] = [
        s(catPalette, [
            "...#........#...",
            "..#o#......#o#..",
            ".#ooo######ooo#.",
            ".#oooooooooooo#.",
            "#oww##oooo##wwo#",
            "#owg##oooo##gwo#",
            "#oooooo##oooooo#",
            "#ooooo#pp#ooooo#",
            ".#oooooooooooo#.",
            ".#oowwwwwwwwoo#.",
            "..#owwwwwwwwo#..",
            "..#oooooooooo#..",
            "...#ooo##ooo#...",
            "..##........##..",
            "................",
            "................",
        ]),
        s(catPalette, [
            "...#........#...",
            "..#o#......#o#..",
            ".#ooo######ooo#.",
            ".#oooooooooooo#.",
            "#o####oooo####o#",
            "#oooooooooooooo#",
            "#oooooo##oooooo#",
            "#ooooo#pp#ooooo#",
            ".#oooooooooooo#.",
            ".#oowwwwwwwwoo#.",
            "..#owwwwwwwwo#..",
            "..#oooooooooo#..",
            "...#ooo##ooo#...",
            "..##........##..",
            "................",
            "................",
        ]),
    ]

    // MARK: - Turtle

    private static let turtlePalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "g": .green,
        "d": .darkGreen, "t": .tan, "w": .white,
    ]

    private static func turtleFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage {
        case .stage1: return turtleStage1
        case .stage2: return turtleStage2
        case .stage3: return turtleStage3
        }
    }

    private static let turtleStage1: [PixelSprite] = [
        s(turtlePalette, [
            "................",
            "................",
            "................",
            "......####......",
            ".....#tttt#.....",
            ".....#t##t#.....",
            ".....#tttt#.....",
            "....########....",
            "...#dddddddd#...",
            "...#dgddddgd#...",
            "...#dddddddd#...",
            "....########....",
            "....#t#..#t#....",
            "................",
            "................",
            "................",
        ]),
        s(turtlePalette, [
            "................",
            "................",
            "................",
            "......####......",
            ".....#tttt#.....",
            ".....######.....",
            ".....#tttt#.....",
            "....########....",
            "...#dddddddd#...",
            "...#dgddddgd#...",
            "...#dddddddd#...",
            "....########....",
            "....#t#..#t#....",
            "................",
            "................",
            "................",
        ]),
    ]

    private static let turtleStage2: [PixelSprite] = [
        s(turtlePalette, [
            "................",
            ".....######.....",
            "....#tttttt#....",
            "....#tw##wt#....",
            "....#tttttt#....",
            "...##########...",
            "..#dddddddddd#..",
            "..#dgddddddgd#..",
            "..#ddggggggdd#..",
            "..#dgddddddgd#..",
            "..#dddddddddd#..",
            "...##########...",
            "...#tt#..#tt#...",
            "..##........##..",
            "................",
            "................",
        ]),
        s(turtlePalette, [
            "................",
            ".....######.....",
            "....#tttttt#....",
            "....########....",
            "....#tttttt#....",
            "...##########...",
            "..#dddddddddd#..",
            "..#dgddddddgd#..",
            "..#ddggggggdd#..",
            "..#dgddddddgd#..",
            "..#dddddddddd#..",
            "...##########...",
            "...#tt#..#tt#...",
            "..##........##..",
            "................",
            "................",
        ]),
    ]

    private static let turtleStage3: [PixelSprite] = [
        s(turtlePalette, [
            "......####......",
            ".....#tttt#.....",
            "....#tttttt#....",
            "....#tw##wt#....",
            "....#tttttt#....",
            "...##########...",
            "..#dddddddddd#..",
            "..#dgddddddgd#..",
            "..#ddggggggdd#..",
            ".#dggddddddggd#.",
            ".#dgddddddddgd#.",
            "..#dddddddddd#..",
            "...##########...",
            "....#tt##tt#....",
            "...##......##...",
            "................",
        ]),
        s(turtlePalette, [
            "......####......",
            ".....#tttt#.....",
            "....#tttttt#....",
            "....########....",
            "....#tttttt#....",
            "...##########...",
            "..#dddddddddd#..",
            "..#dgddddddgd#..",
            "..#ddggggggdd#..",
            ".#dggddddddggd#.",
            ".#dgddddddddgd#.",
            "..#dddddddddd#..",
            "...##########...",
            "....#tt##tt#....",
            "...##......##...",
            "................",
        ]),
    ]

    // MARK: - Butterfly

    private static let bflyPalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "p": .purple,
        "b": .blue, "l": .lavender, "k": .pink, "w": .white,
    ]

    private static func butterflyFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage {
        case .stage1: return bflyStage1
        case .stage2: return bflyStage2
        case .stage3: return bflyStage3
        }
    }

    // Stage 1: caterpillar
    private static let bflyStage1: [PixelSprite] = [
        s(["." : .clear, "#": .black, "g": .green, "l": .lime, "w": .white], [
            "................",
            "................",
            "................",
            "................",
            ".....#....#.....",
            "......#..#......",
            ".....######.....",
            "....#gggggg#....",
            "....#gw##wg#....",
            "....#gggggg#....",
            "...#llggggll#...",
            "...#llllllll#...",
            "...#llggggll#...",
            "....########....",
            "................",
            "................",
        ]),
        s(["." : .clear, "#": .black, "g": .green, "l": .lime, "w": .white], [
            "................",
            "................",
            "................",
            "................",
            "....#......#....",
            ".....#....#.....",
            ".....######.....",
            "....#gggggg#....",
            "....#gw##wg#....",
            "....#gggggg#....",
            "...#llggggll#...",
            "...#llllllll#...",
            "...#llggggll#...",
            "....########....",
            "................",
            "................",
        ]),
    ]

    // Stage 2: chrysalis
    private static let bflyStage2: [PixelSprite] = [
        s(bflyPalette, [
            "................",
            "................",
            "......####......",
            ".....#pppp#.....",
            "....#pppppp#....",
            "....#plpppl#....",
            "....#pppppp#....",
            "....#plpppl#....",
            "....#pppppp#....",
            "....#pppppp#....",
            ".....#pppp#.....",
            "......####......",
            ".......##.......",
            "................",
            "................",
            "................",
        ]),
        s(bflyPalette, [
            "................",
            "................",
            "......####......",
            ".....#pppp#.....",
            "....#pppppp#....",
            "....#plpppl#....",
            "....#pppppp#....",
            "....#ppllpp#....",
            "....#pppppp#....",
            "....#pppppp#....",
            ".....#pppp#.....",
            "......####......",
            ".......##.......",
            "................",
            "................",
            "................",
        ]),
    ]

    // Stage 3: full butterfly
    private static let bflyStage3: [PixelSprite] = [
        s(bflyPalette, [
            "................",
            ".....#....#.....",
            "......#..#......",
            ".##...####...##.",
            "#pp#..#bb#..#pp#",
            "#ppp#.#bb#.#ppp#",
            "#pppp##bb##pppp#",
            "#plpp##bb##pplp#",
            "#pppp##bb##pppp#",
            "#ppp#.#bb#.#ppp#",
            ".##...#bb#...##.",
            "......#bb#......",
            ".......##.......",
            "................",
            "................",
            "................",
        ]),
        s(bflyPalette, [
            "................",
            ".....#....#.....",
            ".##...#..#...##.",
            "#pp#..####..#pp#",
            "#ppp#.#bb#.#ppp#",
            "#pppp##bb##pppp#",
            "#plpp##bb##pplp#",
            "#pppp##bb##pppp#",
            "#ppp#.#bb#.#ppp#",
            ".##...#bb#...##.",
            "......#bb#......",
            ".......##.......",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]

    // MARK: - Dragon

    private static let dragonPalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "r": .red,
        "o": .orange, "y": .yellow, "w": .white, "d": .darkRed,
    ]

    private static func dragonFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage {
        case .stage1: return dragonStage1
        case .stage2: return dragonStage2
        case .stage3: return dragonStage3
        }
    }

    private static let dragonStage1: [PixelSprite] = [
        s(dragonPalette, [
            "................",
            "................",
            "................",
            "....#......#....",
            "...##......##...",
            "...##########...",
            "..#rrrrrrrrrr#..",
            "..#rw##rr##wr#..",
            "..#rrrr##rrrr#..",
            "..#rrr#yy#rrr#..",
            "...#rrooooorr#..",
            "...#rrrrrrrr#...",
            "....#rr##rr#....",
            "...##......##...",
            "................",
            "................",
        ]),
        s(dragonPalette, [
            "................",
            "................",
            "................",
            "....#......#....",
            "...##......##...",
            "...##########...",
            "..#rrrrrrrrrr#..",
            "..#r##rrrr##r#..",
            "..#rrrr##rrrr#..",
            "..#rrr#yy#rrr#..",
            "...#rrooooorr#..",
            "...#rrrrrrrr#...",
            "....#rr##rr#....",
            "...##......##...",
            "................",
            "................",
        ]),
    ]

    private static let dragonStage2: [PixelSprite] = [
        s(dragonPalette, [
            "................",
            "..#..........#..",
            ".##..........##.",
            ".##############.",
            "#rrrrrrrrrrrrrr#",
            "#rww##rrrr##wwr#",
            "#rrrr######rrrr#",
            ".#rrrr#yy#rrrr#.",
            "..#rrrrrrrrrr#..",
            "..#rroooooorrr#.",
            "...#oooooooo#...",
            "...#rrrrrrrr#...",
            "....#rr##rr#....",
            "...##......##...",
            "................",
            "................",
        ]),
        s(dragonPalette, [
            "................",
            "..#..........#..",
            ".##..........##.",
            ".##############.",
            "#rrrrrrrrrrrrrr#",
            "#r####rrrr####r#",
            "#rrrr######rrrr#",
            ".#rrrr#yy#rrrr#.",
            "..#rrrrrrrrrr#..",
            "..#rroooooorrr#.",
            "...#oooooooo#...",
            "...#rrrrrrrr#...",
            "....#rr##rr#....",
            "...##......##...",
            "................",
            "................",
        ]),
    ]

    private static let dragonStage3: [PixelSprite] = [
        s(dragonPalette, [
            "..#..........#..",
            ".##..........##.",
            ".##############.",
            "#rrrrrrrrrrrrrr#",
            "#rww##rrrr##wwr#",
            "#rrrr######rrrr#",
            ".#rrrr#yy#rrrr#.",
            "..#rrrrrrrrrr#..",
            "..#rroooooorr#..",
            "..#roooooooor#..",
            "...#oooooooo#...",
            "...#rrrrrrrr#...",
            "....#rr##rr#....",
            "...##......##...",
            "................",
            "................",
        ]),
        s(dragonPalette, [
            "..#..........#..",
            ".##..........##.",
            ".##############.",
            "#rrrrrrrrrrrrrr#",
            "#r####rrrr####r#",
            "#rrrr######rrrr#",
            ".#rrrr#yy#rrrr#.",
            "..#rrrrrrrrrr#..",
            "..#rroooooorr#..",
            "..#roooooooor#..",
            "...#oooooooo#...",
            "...#rrrrrrrr#...",
            "....#rr##rr#....",
            "...##......##...",
            "................",
            "................",
        ]),
    ]

    // MARK: - Wolf

    private static let wolfPalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "g": .gray, "d": .darkGray, "w": .white,
    ]

    private static func wolfFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage {
        case .stage1: return wolfStage1
        case .stage2: return wolfStage2
        case .stage3: return wolfStage3
        }
    }

    private static let wolfStage1: [PixelSprite] = [
        s(wolfPalette, [
            "................",
            "................",
            "................",
            "....#......#....",
            "...#g#....#g#...",
            "...#gg####gg#...",
            "..#gggggggggg#..",
            "..#gd##gg##dg#..",
            "..#ggg#ww#ggg#..",
            "..#ggwwwwwwgg#..",
            "...#gggggggg#...",
            "....#gg##gg#....",
            "...##......##...",
            "................",
            "................",
            "................",
        ]),
        s(wolfPalette, [
            "................",
            "................",
            "................",
            "....#......#....",
            "...#g#....#g#...",
            "...#gg####gg#...",
            "..#gggggggggg#..",
            "..#g##gggg##g#..",
            "..#ggg#ww#ggg#..",
            "..#ggwwwwwwgg#..",
            "...#gggggggg#...",
            "....#gg##gg#....",
            "...##......##...",
            "................",
            "................",
            "................",
        ]),
    ]

    private static let wolfStage2: [PixelSprite] = [
        s(wolfPalette, [
            "................",
            "...#........#...",
            "..#g#......#g#..",
            ".#ggg######ggg#.",
            ".#gggggggggggg#.",
            "#gdd##gggg##ddg#",
            "#gggg#wwww#gggg#",
            "#gggwwwwwwwwggg#",
            ".#gggggggggggg#.",
            ".#gggggggggggg#.",
            "..#gggggggggg#..",
            "...#ggg##ggg#...",
            "..##........##..",
            "................",
            "................",
            "................",
        ]),
        s(wolfPalette, [
            "................",
            "...#........#...",
            "..#g#......#g#..",
            ".#ggg######ggg#.",
            ".#gggggggggggg#.",
            "#g####gggg####g#",
            "#gggg#wwww#gggg#",
            "#gggwwwwwwwwggg#",
            ".#gggggggggggg#.",
            ".#gggggggggggg#.",
            "..#gggggggggg#..",
            "...#ggg##ggg#...",
            "..##........##..",
            "................",
            "................",
            "................",
        ]),
    ]

    private static let wolfStage3: [PixelSprite] = [
        s(wolfPalette, [
            "...#........#...",
            "..#g#......#g#..",
            ".#ggg######ggg#.",
            "#gggggggggggggg#",
            "#gdd##gggg##ddg#",
            "#gggg#wwww#gggg#",
            "#gggwwwwwwwwggg#",
            ".#gggggggggggg#.",
            ".#gggggggggggg#.",
            "..#gggggggggg#..",
            "..#gggggggggg#..",
            "...#ggg##ggg#...",
            "..##........##..",
            "................",
            "................",
            "................",
        ]),
        s(wolfPalette, [
            "...#........#...",
            "..#g#......#g#..",
            ".#ggg######ggg#.",
            "#gggggggggggggg#",
            "#g####gggg####g#",
            "#gggg#wwww#gggg#",
            "#gggwwwwwwwwggg#",
            ".#gggggggggggg#.",
            ".#gggggggggggg#.",
            "..#gggggggggg#..",
            "..#gggggggggg#..",
            "...#ggg##ggg#...",
            "..##........##..",
            "................",
            "................",
            "................",
        ]),
    ]

    // MARK: - Octopus

    private static let octopusPalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "p": .purple, "l": .lavender, "w": .white,
    ]

    private static func octopusFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage {
        case .stage1: return octopusStage1
        case .stage2: return octopusStage2
        case .stage3: return octopusStage3
        }
    }

    private static let octopusStage1: [PixelSprite] = [
        s(octopusPalette, [
            "................",
            "................",
            "................",
            "......####......",
            ".....#pppp#.....",
            "....#pppppp#....",
            "....#pw##wp#....",
            "....#pppppp#....",
            "....##pppp##....",
            "...#p.#pp#.p#...",
            "...#p.####.p#...",
            "....#.#..#.#....",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(octopusPalette, [
            "................",
            "................",
            "................",
            "......####......",
            ".....#pppp#.....",
            "....#pppppp#....",
            "....#p####p#....",
            "....#pppppp#....",
            "....##pppp##....",
            "...#p.#pp#.p#...",
            "...#p.####.p#...",
            "....#.#..#.#....",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]

    private static let octopusStage2: [PixelSprite] = [
        s(octopusPalette, [
            "................",
            "....########....",
            "...#pppppppp#...",
            "..#pppppppppp#..",
            "..#ppw####wpp#..",
            "..#pppppppppp#..",
            "..#pp####pppp#..",
            "...##pppppp##...",
            "...#p.#pp#.p#...",
            "..#p..####..p#..",
            "..#...#..#...#..",
            "...#..#..#..#...",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(octopusPalette, [
            "................",
            "....########....",
            "...#pppppppp#...",
            "..#pppppppppp#..",
            "..#pp######pp#..",
            "..#pppppppppp#..",
            "..#pp####pppp#..",
            "...##pppppp##...",
            "...#p.#pp#.p#...",
            "..#p..####..p#..",
            "..#...#..#...#..",
            "...#..#..#..#...",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]

    private static let octopusStage3: [PixelSprite] = [
        s(octopusPalette, [
            "....########....",
            "...#pppppppp#...",
            "..#pppppppppp#..",
            ".#pppppppppppp#.",
            ".#pplw####wlpp#.",
            ".#pppppppppppp#.",
            ".#pppp####pppp#.",
            "..##pppppppp##..",
            "..#p.#pppp#.p#..",
            ".#p..#.pp.#..p#.",
            ".#...#....#...#.",
            "..#..#....#..#..",
            "...#.#....#.#...",
            "....##....##....",
            "................",
            "................",
        ]),
        s(octopusPalette, [
            "....########....",
            "...#pppppppp#...",
            "..#pppppppppp#..",
            ".#pppppppppppp#.",
            ".#pp########pp#.",
            ".#pppppppppppp#.",
            ".#pppp####pppp#.",
            "..##pppppppp##..",
            "..#p.#pppp#.p#..",
            ".#p..#.pp.#..p#.",
            ".#...#....#...#.",
            "..#..#....#..#..",
            "...#.#....#.#...",
            "....##....##....",
            "................",
            "................",
        ]),
    ]

    // MARK: - Robot

    private static let robotPalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "m": .lightGray, "b": .blue,
        "r": .red, "y": .yellow, "w": .white,
    ]

    private static func robotFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage {
        case .stage1: return robotStage1
        case .stage2: return robotStage2
        case .stage3: return robotStage3
        }
    }

    private static let robotStage1: [PixelSprite] = [
        s(robotPalette, [
            "................",
            "................",
            "................",
            ".......##.......",
            "......#mm#......",
            ".....########...",
            "....#mmmmmmmm#..",
            "....#mb###bm#...",
            "....#mmmmmmmm#..",
            "....#m#y###m#...",
            "....#mmmmmmmm#..",
            ".....########...",
            "....#m#....#m#..",
            "................",
            "................",
            "................",
        ]),
        s(robotPalette, [
            "................",
            "................",
            "................",
            ".......##.......",
            "......#mm#......",
            ".....########...",
            "....#mmmmmmmm#..",
            "....#m#####m#...",
            "....#mmmmmmmm#..",
            "....#m#y###m#...",
            "....#mmmmmmmm#..",
            ".....########...",
            "....#m#....#m#..",
            "................",
            "................",
            "................",
        ]),
    ]

    private static let robotStage2: [PixelSprite] = [
        s(robotPalette, [
            "................",
            "........##......",
            ".......#mm#.....",
            "....##########..",
            "...#mmmmmmmmmm#.",
            "...#mb####bmmm#.",
            "...#mmmmmmmmmm#.",
            "...#mm#yyy#mmm#.",
            "...#mmmmmmmmmm#.",
            "....##########..",
            "..#m#........#m#",
            "..#mm#......#mm#",
            "...#m#......#m#.",
            "................",
            "................",
            "................",
        ]),
        s(robotPalette, [
            "................",
            "........##......",
            ".......#mm#.....",
            "....##########..",
            "...#mmmmmmmmmm#.",
            "...#m########m#.",
            "...#mmmmmmmmmm#.",
            "...#mm#yyy#mmm#.",
            "...#mmmmmmmmmm#.",
            "....##########..",
            "..#m#........#m#",
            "..#mm#......#mm#",
            "...#m#......#m#.",
            "................",
            "................",
            "................",
        ]),
    ]

    private static let robotStage3: [PixelSprite] = [
        s(robotPalette, [
            "........##......",
            ".......#mm#.....",
            "...############.",
            "..#mmmmmmmmmmmm#",
            "..#mb####r#bmmm#",
            "..#mmmmmmmmmmmm#",
            "..#mmm#yyy#mmmm#",
            "..#mmmmmmmmmmmm#",
            "...############.",
            ".#m#..........#m",
            ".#mm#........#mm",
            ".#mmm#......#mmm",
            "..#m#........#m.",
            "................",
            "................",
            "................",
        ]),
        s(robotPalette, [
            "........##......",
            ".......#mm#.....",
            "...############.",
            "..#mmmmmmmmmmmm#",
            "..#m##########m#",
            "..#mmmmmmmmmmmm#",
            "..#mmm#yyy#mmmm#",
            "..#mmmmmmmmmmmm#",
            "...############.",
            ".#m#..........#m",
            ".#mm#........#mm",
            ".#mmm#......#mmm",
            "..#m#........#m.",
            "................",
            "................",
            "................",
        ]),
    ]

    // MARK: - Jellyfish

    private static let jellyfishPalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "b": .blue, "l": .lavender,
        "p": .pink, "w": .white,
    ]

    private static func jellyfishFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage {
        case .stage1: return jellyfishStage1
        case .stage2: return jellyfishStage2
        case .stage3: return jellyfishStage3
        }
    }

    private static let jellyfishStage1: [PixelSprite] = [
        s(jellyfishPalette, [
            "................",
            "................",
            "................",
            "......####......",
            "....##llll##....",
            "...#llllllll#...",
            "...#lw##llll#...",
            "...#llllllll#...",
            "...#llllllll#...",
            "....########....",
            "....#l.ll.l#....",
            "....#......#....",
            "....#l.ll.l#....",
            "................",
            "................",
            "................",
        ]),
        s(jellyfishPalette, [
            "................",
            "................",
            "................",
            "......####......",
            "....##llll##....",
            "...#llllllll#...",
            "...#l####lll#...",
            "...#llllllll#...",
            "...#llllllll#...",
            "....########....",
            "....#..ll..#....",
            "....#l.ll.l#....",
            "....#......#....",
            "................",
            "................",
            "................",
        ]),
    ]

    private static let jellyfishStage2: [PixelSprite] = [
        s(jellyfishPalette, [
            "................",
            ".....########...",
            "...##llllllll##.",
            "..#llllllllllll#",
            "..#llw####wllll#",
            "..#llllllllllll#",
            "..#lllllllllll#.",
            "...#llllllllll#.",
            "....##########..",
            "....#l.llll.l#..",
            "....#ll....ll#..",
            "....#l.llll.l#..",
            "....#ll....ll#..",
            "................",
            "................",
            "................",
        ]),
        s(jellyfishPalette, [
            "................",
            ".....########...",
            "...##llllllll##.",
            "..#llllllllllll#",
            "..#ll########ll#",
            "..#llllllllllll#",
            "..#lllllllllll#.",
            "...#llllllllll#.",
            "....##########..",
            "....#..llll..#..",
            "....#l.llll.l#..",
            "....#ll....ll#..",
            "....#l.llll.l#..",
            "................",
            "................",
            "................",
        ]),
    ]

    private static let jellyfishStage3: [PixelSprite] = [
        s(jellyfishPalette, [
            "....##########..",
            "..##llllllllll##",
            ".#llllllllllllll",
            "#lllllllllllllll",
            "#llllw####wlllll",
            "#lllllllllllllll",
            "#llllllllllllll#",
            ".#lllllllllllll#",
            "..##############",
            "...#ll.llll.ll#.",
            "...#lll....lll#.",
            "...#ll.llll.ll#.",
            "...#lll....lll#.",
            "....###....###..",
            "................",
            "................",
        ]),
        s(jellyfishPalette, [
            "....##########..",
            "..##llllllllll##",
            ".#llllllllllllll",
            "#lllllllllllllll",
            "#llll########lll",
            "#lllllllllllllll",
            "#llllllllllllll#",
            ".#lllllllllllll#",
            "..##############",
            "...#...llll...#.",
            "...#ll.llll.ll#.",
            "...#lll....lll#.",
            "...#ll.llll.ll#.",
            "....###....###..",
            "................",
            "................",
        ]),
    ]

    // MARK: - Cloud

    private static let cloudPalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "w": .white, "l": .lightGray, "b": .blue,
    ]

    private static func cloudFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage {
        case .stage1: return cloudStage1
        case .stage2: return cloudStage2
        case .stage3: return cloudStage3
        }
    }

    private static let cloudStage1: [PixelSprite] = [
        s(cloudPalette, [
            "................",
            "................",
            "................",
            "....####........",
            "...#wwww#####...",
            "..#wwwwwwwwww#..",
            "..#ww##wwwwww#..",
            "..#wwwwwwwwww#..",
            "..#wwb.b.wwww#..",
            "..#wwwwwwwwww#..",
            "...####wwww###..",
            "....#llllll#....",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(cloudPalette, [
            "................",
            "................",
            "................",
            "....####........",
            "...#wwww#####...",
            "..#wwwwwwwwww#..",
            "..#w####wwwww#..",
            "..#wwwwwwwwww#..",
            "..#wwb.b.wwww#..",
            "..#wwwwwwwwww#..",
            "...####wwww###..",
            "....#llllll#....",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]

    private static let cloudStage2: [PixelSprite] = [
        s(cloudPalette, [
            "................",
            "...####.........",
            "..#wwww######...",
            ".#wwwwwwwwwwww#.",
            ".#wwwwwwwwwwww#.",
            "#wwww##ww##wwww#",
            "#wwwwwwwwwwwwww#",
            "#wwwb..b..bwwww#",
            "#wwwwwwwwwwwwww#",
            ".#wwww####wwww#.",
            ".#wwwwwwwwwwww#.",
            "..####wwwwww###.",
            "...#llllllll#...",
            "................",
            "................",
            "................",
        ]),
        s(cloudPalette, [
            "................",
            "...####.........",
            "..#wwww######...",
            ".#wwwwwwwwwwww#.",
            ".#wwwwwwwwwwww#.",
            "#w####ww######w#",
            "#wwwwwwwwwwwwww#",
            "#wwwb..b..bwwww#",
            "#wwwwwwwwwwwwww#",
            ".#wwww####wwww#.",
            ".#wwwwwwwwwwww#.",
            "..####wwwwww###.",
            "...#llllllll#...",
            "................",
            "................",
            "................",
        ]),
    ]

    private static let cloudStage3: [PixelSprite] = [
        s(cloudPalette, [
            "..####..........",
            ".#wwww#######...",
            "#wwwwwwwwwwwww#.",
            "#wwwwwwwwwwwwww#",
            "#wwww##ww##wwww#",
            "#wwwwwwwwwwwwww#",
            "#wwwb..b..bwwww#",
            "#wwwwwwwwwwwwww#",
            ".#wwwwwwwwwwww#.",
            ".#wwwwwwwwwwww#.",
            "..####wwwwww###.",
            "...#llllllllll#.",
            "....##########..",
            "................",
            "................",
            "................",
        ]),
        s(cloudPalette, [
            "..####..........",
            ".#wwww#######...",
            "#wwwwwwwwwwwww#.",
            "#wwwwwwwwwwwwww#",
            "#w####ww######w#",
            "#wwwwwwwwwwwwww#",
            "#wwwb..b..bwwww#",
            "#wwwwwwwwwwwwww#",
            ".#wwwwwwwwwwww#.",
            ".#wwwwwwwwwwww#.",
            "..####wwwwww###.",
            "...#llllllllll#.",
            "....##########..",
            "................",
            "................",
            "................",
        ]),
    ]

    // MARK: - Fox

    private static let foxPalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "o": .ginger, "w": .white,
        "b": .brown, "p": .pink,
    ]

    private static func foxFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage {
        case .stage1: return foxStage1
        case .stage2: return foxStage2
        case .stage3: return foxStage3
        }
    }

    private static let foxStage1: [PixelSprite] = [
        s(foxPalette, [
            "................",
            "................",
            "................",
            "....#......#....",
            "...#o#....#o#...",
            "...#oo####oo#...",
            "..#oooooooooo#..",
            "..#ob##oo##bo#..",
            "..#ooo#pp#ooo#..",
            "..#oowwwwwwoo#..",
            "...#oooooooo#...",
            "....#oo##oo#....",
            "...##..ww..##...",
            "................",
            "................",
            "................",
        ]),
        s(foxPalette, [
            "................",
            "................",
            "................",
            "....#......#....",
            "...#o#....#o#...",
            "...#oo####oo#...",
            "..#oooooooooo#..",
            "..#o##oooo##o#..",
            "..#ooo#pp#ooo#..",
            "..#oowwwwwwoo#..",
            "...#oooooooo#...",
            "....#oo##oo#....",
            "...##..ww..##...",
            "................",
            "................",
            "................",
        ]),
    ]

    private static let foxStage2: [PixelSprite] = [
        s(foxPalette, [
            "................",
            "...#........#...",
            "..#o#......#o#..",
            ".#ooo######ooo#.",
            ".#oooooooooooo#.",
            "#obb##oooo##bbo#",
            "#oooo#wwww#oooo#",
            "#ooowwwwwwwwoooo",
            ".#oooooooooooo#.",
            ".#oowwwwwwwwoo#.",
            "..#owwwwwwwwo#..",
            "..#oooooooooo#..",
            "...#ooo##ooo#...",
            "..##...ww...##..",
            "................",
            "................",
        ]),
        s(foxPalette, [
            "................",
            "...#........#...",
            "..#o#......#o#..",
            ".#ooo######ooo#.",
            ".#oooooooooooo#.",
            "#o####oooo####o#",
            "#oooo#wwww#oooo#",
            "#ooowwwwwwwwoooo",
            ".#oooooooooooo#.",
            ".#oowwwwwwwwoo#.",
            "..#owwwwwwwwo#..",
            "..#oooooooooo#..",
            "...#ooo##ooo#...",
            "..##...ww...##..",
            "................",
            "................",
        ]),
    ]

    private static let foxStage3: [PixelSprite] = [
        s(foxPalette, [
            "...#........#...",
            "..#o#......#o#..",
            ".#ooo######ooo#.",
            "#oooooooooooooo#",
            "#obb##oooo##bbo#",
            "#oooo#wwww#oooo#",
            "#ooowwwwwwwwoooo",
            ".#oooooooooooo#.",
            ".#oowwwwwwwwoo#.",
            "..#owwwwwwwwo#..",
            "..#oooooooooo#..",
            "..#oooooooooo#..",
            "...#ooo##ooo#...",
            "..##...ww...##..",
            "................",
            "................",
        ]),
        s(foxPalette, [
            "...#........#...",
            "..#o#......#o#..",
            ".#ooo######ooo#.",
            "#oooooooooooooo#",
            "#o####oooo####o#",
            "#oooo#wwww#oooo#",
            "#ooowwwwwwwwoooo",
            ".#oooooooooooo#.",
            ".#oowwwwwwwwoo#.",
            "..#owwwwwwwwo#..",
            "..#oooooooooo#..",
            "..#oooooooooo#..",
            "...#ooo##ooo#...",
            "..##...ww...##..",
            "................",
            "................",
        ]),
    ]

    // MARK: - Mushroom

    private static let mushroomPalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "r": .red, "w": .white, "t": .tan,
    ]

    private static func mushroomFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage {
        case .stage1: return mushroomStage1
        case .stage2: return mushroomStage2
        case .stage3: return mushroomStage3
        }
    }

    private static let mushroomStage1: [PixelSprite] = [
        s(mushroomPalette, [
            "................",
            "................",
            "................",
            ".....######.....",
            "....#rrrrrr#....",
            "...#rrrwwrrr#...",
            "...#rrrrrrrr#...",
            "..#rrrwwwwrrr#..",
            "..#rrrrrrrrrr#..",
            "...#rr#ww#rr#...",
            "....#wwwwww#....",
            "....#w####w#....",
            ".....######.....",
            "................",
            "................",
            "................",
        ]),
        s(mushroomPalette, [
            "................",
            "................",
            "................",
            ".....######.....",
            "....#rrrrrr#....",
            "...#rrrwwrrr#...",
            "...#rrrrrrrr#...",
            "..#rrrwwwwrrr#..",
            "..#rrrrrrrrrr#..",
            "...#r##ww##r#...",
            "....#wwwwww#....",
            "....#w####w#....",
            ".....######.....",
            "................",
            "................",
            "................",
        ]),
    ]

    private static let mushroomStage2: [PixelSprite] = [
        s(mushroomPalette, [
            "................",
            "....########....",
            "...#rrrrrrrr#...",
            "..#rrrwwwwrrrr#.",
            "..#rrrrrrrrrrr#.",
            ".#rrrwwwwwwrrr#.",
            ".#rrrrrrrrrrrr#.",
            "..#rr#wwww#rr#..",
            "...#wwwwwwwww#..",
            "...#ww######w#..",
            "...#wwwwwwwww#..",
            "....#w######w#..",
            ".....########...",
            "................",
            "................",
            "................",
        ]),
        s(mushroomPalette, [
            "................",
            "....########....",
            "...#rrrrrrrr#...",
            "..#rrrwwwwrrrr#.",
            "..#rrrrrrrrrrr#.",
            ".#rrrwwwwwwrrr#.",
            ".#rrrrrrrrrrrr#.",
            "..#r###wwww##r#.",
            "...#wwwwwwwww#..",
            "...#ww######w#..",
            "...#wwwwwwwww#..",
            "....#w######w#..",
            ".....########...",
            "................",
            "................",
            "................",
        ]),
    ]

    private static let mushroomStage3: [PixelSprite] = [
        s(mushroomPalette, [
            "...##########...",
            "..#rrrrrrrrrr#..",
            ".#rrrrwwwwrrrr#.",
            "#rrrrrrrrrrrrrr#",
            "#rrrwwwwwwwwrrr#",
            "#rrrrrrrrrrrrrr#",
            ".#rr#wwwwww#rr#.",
            "..#wwwwwwwwwww#.",
            "..#ww##wwww##w#.",
            "..#wwwwwwwwwww#.",
            "..#ww########w#.",
            "..#wwwwwwwwwww#.",
            "...#w##wwww##w#.",
            "....###wwww###..",
            "................",
            "................",
        ]),
        s(mushroomPalette, [
            "...##########...",
            "..#rrrrrrrrrr#..",
            ".#rrrrwwwwrrrr#.",
            "#rrrrrrrrrrrrrr#",
            "#rrr########rrr#",
            "#rrrrrrrrrrrrrr#",
            ".#r####wwww####.",
            "..#wwwwwwwwwww#.",
            "..#ww##wwww##w#.",
            "..#wwwwwwwwwww#.",
            "..#ww########w#.",
            "..#wwwwwwwwwww#.",
            "...#w##wwww##w#.",
            "....###wwww###..",
            "................",
            "................",
        ]),
    ]

    // MARK: - Penguin

    private static let penguinPalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "w": .white, "o": .orange, "b": .blue,
    ]

    private static func penguinFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage {
        case .stage1: return penguinStage1
        case .stage2: return penguinStage2
        case .stage3: return penguinStage3
        }
    }

    private static let penguinStage1: [PixelSprite] = [
        s(penguinPalette, [
            "................",
            "................",
            "................",
            "......####......",
            ".....#####......",
            "....########....",
            "...##ww##ww##...",
            "...#wwwwwwww#...",
            "...#w##oo##w#...",
            "...#wwwwwwww#...",
            "....########....",
            "....#o#..#o#....",
            "...##........##.",
            "................",
            "................",
            "................",
        ]),
        s(penguinPalette, [
            "................",
            "................",
            "................",
            "......####......",
            ".....#####......",
            "....########....",
            "...##ww##ww##...",
            "...#wwwwwwww#...",
            "...#w####w##w...",
            "...#wwwwwwww#...",
            "....########....",
            "....#o#..#o#....",
            "...##........##.",
            "................",
            "................",
            "................",
        ]),
    ]

    private static let penguinStage2: [PixelSprite] = [
        s(penguinPalette, [
            "................",
            ".....######.....",
            "....########....",
            "...##########...",
            "..##ww####ww##..",
            "..#wwwwwwwwww#..",
            "..#ww##oo##ww#..",
            "..#wwwwwwwwww#..",
            "..#wwwwwwwwww#..",
            "...##########...",
            "...#oo#..#oo#...",
            "..##..........##",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(penguinPalette, [
            "................",
            ".....######.....",
            "....########....",
            "...##########...",
            "..##ww####ww##..",
            "..#wwwwwwwwww#..",
            "..#w########w...",
            "..#wwwwwwwwww#..",
            "..#wwwwwwwwww#..",
            "...##########...",
            "...#oo#..#oo#...",
            "..##..........##",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]

    private static let penguinStage3: [PixelSprite] = [
        s(penguinPalette, [
            "......######....",
            ".....########...",
            "....##########..",
            "..###ww####ww###",
            "..#wwwwwwwwwwww#",
            "..#ww##oooo##ww#",
            "..#wwwwwwwwwwww#",
            "..#wwwwwwwwwwww#",
            "..#wwwwwwwwwwww#",
            "...############.",
            "...#ooo#..#ooo#.",
            "..##............",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(penguinPalette, [
            "......######....",
            ".....########...",
            "....##########..",
            "..###ww####ww###",
            "..#wwwwwwwwwwww#",
            "..#w############",
            "..#wwwwwwwwwwww#",
            "..#wwwwwwwwwwww#",
            "..#wwwwwwwwwwww#",
            "...############.",
            "...#ooo#..#ooo#.",
            "..##............",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]

    // MARK: - Rock

    private static let rockPalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "g": .gray, "l": .lightGray, "d": .darkGray,
    ]

    private static func rockFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage {
        case .stage1: return rockStage1
        case .stage2: return rockStage2
        case .stage3: return rockStage3
        }
    }

    private static let rockStage1: [PixelSprite] = [
        s(rockPalette, [
            "................",
            "................",
            "................",
            "................",
            "......####......",
            "....##gggg##....",
            "...#gglggggg#...",
            "...#gggggggg#...",
            "...#ggg##ggg#...",
            "...#gggggggg#...",
            "....########....",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(rockPalette, [
            "................",
            "................",
            "................",
            "................",
            "......####......",
            "....##gggg##....",
            "...#gglggggg#...",
            "...#gggggggg#...",
            "...#g##g##gg#...",
            "...#gggggggg#...",
            "....########....",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]

    private static let rockStage2: [PixelSprite] = [
        s(rockPalette, [
            "................",
            "................",
            ".....########...",
            "...##gggggggg##.",
            "..#gglggggggggg#",
            "..#ggggggggggg#.",
            "..#ggggg##gggg#.",
            "..#gggggggggg#..",
            "..#ggggggggggg#.",
            "..#gggggggggg#..",
            "...############.",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(rockPalette, [
            "................",
            "................",
            ".....########...",
            "...##gggggggg##.",
            "..#gglggggggggg#",
            "..#ggggggggggg#.",
            "..#gg###g###gg#.",
            "..#gggggggggg#..",
            "..#ggggggggggg#.",
            "..#gggggggggg#..",
            "...############.",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]

    private static let rockStage3: [PixelSprite] = [
        s(rockPalette, [
            "................",
            "....##########..",
            "..##gggggggggg##",
            ".#gglgggggggggg#",
            ".#ggggggggggggd#",
            "#ggggggggggggggg",
            "#gggggg##ggggggg",
            "#ggggggggggggggg",
            "#ggggggggggggggg",
            ".#ggggggggggggg#",
            "..#############.",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(rockPalette, [
            "................",
            "....##########..",
            "..##gggggggggg##",
            ".#gglgggggggggg#",
            ".#ggggggggggggd#",
            "#ggggggggggggggg",
            "#ggg####g####ggg",
            "#ggggggggggggggg",
            "#ggggggggggggggg",
            ".#ggggggggggggg#",
            "..#############.",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]

    // MARK: - Cactus

    private static let cactusPalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "g": .green, "d": .darkGreen, "y": .yellow,
    ]

    private static func cactusFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage {
        case .stage1: return cactusStage1
        case .stage2: return cactusStage2
        case .stage3: return cactusStage3
        }
    }

    private static let cactusStage1: [PixelSprite] = [
        s(cactusPalette, [
            "................",
            "................",
            "................",
            "......####......",
            ".....#gggg#.....",
            "....#gggggg#....",
            "#...#gg##gg#....",
            "##..#gggggg#....",
            ".#..#gggggg#....",
            ".###########....",
            "....#gggggg#....",
            "....#gg##gg#....",
            "....#g####g#....",
            "....########....",
            "................",
            "................",
        ]),
        s(cactusPalette, [
            "................",
            "................",
            "................",
            "......####......",
            ".....#gggg#.....",
            "....#gggggg#....",
            "....#gg##gg#...#",
            "....#gggggg#..##",
            "....#gggggg#..#.",
            "....###########.",
            "....#gggggg#....",
            "....#gg##gg#....",
            "....#g####g#....",
            "....########....",
            "................",
            "................",
        ]),
    ]

    private static let cactusStage2: [PixelSprite] = [
        s(cactusPalette, [
            "................",
            ".......#####....",
            "......#ggggg#...",
            "##...#ggggggg#..",
            "##...#gg###gg#..",
            ".####ggggggggg#.",
            "....#ggggggggg#.",
            "....#gg#####gg#.",
            "....#ggggggggg#.",
            "....#ggggggggg#.",
            "....#ggggggggg#.",
            "....#gg#####gg#.",
            "....#g#######g#.",
            ".....#########..",
            "................",
            "................",
        ]),
        s(cactusPalette, [
            "................",
            ".......#####....",
            "......#ggggg#...",
            "......#gg###gg#.",
            ".....#ggggggggg#",
            ".....#gggg##ggg#",
            ".....#ggggggggg#",
            "..##.#gg#####gg#",
            "..##.#ggggggggg#",
            "..###ggggggggg#.",
            "....#ggggggggg#.",
            "....#gg#####gg#.",
            "....#g#######g#.",
            ".....#########..",
            "................",
            "................",
        ]),
    ]

    private static let cactusStage3: [PixelSprite] = [
        s(cactusPalette, [
            "........#####...",
            ".......#ggggg#..",
            "###...#ggggggg#.",
            "###..#ggg###ggg#",
            ".####ggggggggggg",
            "....#ggggggggggg",
            "....#ggggg#ggggg",
            "....#ggggggggggg",
            "....#gg#######gg",
            "....#ggggggggggg",
            "....#ggggggggggg",
            "....#gg#######gg",
            "....#g#########g",
            ".....###########",
            "................",
            "................",
        ]),
        s(cactusPalette, [
            "........#####...",
            ".......#ggggg#..",
            "......#ggggggg#.",
            "......#ggg###ggg",
            ".....#gggggggggg",
            "####.#ggggggggg#",
            "####.#ggggg#gggg",
            ".#####ggggggggg#",
            "....#gg#######gg",
            "....#ggggggggggg",
            "....#ggggggggggg",
            "....#gg#######gg",
            "....#g#########g",
            ".....###########",
            "................",
            "................",
        ]),
    ]

    // MARK: - Parrot

    private static let parrotPalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "g": .green, "r": .red,
        "y": .yellow, "w": .white, "b": .blue,
    ]

    private static func parrotFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage {
        case .stage1: return parrotStage1
        case .stage2: return parrotStage2
        case .stage3: return parrotStage3
        }
    }

    private static let parrotStage1: [PixelSprite] = [
        s(parrotPalette, [
            "................",
            "................",
            "................",
            ".....#######....",
            "....#rrrrrrr#...",
            "...#gggrrrrr##..",
            "...#ggggggggg#..",
            "...#gw##gg##wg#.",
            "...#ggg#yy#ggg#.",
            "...#ggggggggg#..",
            "....#########...",
            "....#gg...gg#...",
            "....#g#...#g#...",
            "................",
            "................",
            "................",
        ]),
        s(parrotPalette, [
            "................",
            "................",
            "................",
            ".....#######....",
            "....#rrrrrrr#...",
            "...#gggrrrrr##..",
            "...#ggggggggg#..",
            "...#g##ggg##g#..",
            "...#ggg#yy#ggg#.",
            "...#ggggggggg#..",
            "....#########...",
            "....#gg...gg#...",
            "....#g#...#g#...",
            "................",
            "................",
            "................",
        ]),
    ]

    private static let parrotStage2: [PixelSprite] = [
        s(parrotPalette, [
            "................",
            "....#########...",
            "...#rrrrrrrrr#..",
            "..#gggrrrrrrr##.",
            "..#gggggggggggg#",
            "..#gw####gggggg#",
            "..#gggggggggggg#",
            "..#ggg#yyyg#ggg#",
            "..#gggggggggggg#",
            "...#############",
            "....#ggg...ggg#.",
            "....#gg.....gg#.",
            "....#g#.....#g#.",
            "................",
            "................",
            "................",
        ]),
        s(parrotPalette, [
            "................",
            "....#########...",
            "...#rrrrrrrrr#..",
            "..#gggrrrrrrr##.",
            "..#gggggggggggg#",
            "..#g##########g#",
            "..#gggggggggggg#",
            "..#ggg#yyyg#ggg#",
            "..#gggggggggggg#",
            "...#############",
            "....#ggg...ggg#.",
            "....#gg.....gg#.",
            "....#g#.....#g#.",
            "................",
            "................",
            "................",
        ]),
    ]

    private static let parrotStage3: [PixelSprite] = [
        s(parrotPalette, [
            "...#############",
            "..#rrrrrrrrrrrrr",
            ".#gggrrrrrrrrrrr",
            "#ggggggggggggggg",
            "#gw####ggggggggr",
            "#gggggggggggggg#",
            "#ggggg#yyy#ggggg",
            "#gggggggggggggg#",
            "#gggggggggggggg#",
            ".##############.",
            "...#ggggg#ggggg.",
            "...#gggg...gggg.",
            "...#ggg.....ggg.",
            "...#g#.......#g.",
            "................",
            "................",
        ]),
        s(parrotPalette, [
            "...#############",
            "..#rrrrrrrrrrrrr",
            ".#gggrrrrrrrrrrr",
            "#ggggggggggggggg",
            "#g#############r",
            "#gggggggggggggg#",
            "#ggggg#yyy#ggggg",
            "#gggggggggggggg#",
            "#gggggggggggggg#",
            ".##############.",
            "...#ggggg#ggggg.",
            "...#gggg...gggg.",
            "...#ggg.....ggg.",
            "...#g#.......#g.",
            "................",
            "................",
        ]),
    ]

    // MARK: - Puppy

    private static let puppyPalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "t": .tan, "w": .white,
        "b": .brown, "p": .pink,
    ]

    private static func puppyFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage {
        case .stage1: return puppyStage1
        case .stage2: return puppyStage2
        case .stage3: return puppyStage3
        }
    }

    private static let puppyStage1: [PixelSprite] = [
        s(puppyPalette, [
            "................",
            "................",
            "................",
            "...##......##...",
            "..#tt#....#tt#..",
            "..#tttt##tttt#..",
            "..#tttttttttt#..",
            "..#tb##tt##bt#..",
            "..#ttt#pp#ttt#..",
            "..#ttwwwwwwtt#..",
            "...#tttttttt#...",
            "....#tt##tt#....",
            "...##......##...",
            "................",
            "................",
            "................",
        ]),
        s(puppyPalette, [
            "................",
            "................",
            "................",
            "...##......##...",
            "..#tt#....#tt#..",
            "..#tttt##tttt#..",
            "..#tttttttttt#..",
            "..#t##tttt##t#..",
            "..#ttt#pp#ttt#..",
            "..#ttwwwwwwtt#..",
            "...#tttttttt#...",
            "....#tt##tt#....",
            "...##......##...",
            "................",
            "................",
            "................",
        ]),
    ]

    private static let puppyStage2: [PixelSprite] = [
        s(puppyPalette, [
            "................",
            "..##........##..",
            ".#tt#......#tt#.",
            ".#tttttt##tttttt",
            ".#tttttttttttt#.",
            "#tbb##tttttt##bb",
            "#ttttt#wwww#tttt",
            "#ttttwwwwwwwwttt",
            ".#tttttttttttt#.",
            ".#ttttttttttt#..",
            "..#tttttttttt#..",
            "...#ttt##ttt#...",
            "..##........##..",
            "................",
            "................",
            "................",
        ]),
        s(puppyPalette, [
            "................",
            "..##........##..",
            ".#tt#......#tt#.",
            ".#tttttt##tttttt",
            ".#tttttttttttt#.",
            "#t####tttttt####",
            "#ttttt#wwww#tttt",
            "#ttttwwwwwwwwttt",
            ".#tttttttttttt#.",
            ".#ttttttttttt#..",
            "..#tttttttttt#..",
            "...#ttt##ttt#...",
            "..##........##..",
            "................",
            "................",
            "................",
        ]),
    ]

    private static let puppyStage3: [PixelSprite] = [
        s(puppyPalette, [
            "...bbbb..bbbb...",
            "..#bbbb##bbbb#..",
            ".#bbttttttttbb#.",
            ".#bbttttttttbb#.",
            "#bbtt#tttt#ttbb#",
            "#ttttt#wwww#tttt",
            "#ttttwwwwwwwwttt",
            ".#tttttttttttt#.",
            ".#tttttttttttt#.",
            "..#tttttttttt#..",
            "..#tttttttttt#..",
            "...#ttt##ttt#...",
            "..##........##..",
            "................",
            "................",
            "................",
        ]),
        s(puppyPalette, [
            "...bbbb..bbbb...",
            "..#bbbb##bbbb#..",
            ".#bbttttttttbb#.",
            ".#bbttttttttbb#.",
            "#bbtt#tttt#ttbb#",
            "#ttttt#wwww#tttt",
            "#ttttwwwwwwwwttt",
            ".#tttttttttttt#.",
            ".#tttttttttttt#.",
            "..#tttttttttt#..",
            "..#tttttttttt#..",
            "...#ttt##ttt#...",
            "..##........##..",
            "................",
            "................",
            "................",
        ]),
    ]

    // MARK: - Flame

    private static let flamePalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "r": .red, "o": .orange, "y": .yellow, "w": .white,
    ]

    private static func flameFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage {
        case .stage1: return flameStage1
        case .stage2: return flameStage2
        case .stage3: return flameStage3
        }
    }

    private static let flameStage1: [PixelSprite] = [
        s(flamePalette, [
            "................",
            "................",
            "......###.......",
            ".....#ooo#......",
            "....#ooooo#.....",
            "...#ooyyyyy#....",
            "..#ooyyyyyy#....",
            "..#ooyywyyyy#...",
            "..#oooyyyyy#....",
            "..#roooooor#....",
            "..#rroooorr#....",
            "...#rrrrrr#.....",
            "....######......",
            "................",
            "................",
            "................",
        ]),
        s(flamePalette, [
            "................",
            ".......###......",
            "......#ooo#.....",
            ".....#ooooo#....",
            "....#ooyyyyy#...",
            "...#ooyyyyyy#...",
            "...#ooyywyyy#...",
            "..#roooooooo#...",
            "..#rroooooor#...",
            "..#rrrooorrr#...",
            "...#rrrrrr#.....",
            "....######......",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]

    private static let flameStage2: [PixelSprite] = [
        s(flamePalette, [
            "................",
            ".....####.......",
            "....#oooo#......",
            "...#ooooooo#....",
            "..#ooyyyyyyy#...",
            "..#ooyyyyyyyy#..",
            "..#ooyywyyyy##..",
            ".#oooyyyyyyy#...",
            ".#ooooyyyyyyy#..",
            ".#roooooooooo#..",
            ".#rroooooooor#..",
            ".#rrrooooorrr#..",
            "..#rrrrrrrrr#...",
            "...#########....",
            "................",
            "................",
        ]),
        s(flamePalette, [
            "................",
            "......####......",
            ".....#oooo#.....",
            "....#ooooooo#...",
            "...#ooyyyyyyy#..",
            "..#ooyyyyyyy##..",
            "..#ooyywyyyyy#..",
            "..#oooyyyyyyy#..",
            ".#roooooooooo#..",
            ".#rroooooooor#..",
            ".#rrrooooorrr#..",
            "..#rrrrrrrrr#...",
            "...#########....",
            "................",
            "................",
            "................",
        ]),
    ]

    private static let flameStage3: [PixelSprite] = [
        s(flamePalette, [
            "....####........",
            "...#oooo#.......",
            "..#oooooooo#....",
            ".#oooyyyyyyy#...",
            ".#ooyyyyyyyy##..",
            "#ooyyyyywyyy#...",
            "#oooyyyyyyy#....",
            "#oooyyyyyyyy#...",
            "#rooooooooooo#..",
            "#rroooooooooor#.",
            ".#rrrooooorrr#..",
            ".#rrrrrrrrrr#...",
            "..#rrrrrrrr#....",
            "...##########...",
            "................",
            "................",
        ]),
        s(flamePalette, [
            ".....####.......",
            "....#oooo#......",
            "...#oooooooo#...",
            "..#oooyyyyyyy#..",
            ".#ooyyyyyyyy##..",
            ".#oyyyyywyyy#...",
            "#oooyyyyyyyy#...",
            "#rooooooooooo#..",
            "#rroooooooooor#.",
            "#rrrooooooorrr#.",
            ".#rrrrrrrrrrr#..",
            "..#rrrrrrrrrr#..",
            "...##########...",
            "................",
            "................",
            "................",
        ]),
    ]

    // MARK: - Bat

    private static let batPalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "d": .darkGray, "p": .purple,
        "w": .white, "r": .red,
    ]

    private static func batFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage {
        case .stage1: return batStage1
        case .stage2: return batStage2
        case .stage3: return batStage3
        }
    }

    private static let batStage1: [PixelSprite] = [
        s(batPalette, [
            "................",
            "................",
            "................",
            "#.....####.....#",
            "##...#dddd#...##",
            ".#...#dddd#...#.",
            ".##.#dddddd#.##.",
            "..##dpddddpd##..",
            "...#dddddddd#...",
            "...#dd#rr#dd#...",
            "...#dddddddd#...",
            "....#dddddd#....",
            ".....######.....",
            "................",
            "................",
            "................",
        ]),
        s(batPalette, [
            "................",
            "................",
            "#.....####.....#",
            "##...#dddd#...##",
            ".##.#dddddd#.##.",
            "..##dpddddpd##..",
            "...#dddddddd#...",
            "...#dd#rr#dd#...",
            "...#dddddddd#...",
            "....#dddddd#....",
            ".....######.....",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]

    private static let batStage2: [PixelSprite] = [
        s(batPalette, [
            "................",
            "#......####....#",
            "##....#dddd#..##",
            ".##..#dddddd#.##",
            "..##.#dddddd#.##",
            "...##dpddddpd##.",
            "...#dddddddddd#.",
            "...#ddd#rr#ddd#.",
            "...#dddddddddd#.",
            "...#dddddddddd#.",
            "....#dddddddd#..",
            "....##dddddd##..",
            ".....########...",
            "................",
            "................",
            "................",
        ]),
        s(batPalette, [
            "#......####....#",
            "##....#dddd#..##",
            ".##..#dddddd#.##",
            "..###dddddddd##.",
            "...##dpddddpd##.",
            "...#dddddddddd#.",
            "...#ddd#rr#ddd#.",
            "...#dddddddddd#.",
            "...#dddddddddd#.",
            "....#dddddddd#..",
            "....##dddddd##..",
            ".....########...",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]

    private static let batStage3: [PixelSprite] = [
        s(batPalette, [
            "#.....######...#",
            "##...#dddddd#.##",
            ".##.#dddddddd###",
            "..##ddddddddddd#",
            "...#dpdddddddpd#",
            "...#dddddddddd#.",
            "...#ddd#rr#ddd#.",
            "...#dddddddddd#.",
            "...#dddddddddd#.",
            "....#dddddddd#..",
            "....#dddddddd#..",
            "....##dddddd##..",
            ".....########...",
            "................",
            "................",
            "................",
        ]),
        s(batPalette, [
            "#.....######...#",
            "##...#dddddd#.##",
            ".##.#dddddddd###",
            "..###ddddddddddd",
            "...#dpdddddddpd#",
            "...#dddddddddd#.",
            "...#d###rr###d#.",
            "...#dddddddddd#.",
            "...#dddddddddd#.",
            "....#dddddddd#..",
            "....#dddddddd#..",
            "....##dddddd##..",
            ".....########...",
            "................",
            "................",
            "................",
        ]),
    ]

    // MARK: - Moon Rabbit

    private static let moonrabbitPalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "w": .white, "l": .lightGray,
        "y": .yellow, "p": .pink, "g": .gold,
    ]

    private static func moonrabbitFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage {
        case .stage1: return moonrabbitStage1
        case .stage2: return moonrabbitStage2
        case .stage3: return moonrabbitStage3
        }
    }

    private static let moonrabbitStage1: [PixelSprite] = [
        s(moonrabbitPalette, [
            "................",
            "....#......#....",
            "....#w....w#....",
            "....#w....w#....",
            "....#w....w#....",
            "...#wwwwwwww#...",
            "...#wl##wwlw#...",
            "...#wwwwwwww#...",
            "...#ww#pp#ww#...",
            "...#wwwwwwww#...",
            "....########....",
            ".....#w..w#.....",
            "......####......",
            "................",
            "................",
            "................",
        ]),
        s(moonrabbitPalette, [
            "................",
            "....#......#....",
            "....#w....w#....",
            "....#w....w#....",
            "....#w....w#....",
            "...#wwwwwwww#...",
            "...#w####www#...",
            "...#wwwwwwww#...",
            "...#ww#pp#ww#...",
            "...#wwwwwwww#...",
            "....########....",
            ".....#w..w#.....",
            "......####......",
            "................",
            "................",
            "................",
        ]),
    ]

    private static let moonrabbitStage2: [PixelSprite] = [
        s(moonrabbitPalette, [
            "................",
            "...#........#...",
            "...#ww......ww#.",
            "...#ww......ww#.",
            "...#ww......ww#.",
            "..#wwwwwwwwwwww#",
            "..#wwl####lwwww#",
            "..#wwwwwwwwwwww#",
            "..#wwww#pp#wwww#",
            "..#wwwwwwwwwwww#",
            "...#############",
            "....#ww....ww#..",
            "....#w######w#..",
            ".....########...",
            "................",
            "................",
        ]),
        s(moonrabbitPalette, [
            "................",
            "...#........#...",
            "...#ww......ww#.",
            "...#ww......ww#.",
            "...#ww......ww#.",
            "..#wwwwwwwwwwww#",
            "..#ww########ww#",
            "..#wwwwwwwwwwww#",
            "..#wwww#pp#wwww#",
            "..#wwwwwwwwwwww#",
            "...#############",
            "....#ww....ww#..",
            "....#w######w#..",
            ".....########...",
            "................",
            "................",
        ]),
    ]

    private static let moonrabbitStage3: [PixelSprite] = [
        s(moonrabbitPalette, [
            "..#..........#..",
            "..#ww........ww#",
            "..#ww........ww#",
            "..#ww........ww#",
            ".#wwwwwwwwwwwwww",
            ".#wwwl####lwwwww",
            ".#wwwwwwwwwwwwww",
            ".#wwwww#pp#wwwww",
            ".#wwwwwwwwwwwwww",
            ".#wwwwwwwwwwwwww",
            "..##############",
            "...#www....www#.",
            "...#wwww##wwww#.",
            "....#w######w#..",
            ".....########...",
            "................",
        ]),
        s(moonrabbitPalette, [
            "..#..........#..",
            "..#ww........ww#",
            "..#ww........ww#",
            "..#ww........ww#",
            ".#wwwwwwwwwwwwww",
            ".#www##########w",
            ".#wwwwwwwwwwwwww",
            ".#wwwww#pp#wwwww",
            ".#wwwwwwwwwwwwww",
            ".#wwwwwwwwwwwwww",
            "..##############",
            "...#www....www#.",
            "...#wwww##wwww#.",
            "....#w######w#..",
            ".....########...",
            "................",
        ]),
    ]

    // MARK: - Crystal

    private static let crystalPalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "c": .teal, "b": .blue, "w": .white, "l": .lightGray,
    ]
    private static func crystalFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage { case .stage1: return crystalStage1; case .stage2: return crystalStage2; case .stage3: return crystalStage3 }
    }
    private static let crystalStage1: [PixelSprite] = [
        s(crystalPalette, [
            "................",
            "................",
            "................",
            ".......#........",
            "......#c#.......",
            ".....#ccc#......",
            "....#cwccc#.....",
            "....#ccccc#.....",
            "...#ccccccc#....",
            "....#ccccc#.....",
            ".....##c##......",
            "......#c#.......",
            ".......#........",
            "................",
            "................",
            "................",
        ]),
        s(crystalPalette, [
            "................",
            "................",
            "................",
            ".......#........",
            "......#c#.......",
            ".....#ccc#......",
            "....#cccwc#.....",
            "....#ccccc#.....",
            "...#ccccccc#....",
            "....#ccccc#.....",
            ".....##c##......",
            "......#c#.......",
            ".......#........",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let crystalStage2: [PixelSprite] = [
        s(crystalPalette, [
            "................",
            "................",
            "......####......",
            ".....#cccc#.....",
            "....#ccwccc#....",
            "....#ccccccc#...",
            "...#ccccccccc#..",
            "...#cclcclccc#..",
            "...#ccccccccc#..",
            "....#ccccccc#...",
            ".....##cccc##...",
            "......#cccc#....",
            ".......####.....",
            "................",
            "................",
            "................",
        ]),
        s(crystalPalette, [
            "................",
            "................",
            "......####......",
            ".....#cccc#.....",
            "....#cccwcc#....",
            "....#ccccccc#...",
            "...#ccccccccc#..",
            "...#cclcclccc#..",
            "...#ccccccccc#..",
            "....#ccccccc#...",
            ".....##cccc##...",
            "......#cccc#....",
            ".......####.....",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let crystalStage3: [PixelSprite] = [
        s(crystalPalette, [
            "................",
            "....####........",
            "...#cccc#.......",
            "..#ccwccc#......",
            "..#ccccccc#.....",
            ".#ccccccccc#....",
            ".#cclcclcccc#...",
            ".#cccccccccc#...",
            ".#cccwcccwcc#...",
            ".#cccccccccc#...",
            ".#cclcclcccc#...",
            ".#ccccccccc#....",
            "..##cccccc##....",
            "...#cccccc#.....",
            "....######......",
            "................",
        ]),
        s(crystalPalette, [
            "................",
            "....####........",
            "...#cccc#.......",
            "..#ccccwc#......",
            "..#ccccccc#.....",
            ".#ccccccccc#....",
            ".#cclcclcccc#...",
            ".#cccccccccc#...",
            ".#cccwcccwcc#...",
            ".#cccccccccc#...",
            ".#cclcclcccc#...",
            ".#ccccccccc#....",
            "..##cccccc##....",
            "...#cccccc#.....",
            "....######......",
            "................",
        ]),
    ]

    // MARK: - Android

    private static let androidPalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "m": .lightGray, "d": .darkGray, "c": .teal, "y": .yellow,
    ]
    private static func androidFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage { case .stage1: return androidStage1; case .stage2: return androidStage2; case .stage3: return androidStage3 }
    }
    private static let androidStage1: [PixelSprite] = [
        s(androidPalette, [
            "................",
            "................",
            "................",
            "........#.......",
            ".......#m#......",
            "......######....",
            ".....#mmmmmm#...",
            ".....#mc##cm#...",
            ".....#mmmmmm#...",
            ".....#m#yy#m#...",
            ".....#mmmmmm#...",
            "......######....",
            ".....#m#..#m#...",
            "................",
            "................",
            "................",
        ]),
        s(androidPalette, [
            "................",
            "................",
            "................",
            "........#.......",
            ".......#m#......",
            "......######....",
            ".....#mmmmmm#...",
            ".....#m####m#...",
            ".....#mmmmmm#...",
            ".....#m#yy#m#...",
            ".....#mmmmmm#...",
            "......######....",
            ".....#m#..#m#...",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let androidStage2: [PixelSprite] = [
        s(androidPalette, [
            "................",
            ".........#......",
            "........#m#.....",
            ".....########...",
            "....#mmmmmmmm#..",
            "....#mc####cm#..",
            "....#mmmmmmmm#..",
            "....#mm#yy#mm#..",
            "....#mmmmmmmm#..",
            ".....########...",
            "...#mm#....#mm#.",
            "...#m#......#m#.",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(androidPalette, [
            "................",
            ".........#......",
            "........#m#.....",
            ".....########...",
            "....#mmmmmmmm#..",
            "....#m######m#..",
            "....#mmmmmmmm#..",
            "....#mm#yy#mm#..",
            "....#mmmmmmmm#..",
            ".....########...",
            "...#mm#....#mm#.",
            "...#m#......#m#.",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let androidStage3: [PixelSprite] = [
        s(androidPalette, [
            "........#.......",
            ".......#m#......",
            "...############.",
            "..#mmmmmmmmmmmm#",
            "..#mc#####dcm##.",
            "..#mmmmmmmmmmmm#",
            "..#mm##yyy##mmm#",
            "..#mmmmmmmmmmmm#",
            "...############.",
            ".#mm#.........#.",
            ".#m#...........#",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(androidPalette, [
            "........#.......",
            ".......#m#......",
            "...############.",
            "..#mmmmmmmmmmmm#",
            "..#m##########m#",
            "..#mmmmmmmmmmmm#",
            "..#mm##yyy##mmm#",
            "..#mmmmmmmmmmmm#",
            "...############.",
            ".#mm#.........#.",
            ".#m#...........#",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]

    // MARK: - Phoenix

    private static let phoenixPalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "r": .red, "o": .orange, "y": .yellow, "w": .white, "g": .gold,
    ]
    private static func phoenixFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage { case .stage1: return phoenixStage1; case .stage2: return phoenixStage2; case .stage3: return phoenixStage3 }
    }
    private static let phoenixStage1: [PixelSprite] = [
        s(phoenixPalette, [
            "................",
            "................",
            "....r.......r...",
            "...#r#.....#r#..",
            "..#roooo###oor#.",
            "..#rooywooor#...",
            "..#rooooooor#...",
            "..#rroooorrr#...",
            "...#rrrrrrr#....",
            "....#######.....",
            "...r.......r....",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(phoenixPalette, [
            "................",
            "....r.......r...",
            "...#r#.....#r#..",
            "..#roooo###oor#.",
            "..#roooooooor#..",
            "..#rooywooor#...",
            "..#rroooorrr#...",
            "...#rrrrrrr#....",
            "....#######.....",
            "...r.......r....",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let phoenixStage2: [PixelSprite] = [
        s(phoenixPalette, [
            "................",
            "..r.........r...",
            ".#r#.......#r#..",
            "#rooooo###ooooor",
            "#rooyyyywooooor.",
            "#rooooooooooor..",
            ".#rroooooorrr#..",
            "..#rrrooorrr#...",
            "...##########...",
            "..r...........r.",
            ".r.............r",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(phoenixPalette, [
            "..r.........r...",
            ".#r#.......#r#..",
            "#rooooo###ooooor",
            "#rooooooooooor..",
            "#rooyyyywooooor.",
            ".#rroooooorrr#..",
            "..#rrrooorrr#...",
            "...##########...",
            "..r...........r.",
            ".r.............r",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let phoenixStage3: [PixelSprite] = [
        s(phoenixPalette, [
            "r...........r...",
            "#r#.......#r#...",
            "roooooo###ooooor",
            "rooyyywooooooor.",
            "roooooooooooor..",
            "rroooooooorrr#..",
            ".#rrrooooorrr#..",
            "..###########...",
            ".r...........r..",
            "r.............r.",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(phoenixPalette, [
            "r...........r...",
            "#r#.......#r#...",
            "roooooo###ooooor",
            "roooooooooooor..",
            "rooyyywooooooor.",
            "rroooooooorrr#..",
            ".#rrrooooorrr#..",
            "..###########...",
            ".r...........r..",
            "r.............r.",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]

    // MARK: - Sphinx

    private static let sphinxPalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "t": .tan, "g": .gold, "w": .white, "b": .brown, "y": .yellow,
    ]
    private static func sphinxFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage { case .stage1: return sphinxStage1; case .stage2: return sphinxStage2; case .stage3: return sphinxStage3 }
    }
    private static let sphinxStage1: [PixelSprite] = [
        s(sphinxPalette, [
            "................",
            "................",
            "................",
            "....#gggggg#....",
            "....#gtttgt#....",
            "...#tttttttt#...",
            "...#tw##wtt#....",
            "...#ttttttt#....",
            "...#tt#yy#tt#...",
            "...#tttttttt#...",
            "....########....",
            "...#tt#..#tt#...",
            "....####..####..",
            "................",
            "................",
            "................",
        ]),
        s(sphinxPalette, [
            "................",
            "................",
            "................",
            "....#gggggg#....",
            "....#gtttgt#....",
            "...#tttttttt#...",
            "...#t####tt#....",
            "...#ttttttt#....",
            "...#tt#yy#tt#...",
            "...#tttttttt#...",
            "....########....",
            "...#tt#..#tt#...",
            "....####..####..",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let sphinxStage2: [PixelSprite] = [
        s(sphinxPalette, [
            "................",
            "...#gggggggg#...",
            "...#gtttttgt#...",
            "..#tttttttttt#..",
            "..#tw###wwtt#...",
            "..#tttttttttt#..",
            "..#ttt#yy#ttt#..",
            "..#tttttttttt#..",
            "...############.",
            "..#ttt#....#ttt#",
            "..#tt#......#tt#",
            "...##........##.",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(sphinxPalette, [
            "................",
            "...#gggggggg#...",
            "...#gtttttgt#...",
            "..#tttttttttt#..",
            "..#t########t#..",
            "..#tttttttttt#..",
            "..#ttt#yy#ttt#..",
            "..#tttttttttt#..",
            "...############.",
            "..#ttt#....#ttt#",
            "..#tt#......#tt#",
            "...##........##.",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let sphinxStage3: [PixelSprite] = [
        s(sphinxPalette, [
            "..#gggggggggg#..",
            "..#gtttttttgt#..",
            ".#tttttttttttt#.",
            ".#tww###wwwtt#..",
            ".#tttttttttttt#.",
            ".#tttt#yy#tttt#.",
            ".#tttttttttttt#.",
            "..##############",
            ".#ttttt#..#ttttt",
            ".#tttt#....#tttt",
            "..###........###",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(sphinxPalette, [
            "..#gggggggggg#..",
            "..#gtttttttgt#..",
            ".#tttttttttttt#.",
            ".#t############.",
            ".#tttttttttttt#.",
            ".#tttt#yy#tttt#.",
            ".#tttttttttttt#.",
            "..##############",
            ".#ttttt#..#ttttt",
            ".#tttt#....#tttt",
            "..###........###",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]

    // MARK: - Nebula

    private static let nebulaPalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "p": .purple, "l": .lavender, "b": .blue, "w": .white, "y": .yellow,
    ]
    private static func nebulaFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage { case .stage1: return nebulaStage1; case .stage2: return nebulaStage2; case .stage3: return nebulaStage3 }
    }
    private static let nebulaStage1: [PixelSprite] = [
        s(nebulaPalette, [
            "................",
            "................",
            "................",
            "....#pp##pp#....",
            "...#pllllllp#...",
            "...#plbwwblp#...",
            "...#pllllllp#...",
            "...#plbwwblp#...",
            "...#pllllllp#...",
            "....#pp##pp#....",
            "...p#......#p...",
            "..p..........p..",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(nebulaPalette, [
            "................",
            "................",
            "................",
            "....#pp##pp#....",
            "...#pllllllp#...",
            "...#pl####lp#...",
            "...#pllllllp#...",
            "...#plbwwblp#...",
            "...#pllllllp#...",
            "....#pp##pp#....",
            "..p.#......#.p..",
            "...p........p...",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let nebulaStage2: [PixelSprite] = [
        s(nebulaPalette, [
            "................",
            "...#ppp##ppp#...",
            "..#plllllllllp#.",
            "..#plbwwwwblpp#.",
            "..#plllllllllp#.",
            "..#plbwwwwblpp#.",
            "..#plllllllllp#.",
            "...#ppp####pp#..",
            "..p#..........#p",
            ".p.............p",
            "p...............",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(nebulaPalette, [
            "................",
            "...#ppp##ppp#...",
            "..#plllllllllp#.",
            "..#pl########p#.",
            "..#plllllllllp#.",
            "..#plbwwwwblpp#.",
            "..#plllllllllp#.",
            "...#ppp####pp#..",
            "..p#..........#p",
            ".p.............p",
            "p...............",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let nebulaStage3: [PixelSprite] = [
        s(nebulaPalette, [
            "..#pppp##pppp#..",
            ".#plllllllllllp#",
            ".#plbwwwwwwblpp#",
            ".#plllllllllllp#",
            ".#plbwwwwwwblpp#",
            ".#plllllllllllp#",
            "..#pppp####ppp#.",
            ".p#............#",
            "p.............p.",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(nebulaPalette, [
            "..#pppp##pppp#..",
            ".#plllllllllllp#",
            ".#pl##########p#",
            ".#plllllllllllp#",
            ".#plbwwwwwwblpp#",
            ".#plllllllllllp#",
            "..#pppp####ppp#.",
            ".p#............#",
            "p.............p.",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]

    // MARK: - Lotus

    private static let lotusPalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "p": .pink, "w": .white, "y": .yellow, "g": .mint, "l": .lightGray,
    ]
    private static func lotusFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage { case .stage1: return lotusStage1; case .stage2: return lotusStage2; case .stage3: return lotusStage3 }
    }
    private static let lotusStage1: [PixelSprite] = [
        s(lotusPalette, [
            "................",
            "................",
            "................",
            ".....#p##p#.....",
            "....#ppppppp#...",
            "...#ppwwwwwpp#..",
            "...#ppw#y#wpp#..",
            "...#ppwwwwwpp#..",
            "....#ppppppp#...",
            ".....#p##p#.....",
            ".....#g....#....",
            "......###.......",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(lotusPalette, [
            "................",
            "................",
            "................",
            ".....#p##p#.....",
            "....#ppppppp#...",
            "...#ppwwwwwpp#..",
            "...#ppw#w#wpp#..",
            "...#ppwwwwwpp#..",
            "....#ppppppp#...",
            ".....#p##p#.....",
            ".....#g....#....",
            "......###.......",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let lotusStage2: [PixelSprite] = [
        s(lotusPalette, [
            "................",
            "...#p......p#...",
            "..#ppp#pp#ppp#..",
            "..#pppppppppp#..",
            ".#ppwwwwwwwwpp#.",
            ".#ppww#yyy#wwp#.",
            ".#ppwwwwwwwwpp#.",
            "..#pppppppppp#..",
            "...#p......p#...",
            "....##gggg##....",
            ".....#gggg#.....",
            "......####......",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(lotusPalette, [
            "................",
            "...#p......p#...",
            "..#ppp#pp#ppp#..",
            "..#pppppppppp#..",
            ".#ppwwwwwwwwpp#.",
            ".#ppww#www#wwp#.",
            ".#ppwwwwwwwwpp#.",
            "..#pppppppppp#..",
            "...#p......p#...",
            "....##gggg##....",
            ".....#gggg#.....",
            "......####......",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let lotusStage3: [PixelSprite] = [
        s(lotusPalette, [
            "..#p........p#..",
            ".#pppp#pp#pppp#.",
            ".#pppppppppppp#.",
            "#ppwwwwwwwwwwpp#",
            "#ppwww#yyy#wwwp#",
            "#ppwwwwwwwwwwpp#",
            ".#pppppppppppp#.",
            "..#p........p#..",
            "...##gggggg##...",
            "....#gggggg#....",
            ".....######.....",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(lotusPalette, [
            "..#p........p#..",
            ".#pppp#pp#pppp#.",
            ".#pppppppppppp#.",
            "#ppwwwwwwwwwwpp#",
            "#ppwww#www#wwwp#",
            "#ppwwwwwwwwwwpp#",
            ".#pppppppppppp#.",
            "..#p........p#..",
            "...##gggggg##...",
            "....#gggggg#....",
            ".....######.....",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]

    // MARK: - Unicorn

    private static let unicornPalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "w": .white, "l": .lightGray, "p": .pink, "y": .yellow, "r": .red, "b": .blue,
    ]
    private static func unicornFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage { case .stage1: return unicornStage1; case .stage2: return unicornStage2; case .stage3: return unicornStage3 }
    }
    private static let unicornStage1: [PixelSprite] = [
        s(unicornPalette, [
            "................",
            "................",
            "........#y#.....",
            ".......#yyy#....",
            "....#...#wy#....",
            "...##..#wwwww#..",
            "..#ww##wwwwwww#.",
            "..#wl##wwwwwww#.",
            "..#wwwwwwwwwww#.",
            "..#ww#pp#wwww#..",
            "..#wwwwwwwwww#..",
            "...###wwwww###..",
            "....#w#...#w#...",
            "................",
            "................",
            "................",
        ]),
        s(unicornPalette, [
            "................",
            "................",
            "........#y#.....",
            ".......#yyy#....",
            "....#...#wy#....",
            "...##..#wwwww#..",
            "..#ww##wwwwwww#.",
            "..#w####wwwwww#.",
            "..#wwwwwwwwwww#.",
            "..#ww#pp#wwww#..",
            "..#wwwwwwwwww#..",
            "...###wwwww###..",
            "....#w#...#w#...",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let unicornStage2: [PixelSprite] = [
        s(unicornPalette, [
            "................",
            ".........#y#....",
            "........#ryy#...",
            ".......#bryyy#..",
            "....##.#wbwyy#..",
            "...####wwwwwww#.",
            "..#wwwwwwwwwwww#",
            "..#wll##wwwwwww#",
            "..#wwwwwwwwwwww#",
            "..#www#pp#wwwww#",
            "..#wwwwwwwwwwww#",
            "...####wwwww####",
            "....#ww#...#ww#.",
            ".....##.....##..",
            "................",
            "................",
        ]),
        s(unicornPalette, [
            "................",
            ".........#y#....",
            "........#ryy#...",
            ".......#bryyy#..",
            "....##.#wbwyy#..",
            "...####wwwwwww#.",
            "..#wwwwwwwwwwww#",
            "..#w######wwwww#",
            "..#wwwwwwwwwwww#",
            "..#www#pp#wwwww#",
            "..#wwwwwwwwwwww#",
            "...####wwwww####",
            "....#ww#...#ww#.",
            ".....##.....##..",
            "................",
            "................",
        ]),
    ]
    private static let unicornStage3: [PixelSprite] = [
        s(unicornPalette, [
            ".........#y#....",
            "........#ryy#...",
            ".......#bryyy#..",
            "......#wbrwyyy#.",
            "....###wwwwwww#.",
            "...#wwwwwwwwwww#",
            "..#wlll##wwwwww#",
            "..#wwwwwwwwwwww#",
            "..#wwww#pp#wwww#",
            "..#wwwwwwwwwwww#",
            "...#####wwww####",
            "....#www#..#www#",
            ".....###....###.",
            "................",
            "................",
            "................",
        ]),
        s(unicornPalette, [
            ".........#y#....",
            "........#ryy#...",
            ".......#bryyy#..",
            "......#wbrwyyy#.",
            "....###wwwwwww#.",
            "...#wwwwwwwwwww#",
            "..#w#########w#.",
            "..#wwwwwwwwwwww#",
            "..#wwww#pp#wwww#",
            "..#wwwwwwwwwwww#",
            "...#####wwww####",
            "....#www#..#www#",
            ".....###....###.",
            "................",
            "................",
            "................",
        ]),
    ]

    // MARK: - Fairy

    private static let fairyPalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "p": .pink, "y": .yellow, "w": .white, "l": .lavender, "g": .gold,
    ]
    private static func fairyFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage { case .stage1: return fairyStage1; case .stage2: return fairyStage2; case .stage3: return fairyStage3 }
    }
    private static let fairyStage1: [PixelSprite] = [
        s(fairyPalette, [
            "................",
            "................",
            "................",
            "....l#yyy#l.....",
            "...l#ppppp#l....",
            "....#pw#w#p#....",
            "....#pwwwwp#....",
            "....#pp#w#pp#...",
            ".....########...",
            ".....#p....p#...",
            "......######....",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(fairyPalette, [
            "................",
            "................",
            "................",
            "....l#yyy#l.....",
            "...l#ppppp#l....",
            "....#p####p#....",
            "....#pwwwwp#....",
            "....#pp#w#pp#...",
            ".....########...",
            ".....#p....p#...",
            "......######....",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let fairyStage2: [PixelSprite] = [
        s(fairyPalette, [
            "................",
            "...l.#yyy#.l....",
            "..ll#ppppppp#...",
            "...#pww#w#wwp#..",
            "...#pwwwwwwwp#..",
            "...#ppp#w#ppp#..",
            "....###ppppp###.",
            ".....#pp...pp#..",
            "......#######...",
            ".....#pp...pp#..",
            "......###..###..",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(fairyPalette, [
            "...l.#yyy#.l....",
            "..ll#ppppppp#...",
            "...#p#########..",
            "...#pwwwwwwwp#..",
            "...#ppp#w#ppp#..",
            "....###ppppp###.",
            ".....#pp...pp#..",
            "......#######...",
            ".....#pp...pp#..",
            "......###..###..",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let fairyStage3: [PixelSprite] = [
        s(fairyPalette, [
            "..l.#yyyyyy#.l..",
            ".ll#ppppppppp#l.",
            "..#pwww#w#wwwp#.",
            "..#pwwwwwwwwwp#.",
            "..#pppp#w#pppp#.",
            "...####ppppp###.",
            "....#ppp...ppp#.",
            ".....#########..",
            "....#ppp...ppp#.",
            ".....####.####..",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(fairyPalette, [
            "..l.#yyyyyy#.l..",
            ".ll#ppppppppp#l.",
            "..#p###########.",
            "..#pwwwwwwwwwp#.",
            "..#pppp#w#pppp#.",
            "...####ppppp###.",
            "....#ppp...ppp#.",
            ".....#########..",
            "....#ppp...ppp#.",
            ".....####.####..",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]

    // MARK: - Celestial

    private static let celestialPalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "g": .gold, "y": .yellow, "w": .white, "l": .lightGray, "o": .orange,
    ]
    private static func celestialFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage { case .stage1: return celestialStage1; case .stage2: return celestialStage2; case .stage3: return celestialStage3 }
    }
    private static let celestialStage1: [PixelSprite] = [
        s(celestialPalette, [
            "................",
            "................",
            "......#g#.......",
            ".....#ggg#......",
            "..#..#gwg#..#...",
            "..##.#ggg#.##...",
            "...##gggggg##...",
            "...#gwwwwwwg#...",
            "...##gggggg##...",
            "..##.#ggg#.##...",
            "..#..#ggg#..#...",
            ".....#####......",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(celestialPalette, [
            "................",
            "......#g#.......",
            ".....#ggg#......",
            "..#..#gwg#..#...",
            "..##.#ggg#.##...",
            "...##gggggg##...",
            "...#gwwwwwwg#...",
            "...##gggggg##...",
            "..##.#ggg#.##...",
            "..#..#ggg#..#...",
            ".....#####......",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let celestialStage2: [PixelSprite] = [
        s(celestialPalette, [
            "................",
            ".....##g##......",
            "....#ggggg#.....",
            "..#.#gwwwg#.#...",
            ".##.#ggggg#.##..",
            "..##gggggggg##..",
            "..#gwwwwwwwwg#..",
            "..#ggggggggg#...",
            "..##gggggggg##..",
            ".##.#ggggg#.##..",
            "..#.#ggggg#.#...",
            "....#######.....",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(celestialPalette, [
            ".....##g##......",
            "....#ggggg#.....",
            "..#.#gwwwg#.#...",
            ".##.#ggggg#.##..",
            "..##gggggggg##..",
            "..#gwwwwwwwwg#..",
            "..#ggggggggg#...",
            "..##gggggggg##..",
            ".##.#ggggg#.##..",
            "..#.#ggggg#.#...",
            "....#######.....",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let celestialStage3: [PixelSprite] = [
        s(celestialPalette, [
            "......##g##.....",
            "...#.#ggggg#.#..",
            ".###.#gwwwg#.###",
            "..##gggggggggg##",
            "..#gwwwwwwwwwwg#",
            "..#gggggggggggg#",
            "..##gggggggggg##",
            ".###.#ggggg#.###",
            "...#.#ggggg#.#..",
            "....#########...",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(celestialPalette, [
            "......##g##.....",
            "...#.#ggggg#.#..",
            ".###.#goooo#.###",
            "..##gggggggggg##",
            "..#gwwwwwwwwwwg#",
            "..#gggggggggggg#",
            "..##gggggggggg##",
            ".###.#ggggg#.###",
            "...#.#ggggg#.#..",
            "....#########...",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]

    // MARK: - Aurora

    private static let auroraPalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "g": .mint, "b": .blue, "p": .purple, "l": .lavender, "w": .white, "t": .teal,
    ]
    private static func auroraFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage { case .stage1: return auroraStage1; case .stage2: return auroraStage2; case .stage3: return auroraStage3 }
    }
    private static let auroraStage1: [PixelSprite] = [
        s(auroraPalette, [
            "................",
            "................",
            "................",
            "...#gggggggg#...",
            "..#gggggggggg#..",
            "..#ggtttttggg#..",
            "..#gggggggggg#..",
            "..#bbbbbbbbbb#..",
            "..#bblllllbbb#..",
            "..#bbbbbbbbbb#..",
            "..#pppppppppp#..",
            "...#ppllllpp#...",
            "....########....",
            "................",
            "................",
            "................",
        ]),
        s(auroraPalette, [
            "................",
            "................",
            "................",
            "..#gggggggggg#..",
            "..#ggttttttgg#..",
            "..#gggggggggg#..",
            "..#gggggggggg#..",
            "..#bbbbbbbbbb#..",
            "..#bbllllllbb#..",
            "..#bbbbbbbbbb#..",
            "..#pppppppppp#..",
            "...#pppllppp#...",
            "....########....",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let auroraStage2: [PixelSprite] = [
        s(auroraPalette, [
            "................",
            "................",
            "..#gggggggggg#..",
            ".#ggggttttgggg#.",
            ".#gggggggggggg#.",
            ".#bbbbbbbbbbbbb#",
            ".#bbbllllllbbb#.",
            ".#bbbbbbbbbbbb#.",
            ".#pppppppppppp#.",
            ".#ppllwwwllppp#.",
            ".#pppppppppppp#.",
            "..############..",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(auroraPalette, [
            "................",
            "..#gggggggggg#..",
            ".#gggtttttttgg#.",
            ".#gggggggggggg#.",
            ".#bbbbbbbbbbbbb#",
            ".#bbllllllllbb#.",
            ".#bbbbbbbbbbbb#.",
            ".#pppppppppppp#.",
            ".#pplwwwwwwlpp#.",
            ".#pppppppppppp#.",
            "..############..",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let auroraStage3: [PixelSprite] = [
        s(auroraPalette, [
            "................",
            ".#gggggggggggg#.",
            "#gggttttttttggg#",
            "#gggggggggggggg#",
            "#bbbbbbbbbbbbbb#",
            "#bblllllllllbbb#",
            "#bbbbbbbbbbbbbb#",
            "#pppppppppppppp#",
            "#ppllwwwwwwllpp#",
            "#pppppppppppppp#",
            ".##############.",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(auroraPalette, [
            ".#gggggggggggg#.",
            "#gggttttttttggg#",
            "#gggggggggggggg#",
            "#bbbbbbbbbbbbbb#",
            "#bbllllllllllbb#",
            "#bbbbbbbbbbbbbb#",
            "#pppppppppppppp#",
            "#pplwwwwwwwwlpp#",
            "#pppppppppppppp#",
            ".##############.",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]

    // MARK: - Bear

    private static let bearPalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "b": .brown, "t": .tan, "w": .white, "p": .pink,
    ]
    private static func bearFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage { case .stage1: return bearStage1; case .stage2: return bearStage2; case .stage3: return bearStage3 }
    }
    private static let bearStage1: [PixelSprite] = [
        s(bearPalette, [
            "................",
            "................",
            "................",
            "...#b#....#b#...",
            "..#bbb#..#bbb#..",
            "..#bbbbbbbbb#...",
            "..#bw##bb##wb#..",
            "..#bbbbbbbbb#...",
            "..#bbb#tt#bbb#..",
            "...#bbbbbbbbb#..",
            "....#########...",
            "....#b#....#b#..",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(bearPalette, [
            "................",
            "................",
            "................",
            "...#b#....#b#...",
            "..#bbb#..#bbb#..",
            "..#bbbbbbbbb#...",
            "..#b####bb##b#..",
            "..#bbbbbbbbb#...",
            "..#bbb#tt#bbb#..",
            "...#bbbbbbbbb#..",
            "....#########...",
            "....#b#....#b#..",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let bearStage2: [PixelSprite] = [
        s(bearPalette, [
            "................",
            "..#b#......#b#..",
            ".#bbb#....#bbb#.",
            ".#bbbbbbbbbbb#..",
            ".#bww##bb##wwb#.",
            ".#bbbbbbbbbbb#..",
            ".#bbbb#tt#bbbb#.",
            ".#bbbbbbbbbbb#..",
            "..#bbbbbbbbb#...",
            "...###########..",
            "..#bb#.....#bb#.",
            "..#b#.......#b#.",
            "...##.........##",
            "................",
            "................",
            "................",
        ]),
        s(bearPalette, [
            "................",
            "..#b#......#b#..",
            ".#bbb#....#bbb#.",
            ".#bbbbbbbbbbb#..",
            ".#b#########b#..",
            ".#bbbbbbbbbbb#..",
            ".#bbbb#tt#bbbb#.",
            ".#bbbbbbbbbbb#..",
            "..#bbbbbbbbb#...",
            "...###########..",
            "..#bb#.....#bb#.",
            "..#b#.......#b#.",
            "...##.........##",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let bearStage3: [PixelSprite] = [
        s(bearPalette, [
            ".#b#........#b#.",
            "#bbb#......#bbb#",
            "#bbbbbbbbbbbbb#.",
            "#bwww##bb##wwwb#",
            "#bbbbbbbbbbbbb#.",
            "#bbbbb#tt#bbbbb#",
            "#bbbbbbbbbbbbb#.",
            ".#bbbbbbbbbbb#..",
            "..#############.",
            ".#bbb#.....#bbb#",
            ".#bb#.......#bb#",
            "..###.........##",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(bearPalette, [
            ".#b#........#b#.",
            "#bbb#......#bbb#",
            "#bbbbbbbbbbbbb#.",
            "#b###########b#.",
            "#bbbbbbbbbbbbb#.",
            "#bbbbb#tt#bbbbb#",
            "#bbbbbbbbbbbbb#.",
            ".#bbbbbbbbbbb#..",
            "..#############.",
            ".#bbb#.....#bbb#",
            ".#bb#.......#bb#",
            "..###.........##",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]

    // MARK: - Hedgehog

    private static let hedgehogPalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "b": .brown, "t": .tan, "w": .white, "p": .pink, "d": .darkGray,
    ]
    private static func hedgehogFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage { case .stage1: return hedgehogStage1; case .stage2: return hedgehogStage2; case .stage3: return hedgehogStage3 }
    }
    private static let hedgehogStage1: [PixelSprite] = [
        s(hedgehogPalette, [
            "................",
            "................",
            "................",
            "....#d#d#d#.....",
            "...#ddbddbd#....",
            "..#dbbbbbbbbd#..",
            "..#dbtw##wtbd#..",
            "..#dbbbbbbbbd#..",
            "..#dbbb#p#bbbd#.",
            "..#dbbbbbbbd#...",
            "...#tttttttt#...",
            "....########....",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(hedgehogPalette, [
            "................",
            "................",
            "................",
            "....#d#d#d#.....",
            "...#ddbddbd#....",
            "..#dbbbbbbbbd#..",
            "..#db####wtbd#..",
            "..#dbbbbbbbbd#..",
            "..#dbbb#p#bbbd#.",
            "..#dbbbbbbbd#...",
            "...#tttttttt#...",
            "....########....",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let hedgehogStage2: [PixelSprite] = [
        s(hedgehogPalette, [
            "................",
            "...#d#d#d#d#....",
            "..#ddbddbdbd#...",
            ".#dbbbbbbbbbd#..",
            ".#dbbtw##wtbbd#.",
            ".#dbbbbbbbbbd#..",
            ".#dbbbb#p#bbbd#.",
            ".#dbbbbbbbbd#...",
            "..#ttttttttttt#.",
            "...############.",
            "..#tt#.....#tt#.",
            "...##.......##..",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(hedgehogPalette, [
            "................",
            "...#d#d#d#d#....",
            "..#ddbddbdbd#...",
            ".#dbbbbbbbbbd#..",
            ".#dbb########d#.",
            ".#dbbbbbbbbbd#..",
            ".#dbbbb#p#bbbd#.",
            ".#dbbbbbbbbd#...",
            "..#ttttttttttt#.",
            "...############.",
            "..#tt#.....#tt#.",
            "...##.......##..",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let hedgehogStage3: [PixelSprite] = [
        s(hedgehogPalette, [
            "..#d#d#d#d#d#...",
            ".#ddbbddbdbd#...",
            "#dbbbbbbbbbbbd#.",
            "#dbbtw###wtbbbd#",
            "#dbbbbbbbbbbbd#.",
            "#dbbbbb#p#bbbbd#",
            "#dbbbbbbbbbd#...",
            ".#ttttttttttttt#",
            "..##############",
            ".#ttt#.....#ttt#",
            "..###.......###.",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(hedgehogPalette, [
            "..#d#d#d#d#d#...",
            ".#ddbbddbdbd#...",
            "#dbbbbbbbbbbbd#.",
            "#dbb##########d#",
            "#dbbbbbbbbbbbd#.",
            "#dbbbbb#p#bbbbd#",
            "#dbbbbbbbbbd#...",
            ".#ttttttttttttt#",
            "..##############",
            ".#ttt#.....#ttt#",
            "..###.......###.",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]

    // MARK: - Golem

    private static let golemPalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "g": .gray, "d": .darkGray, "o": .orange, "m": .mint, "l": .lightGray,
    ]
    private static func golemFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage { case .stage1: return golemStage1; case .stage2: return golemStage2; case .stage3: return golemStage3 }
    }
    private static let golemStage1: [PixelSprite] = [
        s(golemPalette, [
            "................",
            "................",
            "................",
            "....########....",
            "...#glllllg#....",
            "..#gllo##llg#...",
            "..#gllllllg#....",
            "..#gll#m#llg#...",
            "..#gllllllg#....",
            "...#glllllg#....",
            "....#######.....",
            "...#g#....#g#...",
            "....##......##..",
            "................",
            "................",
            "................",
        ]),
        s(golemPalette, [
            "................",
            "................",
            "................",
            "....########....",
            "...#glllllg#....",
            "..#gl#####lg#...",
            "..#gllllllg#....",
            "..#gll#m#llg#...",
            "..#gllllllg#....",
            "...#glllllg#....",
            "....#######.....",
            "...#g#....#g#...",
            "....##......##..",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let golemStage2: [PixelSprite] = [
        s(golemPalette, [
            "................",
            "...##########...",
            "..#gllllllllg#..",
            "..#gllo####llg#.",
            "..#gllllllllg#..",
            "..#glll#mm#lllg#",
            "..#gllllllllg#..",
            "...#gllllllg#...",
            "....##########..",
            "..#g#......#g#..",
            "..#gl#....#lg#..",
            "...###......###.",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(golemPalette, [
            "................",
            "...##########...",
            "..#gllllllllg#..",
            "..#gl########g#.",
            "..#gllllllllg#..",
            "..#glll#mm#lllg#",
            "..#gllllllllg#..",
            "...#gllllllg#...",
            "....##########..",
            "..#g#......#g#..",
            "..#gl#....#lg#..",
            "...###......###.",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let golemStage3: [PixelSprite] = [
        s(golemPalette, [
            "..############..",
            ".#gllllllllllg#.",
            ".#gllo######llg#",
            ".#gllllllllllg#.",
            ".#glllll#mm#lllg",
            ".#gllllllllllg#.",
            "..#gllllllllg#..",
            "...############.",
            "..#g#........#g#",
            "..#gl#......#lg#",
            "...###......###.",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(golemPalette, [
            "..############..",
            ".#gllllllllllg#.",
            ".#gl##########g#",
            ".#gllllllllllg#.",
            ".#glllll#mm#lllg",
            ".#gllllllllllg#.",
            "..#gllllllllg#..",
            "...############.",
            "..#g#........#g#",
            "..#gl#......#lg#",
            "...###......###.",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]

    // MARK: - Elephant

    private static let elephantPalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "g": .gray, "l": .lightGray, "w": .white, "p": .pink, "y": .yellow,
    ]
    private static func elephantFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage { case .stage1: return elephantStage1; case .stage2: return elephantStage2; case .stage3: return elephantStage3 }
    }
    private static let elephantStage1: [PixelSprite] = [
        s(elephantPalette, [
            "................",
            "................",
            "..#g#......#g#..",
            ".#ggg#....#ggg#.",
            ".#ggggggggggg#..",
            ".#glw##gg##wlg#.",
            ".#ggggggggggg#..",
            "..#gggg##gggg#..",
            "..#gggggggggg#..",
            "..#g##glllg##g#.",
            "..#ggggggggg#...",
            "...#g##...##g#..",
            "....##.....##...",
            "................",
            "................",
            "................",
        ]),
        s(elephantPalette, [
            "................",
            "................",
            "..#g#......#g#..",
            ".#ggg#....#ggg#.",
            ".#ggggggggggg#..",
            ".#g##########g#.",
            ".#ggggggggggg#..",
            "..#gggg##gggg#..",
            "..#gggggggggg#..",
            "..#g##glllg##g#.",
            "..#ggggggggg#...",
            "...#g##...##g#..",
            "....##.....##...",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let elephantStage2: [PixelSprite] = [
        s(elephantPalette, [
            "................",
            ".#g#........#g#.",
            "#ggg#......#ggg#",
            "#ggggggggggggg#.",
            "#glww##gg##wwlg#",
            "#ggggggggggggg#.",
            ".#ggggg##ggggg#.",
            ".#gggggggggggg#.",
            ".#g###gllllg###g",
            ".#ggggggggggggg.",
            "..#gg##....##gg#",
            "..###........###",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(elephantPalette, [
            "................",
            ".#g#........#g#.",
            "#ggg#......#ggg#",
            "#ggggggggggggg#.",
            "#g############g#",
            "#ggggggggggggg#.",
            ".#ggggg##ggggg#.",
            ".#gggggggggggg#.",
            ".#g###gllllg###g",
            ".#ggggggggggggg.",
            "..#gg##....##gg#",
            "..###........###",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let elephantStage3: [PixelSprite] = [
        s(elephantPalette, [
            "#g#..........#g#",
            "ggg#........#ggg",
            "ggggggggggggggg#",
            "glwww##gg##wwwlg",
            "ggggggggggggggg#",
            ".#ggggg###ggggg#",
            ".#gggggggggggg#.",
            ".#g####gllg####g",
            ".#ggggggggggggg.",
            "..#ggg##..##ggg#",
            "..####......####",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(elephantPalette, [
            "#g#..........#g#",
            "ggg#........#ggg",
            "ggggggggggggggg#",
            "g##############g",
            "ggggggggggggggg#",
            ".#ggggg###ggggg#",
            ".#gggggggggggg#.",
            ".#g####gllg####g",
            ".#ggggggggggggg.",
            "..#ggg##..##ggg#",
            "..####......####",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]

    // MARK: - Kraken

    private static let krakenPalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "d": .darkBlue, "b": .blue, "p": .purple, "w": .white, "l": .lavender,
    ]
    private static func krakenFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage { case .stage1: return krakenStage1; case .stage2: return krakenStage2; case .stage3: return krakenStage3 }
    }
    private static let krakenStage1: [PixelSprite] = [
        s(krakenPalette, [
            "................",
            "................",
            "................",
            "....########....",
            "...#bbbbbbbb#...",
            "...#bw##wwb#....",
            "...#bbbbbbbb#...",
            "....########....",
            "...#b#b#b#b#....",
            "...#b#b#b#b#....",
            "..#d###d###d#...",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(krakenPalette, [
            "................",
            "................",
            "................",
            "....########....",
            "...#bbbbbbbb#...",
            "...#b####wb#....",
            "...#bbbbbbbb#...",
            "....########....",
            "....#b#b#b#b#...",
            "....#b#b#b#b#...",
            "...#d###d###d#..",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let krakenStage2: [PixelSprite] = [
        s(krakenPalette, [
            "................",
            "...##########...",
            "..#bbbbbbbbbb#..",
            "..#bww####wwb#..",
            "..#bbbbbbbbbb#..",
            "...##########...",
            "..#bb#bb#bb#bb#.",
            "..#b##bb#bb##b#.",
            ".#d###dd#dd###d#",
            ".#d#..#d#d#..#d#",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(krakenPalette, [
            "................",
            "...##########...",
            "..#bbbbbbbbbb#..",
            "..#b##########..",
            "..#bbbbbbbbbb#..",
            "...##########...",
            ".#bb#bb#bb#bb#..",
            ".#b##bb#bb##b#..",
            "#d###dd#dd###d#.",
            "#d#..#d#d#..#d#.",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let krakenStage3: [PixelSprite] = [
        s(krakenPalette, [
            "..############..",
            ".#bbbbbbbbbbbb#.",
            ".#bwww####wwwb#.",
            ".#bbbbbbbbbbbb#.",
            "..############..",
            ".#bbb#bbb#bbb#b.",
            ".#bb##bbb#bb##b.",
            "#d####ddd#d####d",
            "#d##..#d#d#..##d",
            "#d#....#d#....#d",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(krakenPalette, [
            "..############..",
            ".#bbbbbbbbbbbb#.",
            ".#b############.",
            ".#bbbbbbbbbbbb#.",
            "..############..",
            "..#bbb#bbb#bbb#b",
            "..#bb##bbb#bb##b",
            ".#d####ddd#d####",
            ".#d##..#d#d#..##",
            ".#d#....#d#....#",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]

    // MARK: - Rabbit

    private static let rabbitPalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "w": .white, "l": .lightGray, "p": .pink, "g": .gray,
    ]
    private static func rabbitFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage { case .stage1: return rabbitStage1; case .stage2: return rabbitStage2; case .stage3: return rabbitStage3 }
    }
    private static let rabbitStage1: [PixelSprite] = [
        s(rabbitPalette, [
            "................",
            "....#w....w#....",
            "....#wp..pw#....",
            "....#w....w#....",
            "...#wwwwwwww#...",
            "...#wl##wwlw#...",
            "...#wwwwwwww#...",
            "...#ww#pp#ww#...",
            "...#wwwwwwww#...",
            "....########....",
            ".....#w..w#.....",
            "......####......",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(rabbitPalette, [
            "................",
            "....#w....w#....",
            "....#wp..pw#....",
            "....#w....w#....",
            "...#wwwwwwww#...",
            "...#w####www#...",
            "...#wwwwwwww#...",
            "...#ww#pp#ww#...",
            "...#wwwwwwww#...",
            "....########....",
            ".....#w..w#.....",
            "......####......",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let rabbitStage2: [PixelSprite] = [
        s(rabbitPalette, [
            "................",
            "...#w......w#...",
            "...#wp....pw#...",
            "...#w......w#...",
            "..#wwwwwwwwww#..",
            "..#wll##wwllw#..",
            "..#wwwwwwwwww#..",
            "..#www#pp#www#..",
            "..#wwwwwwwwww#..",
            "...############.",
            "..#www#....#www#",
            "..#ww#......#ww#",
            "...##........##.",
            "................",
            "................",
            "................",
        ]),
        s(rabbitPalette, [
            "................",
            "...#w......w#...",
            "...#wp....pw#...",
            "...#w......w#...",
            "..#wwwwwwwwww#..",
            "..#w##########..",
            "..#wwwwwwwwww#..",
            "..#www#pp#www#..",
            "..#wwwwwwwwww#..",
            "...############.",
            "..#www#....#www#",
            "..#ww#......#ww#",
            "...##........##.",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let rabbitStage3: [PixelSprite] = [
        s(rabbitPalette, [
            "..#w........w#..",
            "..#wp......pw#..",
            "..#w........w#..",
            ".#wwwwwwwwwwww#.",
            ".#wlll##wwlllw#.",
            ".#wwwwwwwwwwww#.",
            ".#wwww#pp#wwww#.",
            ".#wwwwwwwwwwww#.",
            "..#############.",
            ".#wwww#....#wwww",
            ".#www#......#www",
            "..###........###",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(rabbitPalette, [
            "..#w........w#..",
            "..#wp......pw#..",
            "..#w........w#..",
            ".#wwwwwwwwwwww#.",
            ".#w############.",
            ".#wwwwwwwwwwww#.",
            ".#wwww#pp#wwww#.",
            ".#wwwwwwwwwwww#.",
            "..#############.",
            ".#wwww#....#wwww",
            ".#www#......#www",
            "..###........###",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]

    // MARK: - Scorpion

    private static let scorpionPalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "o": .orange, "r": .red, "y": .yellow, "w": .white, "d": .darkGray,
    ]
    private static func scorpionFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage { case .stage1: return scorpionStage1; case .stage2: return scorpionStage2; case .stage3: return scorpionStage3 }
    }
    private static let scorpionStage1: [PixelSprite] = [
        s(scorpionPalette, [
            "................",
            "................",
            "................",
            "....r...........",
            "....#r#.........",
            "....#rrr#.......",
            "...#rooooo#.....",
            "..#ow####wo#....",
            "..#oooooooo#....",
            "..#o#yy#oo#.....",
            "..#oooooooo#....",
            "..##########....",
            ".#o#....#o#.....",
            "................",
            "................",
            "................",
        ]),
        s(scorpionPalette, [
            "................",
            "................",
            "................",
            ".....r..........",
            ".....#r#........",
            ".....#rrr#......",
            "...#rooooo#.....",
            "..#ow####wo#....",
            "..#oooooooo#....",
            "..#o#yy#oo#.....",
            "..#oooooooo#....",
            "..##########....",
            ".#o#....#o#.....",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let scorpionStage2: [PixelSprite] = [
        s(scorpionPalette, [
            "................",
            "......r.........",
            ".....#r#........",
            "....#rrrrr#.....",
            "...#roooooo#....",
            "..#oow####woo#..",
            "..#oooooooooo#..",
            "..#oo#yy#ooo#...",
            "..#oooooooooo#..",
            "...############.",
            "..#oo#....#oo#..",
            "..#o#......#o#..",
            "...##........##.",
            "................",
            "................",
            "................",
        ]),
        s(scorpionPalette, [
            "................",
            ".......r........",
            "......#r#.......",
            ".....#rrrrr#....",
            "...#roooooo#....",
            "..#oow####woo#..",
            "..#oooooooooo#..",
            "..#oo#yy#ooo#...",
            "..#oooooooooo#..",
            "...############.",
            "..#oo#....#oo#..",
            "..#o#......#o#..",
            "...##........##.",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let scorpionStage3: [PixelSprite] = [
        s(scorpionPalette, [
            ".......r........",
            "......#r#.......",
            ".....#rrrrr#....",
            "...#rooooooo#...",
            "..#oow#####woo#.",
            "..#oooooooooooo#",
            "..#ooo#yy#ooooo#",
            "..#oooooooooooo#",
            "...#############",
            "..#ooo#....#ooo#",
            "..#oo#......#oo#",
            "...###......###.",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(scorpionPalette, [
            "........r.......",
            ".......#r#......",
            "......#rrrrr#...",
            "...#rooooooo#...",
            "..#oow#####woo#.",
            "..#oooooooooooo#",
            "..#ooo#yy#ooooo#",
            "..#oooooooooooo#",
            "...#############",
            "..#ooo#....#ooo#",
            "..#oo#......#oo#",
            "...###......###.",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]

    // MARK: - Fish

    private static let fishPalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "b": .blue, "l": .lightGray, "o": .orange, "w": .white, "y": .yellow, "t": .teal,
    ]
    private static func fishFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage { case .stage1: return fishStage1; case .stage2: return fishStage2; case .stage3: return fishStage3 }
    }
    private static let fishStage1: [PixelSprite] = [
        s(fishPalette, [
            "................",
            "................",
            "................",
            "...o...........o",
            "..#o#.....####..",
            "..#bbbbbb#llll#.",
            ".#bbtbwbb#llll#.",
            ".#bbbbbbb#llll#.",
            "..#bbbbbb#llll#.",
            "..#bbbbb####....",
            "...#######......",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(fishPalette, [
            "................",
            "................",
            "................",
            "...o...........o",
            "..#o#.....####..",
            "..#bbbbbb#llll#.",
            ".#bbt####b#lll#.",
            ".#bbbbbbb#llll#.",
            "..#bbbbbb#llll#.",
            "..#bbbbb####....",
            "...#######......",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let fishStage2: [PixelSprite] = [
        s(fishPalette, [
            "................",
            "................",
            "..o...........oo",
            ".#o#.....#####..",
            ".#bbbbbbb#llll#.",
            "#bbtbbwbbb#lll#.",
            "#bbbbbbbbbb#ll#.",
            ".#bbbbbbb#llll#.",
            ".#bbbbbbbb#lll#.",
            "..#bbbbb######..",
            "...#########....",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(fishPalette, [
            "................",
            "................",
            "..o...........oo",
            ".#o#.....#####..",
            ".#bbbbbbb#llll#.",
            "#bbt#####b#lll#.",
            "#bbbbbbbbbb#ll#.",
            ".#bbbbbbb#llll#.",
            ".#bbbbbbbb#lll#.",
            "..#bbbbb######..",
            "...#########....",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let fishStage3: [PixelSprite] = [
        s(fishPalette, [
            "................",
            ".o...........oo.",
            "#o#.....######..",
            "#bbbbbbb#lllll#.",
            "bbtbbbwbb#llll#.",
            "bbbbbbbbb#llll#.",
            "bbbbbbbbbb#lll#.",
            "#bbbbbbb#lllll#.",
            "#bbbbbbbb######.",
            ".########.......",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(fishPalette, [
            "................",
            ".o...........oo.",
            "#o#.....######..",
            "#bbbbbbb#lllll#.",
            "bbt######b#lll#.",
            "bbbbbbbbb#llll#.",
            "bbbbbbbbbb#lll#.",
            "#bbbbbbb#lllll#.",
            "#bbbbbbbb######.",
            ".########.......",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]

    // MARK: - Lightning

    private static let lightningPalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "y": .yellow, "w": .white, "o": .orange, "l": .lightGray,
    ]
    private static func lightningFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage { case .stage1: return lightningStage1; case .stage2: return lightningStage2; case .stage3: return lightningStage3 }
    }
    private static let lightningStage1: [PixelSprite] = [
        s(lightningPalette, [
            "................",
            "................",
            "................",
            "....#yyyyy#.....",
            "...#ywwwyyo#....",
            "...#ywwwyyyy#...",
            "....#yyyyyyy#...",
            ".....#yyyyyy#...",
            "......#yyyyo#...",
            ".......#yyyy#...",
            "........#yyy#...",
            ".........###....",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(lightningPalette, [
            "................",
            "................",
            "....#yyyyy#.....",
            "...#ywwwyyo#....",
            "...#ywwwyyyy#...",
            "....#yyyyyyy#...",
            ".....#yyyyyy#...",
            "......#yyyyo#...",
            ".......#yyyy#...",
            "........#yyy#...",
            ".........###....",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let lightningStage2: [PixelSprite] = [
        s(lightningPalette, [
            "................",
            "...#yyyyyy#.....",
            "..#ywwwwyyo#....",
            "..#ywwwwyyyy#...",
            "...#yyyyyyyy#...",
            "....#yyyyyyy#...",
            ".....#yyyyyy#...",
            "......#yyyyyoo#.",
            ".......#yyyyyyy#",
            "........#yyyyyy#",
            ".........#####..",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(lightningPalette, [
            "...#yyyyyy#.....",
            "..#ywwwwyyo#....",
            "..#ywwwwyyyy#...",
            "...#yyyyyyyy#...",
            "....#yyyyyyy#...",
            ".....#yyyyyy#...",
            "......#yyyyyoo#.",
            ".......#yyyyyyy#",
            "........#yyyyyy#",
            ".........#####..",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let lightningStage3: [PixelSprite] = [
        s(lightningPalette, [
            "..#yyyyyyyy#....",
            ".#ywwwwwyyo#....",
            ".#ywwwwyyyyyy#..",
            "..#yyyyyyyyy#...",
            "...#yyyyyyyy#...",
            "....#yyyyyyy#...",
            ".....#yyyyyy#...",
            "......#yyyyyyy#.",
            ".......#yyyyyyyy",
            "........#yyyyyy#",
            ".........######.",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(lightningPalette, [
            ".#yyyyyyyy#.....",
            "#ywwwwwyyo#.....",
            "#ywwwwyyyyyy#...",
            ".#yyyyyyyyy#....",
            "..#yyyyyyyy#....",
            "...#yyyyyyy#....",
            "....#yyyyyy#....",
            ".....#yyyyyyy#..",
            "......#yyyyyyyy.",
            ".......#yyyyyy#.",
            "........######..",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]

    // MARK: - Comet

    private static let cometPalette: [Character: PixelColor] = [
        ".": .clear, "#": .black, "b": .blue, "t": .teal, "w": .white, "l": .lightGray, "y": .yellow,
    ]
    private static func cometFrames(_ stage: Stage) -> [PixelSprite] {
        switch stage { case .stage1: return cometStage1; case .stage2: return cometStage2; case .stage3: return cometStage3 }
    }
    private static let cometStage1: [PixelSprite] = [
        s(cometPalette, [
            "................",
            "................",
            "...#####........",
            "..#bbbbb#.......",
            ".#bbtwtbb#......",
            ".#bbbbbbb#...l..",
            "..#bbbbb#....ll.",
            "...#bbb#.....l..",
            "....###......l..",
            ".............l..",
            "..............l.",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(cometPalette, [
            "................",
            "...#####........",
            "..#bbbbb#.......",
            ".#bbtwtbb#......",
            ".#bbbbbbb#..l...",
            "..#bbbbb#...ll..",
            "...#bbb#....l...",
            "....###.....l...",
            "............l...",
            ".............l..",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let cometStage2: [PixelSprite] = [
        s(cometPalette, [
            "................",
            "..#######.......",
            ".#bbbbbbb#......",
            "#bbtwwtbbb#.....",
            "#bbbbbbbbb#..l..",
            "#bbbbbbbbb#..ll.",
            ".#bbbbbbb#....l.",
            "..#bbbbb#.....l.",
            "...#bbb#......l.",
            "....###.......l.",
            "..............l.",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(cometPalette, [
            "..#######.......",
            ".#bbbbbbb#......",
            "#bbtwwtbbb#.....",
            "#bbbbbbbbb#.l...",
            "#bbbbbbbbb#.ll..",
            ".#bbbbbbb#..l...",
            "..#bbbbb#...l...",
            "...#bbb#....l...",
            "....###.....l...",
            "..............l.",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]
    private static let cometStage3: [PixelSprite] = [
        s(cometPalette, [
            ".#########......",
            "#bbbbbbbbb#.....",
            "#bbttwwtbbb#....",
            "#bbbbbbbbbbb#...",
            "#bbbbbbbbbbb#.l.",
            "#bbbbbbbbbbb#.ll",
            ".#bbbbbbbbb#..l.",
            "..#bbbbbbb#...l.",
            "...#bbbbb#....l.",
            "....#####.....l.",
            "..............l.",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
        s(cometPalette, [
            "#########.......",
            "bbbbbbbbb#......",
            "bbttwwtbbb#.....",
            "bbbbbbbbbbb#....",
            "bbbbbbbbbbb#.l..",
            "bbbbbbbbbbb#.ll.",
            ".#bbbbbbbbb#.l..",
            "..#bbbbbbb#..l..",
            "...#bbbbb#...l..",
            "....#####....l..",
            ".............l..",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]),
    ]

    // MARK: - Default (blob for unmapped species)

    private static func defaultFrames(_ stage: Stage) -> [PixelSprite] {
        let palette: [Character: PixelColor] = [
            ".": .clear, "#": .black, "b": .blue, "l": .lightGray, "w": .white,
        ]
        switch stage {
        case .stage1:
            return [
                s(palette, [
                    "................",
                    "................",
                    "................",
                    "................",
                    ".....######.....",
                    "....#bbbbbb#....",
                    "...#bbw##wbb#...",
                    "...#bbbbbbbb#...",
                    "...#bbbbbbbb#...",
                    "....#bbbbbb#....",
                    ".....######.....",
                    "................",
                    "................",
                    "................",
                    "................",
                    "................",
                ]),
                s(palette, [
                    "................",
                    "................",
                    "................",
                    "................",
                    "......######....",
                    ".....#bbbbbb#...",
                    "....#bbw##wbb#..",
                    "....#bbbbbbbb#..",
                    "....#bbbbbbbb#..",
                    ".....#bbbbbb#...",
                    "......######....",
                    "................",
                    "................",
                    "................",
                    "................",
                    "................",
                ]),
            ]
        case .stage2:
            return [
                s(palette, [
                    "................",
                    "................",
                    "....########....",
                    "...#bbbbbbbb#...",
                    "..#bbww##wwbb#..",
                    "..#bbbbbbbbbb#..",
                    "..#bbbbbbbbbb#..",
                    "..#bbllllllbb#..",
                    "...#bbbbbbbb#...",
                    "....########....",
                    "................",
                    "................",
                    "................",
                    "................",
                    "................",
                    "................",
                ]),
                s(palette, [
                    "................",
                    "................",
                    ".....########...",
                    "....#bbbbbbbb#..",
                    "...#bbww##wwbb#.",
                    "...#bbbbbbbbbb#.",
                    "...#bbbbbbbbbb#.",
                    "...#bbllllllbb#.",
                    "....#bbbbbbbb#..",
                    ".....########...",
                    "................",
                    "................",
                    "................",
                    "................",
                    "................",
                    "................",
                ]),
            ]
        case .stage3:
            return [
                s(palette, [
                    "................",
                    "...##########...",
                    "..#bbbbbbbbbb#..",
                    ".#bbbbbbbbbbbb#.",
                    "#bbwww##wwwbbb##",
                    "#bbbbb####bbbbb#",
                    "#bbbbbbbbbbbbbb#",
                    "#bbbllllllllbbb#",
                    "#bbblllllllbbbb#",
                    ".#bbbbbbbbbbbb#.",
                    "..#bbbbbbbbbb#..",
                    "...##########...",
                    "................",
                    "................",
                    "................",
                    "................",
                ]),
                s(palette, [
                    "................",
                    "....##########..",
                    "...#bbbbbbbbbb#.",
                    "..#bbbbbbbbbbbb#",
                    ".#bbwww##wwwbbb#",
                    ".#bbbbb####bbbb#",
                    ".#bbbbbbbbbbbb#.",
                    ".#bbbllllllllbb#",
                    ".#bbblllllllbbb#",
                    "..#bbbbbbbbbbbb#",
                    "...#bbbbbbbbbb#.",
                    "....##########..",
                    "................",
                    "................",
                    "................",
                    "................",
                ]),
            ]
        }
    }

    // MARK: - Equipment Overlays

    public struct EquippedOverlay: Sendable {
        public let slot: EquipmentSlot
        public let item: Equipment
        public let sprite: PixelSprite
    }

    public static func equippedOverlays(
        equipped: EquippedItems,
        inventory: [Equipment]
    ) -> [EquippedOverlay] {
        var result: [EquippedOverlay] = []
        if let id = equipped.head, let item = inventory.first(where: { $0.id == id }) {
            result.append(EquippedOverlay(slot: .head, item: item, sprite: normalizedOverlay(headOverlay(item: item))))
        }
        if let id = equipped.hand, let item = inventory.first(where: { $0.id == id }) {
            result.append(EquippedOverlay(slot: .hand, item: item, sprite: normalizedOverlay(handOverlay(item: item))))
        }
        if let id = equipped.effect, let item = inventory.first(where: { $0.id == id }) {
            result.append(EquippedOverlay(slot: .effect, item: item, sprite: normalizedOverlay(effectOverlay(item: item))))
        }
        return result
    }

    private static func normalizedOverlay(_ sprite: PixelSprite) -> PixelSprite {
        sprite.nearestResized(width: spriteGridSize, height: spriteGridSize)
    }

    public static func frames(
        species: String?,
        stage: Stage,
        phase: PetPhase,
        equipped: EquippedItems,
        inventory: [Equipment]
    ) -> [PixelSprite] {
        let base = frames(species: species, stage: stage, phase: phase)
        guard phase == .alive else { return base }

        let overlayList = equippedOverlays(equipped: equipped, inventory: inventory).map { $0.sprite }
        guard !overlayList.isEmpty else { return base }
        return base.map { frame in overlayList.reduce(frame) { $0.overlaid(with: $1) } }
    }

    private static func headOverlay(item: Equipment) -> PixelSprite {
        switch item.spriteId {
        case "head_common_1":    return headCodingCap
        case "head_common_2":    return headBaseballCap
        case "head_common_3":    return headBeanie
        case "head_rare_1":      return headGlowCrown
        case "head_rare_2":      return headWizardHat
        case "head_rare_3":      return headSamuraiHelm
        case "head_legendary_1": return headDragonHorns
        case "head_legendary_2": return headFlameCrown
        case "head_mythic_1":    return headHeavenlyHalo
        case "head_mythic_2":    return headCosmicRing
        default:
            switch item.rarity {
            case .common:    return headBeanie
            case .rare:      return headGlowCrown
            case .legendary: return headFlameCrown
            case .mythic:    return headHeavenlyHalo
            }
        }
    }

    private static func handOverlay(item: Equipment) -> PixelSprite {
        switch item.spriteId {
        case "hand_common_1":    return handWoodStaff
        case "hand_common_2":    return handSmallShield
        case "hand_common_3":    return handLaptop
        case "hand_rare_1":      return handMagicKeyboard
        case "hand_rare_2":      return handCrystalStaff
        case "hand_rare_3":      return handEnergySword
        case "hand_legendary_1": return handLightningMouse
        case "hand_legendary_2": return handCodeScroll
        case "hand_mythic_1":    return handInfinityTerminal
        case "hand_mythic_2":    return handHourglass
        default:
            switch item.rarity {
            case .common:    return handWoodStaff
            case .rare:      return handCrystalStaff
            case .legendary: return handLightningMouse
            case .mythic:    return handInfinityTerminal
            }
        }
    }

    private static func effectOverlay(item: Equipment) -> PixelSprite {
        switch item.spriteId {
        case "effect_common_1":    return effectSparkle
        case "effect_common_2":    return effectBubbles
        case "effect_common_3":    return effectLeaves
        case "effect_rare_1":      return effectCodeAura
        case "effect_rare_2":      return effectLightningAura
        case "effect_rare_3":      return effectFlameTrail
        case "effect_legendary_1": return effectRainbowTrail
        case "effect_legendary_2": return effectStarBurst
        case "effect_mythic_1":    return effectCosmicDust
        case "effect_mythic_2":    return effectDimensionRift
        default:
            switch item.rarity {
            case .common:    return effectSparkle
            case .rare:      return effectCodeAura
            case .legendary: return effectStarBurst
            case .mythic:    return effectCosmicDust
            }
        }
    }

    // MARK: Head — Common
    // Hats sit only at rows 0-4 (above the pet head) so the face stays visible.

    // 코딩 모자: small dev cap with binary band
    private static let headCodingCap = s(
        [".": .clear, "#": .black, "d": .darkBlue, "b": .blue, "w": .white],
        [
            "................",
            "................",
            ".....######.....",
            "....#dwbwbd#....",
            "...##########...",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]
    )

    // 야구 모자: red cap with side brim
    private static let headBaseballCap = s(
        [".": .clear, "#": .black, "r": .red, "k": .darkRed, "w": .white],
        [
            "................",
            "................",
            ".....####.......",
            "....#rwrr##.....",
            "...########.....",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]
    )

    // 비니: knit beanie with pom-pom
    private static let headBeanie = s(
        [".": .clear, "#": .black, "m": .mint, "g": .green, "w": .white],
        [
            "................",
            ".......##.......",
            "......#ww#......",
            "....##########..",
            "...#mgmgmgmg#...",
            "...##########...",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]
    )

    // MARK: Head — Rare

    // 빛나는 왕관: small gold crown with three spikes
    private static let headGlowCrown = s(
        [".": .clear, "#": .black, "g": .gold, "y": .yellow, "r": .red, "b": .blue],
        [
            "................",
            "....#..#..#.....",
            "...#g##g##g#....",
            "...#grgygbg#....",
            "...##########...",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]
    )

    // 마법사 모자: tiny pointy purple hat with star
    private static let headWizardHat = s(
        [".": .clear, "#": .black, "p": .purple, "l": .lavender, "y": .yellow],
        [
            "......#y#.......",
            ".....#py#.......",
            "....#ppl#.......",
            "...#pppl#.......",
            "..############..",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]
    )

    // 사무라이 투구: helmet crest with side wings
    private static let headSamuraiHelm = s(
        [".": .clear, "#": .black, "k": .darkGray, "g": .gold, "y": .yellow],
        [
            "................",
            "..#g#......#g#..",
            "..#gg########gg#",
            "..#kkkyyyykkk#..",
            "..############..",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]
    )

    // MARK: Head — Legendary

    // 용의 뿔: pair of curved dragon horns sticking up
    private static let headDragonHorns = s(
        [".": .clear, "#": .black, "r": .darkRed, "o": .red, "y": .gold],
        [
            "..#r#......#r#..",
            "..#or#....#or#..",
            "...#ro#..#or#...",
            "....#oryyyo#....",
            ".....########...",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]
    )

    // 불꽃 왕관: gold band with dancing flames
    private static let headFlameCrown = s(
        [".": .clear, "#": .black, "g": .gold, "y": .yellow, "o": .orange, "r": .red],
        [
            "................",
            "....y...y...y...",
            "...yoy.yoy.yoy..",
            "..#gggggggggg#..",
            "..############..",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]
    )

    // MARK: Head — Mythic

    // 천상의 후광: thin halo ring floating above the head
    private static let headHeavenlyHalo = s(
        [".": .clear, "#": .black, "y": .yellow, "g": .gold, "w": .white],
        [
            "................",
            "...##########...",
            "..#wgggggggw#...",
            "...##########...",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]
    )

    // 우주의 고리: small planet with tilted ring
    private static let headCosmicRing = s(
        [".": .clear, "#": .black, "p": .purple, "l": .lavender, "y": .yellow, "w": .white],
        [
            "................",
            "......####......",
            ".....#plll#.....",
            "...#yyyyyyyy#...",
            ".....#lllp#.....",
            "......####......",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
        ]
    )

    // MARK: Hand — Common
    // Hand items stay in cols 11-15 so they read as held without covering the body.

    // 나무 지팡이: thin wooden staff at the right edge
    private static let handWoodStaff = s(
        [".": .clear, "#": .black, "b": .brown, "g": .ginger, "t": .tan],
        [
            "................",
            "................",
            "................",
            "................",
            "................",
            ".............#..",
            "............#g#.",
            "............#b#.",
            "............#t#.",
            "............#b#.",
            "............#g#.",
            "............#b#.",
            "............#b#.",
            ".............#..",
            "................",
            "................",
        ]
    )

    // 작은 방패: small round wooden shield
    private static let handSmallShield = s(
        [".": .clear, "#": .black, "b": .brown, "t": .tan, "g": .gray],
        [
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            ".............##.",
            "............#bb#",
            "............#tb#",
            "............#bb#",
            ".............##.",
            "................",
            "................",
            "................",
            "................",
        ]
    )

    // 노트북: tiny open laptop
    private static let handLaptop = s(
        [".": .clear, "#": .black, "k": .darkGray, "g": .gray, "w": .white, "b": .blue],
        [
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "............####",
            "...........#kkk#",
            "...........#wbk#",
            "...........#####",
            "..........######",
            "..........#gggg#",
            "..........######",
            "................",
        ]
    )

    // MARK: Hand — Rare

    // 마법 키보드: tiny glowing keyboard
    private static let handMagicKeyboard = s(
        [".": .clear, "#": .black, "k": .darkGray, "w": .white, "p": .lavender],
        [
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "............####",
            "...........#wpw#",
            "...........#kpk#",
            "...........#wpw#",
            "............####",
            "................",
            "................",
        ]
    )

    // 수정 지팡이: staff topped with a small crystal
    private static let handCrystalStaff = s(
        [".": .clear, "#": .black, "b": .brown, "t": .teal, "m": .mint, "w": .white],
        [
            "................",
            "................",
            "................",
            "............#m#.",
            "...........#wmt#",
            "............#m#.",
            ".............#..",
            "............#b#.",
            "............#b#.",
            "............#b#.",
            "............#b#.",
            "............#b#.",
            "............#b#.",
            ".............#..",
            "................",
            "................",
        ]
    )

    // 에너지 검: thin glowing blade
    private static let handEnergySword = s(
        [".": .clear, "#": .black, "c": .teal, "w": .white, "y": .yellow, "k": .darkGray],
        [
            "................",
            "................",
            ".............#..",
            "............#c#.",
            "............#w#.",
            "............#c#.",
            "............#w#.",
            "............#c#.",
            "............#w#.",
            "...........#cwc#",
            "...........##c##",
            "............#k#.",
            "............#y#.",
            ".............#..",
            "................",
            "................",
        ]
    )

    // MARK: Hand — Legendary

    // 번개 마우스: small mouse with a lightning spark
    private static let handLightningMouse = s(
        [".": .clear, "#": .black, "g": .lightGray, "w": .white, "y": .yellow, "k": .darkGray],
        [
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            ".............y..",
            "............y...",
            "............####",
            "...........#wgg#",
            "...........#kgg#",
            "...........#####",
            "................",
            "................",
            "................",
        ]
    )

    // 코드 스크롤: small rolled parchment with code lines
    private static let handCodeScroll = s(
        [".": .clear, "#": .black, "t": .tan, "c": .cream, "b": .brown, "k": .darkGray],
        [
            "................",
            "................",
            "................",
            "................",
            "................",
            "............####",
            "...........#bbb#",
            "...........#ckc#",
            "...........#cck#",
            "...........#kcc#",
            "...........#ckc#",
            "...........#bbb#",
            "............####",
            "................",
            "................",
            "................",
        ]
    )

    // MARK: Hand — Mythic

    // 무한의 터미널: tiny floating terminal window
    private static let handInfinityTerminal = s(
        [".": .clear, "#": .black, "k": .black, "g": .green, "w": .white, "d": .darkGray],
        [
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "............####",
            "...........#dddd",
            "...........#####",
            "...........#kgw#",
            "...........#kkk#",
            "...........#####",
            "................",
            "................",
            "................",
            "................",
        ]
    )

    // 시간의 모래시계: small hourglass at the right hand
    private static let handHourglass = s(
        [".": .clear, "#": .black, "g": .gold, "y": .yellow, "w": .white, "b": .brown],
        [
            "................",
            "................",
            "................",
            "............####",
            "...........#bbb#",
            "...........#yyy#",
            "............#y#.",
            "............#y#.",
            "............#y#.",
            "............#y#.",
            "...........#yyy#",
            "...........#bbb#",
            "............####",
            "................",
            "................",
            "................",
        ]
    )

    // MARK: Effect — Common
    // Effects stick to the outer ring (rows 0-1, rows 14-15, cols 0-1, cols 14-15)
    // so they decorate around the pet without covering its body.

    // 작은 반짝임: four-point sparkles at the four corners
    private static let effectSparkle = s(
        [".": .clear, "y": .yellow, "w": .white],
        [
            ".y............y.",
            "ywy..........ywy",
            ".y............y.",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            ".y............y.",
            "ywy..........ywy",
            ".y............y.",
        ]
    )

    // 버블 이펙트: little bubbles drifting along the edges
    private static let effectBubbles = s(
        [".": .clear, "b": .blue, "w": .white, "c": .teal],
        [
            "bbb..........bbb",
            "bwb..........bwb",
            "bbb..........bbb",
            "................",
            ".b............b.",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            ".b............b.",
            "................",
            "bbb..........bbb",
            "bcb..........bcb",
            "bbb..........bbb",
        ]
    )

    // 잎사귀 흔들림: a few leaves drifting at the sides
    private static let effectLeaves = s(
        [".": .clear, "g": .green, "d": .darkGreen, "l": .lime],
        [
            "lg............gl",
            "dgg..........ggd",
            ".g............g.",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            ".g............g.",
            "lg............gl",
            "dgg..........ggd",
            "................",
        ]
    )

    // MARK: Effect — Rare

    // 코드 오라: 0/1 chars floating along the outer edges
    private static let effectCodeAura = s(
        [".": .clear, "g": .green, "w": .white, "d": .darkGreen],
        [
            "g.w..........d.w",
            ".w............g.",
            "g..............d",
            "................",
            ".w............g.",
            "................",
            "................",
            "g..............w",
            "................",
            ".d............w.",
            "................",
            "g..............w",
            "................",
            "w..............d",
            ".g............w.",
            "g..d........w..g",
        ]
    )

    // 번개 오라: lightning bolts in the four corners
    private static let effectLightningAura = s(
        [".": .clear, "y": .yellow, "w": .white, "o": .orange],
        [
            "y..............y",
            "yw............wy",
            "yo............oy",
            ".o............o.",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            ".o............o.",
            "yo............oy",
            "yw............wy",
            "y..............y",
            "................",
        ]
    )

    // 불꽃 트레일: rising flame trail confined to the bottom edge
    private static let effectFlameTrail = s(
        [".": .clear, "r": .red, "o": .orange, "y": .yellow],
        [
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "...y......y.....",
            "..yoy....yoy....",
            ".yorroy.yorroy..",
            "yorrrroyorrroy..",
        ]
    )

    // MARK: Effect — Legendary

    // 무지개 궤적: rainbow streaming across the bottom edge
    private static let effectRainbowTrail = s(
        [".": .clear, "r": .red, "o": .orange, "y": .yellow, "g": .green, "b": .blue, "p": .purple],
        [
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "rrr.............",
            "rooorr..........",
            "rooyyoor........",
            "rooyyggbbpp.....",
        ]
    )

    // 별빛 폭발: starbursts in the four corners (no center cross)
    private static let effectStarBurst = s(
        [".": .clear, "y": .yellow, "w": .white, "o": .orange],
        [
            "y..o........o..y",
            ".yw..........wy.",
            "..y..........y..",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "..y..........y..",
            ".yw..........wy.",
            "y..o........o..y",
            "................",
        ]
    )

    // MARK: Effect — Mythic

    // 우주 먼지: drifting dust kept along the outer ring
    private static let effectCosmicDust = s(
        [".": .clear, "y": .yellow, "w": .white, "p": .purple, "b": .blue, "l": .lavender],
        [
            "y..l..p....b..wy",
            ".w............l.",
            "p..............b",
            "y..............w",
            "l..............p",
            "w..............y",
            "p..............l",
            "................",
            "................",
            "y..............w",
            "l..............b",
            "w..............p",
            "p..............y",
            "y..............l",
            ".b............w.",
            "yw..b..p....l..y",
        ]
    )

    // 차원 균열: jagged rifts at the left and right edges
    private static let effectDimensionRift = s(
        [".": .clear, "p": .purple, "l": .lavender, "w": .white, "k": .black],
        [
            "k..............k",
            "kp............pk",
            "kpl..........lpk",
            "lwp..........pwl",
            "kpl..........lpk",
            "kp............pk",
            "k..............k",
            "................",
            "................",
            "k..............k",
            "kp............pk",
            "kpl..........lpk",
            "lwp..........pwl",
            "kpl..........lpk",
            "kp............pk",
            "k..............k",
        ]
    )

    // MARK: - Menu Bar Icons (8x8)

    public static func menuBarIcon(phase: PetPhase, stage: Stage) -> PixelSprite {
        let palette: [Character: PixelColor] = [
            ".": .clear, "#": .black, "w": .white, "g": .gray,
        ]
        switch phase {
        case .egg:
            return s(palette, [
                "..####..",
                ".#wwww#.",
                "#wwwwww#",
                "#ww##ww#",
                "#wwwwww#",
                "#wwwwww#",
                ".#wwww#.",
                "..####..",
            ])
        case .dead:
            return s(palette, [
                "..####..",
                ".#gggg#.",
                "#g#gg#g#",
                "#gggggg#",
                "#ggg#gg#",
                "#gggggg#",
                ".#gggg#.",
                "..####..",
            ])
        case .alive:
            switch stage {
            case .stage1:
                return s(palette, [
                    "..####..",
                    ".#wwww#.",
                    "#w#ww#w#",
                    "#wwwwww#",
                    "#wwwwww#",
                    ".#wwww#.",
                    "..####..",
                    "........",
                ])
            case .stage2:
                return s(palette, [
                    ".#....#.",
                    ".######.",
                    "#w##w##w",
                    "#wwwwww#",
                    "#wwwwww#",
                    ".#wwww#.",
                    "..####..",
                    "........",
                ])
            case .stage3:
                return s(palette, [
                    "#......#",
                    "########",
                    "#w##w##w",
                    "#wwwwww#",
                    "#wwwwww#",
                    "#wwwwww#",
                    ".######.",
                    "..#..#..",
                ])
            }
        }
    }
}
