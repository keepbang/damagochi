import DamagochiCore

/// Species-first pixel art.  The shared code in this file is deliberately
/// limited to pixel primitives and growth scaling; each species supplies its
/// own anatomy, proportions and signature attachment instead of inheriting a
/// mascot-like head/body template.
enum SpeciesAnatomySprites {
    /// Species recipes are composed in familiar 24px design coordinates, then
    /// painted into a 48px canvas.  This lets the existing growth rules remain
    /// stable while the native finishing pass has one-pixel room for readable
    /// eyes, ear roots, masks and material detail.
    private static let logicalGridSize = 24
    private static let nativeGridSize = 48

    static let speciesIDs: Set<String> = [
        "owl", "wolf", "crystal", "octopus", "android", "phoenix", "dragon", "sphinx", "robot", "nebula", "butterfly", "cloud", "lotus", "jellyfish", "fox", "unicorn", "mushroom", "fairy", "celestial", "aurora", "turtle", "penguin", "bear", "rock", "cactus", "hedgehog", "parrot", "golem", "elephant", "kraken", "cat", "puppy", "rabbit", "flame", "bat", "scorpion", "fish", "lightning", "moonrabbit", "comet",
        "raven", "otter", "chameleon", "atlas_beetle", "clockwork", "orb", "gryphon", "leviathan", "singularity", "chrono_dragon", "deer", "seal", "peach", "luna_moth", "capybara", "mermaid", "pegasus", "moonflower", "seraph", "dream_whale", "beaver", "koala", "acorn", "badger", "teapot", "lantern", "mammoth", "bastion", "world_tree", "titan", "raccoon", "ferret", "gecko", "skate", "parakeet", "ninja", "wyvern", "thunderbird", "starfox", "void_runner",
    ]

    enum Form {
        case quadruped, bird, swimmer, cephalopod, insect, humanoid
        case object, plant, elemental, dragon, mermaid, skate
    }

    /// Facial treatment is deliberately independent from the animal's body
    /// plan.  A wolf keeps its long torso, a ray keeps its wide fins, and a
    /// world tree keeps its trunk; this only tells the renderer how that
    /// particular anatomy becomes a friendly game character.
    enum FaceStyle: Equatable {
        case muzzle, beak, sea, insect, visor, relic
        case bloom, elemental, draconic, merfolk, ray
    }

    enum Expression: Equatable {
        case warm, sleepy, playful, sparkling, brave, mechanical
    }

    struct Design {
        let form: Form
        let trait: String
        let bodyWidth: Int
        let bodyHeight: Int
        let headWidth: Int
        let headHeight: Int
        let limbLength: Int
        let primary: PixelColor
        let accent: PixelColor
        let faceStyle: FaceStyle
        let expression: Expression
    }

    struct FaceAnchor {
        let x: Int
        let y: Int
        let span: Int
    }

    /// Stage scaling only changes the size of a species' existing anatomy. It
    /// never substitutes an infant-like common head or torso.
    struct Scale {
        let numerator: Int
        let denominator: Int
        let lift: Int

        init(stage: Stage, step: Int) {
            switch stage {
            case .stage1: (numerator, denominator) = (2, 3)
            case .stage2: (numerator, denominator) = (5, 6)
            case .stage3: (numerator, denominator) = (1, 1)
            }
            lift = step == 0 ? 0 : -1
        }

        func value(_ source: Int, minimum: Int = 1) -> Int {
            guard source > 0 else { return 0 }
            return max(minimum, source * numerator / denominator)
        }

        var baseline: Int { 21 + lift }
        var centerX: Int { 12 }
    }

    static func frames(species: String, stage: Stage, direction: SpriteDirection) -> [PixelSprite]? {
        guard let design = design(for: species) else { return nil }
        return (0...1).map { step in
            var canvas = Array(repeating: Array(repeating: PixelColor.clear, count: nativeGridSize), count: nativeGridSize)
            draw(&canvas, design: design, direction: direction, scale: Scale(stage: stage, step: step))
            return PixelSprite(width: nativeGridSize, height: nativeGridSize, pixels: canvas)
        }
    }

    private static func d(
        _ form: Form, _ trait: String,
        _ bodyWidth: Int, _ bodyHeight: Int,
        _ headWidth: Int, _ headHeight: Int,
        _ limbLength: Int,
        _ primary: PixelColor, _ accent: PixelColor
    ) -> Design {
        Design(
            form: form,
            trait: trait,
            bodyWidth: bodyWidth,
            bodyHeight: bodyHeight,
            headWidth: headWidth,
            headHeight: headHeight,
            limbLength: limbLength,
            primary: primary,
            accent: accent,
            faceStyle: faceStyle(for: trait, form: form),
            expression: expression(for: trait)
        )
    }

    // Every catalog id has an explicit build sheet. The values describe the
    // mature silhouette; Scale preserves those differences at earlier stages.
    private static func design(for id: String) -> Design? {
        switch id {
        case "owl":          return d(.bird, id, 10, 11, 7, 6, 2, .brown, .tan)
        case "wolf":         return d(.quadruped, id, 15, 7, 7, 5, 3, .darkGray, .gray)
        case "crystal":      return d(.object, id, 10, 16, 0, 0, 0, .teal, .mint)
        case "octopus":      return d(.cephalopod, id, 11, 7, 0, 0, 7, .purple, .lavender)
        case "android":      return d(.humanoid, id, 8, 10, 6, 6, 6, .lightGray, .blue)
        case "phoenix":      return d(.bird, id, 9, 12, 6, 5, 3, .red, .orange)
        case "dragon":       return d(.dragon, id, 15, 8, 7, 5, 4, .darkRed, .orange)
        case "sphinx":       return d(.quadruped, id, 15, 7, 7, 6, 3, .tan, .gold)
        case "robot":        return d(.humanoid, id, 10, 9, 7, 5, 5, .gray, .yellow)
        case "nebula":       return d(.elemental, id, 16, 9, 0, 0, 0, .purple, .blue)
        case "butterfly":    return d(.insect, id, 5, 10, 4, 4, 4, .darkBlue, .purple)
        case "cloud":        return d(.elemental, id, 16, 7, 0, 0, 0, .cream, .mint)
        case "lotus":        return d(.plant, id, 14, 13, 0, 0, 0, .pink, .mint)
        case "jellyfish":    return d(.cephalopod, id, 13, 6, 0, 0, 8, .pink, .lavender)
        case "fox":          return d(.quadruped, id, 14, 7, 7, 5, 4, .ginger, .cream)
        case "unicorn":      return d(.quadruped, id, 15, 7, 7, 6, 5, .white, .lavender)
        case "mushroom":     return d(.plant, id, 14, 8, 0, 0, 0, .red, .cream)
        case "fairy":        return d(.humanoid, id, 6, 9, 6, 6, 6, .peach, .lavender)
        case "celestial":    return d(.humanoid, id, 7, 11, 6, 6, 6, .cream, .gold)
        case "aurora":       return d(.elemental, id, 17, 8, 0, 0, 0, .purple, .mint)
        case "turtle":       return d(.quadruped, id, 16, 6, 6, 4, 2, .green, .darkGreen)
        case "penguin":      return d(.bird, id, 9, 12, 6, 5, 2, .darkGray, .white)
        case "bear":         return d(.quadruped, id, 11, 10, 8, 7, 3, .brown, .tan)
        case "rock":         return d(.object, id, 15, 10, 0, 0, 0, .darkGray, .lightGray)
        case "cactus":       return d(.plant, id, 9, 17, 0, 0, 0, .green, .lime)
        case "hedgehog":     return d(.quadruped, id, 12, 7, 6, 5, 2, .brown, .darkGray)
        case "parrot":       return d(.bird, id, 8, 10, 5, 5, 2, .green, .coral)
        case "golem":        return d(.humanoid, id, 12, 11, 7, 6, 4, .gray, .darkGray)
        case "elephant":     return d(.quadruped, id, 17, 8, 8, 7, 5, .gray, .lightGray)
        case "kraken":       return d(.cephalopod, id, 14, 9, 0, 0, 9, .darkBlue, .purple)
        case "cat":          return d(.quadruped, id, 11, 7, 7, 6, 3, .ginger, .white)
        case "puppy":        return d(.quadruped, id, 12, 8, 7, 6, 4, .tan, .brown)
        case "rabbit":       return d(.quadruped, id, 9, 8, 6, 6, 4, .white, .pink)
        case "flame":        return d(.elemental, id, 9, 15, 0, 0, 0, .orange, .red)
        case "bat":          return d(.bird, id, 7, 7, 5, 4, 2, .darkGray, .purple)
        case "scorpion":     return d(.insect, id, 13, 6, 5, 4, 5, .orange, .darkRed)
        case "fish":         return d(.swimmer, id, 16, 7, 0, 0, 0, .blue, .teal)
        case "lightning":    return d(.elemental, id, 9, 17, 0, 0, 0, .yellow, .orange)
        case "moonrabbit":   return d(.quadruped, id, 10, 9, 6, 6, 4, .white, .lavender)
        case "comet":        return d(.elemental, id, 17, 7, 0, 0, 0, .orange, .blue)
        case "raven":        return d(.bird, id, 10, 10, 6, 5, 2, .darkGray, .black)
        case "otter":        return d(.quadruped, id, 17, 6, 6, 4, 2, .brown, .tan)
        case "chameleon":    return d(.quadruped, id, 14, 5, 6, 5, 2, .green, .lime)
        case "atlas_beetle": return d(.insect, id, 10, 12, 5, 5, 5, .darkBlue, .blue)
        case "clockwork":    return d(.object, id, 12, 12, 0, 0, 0, .tan, .gold)
        case "orb":          return d(.object, id, 12, 12, 0, 0, 0, .purple, .gold)
        case "gryphon":      return d(.dragon, id, 15, 8, 7, 6, 4, .brown, .gold)
        case "leviathan":    return d(.swimmer, id, 19, 8, 0, 0, 0, .teal, .darkBlue)
        case "singularity":  return d(.object, id, 14, 14, 0, 0, 0, .black, .purple)
        case "chrono_dragon": return d(.dragon, id, 16, 9, 7, 5, 4, .blue, .gold)
        case "deer":         return d(.quadruped, id, 14, 7, 6, 5, 7, .ginger, .brown)
        case "seal":         return d(.swimmer, id, 16, 7, 0, 0, 0, .lightGray, .cream)
        case "peach":        return d(.plant, id, 11, 12, 0, 0, 0, .peach, .green)
        case "luna_moth":    return d(.insect, id, 5, 10, 4, 4, 4, .mint, .lavender)
        case "capybara":     return d(.quadruped, id, 15, 8, 7, 5, 3, .brown, .ginger)
        case "mermaid":      return d(.mermaid, id, 7, 16, 8, 7, 0, .teal, .pink)
        case "pegasus":      return d(.quadruped, id, 15, 7, 7, 6, 6, .cream, .lavender)
        case "moonflower":   return d(.plant, id, 15, 14, 0, 0, 0, .lavender, .purple)
        case "seraph":       return d(.humanoid, id, 7, 12, 6, 6, 7, .white, .gold)
        case "dream_whale":  return d(.swimmer, id, 20, 8, 0, 0, 0, .blue, .mint)
        case "beaver":       return d(.quadruped, id, 13, 8, 6, 5, 3, .brown, .darkBrown)
        case "koala":        return d(.quadruped, id, 10, 9, 8, 6, 3, .gray, .cream)
        case "acorn":        return d(.plant, id, 10, 13, 0, 0, 0, .brown, .tan)
        case "badger":       return d(.quadruped, id, 14, 6, 7, 5, 3, .darkGray, .white)
        case "teapot":       return d(.object, id, 13, 10, 0, 0, 0, .teal, .darkBlue)
        case "lantern":      return d(.object, id, 9, 14, 0, 0, 0, .orange, .brown)
        case "mammoth":      return d(.quadruped, id, 18, 9, 8, 7, 5, .darkGray, .cream)
        case "bastion":      return d(.object, id, 17, 13, 0, 0, 0, .gray, .darkGray)
        case "world_tree":   return d(.plant, id, 16, 19, 0, 0, 0, .green, .brown)
        case "titan":        return d(.humanoid, id, 12, 13, 7, 6, 7, .darkGray, .gold)
        case "raccoon":      return d(.quadruped, id, 13, 7, 7, 5, 3, .gray, .darkGray)
        case "ferret":       return d(.quadruped, id, 18, 5, 5, 4, 2, .cream, .brown)
        case "gecko":        return d(.quadruped, id, 14, 5, 6, 4, 2, .green, .lime)
        case "skate":        return d(.skate, id, 20, 7, 0, 0, 0, .teal, .blue)
        case "parakeet":     return d(.bird, id, 8, 9, 5, 4, 2, .green, .lime)
        case "ninja":        return d(.humanoid, id, 7, 10, 6, 5, 7, .darkGray, .purple)
        case "wyvern":       return d(.dragon, id, 16, 8, 6, 5, 4, .purple, .lavender)
        case "thunderbird":  return d(.bird, id, 11, 11, 6, 5, 3, .darkBlue, .yellow)
        case "starfox":      return d(.quadruped, id, 14, 7, 7, 5, 4, .orange, .cream)
        case "void_runner":  return d(.humanoid, id, 8, 11, 6, 5, 7, .darkGray, .teal)
        default: return nil
        }
    }

    private static func draw(_ canvas: inout [[PixelColor]], design: Design, direction: SpriteDirection, scale: Scale) {
        if drawNativeActualSpecies(&canvas, design: design, direction: direction, scale: scale) {
            drawMaterialVolume(&canvas, design: design)
            drawNativeClusteredSurface(&canvas, design: design)
            return
        }

        if drawNativeFeaturedSpecies(&canvas, design: design, direction: direction, scale: scale) {
            drawMaterialVolume(&canvas, design: design)
            drawNativeClusteredSurface(&canvas, design: design)
            drawNativeFeaturedSurface(&canvas, design: design, direction: direction, scale: scale)
            return
        }

        switch design.form {
        case .quadruped: drawQuadruped(&canvas, design, direction, scale)
        case .bird: drawBird(&canvas, design, direction, scale)
        case .swimmer: drawSwimmer(&canvas, design, direction, scale)
        case .cephalopod: drawCephalopod(&canvas, design, direction, scale)
        case .insect: drawInsect(&canvas, design, direction, scale)
        case .humanoid: drawHumanoid(&canvas, design, direction, scale)
        case .object: drawObject(&canvas, design, direction, scale)
        case .plant: drawPlant(&canvas, design, direction, scale)
        case .elemental: drawElemental(&canvas, design, direction, scale)
        case .dragon: drawDragon(&canvas, design, direction, scale)
        case .mermaid: drawMermaid(&canvas, design, direction, scale)
        case .skate: drawSkate(&canvas, design, direction, scale)
        }
        drawMaterialVolume(&canvas, design: design)
        softenNativeContour(&canvas)
        // Keep the large anatomical forms, but break their perfectly flat
        // fills with a few hand-placed native-pixel clusters before the face
        // is painted. This is the difference between an enlarged icon and a
        // soft game-character sprite at the same on-screen footprint.
        drawNativeClusteredSurface(&canvas, design: design)
        drawCharacterFinish(&canvas, design, direction, scale)
        drawNativeCharacterFinish(&canvas, design: design, direction: direction, scale: scale)
    }

    // MARK: - Pixel primitives

    private static func pixel(_ canvas: inout [[PixelColor]], _ x: Int, _ y: Int, _ color: PixelColor) {
        guard x >= 0, y >= 0, !canvas.isEmpty, !canvas[0].isEmpty else { return }
        let factor = max(1, min(canvas.count / logicalGridSize, canvas[0].count / logicalGridSize))
        let startX = x * factor
        let startY = y * factor
        for nativeY in startY..<(startY + factor) {
            for nativeX in startX..<(startX + factor) {
                nativePixel(&canvas, nativeX, nativeY, color)
            }
        }
    }

    /// Writes directly to the 48px canvas.  These pixels are reserved for the
    /// high-resolution character pass; all recipe coordinates above remain in
    /// the stable logical 24px space.
    private static func nativePixel(_ canvas: inout [[PixelColor]], _ x: Int, _ y: Int, _ color: PixelColor) {
        guard canvas.indices.contains(y), canvas[y].indices.contains(x) else { return }
        canvas[y][x] = color
    }

    private static func nativeRect(_ canvas: inout [[PixelColor]], _ x: Int, _ y: Int, _ width: Int, _ height: Int, _ color: PixelColor) {
        guard width > 0, height > 0 else { return }
        for row in y..<(y + height) {
            for column in x..<(x + width) {
                nativePixel(&canvas, column, row, color)
            }
        }
    }

    private static func rect(_ canvas: inout [[PixelColor]], _ x: Int, _ y: Int, _ width: Int, _ height: Int, _ color: PixelColor) {
        guard width > 0, height > 0 else { return }
        for row in y..<(y + height) {
            for column in x..<(x + width) {
                pixel(&canvas, column, row, color)
            }
        }
    }

    private static func oval(_ canvas: inout [[PixelColor]], _ x: Int, _ y: Int, _ width: Int, _ height: Int, _ color: PixelColor) {
        let radiusX = max(1, width / 2)
        let radiusY = max(1, height / 2)
        for row in -radiusY...radiusY {
            // Quadratic easing expands quickly away from the cap and slows
            // through the middle.  A linear inset traces a 45° rhombus;
            // this gives soft bodies a round sprite contour instead.
            let distance = abs(row)
            let inset = distance * distance * max(0, radiusX - 1) / max(1, radiusY * radiusY)
            for column in -(radiusX - inset)...(radiusX - inset) {
                pixel(&canvas, x + column, y + row, color)
            }
        }
    }

    private static func diamond(_ canvas: inout [[PixelColor]], _ x: Int, _ y: Int, _ radiusX: Int, _ radiusY: Int, _ color: PixelColor) {
        guard radiusX > 0, radiusY > 0 else { return }
        // Legacy callers use this for fins, petals and crystal faces.  It is
        // intentionally a rounded lobe now, not a pointed rhombus, so a pet
        // never inherits the old decorative-diamond silhouette.
        oval(&canvas, x, y, radiusX * 2 + 1, radiusY * 2 + 1, color)
    }

    private static func line(_ canvas: inout [[PixelColor]], _ x: Int, _ y: Int, _ dx: Int, _ dy: Int, _ length: Int, _ color: PixelColor) {
        guard length > 0 else { return }
        for index in 0..<length {
            pixel(&canvas, x + dx * index, y + dy * index, color)
        }
    }

    private static func outlinedOval(_ canvas: inout [[PixelColor]], _ x: Int, _ y: Int, _ width: Int, _ height: Int, _ fill: PixelColor) {
        oval(&canvas, x, y, width + 2, height + 2, softOutline(for: fill))
        oval(&canvas, x, y, width, height, fill)
    }

    private static func outlinedDiamond(_ canvas: inout [[PixelColor]], _ x: Int, _ y: Int, _ radiusX: Int, _ radiusY: Int, _ fill: PixelColor) {
        // Retained as a semantic name for existing species recipes; render a
        // soft lobe rather than an outlined diamond.
        outlinedOval(&canvas, x, y, radiusX * 2 + 1, radiusY * 2 + 1, fill)
    }

    /// Pure black around every body made the sprites read like diagram icons.
    /// Deep coloured outlines preserve pixel readability while keeping fur,
    /// feathers and soft materials gentle.  Black remains for true cavities,
    /// visor gaps and the occasional hard mechanical seam.
    private static func softOutline(for fill: PixelColor) -> PixelColor {
        switch fill {
        case .white, .cream, .peach, .tan, .ginger, .brown, .darkBrown, .warmGray, .cocoa:
            return .darkBrown
        case .red, .orange, .yellow, .gold, .coral, .pink, .blush:
            return .darkRed
        case .green, .darkGreen, .lime, .teal, .mint:
            return .darkGreen
        case .blue, .darkBlue, .purple, .lavender, .mistBlue:
            return .darkBlue
        case .gray, .lightGray, .darkGray:
            return .darkGray
        default:
            return .black
        }
    }
}

private extension SpeciesAnatomySprites {
    // MARK: - Native 48px finishing

    /// Turns the hard 2× enlargement corners into one-pixel chamfers.  This
    /// keeps a deliberate pixel-art edge, but removes the block-stamp look
    /// that made the old low-resolution sprites feel like UI symbols.
    static func softenNativeContour(_ canvas: inout [[PixelColor]]) {
        guard canvas.count >= nativeGridSize, canvas.first?.count ?? 0 >= nativeGridSize else { return }
        let source = canvas

        func isOpaque(_ x: Int, _ y: Int) -> Bool {
            guard source.indices.contains(y), source[y].indices.contains(x) else { return false }
            return !source[y][x].isTransparent
        }

        for y in 2..<(source.count - 2) {
            for x in 2..<(source[y].count - 2) where isOpaque(x, y) {
                let extendsDownOrRight = isOpaque(x + 2, y) || isOpaque(x, y + 2)
                let extendsDownOrLeft = isOpaque(x - 2, y) || isOpaque(x, y + 2)
                let extendsUpOrRight = isOpaque(x + 2, y) || isOpaque(x, y - 2)
                let extendsUpOrLeft = isOpaque(x - 2, y) || isOpaque(x, y - 2)

                if !isOpaque(x, y - 1), !isOpaque(x - 1, y), isOpaque(x + 1, y), isOpaque(x, y + 1), extendsDownOrRight {
                    nativePixel(&canvas, x, y, .clear)
                } else if !isOpaque(x, y - 1), !isOpaque(x + 1, y), isOpaque(x - 1, y), isOpaque(x, y + 1), extendsDownOrLeft {
                    nativePixel(&canvas, x, y, .clear)
                } else if !isOpaque(x, y + 1), !isOpaque(x - 1, y), isOpaque(x + 1, y), isOpaque(x, y - 1), extendsUpOrRight {
                    nativePixel(&canvas, x, y, .clear)
                } else if !isOpaque(x, y + 1), !isOpaque(x + 1, y), isOpaque(x - 1, y), isOpaque(x, y - 1), extendsUpOrLeft {
                    nativePixel(&canvas, x, y, .clear)
                }
            }
        }
    }

    static func nativeCoordinate(_ logical: Int) -> Int {
        logical * (nativeGridSize / logicalGridSize)
    }

    static func nativeCenter(_ logical: Int) -> Int {
        nativeCoordinate(logical) + (nativeGridSize / logicalGridSize - 1)
    }

    static func nativePill(
        _ canvas: inout [[PixelColor]],
        centerX: Int,
        centerY: Int,
        width: Int,
        height: Int,
        color: PixelColor
    ) {
        guard width > 0, height > 0 else { return }
        let left = centerX - width / 2
        let top = centerY - height / 2
        if width < 3 || height < 3 {
            nativeRect(&canvas, left, top, width, height, color)
            return
        }
        nativeRect(&canvas, left + 1, top, width - 2, height, color)
        nativeRect(&canvas, left, top + 1, width, height - 2, color)
    }

    /// A real native-resolution oval is used for the featured character
    /// bodies.  Unlike a rounded rectangle, its 2-1 style contour keeps the
    /// silhouette soft at the same physical size as the old 24px art.
    static func nativeOval(
        _ canvas: inout [[PixelColor]],
        centerX: Int,
        centerY: Int,
        width: Int,
        height: Int,
        color: PixelColor
    ) {
        guard width > 0, height > 0 else { return }
        let radiusX = max(1, width / 2)
        let radiusY = max(1, height / 2)
        for row in -radiusY...radiusY {
            // The eased contour keeps one-pixel clusters but avoids the
            // straight diagonal sides that made a "rounded" head look like a
            // decorative diamond. It is deliberately not anti-aliased.
            let distance = abs(row)
            let inset = min(
                radiusX - 1,
                distance * distance * max(1, radiusX - 1) / max(1, radiusY * radiusY)
            )
            let halfWidth = max(1, radiusX - inset)
            nativeRect(&canvas, centerX - halfWidth, centerY + row, halfWidth * 2 + 1, 1, color)
        }
    }

    static func nativeOutlinedPill(
        _ canvas: inout [[PixelColor]],
        centerX: Int,
        centerY: Int,
        width: Int,
        height: Int,
        fill: PixelColor
    ) {
        nativeOval(
            &canvas,
            centerX: centerX,
            centerY: centerY,
            // A two-native-pixel outline remains continuous around light
            // bodies on a white UI background; a one-pixel rim broke into
            // visually dotted segments along the stepped curve.
            width: width + 4,
            height: height + 4,
            color: softOutline(for: fill)
        )
        nativeOval(&canvas, centerX: centerX, centerY: centerY, width: width, height: height, color: fill)
    }

    /// Paints a deliberately uneven 2–3px colour cluster, but only over the
    /// requested material.  The source check keeps fur highlights inside the
    /// silhouette and prevents a finishing pass from covering a face, mask or
    /// accessory that has already been drawn.
    static func nativeClusterReplacing(
        _ canvas: inout [[PixelColor]],
        source: PixelColor,
        atX: Int,
        _ atY: Int,
        color: PixelColor,
        cells: [(Int, Int)]
    ) {
        guard source != color else { return }
        for (offsetX, offsetY) in cells {
            let x = atX + offsetX
            let y = atY + offsetY
            guard canvas.indices.contains(y), canvas[y].indices.contains(x), canvas[y][x] == source else { continue }
            canvas[y][x] = color
        }
    }

    /// Adds a small number of clustered highlights and shadows to every
    /// anatomy recipe.  Old recipes still own their silhouette; this pass only
    /// gives their broad colour fields the hand-placed pixel depth visible in
    /// RPG character sprites instead of leaving 2× enlarged flat panels.
    static func drawNativeClusteredSurface(_ canvas: inout [[PixelColor]], design: Design) {
        var minX = canvas.first?.count ?? 0
        var minY = canvas.count
        var maxX = -1
        var maxY = -1

        for y in canvas.indices {
            for x in canvas[y].indices where !canvas[y][x].isTransparent {
                minX = min(minX, x)
                minY = min(minY, y)
                maxX = max(maxX, x)
                maxY = max(maxY, y)
            }
        }
        guard maxX >= minX, maxY >= minY else { return }

        let width = maxX - minX + 1
        let height = maxY - minY + 1
        let light = materialHighlight(for: design.primary)
        let shadow = materialShadow(for: design.primary)
        let topLeftX = minX + max(3, width / 4)
        let topLeftY = minY + max(3, height / 4)
        let lowerRightX = maxX - max(4, width / 4)
        let lowerRightY = maxY - max(4, height / 4)

        nativeClusterReplacing(
            &canvas,
            source: design.primary,
            atX: topLeftX,
            topLeftY,
            color: light,
            cells: [(0, 0), (1, 0), (0, 1), (1, 1), (2, 1)]
        )
        nativeClusterReplacing(
            &canvas,
            source: design.primary,
            atX: lowerRightX,
            lowerRightY,
            color: shadow,
            cells: [(0, 0), (1, 0), (-1, 1), (0, 1), (1, 1), (0, 2)]
        )
    }

    /// The three animals that prompted the resolution change are drawn as
    /// genuine 48px characters instead of enlarged 24px recipes.  They serve
    /// as the visual standard for the rest of the species: a connected animal
    /// silhouette first, then a small face and only then surface detail.
    /// High-priority species use a complete native blueprint rather than the
    /// form-level body recipe. Each blueprint starts from the real creature's
    /// load-bearing parts (spine, shell, wing, trunk, segmented body) and
    /// only then adds a small friendly face.
    static func drawNativeActualSpecies(
        _ canvas: inout [[PixelColor]],
        design: Design,
        direction: SpriteDirection,
        scale: Scale
    ) -> Bool {
        switch design.trait {
        case "owl":
            drawNativeAnatomicalOwl(&canvas, direction: direction, scale: scale)
        case "wolf", "fox", "starfox":
            drawNativeAnatomicalCanid(&canvas, design: design, direction: direction, scale: scale)
        case "phoenix", "penguin", "raven", "parakeet", "thunderbird":
            drawNativeAnatomicalBird(&canvas, design: design, direction: direction, scale: scale)
        case "bat":
            drawNativeAnatomicalBat(&canvas, direction: direction, scale: scale)
        case "butterfly", "luna_moth":
            drawNativeAnatomicalLepidoptera(&canvas, design: design, direction: direction, scale: scale)
        case "sphinx", "gryphon":
            drawNativeAnatomicalHybrid(&canvas, design: design, direction: direction, scale: scale)
        case "unicorn", "deer", "pegasus":
            drawNativeAnatomicalHoofed(&canvas, design: design, direction: direction, scale: scale)
        case "cat", "puppy", "hedgehog", "koala":
            drawNativeAnatomicalSmallMammal(&canvas, design: design, direction: direction, scale: scale)
        case "otter", "ferret", "badger", "beaver", "capybara":
            drawNativeAnatomicalLongMammal(&canvas, design: design, direction: direction, scale: scale)
        case "turtle", "chameleon", "gecko", "scorpion":
            drawNativeAnatomicalCrawler(&canvas, design: design, direction: direction, scale: scale)
        case "jellyfish", "fish", "seal", "leviathan":
            drawNativeAnatomicalSeaLife(&canvas, design: design, direction: direction, scale: scale)
        case "octopus", "kraken":
            drawNativeAnatomicalCephalopod(&canvas, design: design, direction: direction, scale: scale)
        case "android", "robot":
            drawNativeAnatomicalAndroid(&canvas, design: design, direction: direction, scale: scale)
        case "atlas_beetle":
            drawNativeAnatomicalBeetle(&canvas, direction: direction, scale: scale)
        case "crystal", "rock", "clockwork", "orb", "singularity", "lantern", "bastion":
            drawNativeAnatomicalObject(&canvas, design: design, direction: direction, scale: scale)
        case "lotus", "mushroom", "cactus", "parrot", "peach", "moonflower", "acorn":
            drawNativeAnatomicalPlant(&canvas, design: design, direction: direction, scale: scale)
        case "flame", "comet", "cloud", "nebula", "aurora":
            drawNativeAnatomicalElemental(&canvas, design: design, direction: direction, scale: scale)
        case "fairy", "celestial", "golem", "seraph", "titan", "ninja", "void_runner":
            drawNativeAnatomicalHumanoid(&canvas, design: design, direction: direction, scale: scale)
        case "dragon", "chrono_dragon", "wyvern":
            drawNativeAnatomicalDragon(&canvas, design: design, direction: direction, scale: scale)
        case "elephant", "mammoth":
            drawNativeAnatomicalElephant(&canvas, mammoth: design.trait == "mammoth", direction: direction, scale: scale)
        case "dream_whale":
            drawNativeAnatomicalWhale(&canvas, direction: direction, scale: scale)
        case "teapot":
            drawNativeAnatomicalTeapot(&canvas, direction: direction, scale: scale)
        case "world_tree":
            drawNativeAnatomicalWorldTree(&canvas, direction: direction, scale: scale)
        case "mermaid":
            drawNativeAnatomicalMermaid(&canvas, direction: direction, scale: scale)
        case "skate":
            drawNativeAnatomicalSkate(&canvas, direction: direction, scale: scale)
        case "lightning":
            drawNativeAnatomicalLightning(&canvas, direction: direction, scale: scale)
        default:
            return false
        }
        return true
    }

    static func nativeDirectionSide(_ direction: SpriteDirection) -> Int {
        switch direction {
        case .sideLeft: return -1
        case .sideRight: return 1
        case .front, .back: return 0
        }
    }

    static func nativeStroke(
        _ canvas: inout [[PixelColor]],
        fromX: Int,
        _ fromY: Int,
        dx: Int,
        dy: Int,
        length: Int,
        width: Int = 2,
        color: PixelColor
    ) {
        guard length > 0 else { return }
        for step in 0..<length {
            nativeRect(
                &canvas,
                fromX + dx * step - width / 2,
                fromY + dy * step - width / 2,
                width,
                width,
                color
            )
        }
    }

    static func nativePolyline(
        _ canvas: inout [[PixelColor]],
        points: [(Int, Int)],
        width: Int = 2,
        color: PixelColor
    ) {
        guard points.count > 1 else { return }
        for index in 1..<points.count {
            let start = points[index - 1]
            let end = points[index]
            let deltaX = end.0 - start.0
            let deltaY = end.1 - start.1
            let steps = max(abs(deltaX), abs(deltaY))
            guard steps > 0 else { continue }
            for step in 0...steps {
                let x = start.0 + deltaX * step / steps
                let y = start.1 + deltaY * step / steps
                nativeRect(&canvas, x - width / 2, y - width / 2, width, width, color)
            }
        }
    }

    static func drawNativeEyePair(_ canvas: inout [[PixelColor]], centerX: Int, centerY: Int, separation: Int, ink: PixelColor = .darkBrown) {
        nativeEye(&canvas, centerX: centerX - separation, centerY: centerY, ink: ink)
        nativeEye(&canvas, centerX: centerX + separation, centerY: centerY, ink: ink)
    }

    static func drawNativeAnatomicalOwl(_ canvas: inout [[PixelColor]], direction: SpriteDirection, scale: Scale) {
        let x = nativeGridSize / 2
        let ground = nativeCenter(scale.baseline)
        let side = nativeDirectionSide(direction)
        let bodyY = ground - 12 + scale.lift
        let headY = bodyY - 7

        if side == 0 {
            // A real owl has a broad head, compact vertical body and folded
            // wings; it should not share the long-legged bird body plan.
            nativeOutlinedPill(&canvas, centerX: x - 8, centerY: bodyY + 2, width: 7, height: 18, fill: .brown)
            nativeOutlinedPill(&canvas, centerX: x + 8, centerY: bodyY + 2, width: 7, height: 18, fill: .brown)
            nativeOutlinedPill(&canvas, centerX: x, centerY: bodyY, width: 19, height: 23, fill: .brown)
            nativeOval(&canvas, centerX: x, centerY: bodyY + 4, width: 13, height: 15, color: .cream)
            nativeOutlinedPill(&canvas, centerX: x, centerY: headY, width: 21, height: 17, fill: .brown)
            nativePill(&canvas, centerX: x - 5, centerY: headY, width: 8, height: 9, color: .cream)
            nativePill(&canvas, centerX: x + 5, centerY: headY, width: 8, height: 9, color: .cream)
            drawNativeEyePair(&canvas, centerX: x, centerY: headY, separation: 5)
            nativePill(&canvas, centerX: x, centerY: headY + 6, width: 5, height: 3, color: .gold)
            nativeStroke(&canvas, fromX: x - 7, headY - 6, dx: -1, dy: -1, length: 3, color: .brown)
            nativeStroke(&canvas, fromX: x + 7, headY - 6, dx: 1, dy: -1, length: 3, color: .brown)
            nativePill(&canvas, centerX: x - 5, centerY: ground - 1, width: 5, height: 3, color: .gold)
            nativePill(&canvas, centerX: x + 5, centerY: ground - 1, width: 5, height: 3, color: .gold)
            if direction == .back {
                nativeRect(&canvas, x - 9, bodyY - 4, 19, 3, .tan)
                nativeStroke(&canvas, fromX: x, bodyY + 1, dx: 0, dy: 1, length: 6, color: .darkBrown)
            }
        } else {
            let headX = x + side * 8
            nativeOutlinedPill(&canvas, centerX: x - side * 2, centerY: bodyY + 1, width: 25, height: 17, fill: .brown)
            nativeOutlinedPill(&canvas, centerX: headX, centerY: headY + 2, width: 18, height: 14, fill: .brown)
            nativeOutlinedPill(&canvas, centerX: x - side * 5, centerY: bodyY + 1, width: 14, height: 15, fill: .tan)
            nativePill(&canvas, centerX: headX + side * 5, centerY: headY + 2, width: 5, height: 5, color: .cream)
            nativeEye(&canvas, centerX: headX + side * 5, centerY: headY + 2, ink: .darkBrown)
            nativeStroke(&canvas, fromX: headX + side * 9, headY + 7, dx: side, dy: 0, length: 4, color: .gold)
            nativeStroke(&canvas, fromX: headX - side * 5, headY - 5, dx: -side, dy: -1, length: 3, color: .brown)
            nativePill(&canvas, centerX: x - 4, centerY: ground - 1, width: 6, height: 3, color: .gold)
            nativePill(&canvas, centerX: x + 5, centerY: ground - 1, width: 6, height: 3, color: .gold)
        }
    }

    static func drawNativeAnatomicalCanid(_ canvas: inout [[PixelColor]], design: Design, direction: SpriteDirection, scale: Scale) {
        let x = nativeGridSize / 2
        let ground = nativeCenter(scale.baseline)
        let side = nativeDirectionSide(direction)
        let fur = design.primary
        let chest: PixelColor = design.trait == "wolf" ? .lightGray : .cream
        let tailFill: PixelColor = design.trait == "starfox" ? .yellow : design.accent
        let bodyY = ground - 9 + scale.lift
        let headY = bodyY - 8
        let bodyWidth = design.trait == "wolf" ? 27 : design.trait == "starfox" ? 25 : 24
        let tailWidth = design.trait == "wolf" ? 16 : design.trait == "starfox" ? 18 : 14
        let earLength = design.trait == "wolf" ? 4 : design.trait == "starfox" ? 6 : 5

        if side == 0 {
            nativeOutlinedPill(&canvas, centerX: x - bodyWidth / 2 + 2, centerY: bodyY + 3, width: tailWidth, height: 11, fill: tailFill)
            nativeOutlinedPill(&canvas, centerX: x, centerY: bodyY, width: bodyWidth, height: 18, fill: fur)
            nativeOval(&canvas, centerX: x, centerY: bodyY + 4, width: 13, height: 11, color: chest)
            nativeOutlinedPill(&canvas, centerX: x, centerY: headY, width: 20, height: 16, fill: fur)
            nativeStroke(&canvas, fromX: x - 7, headY - 6, dx: -1, dy: -1, length: earLength, color: fur)
            nativeStroke(&canvas, fromX: x + 7, headY - 6, dx: 1, dy: -1, length: earLength, color: fur)
            nativePill(&canvas, centerX: x, centerY: headY + 4, width: 11, height: 6, color: chest)
            drawNativeEyePair(&canvas, centerX: x, centerY: headY - 1, separation: 4)
            nativePill(&canvas, centerX: x, centerY: headY + 3, width: 3, height: 2, color: .darkBrown)
            nativePill(&canvas, centerX: x - 6, centerY: ground - 1, width: 7, height: 4, color: fur)
            nativePill(&canvas, centerX: x + 6, centerY: ground - 1, width: 7, height: 4, color: fur)
            if direction == .back {
                nativeStroke(&canvas, fromX: x, bodyY - 5, dx: 0, dy: 1, length: 8, color: design.accent)
            }
        } else {
            let headX = x + side * 10
            let tailX = x - side * 13
            nativeOutlinedPill(&canvas, centerX: tailX, centerY: bodyY + 1, width: tailWidth, height: 10, fill: tailFill)
            nativeOutlinedPill(&canvas, centerX: x, centerY: bodyY, width: bodyWidth + 4, height: 14, fill: fur)
            nativeOval(&canvas, centerX: x - side * 2, centerY: bodyY + 3, width: 15, height: 7, color: chest)
            nativeOutlinedPill(&canvas, centerX: headX, centerY: headY + 4, width: 17, height: 13, fill: fur)
            nativeStroke(&canvas, fromX: headX - side * 5, headY - 1, dx: -side, dy: -1, length: earLength, color: fur)
            nativeStroke(&canvas, fromX: headX + side * 4, headY - 2, dx: side, dy: -1, length: earLength, color: fur)
            nativePill(&canvas, centerX: headX + side * 7, centerY: headY + 6, width: 7, height: 5, color: chest)
            nativeEye(&canvas, centerX: headX + side * 4, centerY: headY + 3, ink: .darkBrown)
            nativePill(&canvas, centerX: x - 8, centerY: ground - 1, width: 6, height: 4, color: fur)
            nativePill(&canvas, centerX: x + 7, centerY: ground - 1, width: 6, height: 4, color: fur)
        }
    }

    static func drawNativeAnatomicalCephalopod(_ canvas: inout [[PixelColor]], design: Design, direction: SpriteDirection, scale: Scale) {
        let x = nativeGridSize / 2
        let ground = nativeCenter(scale.baseline)
        let side = nativeDirectionSide(direction)
        let bellY = ground - 16 + scale.lift
        let armColor: PixelColor = design.trait == "kraken" ? .purple : .lavender
        let armCount = design.trait == "kraken" ? 6 : 5

        let headX = side == 0 ? x : x + side * 4
        nativeOutlinedPill(&canvas, centerX: headX, centerY: bellY, width: design.trait == "kraken" ? 25 : 22, height: 18, fill: design.primary)
        nativeOval(&canvas, centerX: headX, centerY: bellY + 4, width: 16, height: 8, color: armColor)
        for index in 0..<armCount {
            let offset = (index - armCount / 2) * 4
            let startX = headX + offset
            let bend = side == 0 ? (offset < 0 ? -1 : 1) : (index.isMultiple(of: 2) ? -side : side)
            nativeStroke(&canvas, fromX: startX, bellY + 8, dx: bend, dy: 1, length: 6 + abs(offset) / 4, width: 3, color: armColor)
            nativePill(&canvas, centerX: startX + bend * 4, centerY: ground - 2, width: 4, height: 4, color: armColor)
        }
        nativeRect(&canvas, headX - 7, bellY + 7, 15, 3, armColor)
        if direction == .front {
            drawNativeEyePair(&canvas, centerX: headX, centerY: bellY - 1, separation: 4, ink: .darkBlue)
            nativeSmile(&canvas, centerX: headX, centerY: bellY + 4, ink: .darkBlue, expression: .warm)
        } else if direction == .back {
            nativePill(&canvas, centerX: headX, centerY: bellY - 2, width: 13, height: 3, color: design.accent)
        } else {
            nativeEye(&canvas, centerX: headX + side * 5, centerY: bellY - 1, ink: .darkBlue)
            nativeStroke(&canvas, fromX: headX - side * 8, bellY - 2, dx: -side, dy: -1, length: 3, color: design.accent)
        }
    }

    static func drawNativeAnatomicalAndroid(_ canvas: inout [[PixelColor]], design: Design, direction: SpriteDirection, scale: Scale) {
        let x = nativeGridSize / 2
        let ground = nativeCenter(scale.baseline)
        let side = nativeDirectionSide(direction)
        let metal: PixelColor = design.trait == "robot" ? .gray : .lightGray
        let headX = x + side * 2
        let headY = ground - 27 + scale.lift
        let torsoY = ground - 14 + scale.lift

        nativeOutlinedPill(&canvas, centerX: headX, centerY: headY, width: 17, height: 13, fill: metal)
        nativePill(&canvas, centerX: headX, centerY: headY, width: 13, height: 5, color: .darkBlue)
        if direction == .back {
            nativePill(&canvas, centerX: headX, centerY: headY + 1, width: 11, height: 5, color: .darkGray)
        } else if side == 0 {
            nativePill(&canvas, centerX: headX - 4, centerY: headY, width: 3, height: 2, color: design.accent)
            nativePill(&canvas, centerX: headX + 4, centerY: headY, width: 3, height: 2, color: design.accent)
        } else {
            nativePill(&canvas, centerX: headX + side * 4, centerY: headY, width: 3, height: 2, color: design.accent)
        }
        if design.trait == "robot" {
            nativeStroke(&canvas, fromX: headX, headY - 8, dx: 0, dy: -1, length: 4, color: .yellow)
            nativePill(&canvas, centerX: headX, centerY: headY - 11, width: 3, height: 3, color: .yellow)
        }
        nativeOutlinedPill(&canvas, centerX: x, centerY: torsoY, width: 16, height: 16, fill: metal)
        nativePill(&canvas, centerX: x, centerY: torsoY + 1, width: 9, height: 7, color: design.accent)
        nativeStroke(&canvas, fromX: x - 9, torsoY - 2, dx: -1, dy: 1, length: 6, width: 3, color: metal)
        nativeStroke(&canvas, fromX: x + 9, torsoY - 2, dx: 1, dy: 1, length: 6, width: 3, color: metal)
        nativePill(&canvas, centerX: x - 13, centerY: torsoY + 5, width: 5, height: 5, color: design.accent)
        nativePill(&canvas, centerX: x + 13, centerY: torsoY + 5, width: 5, height: 5, color: design.accent)
        nativeStroke(&canvas, fromX: x - 5, torsoY + 8, dx: 0, dy: 1, length: 8, width: 4, color: metal)
        nativeStroke(&canvas, fromX: x + 5, torsoY + 8, dx: 0, dy: 1, length: 8, width: 4, color: metal)
        nativePill(&canvas, centerX: x - 6, centerY: ground - 1, width: 8, height: 4, color: .darkGray)
        nativePill(&canvas, centerX: x + 6, centerY: ground - 1, width: 8, height: 4, color: .darkGray)
        if direction == .back {
            nativePill(&canvas, centerX: x, centerY: torsoY, width: 8, height: 8, color: .darkGray)
        }
    }

    static func drawNativeAnatomicalBeetle(_ canvas: inout [[PixelColor]], direction: SpriteDirection, scale: Scale) {
        let x = nativeGridSize / 2
        let ground = nativeCenter(scale.baseline)
        let side = nativeDirectionSide(direction)
        let y = ground - 16 + scale.lift

        if side == 0 {
            nativeOutlinedPill(&canvas, centerX: x, centerY: y + 6, width: 21, height: 19, fill: .darkBlue)
            nativePill(&canvas, centerX: x, centerY: y + 6, width: 3, height: 16, color: .blue)
            nativeOutlinedPill(&canvas, centerX: x, centerY: y - 5, width: 15, height: 10, fill: .darkBlue)
            nativeOutlinedPill(&canvas, centerX: x, centerY: y - 12, width: 11, height: 8, fill: .darkBlue)
            nativeStroke(&canvas, fromX: x, y - 15, dx: 0, dy: -1, length: 8, width: 3, color: .blue)
            for offset in [-8, -3, 3, 8] {
                let dir = offset < 0 ? -1 : 1
                nativeStroke(&canvas, fromX: x + offset, y + 8, dx: dir, dy: 1, length: 5, width: 2, color: .black)
            }
            if direction == .front {
                drawNativeEyePair(&canvas, centerX: x, centerY: y - 12, separation: 3, ink: .cream)
            } else {
                nativePill(&canvas, centerX: x, centerY: y + 5, width: 13, height: 3, color: .blue)
            }
        } else {
            let headX = x + side * 11
            nativeOutlinedPill(&canvas, centerX: x, centerY: y + 5, width: 28, height: 13, fill: .darkBlue)
            nativePill(&canvas, centerX: x, centerY: y + 5, width: 4, height: 10, color: .blue)
            nativeOutlinedPill(&canvas, centerX: headX, centerY: y - 2, width: 12, height: 9, fill: .darkBlue)
            nativeStroke(&canvas, fromX: headX + side * 4, y - 7, dx: side, dy: -1, length: 8, width: 3, color: .blue)
            for offset in [-8, -2, 5] {
                nativeStroke(&canvas, fromX: x + offset, y + 9, dx: -side, dy: 1, length: 5, width: 2, color: .black)
            }
            nativeEye(&canvas, centerX: headX + side * 3, centerY: y - 3, ink: .cream)
        }
    }

    static func drawNativeAnatomicalDragon(_ canvas: inout [[PixelColor]], design: Design, direction: SpriteDirection, scale: Scale) {
        let x = nativeGridSize / 2
        let ground = nativeCenter(scale.baseline)
        let side = nativeDirectionSide(direction)
        let bodyY = ground - 10 + scale.lift
        let neckY = bodyY - 10
        let wing = design.trait == "wyvern" ? 14 : design.trait == "chrono_dragon" ? 15 : 12
        let bodyWidth = design.trait == "chrono_dragon" ? 27 : 24

        if side == 0 {
            nativeOutlinedPill(&canvas, centerX: x - 13, centerY: bodyY - 3, width: wing, height: 19, fill: design.accent)
            nativeOutlinedPill(&canvas, centerX: x + 13, centerY: bodyY - 3, width: wing, height: 19, fill: design.accent)
            nativeOutlinedPill(&canvas, centerX: x, centerY: bodyY, width: bodyWidth, height: 15, fill: design.primary)
            nativeStroke(&canvas, fromX: x, bodyY - 8, dx: 0, dy: -1, length: 10, width: 7, color: design.primary)
            nativeOutlinedPill(&canvas, centerX: x, centerY: neckY - 4, width: 18, height: 12, fill: design.primary)
            nativeStroke(&canvas, fromX: x - 5, neckY - 8, dx: -1, dy: -1, length: 4, color: design.accent)
            nativeStroke(&canvas, fromX: x + 5, neckY - 8, dx: 1, dy: -1, length: 4, color: design.accent)
            drawNativeEyePair(&canvas, centerX: x, centerY: neckY - 5, separation: 4, ink: .cream)
            nativeStroke(&canvas, fromX: x + 9, bodyY + 2, dx: 1, dy: 1, length: 8, width: 3, color: design.accent)
            if design.trait == "chrono_dragon" {
                nativeOutlinedPill(&canvas, centerX: x + 13, centerY: bodyY + 8, width: 6, height: 6, fill: .gold)
            }
            nativePill(&canvas, centerX: x - 6, centerY: ground - 1, width: 7, height: 4, color: design.primary)
            nativePill(&canvas, centerX: x + 6, centerY: ground - 1, width: 7, height: 4, color: design.primary)
            if direction == .back {
                nativeStroke(&canvas, fromX: x - 8, bodyY - 5, dx: 1, dy: 0, length: 9, width: 2, color: design.accent)
            }
        } else {
            let headX = x + side * 12
            nativeOutlinedPill(&canvas, centerX: x, centerY: bodyY, width: design.trait == "chrono_dragon" ? 32 : 29, height: 13, fill: design.primary)
            nativeOutlinedPill(&canvas, centerX: x - side * 4, centerY: bodyY - 9, width: 15, height: 15, fill: design.accent)
            nativeStroke(&canvas, fromX: x + side * 7, bodyY - 5, dx: side, dy: -1, length: 8, width: 6, color: design.primary)
            nativeOutlinedPill(&canvas, centerX: headX, centerY: neckY - 3, width: 17, height: 11, fill: design.primary)
            nativeStroke(&canvas, fromX: headX - side * 4, neckY - 8, dx: -side, dy: -1, length: 4, color: design.accent)
            nativeStroke(&canvas, fromX: headX + side * 4, neckY - 8, dx: side, dy: -1, length: 4, color: design.accent)
            nativeEye(&canvas, centerX: headX + side * 4, centerY: neckY - 4, ink: .cream)
            nativeStroke(&canvas, fromX: x - side * 13, bodyY + 2, dx: -side, dy: 1, length: 10, width: 3, color: design.accent)
            if design.trait == "chrono_dragon" {
                nativeOutlinedPill(&canvas, centerX: x - side * 13, centerY: bodyY + 8, width: 6, height: 6, fill: .gold)
            }
            nativePill(&canvas, centerX: x - 8, centerY: ground - 1, width: 7, height: 4, color: design.primary)
            nativePill(&canvas, centerX: x + 6, centerY: ground - 1, width: 7, height: 4, color: design.primary)
        }
    }

    static func drawNativeAnatomicalElephant(_ canvas: inout [[PixelColor]], mammoth: Bool, direction: SpriteDirection, scale: Scale) {
        let x = nativeGridSize / 2
        let ground = nativeCenter(scale.baseline)
        let side = nativeDirectionSide(direction)
        let skin: PixelColor = mammoth ? .darkGray : .gray
        let ear: PixelColor = mammoth ? .brown : .lightGray
        let bodyY = ground - 10 + scale.lift
        let headY = bodyY - 6

        if side == 0 {
            nativeOutlinedPill(&canvas, centerX: x, centerY: bodyY + 2, width: 25, height: 17, fill: skin)
            nativeOutlinedPill(&canvas, centerX: x - 11, centerY: headY + 2, width: 12, height: 17, fill: ear)
            nativeOutlinedPill(&canvas, centerX: x + 11, centerY: headY + 2, width: 12, height: 17, fill: ear)
            nativeOutlinedPill(&canvas, centerX: x, centerY: headY, width: 21, height: 16, fill: skin)
            drawNativeEyePair(&canvas, centerX: x, centerY: headY - 1, separation: 4)
            nativeStroke(&canvas, fromX: x, headY + 5, dx: 0, dy: 1, length: 12, width: 5, color: skin)
            nativeStroke(&canvas, fromX: x - 7, headY + 6, dx: -1, dy: 1, length: 5, width: 2, color: .cream)
            nativeStroke(&canvas, fromX: x + 7, headY + 6, dx: 1, dy: 1, length: 5, width: 2, color: .cream)
            nativePill(&canvas, centerX: x - 8, centerY: ground - 1, width: 7, height: 5, color: skin)
            nativePill(&canvas, centerX: x + 8, centerY: ground - 1, width: 7, height: 5, color: skin)
            if mammoth { nativeRect(&canvas, x - 7, headY - 8, 15, 4, .brown) }
            if direction == .back { nativeStroke(&canvas, fromX: x, bodyY - 4, dx: 0, dy: 1, length: 7, color: ear) }
        } else {
            let headX = x + side * 11
            nativeOutlinedPill(&canvas, centerX: x - side * 2, centerY: bodyY + 1, width: 29, height: 16, fill: skin)
            nativeOutlinedPill(&canvas, centerX: headX, centerY: headY + 3, width: 17, height: 14, fill: skin)
            nativeOutlinedPill(&canvas, centerX: headX - side * 4, centerY: headY + 3, width: 12, height: 13, fill: ear)
            nativeEye(&canvas, centerX: headX + side * 4, centerY: headY, ink: .darkBrown)
            nativeStroke(&canvas, fromX: headX + side * 8, headY + 5, dx: side, dy: 1, length: 10, width: 5, color: skin)
            nativeStroke(&canvas, fromX: headX + side * 6, headY + 6, dx: side, dy: 1, length: 5, width: 2, color: .cream)
            nativeStroke(&canvas, fromX: x - side * 14, bodyY + 1, dx: -side, dy: 1, length: 5, color: ear)
            nativePill(&canvas, centerX: x - 8, centerY: ground - 1, width: 7, height: 5, color: skin)
            nativePill(&canvas, centerX: x + 8, centerY: ground - 1, width: 7, height: 5, color: skin)
        }
    }

    static func drawNativeAnatomicalWhale(_ canvas: inout [[PixelColor]], direction: SpriteDirection, scale: Scale) {
        let x = nativeGridSize / 2
        let ground = nativeCenter(scale.baseline)
        let side = nativeDirectionSide(direction)
        let bodyY = ground - 11 + scale.lift

        if side == 0 {
            // The front view keeps a whale wide, low and fin-led instead of
            // turning it into a round land-animal face with legs.
            nativeOutlinedPill(&canvas, centerX: x, centerY: bodyY, width: 28, height: 16, fill: .blue)
            nativeOval(&canvas, centerX: x, centerY: bodyY + 4, width: 19, height: 8, color: .mint)
            nativeOutlinedPill(&canvas, centerX: x - 14, centerY: bodyY + 4, width: 12, height: 7, fill: .blue)
            nativeOutlinedPill(&canvas, centerX: x + 14, centerY: bodyY + 4, width: 12, height: 7, fill: .blue)
            drawNativeEyePair(&canvas, centerX: x, centerY: bodyY - 2, separation: 5, ink: .darkBlue)
            nativeSmile(&canvas, centerX: x, centerY: bodyY + 4, ink: .darkBlue, expression: .warm)
            nativePill(&canvas, centerX: x - 6, centerY: ground - 1, width: 10, height: 5, color: .mint)
            nativePill(&canvas, centerX: x + 6, centerY: ground - 1, width: 10, height: 5, color: .mint)
            if direction == .back {
                nativeStroke(&canvas, fromX: x - 7, bodyY - 2, dx: 1, dy: 0, length: 8, width: 2, color: .darkBlue)
            }
        } else {
            let headX = x + side * 11
            let tailX = x - side * 14
            nativeOutlinedPill(&canvas, centerX: x, centerY: bodyY, width: 30, height: 14, fill: .blue)
            nativeOval(&canvas, centerX: x, centerY: bodyY + 3, width: 19, height: 7, color: .mint)
            nativeOutlinedPill(&canvas, centerX: headX, centerY: bodyY - 1, width: 14, height: 11, fill: .blue)
            nativeEye(&canvas, centerX: headX + side * 4, centerY: bodyY - 2, ink: .darkBlue)
            nativeOutlinedPill(&canvas, centerX: x + side * 2, centerY: bodyY + 7, width: 12, height: 6, fill: .mint)
            nativeStroke(&canvas, fromX: tailX, bodyY, dx: -side, dy: 0, length: 5, width: 3, color: .mint)
            nativePill(&canvas, centerX: tailX - side * 5, centerY: bodyY - 4, width: 8, height: 6, color: .mint)
            nativePill(&canvas, centerX: tailX - side * 5, centerY: bodyY + 4, width: 8, height: 6, color: .mint)
            nativeStroke(&canvas, fromX: x - side * 3, bodyY - 7, dx: 0, dy: -1, length: 4, color: .mint)
        }
    }

    static func drawNativeAnatomicalTeapot(_ canvas: inout [[PixelColor]], direction: SpriteDirection, scale: Scale) {
        let x = nativeGridSize / 2
        let ground = nativeCenter(scale.baseline)
        let side = nativeDirectionSide(direction)
        let bodyY = ground - 13 + scale.lift

        nativeOutlinedPill(&canvas, centerX: x, centerY: bodyY, width: 25, height: 20, fill: .teal)
        nativePill(&canvas, centerX: x, centerY: bodyY + 4, width: 16, height: 8, color: .mint)
        nativeOutlinedPill(&canvas, centerX: x, centerY: bodyY - 12, width: 17, height: 5, fill: .teal)
        nativePill(&canvas, centerX: x, centerY: bodyY - 16, width: 5, height: 4, color: .gold)

        if side == 0 {
            nativeOutlinedPill(&canvas, centerX: x - 15, centerY: bodyY + 1, width: 9, height: 13, fill: .teal)
            nativeOval(&canvas, centerX: x - 15, centerY: bodyY + 1, width: 4, height: 7, color: .clear)
            nativePolyline(&canvas, points: [(x + 11, bodyY - 2), (x + 17, bodyY - 6), (x + 21, bodyY - 2)], width: 3, color: .teal)
            nativePill(&canvas, centerX: x + 22, centerY: bodyY - 1, width: 6, height: 5, color: .mint)
            if direction == .front {
                drawNativeEyePair(&canvas, centerX: x, centerY: bodyY, separation: 4, ink: .cream)
                nativeSmile(&canvas, centerX: x, centerY: bodyY + 5, ink: .darkBlue, expression: .warm)
            } else {
                nativePill(&canvas, centerX: x, centerY: bodyY, width: 12, height: 4, color: .darkBlue)
            }
        } else {
            let spoutSide = side
            nativePolyline(&canvas, points: [(x + spoutSide * 11, bodyY - 2), (x + spoutSide * 17, bodyY - 6), (x + spoutSide * 21, bodyY - 2)], width: 3, color: .teal)
            nativePill(&canvas, centerX: x + spoutSide * 22, centerY: bodyY - 1, width: 6, height: 5, color: .mint)
            nativeOutlinedPill(&canvas, centerX: x - spoutSide * 14, centerY: bodyY + 1, width: 8, height: 12, fill: .teal)
            nativeOval(&canvas, centerX: x - spoutSide * 14, centerY: bodyY + 1, width: 3, height: 6, color: .clear)
            nativeEye(&canvas, centerX: x + side * 5, centerY: bodyY, ink: .cream)
        }
        nativePill(&canvas, centerX: x, centerY: ground - 2, width: 12, height: 3, color: .darkBlue)
    }

    static func drawNativeAnatomicalWorldTree(_ canvas: inout [[PixelColor]], direction: SpriteDirection, scale: Scale) {
        let x = nativeGridSize / 2
        let ground = nativeCenter(scale.baseline)
        let side = nativeDirectionSide(direction)
        let trunkTop = ground - 27 + scale.lift

        // Roots, trunk, branches, then staggered canopy: the face belongs in
        // the bark knot, never in a generic green "head".
        nativePolyline(&canvas, points: [(x - 2, ground - 2), (x - 9, ground + 1), (x - 13, ground + 1)], width: 3, color: .brown)
        nativePolyline(&canvas, points: [(x + 2, ground - 2), (x + 9, ground + 1), (x + 13, ground + 1)], width: 3, color: .brown)
        nativeOutlinedPill(&canvas, centerX: x, centerY: ground - 14, width: 11, height: 27, fill: .brown)
        nativeStroke(&canvas, fromX: x - 2, ground - 17, dx: -1, dy: -1, length: 7, width: 3, color: .brown)
        nativeStroke(&canvas, fromX: x + 2, ground - 18, dx: 1, dy: -1, length: 8, width: 3, color: .brown)
        nativeOutlinedPill(&canvas, centerX: x - 8, centerY: trunkTop + 10, width: 13, height: 17, fill: .green)
        nativeOutlinedPill(&canvas, centerX: x + 8, centerY: trunkTop + 9, width: 14, height: 18, fill: .green)
        nativeOutlinedPill(&canvas, centerX: x - 2, centerY: trunkTop + 2, width: 15, height: 16, fill: .lime)
        nativeOutlinedPill(&canvas, centerX: x + 7, centerY: trunkTop + 2, width: 12, height: 14, fill: .green)
        nativeClusterReplacing(&canvas, source: .green, atX: x + 7, trunkTop + 9, color: .darkGreen, cells: [(0, 0), (1, 0), (0, 1), (1, 1)])
        if direction == .front {
            drawNativeEyePair(&canvas, centerX: x, centerY: ground - 16, separation: 3)
            nativeSmile(&canvas, centerX: x, centerY: ground - 11, ink: .darkBrown, expression: .warm)
        } else if direction == .back {
            nativeStroke(&canvas, fromX: x, ground - 24, dx: 0, dy: 1, length: 15, width: 2, color: .darkBrown)
        } else {
            nativeEye(&canvas, centerX: x + side * 3, centerY: ground - 16, ink: .darkBrown)
            nativeStroke(&canvas, fromX: x - side * 3, ground - 21, dx: -side, dy: -1, length: 5, width: 3, color: .brown)
        }
    }

    static func drawNativeAnatomicalMermaid(_ canvas: inout [[PixelColor]], direction: SpriteDirection, scale: Scale) {
        let x = nativeGridSize / 2
        let ground = nativeCenter(scale.baseline)
        let side = nativeDirectionSide(direction)
        let headY = ground - 31 + scale.lift
        let shoulderY = ground - 20 + scale.lift
        let waistY = ground - 14 + scale.lift

        let headX = x + side * 2
        // Keep the human and fish halves visibly separate.  The previous
        // single wide head and two large fins read too much like a flower.
        // Here the hair frames a smaller face, shoulders carry real arms, and
        // the waist tapers into one continuous fish tail.
        nativeOutlinedPill(&canvas, centerX: headX, centerY: headY, width: 17, height: 15, fill: .pink)
        nativePill(&canvas, centerX: headX + side, centerY: headY + 1, width: 11, height: 11, color: .peach)
        if side == 0 {
            nativeStroke(&canvas, fromX: headX - 7, headY - 4, dx: -1, dy: 1, length: 8, width: 3, color: .pink)
            nativeStroke(&canvas, fromX: headX + 7, headY - 4, dx: 1, dy: 1, length: 8, width: 3, color: .pink)
        } else {
            nativeStroke(&canvas, fromX: headX - side * 6, headY - 4, dx: -side, dy: 1, length: 10, width: 3, color: .pink)
        }
        nativeOutlinedPill(&canvas, centerX: x, centerY: shoulderY, width: 13, height: 11, fill: .teal)
        nativePill(&canvas, centerX: x, centerY: shoulderY - 2, width: 8, height: 3, color: .pink)
        if side == 0 {
            nativeStroke(&canvas, fromX: x - 7, shoulderY - 2, dx: -1, dy: 1, length: 7, width: 3, color: .peach)
            nativeStroke(&canvas, fromX: x + 7, shoulderY - 2, dx: 1, dy: 1, length: 7, width: 3, color: .peach)
            nativePill(&canvas, centerX: x - 10, centerY: shoulderY + 5, width: 4, height: 4, color: .peach)
            nativePill(&canvas, centerX: x + 10, centerY: shoulderY + 5, width: 4, height: 4, color: .peach)
        } else {
            nativeStroke(&canvas, fromX: x - side * 7, shoulderY - 1, dx: -side, dy: 1, length: 7, width: 3, color: .peach)
            nativePill(&canvas, centerX: x - side * 10, centerY: shoulderY + 5, width: 4, height: 4, color: .peach)
        }
        nativePolyline(&canvas, points: [(x, waistY), (x + side * 2, waistY + 8), (x + side, ground - 7)], width: 8, color: .teal)
        nativeStroke(&canvas, fromX: x - 2, waistY + 3, dx: 1, dy: 1, length: 5, width: 2, color: .mint)
        nativeOutlinedPill(&canvas, centerX: x - 5, centerY: ground - 2, width: 10, height: 6, fill: .teal)
        nativeOutlinedPill(&canvas, centerX: x + 5, centerY: ground - 2, width: 10, height: 6, fill: .teal)
        nativePill(&canvas, centerX: x - 5, centerY: ground - 2, width: 5, height: 3, color: .mint)
        nativePill(&canvas, centerX: x + 5, centerY: ground - 2, width: 5, height: 3, color: .mint)
        if direction == .front {
            drawNativeEyePair(&canvas, centerX: headX, centerY: headY, separation: 3)
            nativePill(&canvas, centerX: headX, centerY: headY + 5, width: 3, height: 2, color: .blush)
        } else if direction == .back {
            nativePill(&canvas, centerX: headX, centerY: headY + 1, width: 13, height: 8, color: .pink)
            nativeStroke(&canvas, fromX: x, waistY, dx: 0, dy: 1, length: 10, color: .darkBlue)
        } else {
            nativeEye(&canvas, centerX: headX + side * 3, centerY: headY, ink: .darkBrown)
            nativePill(&canvas, centerX: headX + side * 7, centerY: headY + 4, width: 4, height: 3, color: .blush)
        }
    }

    static func drawNativeAnatomicalSkate(_ canvas: inout [[PixelColor]], direction: SpriteDirection, scale: Scale) {
        let x = nativeGridSize / 2
        let ground = nativeCenter(scale.baseline)
        let side = nativeDirectionSide(direction)
        let y = ground - 16 + scale.lift

        if side == 0 {
            // The ray is one continuous pectoral-fin disc; the central face
            // is inset, never a separate dark creature laid over two wings.
            nativeOutlinedPill(&canvas, centerX: x - 11, centerY: y, width: 23, height: 13, fill: .teal)
            nativeOutlinedPill(&canvas, centerX: x + 11, centerY: y, width: 23, height: 13, fill: .teal)
            nativePill(&canvas, centerX: x, centerY: y + 1, width: 26, height: 10, color: .teal)
            nativePill(&canvas, centerX: x, centerY: y + 2, width: 13, height: 7, color: .blue)
            drawNativeEyePair(&canvas, centerX: x, centerY: y - 2, separation: 6, ink: .darkBlue)
            nativeSmile(&canvas, centerX: x, centerY: y + 4, ink: .darkBlue, expression: .warm)
            nativePolyline(&canvas, points: [(x, y + 7), (x, ground - 5), (x + (direction == .front ? 1 : -1), ground)], width: 2, color: .darkBlue)
            if direction == .back {
                nativePill(&canvas, centerX: x, centerY: y - 1, width: 19, height: 3, color: .blue)
            }
        } else {
            let nose = x + side * 14
            nativeOutlinedPill(&canvas, centerX: x, centerY: y + 1, width: 32, height: 9, fill: .teal)
            nativePill(&canvas, centerX: x - side * 4, centerY: y - 2, width: 15, height: 5, color: .blue)
            nativeStroke(&canvas, fromX: nose - side * 3, y - 2, dx: side, dy: 0, length: 6, width: 3, color: .teal)
            nativeEye(&canvas, centerX: nose - side * 5, centerY: y - 3, ink: .darkBlue)
            nativePolyline(&canvas, points: [(x - side * 14, y + 2), (x - side * 19, ground - 3), (x - side * 20, ground)], width: 2, color: .darkBlue)
            nativePill(&canvas, centerX: x - side * 3, centerY: y + 4, width: 12, height: 3, color: .mint)
        }
    }

    static func drawNativeAnatomicalLightning(_ canvas: inout [[PixelColor]], direction: SpriteDirection, scale: Scale) {
        let x = nativeGridSize / 2 + nativeDirectionSide(direction) * 2
        let ground = nativeCenter(scale.baseline)
        let top = ground - 35 + scale.lift
        let side = nativeDirectionSide(direction)
        // Lightning keeps one connected discharge channel. Its small face is
        // recessed in the broad middle segment instead of becoming a round
        // mascot body.
        let bolt = [
            (x + 4, top), (x - 4, top + 11), (x + 3, top + 11),
            (x - 5, top + 27), (x + 5, top + 19), (x - 2, ground - 1)
        ]
        nativePolyline(&canvas, points: bolt, width: 5, color: .yellow)
        nativePolyline(&canvas, points: bolt, width: 2, color: .orange)
        nativePolyline(&canvas, points: [(x + 3, top + 11), (x + 11 + side * 2, top + 8)], width: 2, color: .yellow)
        if direction == .front {
            nativePill(&canvas, centerX: x - 2, centerY: top + 15, width: 2, height: 3, color: .darkBrown)
            nativePill(&canvas, centerX: x + 2, centerY: top + 15, width: 2, height: 3, color: .darkBrown)
        } else if direction == .back {
            nativePill(&canvas, centerX: x, centerY: top + 16, width: 5, height: 2, color: .orange)
        } else {
            nativePill(&canvas, centerX: x + side * 2, centerY: top + 15, width: 2, height: 3, color: .darkBrown)
        }
    }

    // MARK: - Remaining species: real body plans

    /// Birds share a skeleton, not a mascot body: chest, folded or spread
    /// wings, beak, tail and feet remain readable in every orientation.
    static func drawNativeAnatomicalBird(_ canvas: inout [[PixelColor]], design: Design, direction: SpriteDirection, scale: Scale) {
        let x = nativeGridSize / 2
        let ground = nativeCenter(scale.baseline)
        let side = nativeDirectionSide(direction)
        let isPhoenix = design.trait == "phoenix"
        let isPenguin = design.trait == "penguin"
        let isRaven = design.trait == "raven"
        let isParakeet = design.trait == "parakeet"
        let isThunderbird = design.trait == "thunderbird"
        let body = isPenguin ? .darkGray : design.primary
        let wing = isPhoenix ? .orange : isThunderbird ? .yellow : isRaven ? .black : design.accent
        let bodyY = ground - (isPenguin ? 16 : 15) + scale.lift
        let headY = bodyY - (isPenguin ? 10 : 9)

        if side == 0 {
            nativeOutlinedPill(&canvas, centerX: x, centerY: bodyY, width: isPenguin ? 21 : 17, height: isPenguin ? 24 : 21, fill: body)
            nativeOutlinedPill(&canvas, centerX: x - (isPenguin ? 9 : 8), centerY: bodyY + 1, width: isPenguin ? 8 : 7, height: isPhoenix || isThunderbird ? 18 : 15, fill: wing)
            nativeOutlinedPill(&canvas, centerX: x + (isPenguin ? 9 : 8), centerY: bodyY + 1, width: isPenguin ? 8 : 7, height: isPhoenix || isThunderbird ? 18 : 15, fill: wing)
            nativeOutlinedPill(&canvas, centerX: x, centerY: headY, width: isPenguin ? 18 : 16, height: 14, fill: body)
            if isPenguin {
                nativePill(&canvas, centerX: x, centerY: bodyY + 3, width: 12, height: 15, color: .white)
                nativePill(&canvas, centerX: x, centerY: headY + 3, width: 7, height: 4, color: .orange)
                nativePill(&canvas, centerX: x - 5, centerY: ground - 1, width: 7, height: 3, color: .orange)
                nativePill(&canvas, centerX: x + 5, centerY: ground - 1, width: 7, height: 3, color: .orange)
            } else {
                nativePill(&canvas, centerX: x, centerY: headY + 4, width: isRaven ? 8 : 6, height: 4, color: isRaven ? .darkGray : .gold)
                nativeStroke(&canvas, fromX: x - 5, bodyY + 8, dx: -1, dy: 1, length: isParakeet ? 8 : 5, width: 2, color: wing)
                nativeStroke(&canvas, fromX: x + 5, bodyY + 8, dx: 1, dy: 1, length: isParakeet ? 8 : 5, width: 2, color: wing)
                nativePill(&canvas, centerX: x - 4, centerY: ground - 1, width: 4, height: 3, color: .gold)
                nativePill(&canvas, centerX: x + 4, centerY: ground - 1, width: 4, height: 3, color: .gold)
            }
            if isPhoenix || isThunderbird {
                nativeStroke(&canvas, fromX: x - 5, headY - 7, dx: -1, dy: -1, length: 4, width: 2, color: wing)
                nativeStroke(&canvas, fromX: x + 5, headY - 7, dx: 1, dy: -1, length: 4, width: 2, color: wing)
            }
            if isPhoenix {
                nativeStroke(&canvas, fromX: x - 3, bodyY + 8, dx: -1, dy: 1, length: 8, width: 2, color: .red)
                nativeStroke(&canvas, fromX: x + 3, bodyY + 8, dx: 1, dy: 1, length: 8, width: 2, color: .red)
            }
            if isThunderbird {
                nativeStroke(&canvas, fromX: x, headY - 9, dx: 0, dy: -1, length: 5, width: 3, color: .yellow)
                nativeStroke(&canvas, fromX: x - 12, bodyY - 2, dx: -1, dy: -1, length: 4, width: 2, color: .darkBlue)
                nativeStroke(&canvas, fromX: x + 12, bodyY - 2, dx: 1, dy: -1, length: 4, width: 2, color: .darkBlue)
            }
            if direction == .front {
                drawNativeEyePair(&canvas, centerX: x, centerY: headY - 1, separation: 3, ink: isRaven ? .cream : .darkBrown)
            } else {
                nativeStroke(&canvas, fromX: x, bodyY - 6, dx: 0, dy: 1, length: 11, width: 2, color: wing)
            }
        } else {
            let headX = x + side * 9
            nativeOutlinedPill(&canvas, centerX: x - side * 2, centerY: bodyY + 2, width: isPenguin ? 25 : 26, height: isPenguin ? 17 : 14, fill: body)
            nativeOutlinedPill(&canvas, centerX: headX, centerY: headY + 3, width: 15, height: 12, fill: body)
            nativeOutlinedPill(&canvas, centerX: x - side * 3, centerY: bodyY, width: isPhoenix || isThunderbird ? 15 : 12, height: 16, fill: wing)
            nativeStroke(&canvas, fromX: x - side * 10, bodyY + 4, dx: -side, dy: 1, length: isParakeet ? 10 : 6, width: 2, color: wing)
            nativePill(&canvas, centerX: headX + side * 7, centerY: headY + 5, width: isRaven ? 8 : 6, height: 4, color: isRaven ? .darkGray : .gold)
            nativeEye(&canvas, centerX: headX + side * 3, centerY: headY, ink: isRaven ? .cream : .darkBrown)
            if isPenguin { nativePill(&canvas, centerX: x + side * 2, centerY: bodyY + 4, width: 10, height: 8, color: .white) }
            nativePill(&canvas, centerX: x - 6, centerY: ground - 1, width: 5, height: 3, color: isPenguin ? .orange : .gold)
            nativePill(&canvas, centerX: x + 5, centerY: ground - 1, width: 5, height: 3, color: isPenguin ? .orange : .gold)
        }
    }

    static func drawNativeAnatomicalBat(_ canvas: inout [[PixelColor]], direction: SpriteDirection, scale: Scale) {
        let x = nativeGridSize / 2
        let ground = nativeCenter(scale.baseline)
        let side = nativeDirectionSide(direction)
        let bodyY = ground - 15 + scale.lift
        let headX = x + side * 4
        if side == 0 {
            // Bat wings are membrane stretched between digit-like supports,
            // not detached triangular decorations.
            nativeOutlinedPill(&canvas, centerX: x, centerY: bodyY, width: 13, height: 17, fill: .darkGray)
            nativePolyline(&canvas, points: [(x - 4, bodyY - 3), (x - 15, bodyY - 8), (x - 20, bodyY + 8), (x - 7, bodyY + 6)], width: 3, color: .purple)
            nativePolyline(&canvas, points: [(x + 4, bodyY - 3), (x + 15, bodyY - 8), (x + 20, bodyY + 8), (x + 7, bodyY + 6)], width: 3, color: .purple)
            nativeOutlinedPill(&canvas, centerX: x, centerY: bodyY - 10, width: 16, height: 12, fill: .darkGray)
            nativeStroke(&canvas, fromX: x - 5, bodyY - 15, dx: -1, dy: -1, length: 4, color: .purple)
            nativeStroke(&canvas, fromX: x + 5, bodyY - 15, dx: 1, dy: -1, length: 4, color: .purple)
            drawNativeEyePair(&canvas, centerX: x, centerY: bodyY - 10, separation: 3, ink: .coral)
            if direction == .back { nativePill(&canvas, centerX: x, centerY: bodyY + 2, width: 7, height: 7, color: .purple) }
        } else {
            nativeOutlinedPill(&canvas, centerX: x - side * 2, centerY: bodyY, width: 18, height: 15, fill: .darkGray)
            nativePolyline(&canvas, points: [(x - side * 4, bodyY - 4), (x - side * 17, bodyY - 5), (x - side * 20, bodyY + 8), (x - side * 5, bodyY + 6)], width: 3, color: .purple)
            nativeOutlinedPill(&canvas, centerX: headX + side * 5, centerY: bodyY - 8, width: 14, height: 11, fill: .darkGray)
            nativeStroke(&canvas, fromX: headX + side * 3, bodyY - 14, dx: side, dy: -1, length: 4, color: .purple)
            nativeEye(&canvas, centerX: headX + side * 8, centerY: bodyY - 9, ink: .coral)
        }
    }

    static func drawNativeAnatomicalLepidoptera(_ canvas: inout [[PixelColor]], design: Design, direction: SpriteDirection, scale: Scale) {
        let x = nativeGridSize / 2
        let ground = nativeCenter(scale.baseline)
        let side = nativeDirectionSide(direction)
        let luna = design.trait == "luna_moth"
        let wing = luna ? PixelColor.mint : PixelColor.purple
        let pattern = luna ? PixelColor.lavender : PixelColor.darkBlue
        let bodyY = ground - 17 + scale.lift
        if side == 0 {
            nativeOutlinedPill(&canvas, centerX: x - 9, centerY: bodyY - 3, width: 16, height: 18, fill: wing)
            nativeOutlinedPill(&canvas, centerX: x + 9, centerY: bodyY - 3, width: 16, height: 18, fill: wing)
            nativeOutlinedPill(&canvas, centerX: x - 8, centerY: bodyY + 9, width: 13, height: 14, fill: wing)
            nativeOutlinedPill(&canvas, centerX: x + 8, centerY: bodyY + 9, width: 13, height: 14, fill: wing)
            nativeOutlinedPill(&canvas, centerX: x, centerY: bodyY + 3, width: 8, height: 23, fill: pattern)
            nativeStroke(&canvas, fromX: x - 3, bodyY - 9, dx: -1, dy: -1, length: 5, width: 2, color: pattern)
            nativeStroke(&canvas, fromX: x + 3, bodyY - 9, dx: 1, dy: -1, length: 5, width: 2, color: pattern)
            nativePill(&canvas, centerX: x - 9, centerY: bodyY - 4, width: 5, height: 5, color: pattern)
            nativePill(&canvas, centerX: x + 9, centerY: bodyY - 4, width: 5, height: 5, color: pattern)
            if luna {
                nativeStroke(&canvas, fromX: x - 10, bodyY + 14, dx: -1, dy: 1, length: 6, width: 2, color: .lavender)
                nativeStroke(&canvas, fromX: x + 10, bodyY + 14, dx: 1, dy: 1, length: 6, width: 2, color: .lavender)
            }
            if direction == .front { nativeEye(&canvas, centerX: x, centerY: bodyY - 5, ink: .cream) }
        } else {
            nativeOutlinedPill(&canvas, centerX: x - side * 2, centerY: bodyY + 2, width: 11, height: 23, fill: pattern)
            nativeOutlinedPill(&canvas, centerX: x - side * 6, centerY: bodyY, width: 25, height: 18, fill: wing)
            nativeOutlinedPill(&canvas, centerX: x - side * 2, centerY: bodyY + 10, width: 20, height: 10, fill: wing)
            nativeStroke(&canvas, fromX: x + side * 2, bodyY - 10, dx: side, dy: -1, length: 5, width: 2, color: pattern)
            nativeEye(&canvas, centerX: x + side * 4, centerY: bodyY - 6, ink: .cream)
        }
    }

    static func drawNativeAnatomicalSmallMammal(_ canvas: inout [[PixelColor]], design: Design, direction: SpriteDirection, scale: Scale) {
        let x = nativeGridSize / 2
        let ground = nativeCenter(scale.baseline)
        let side = nativeDirectionSide(direction)
        let hedgehog = design.trait == "hedgehog"
        let koala = design.trait == "koala"
        let puppy = design.trait == "puppy"
        let headY = ground - 23 + scale.lift
        let bodyY = ground - 11 + scale.lift
        let bodyColor = hedgehog ? PixelColor.darkGray : design.primary
        let muzzle = koala ? PixelColor.black : hedgehog ? PixelColor.peach : design.accent

        if side == 0 {
            nativeOutlinedPill(&canvas, centerX: x, centerY: bodyY, width: hedgehog ? 25 : 20, height: 18, fill: bodyColor)
            nativeOutlinedPill(&canvas, centerX: x, centerY: headY, width: koala ? 20 : 18, height: 15, fill: design.primary)
            if hedgehog {
                for offset in [-9, -5, -1, 3, 7] {
                    nativeStroke(&canvas, fromX: x + offset, bodyY - 8, dx: offset < 0 ? -1 : 1, dy: -1, length: 4, width: 2, color: .brown)
                }
            } else if koala {
                nativeOutlinedPill(&canvas, centerX: x - 10, centerY: headY - 2, width: 9, height: 10, fill: .gray)
                nativeOutlinedPill(&canvas, centerX: x + 10, centerY: headY - 2, width: 9, height: 10, fill: .gray)
            } else if puppy {
                nativeOutlinedPill(&canvas, centerX: x - 10, centerY: headY + 1, width: 7, height: 12, fill: .brown)
                nativeOutlinedPill(&canvas, centerX: x + 10, centerY: headY + 1, width: 7, height: 12, fill: .brown)
            } else {
                nativeStroke(&canvas, fromX: x - 6, headY - 6, dx: -1, dy: -1, length: 5, width: 3, color: .darkBrown)
                nativeStroke(&canvas, fromX: x + 6, headY - 6, dx: 1, dy: -1, length: 5, width: 3, color: .darkBrown)
            }
            nativePill(&canvas, centerX: x, centerY: headY + 4, width: koala ? 7 : 9, height: 5, color: muzzle)
            if direction == .front { drawNativeEyePair(&canvas, centerX: x, centerY: headY - 1, separation: 3) }
            nativePill(&canvas, centerX: x - 6, centerY: ground - 1, width: 6, height: 4, color: bodyColor)
            nativePill(&canvas, centerX: x + 6, centerY: ground - 1, width: 6, height: 4, color: bodyColor)
            if direction == .back { nativePill(&canvas, centerX: x, centerY: bodyY - 2, width: 13, height: 4, color: design.accent) }
        } else {
            let headX = x + side * 10
            nativeOutlinedPill(&canvas, centerX: x - side * 2, centerY: bodyY + 1, width: hedgehog ? 28 : 27, height: 15, fill: bodyColor)
            nativeOutlinedPill(&canvas, centerX: headX, centerY: headY + 4, width: 15, height: 12, fill: design.primary)
            if hedgehog {
                for offset in [-10, -5, 0, 5] { nativeStroke(&canvas, fromX: x + offset, bodyY - 7, dx: -side, dy: -1, length: 3, width: 2, color: .brown) }
            } else if koala {
                nativeOutlinedPill(&canvas, centerX: headX - side * 4, centerY: headY, width: 9, height: 10, fill: .gray)
            } else if puppy {
                nativeOutlinedPill(&canvas, centerX: headX - side * 5, centerY: headY + 2, width: 7, height: 11, fill: .brown)
            } else {
                nativeStroke(&canvas, fromX: headX - side * 4, headY - 3, dx: -side, dy: -1, length: 4, width: 3, color: .darkBrown)
            }
            nativePill(&canvas, centerX: headX + side * 7, centerY: headY + 6, width: koala ? 6 : 5, height: 4, color: muzzle)
            nativeEye(&canvas, centerX: headX + side * 3, centerY: headY + 1, ink: .darkBrown)
            nativeStroke(&canvas, fromX: x - side * 13, bodyY + 1, dx: -side, dy: 1, length: hedgehog ? 3 : 7, width: 2, color: design.accent)
            nativePill(&canvas, centerX: x - 7, centerY: ground - 1, width: 6, height: 4, color: bodyColor)
            nativePill(&canvas, centerX: x + 7, centerY: ground - 1, width: 6, height: 4, color: bodyColor)
        }
    }

    static func drawNativeAnatomicalLongMammal(_ canvas: inout [[PixelColor]], design: Design, direction: SpriteDirection, scale: Scale) {
        let x = nativeGridSize / 2
        let ground = nativeCenter(scale.baseline)
        let side = nativeDirectionSide(direction)
        let otter = design.trait == "otter"
        let ferret = design.trait == "ferret"
        let badger = design.trait == "badger"
        let beaver = design.trait == "beaver"
        let capybara = design.trait == "capybara"
        let body = capybara ? PixelColor.brown : design.primary
        let bodyY = ground - 9 + scale.lift
        let headY = bodyY - 7
        if side == 0 {
            let frontWidth = capybara ? 28 : ferret ? 33 : otter ? 28 : 30
            nativeOutlinedPill(&canvas, centerX: x, centerY: bodyY, width: frontWidth, height: capybara ? 16 : 14, fill: body)
            nativeOutlinedPill(&canvas, centerX: x, centerY: headY, width: capybara ? 20 : 17, height: 13, fill: body)
            if badger {
                nativeStroke(&canvas, fromX: x, headY - 6, dx: 0, dy: 1, length: 11, width: 4, color: .white)
            } else if beaver {
                nativePill(&canvas, centerX: x, centerY: headY + 4, width: 8, height: 4, color: .cream)
                nativePill(&canvas, centerX: x - 2, centerY: headY + 5, width: 2, height: 3, color: .white)
                nativePill(&canvas, centerX: x + 2, centerY: headY + 5, width: 2, height: 3, color: .white)
            } else if capybara {
                nativePill(&canvas, centerX: x, centerY: headY + 4, width: 10, height: 5, color: .ginger)
                nativePill(&canvas, centerX: x - 7, centerY: headY - 5, width: 4, height: 4, color: .brown)
                nativePill(&canvas, centerX: x + 7, centerY: headY - 5, width: 4, height: 4, color: .brown)
            }
            if direction == .front { drawNativeEyePair(&canvas, centerX: x, centerY: headY - 1, separation: 3) }
            if beaver {
                nativeOutlinedPill(&canvas, centerX: x, centerY: ground - 1, width: 14, height: 7, fill: .darkBrown)
                nativeStroke(&canvas, fromX: x - 4, ground - 3, dx: 1, dy: 1, length: 5, width: 2, color: .brown)
            } else {
                nativePill(&canvas, centerX: x - 9, centerY: ground - 1, width: 6, height: 4, color: body)
                nativePill(&canvas, centerX: x + 9, centerY: ground - 1, width: 6, height: 4, color: body)
            }
            if direction == .back { nativeStroke(&canvas, fromX: x, bodyY - 4, dx: 0, dy: 1, length: 6, color: design.accent) }
        } else {
            let headX = x + side * (capybara ? 12 : 13)
            nativeOutlinedPill(&canvas, centerX: x - side * 2, centerY: bodyY, width: ferret ? 34 : 31, height: 13, fill: body)
            nativeOutlinedPill(&canvas, centerX: headX, centerY: headY + 4, width: capybara ? 16 : 14, height: 11, fill: body)
            if badger { nativeStroke(&canvas, fromX: headX - side * 4, headY - 1, dx: side, dy: 1, length: 7, width: 3, color: .white) }
            if beaver {
                nativeOutlinedPill(&canvas, centerX: x - side * 17, centerY: bodyY + 4, width: 12, height: 8, fill: .darkBrown)
                nativeStroke(&canvas, fromX: x - side * 18, bodyY + 1, dx: side, dy: 1, length: 5, width: 2, color: .brown)
            } else {
                let tailColor = ferret ? PixelColor.brown : otter ? PixelColor.darkBrown : design.accent
                nativeStroke(&canvas, fromX: x - side * 15, bodyY + 1, dx: -side, dy: 1, length: ferret ? 10 : 7, width: 3, color: tailColor)
            }
            nativePill(&canvas, centerX: headX + side * 7, centerY: headY + 6, width: capybara ? 7 : 5, height: 4, color: capybara ? .ginger : .darkBrown)
            nativeEye(&canvas, centerX: headX + side * 3, centerY: headY + 1, ink: .darkBrown)
            nativePill(&canvas, centerX: x - 8, centerY: ground - 1, width: 6, height: 4, color: body)
            nativePill(&canvas, centerX: x + 8, centerY: ground - 1, width: 6, height: 4, color: body)
        }
    }

    static func drawNativeAnatomicalHoofed(_ canvas: inout [[PixelColor]], design: Design, direction: SpriteDirection, scale: Scale) {
        let x = nativeGridSize / 2
        let ground = nativeCenter(scale.baseline)
        let side = nativeDirectionSide(direction)
        let deer = design.trait == "deer"
        let pegasus = design.trait == "pegasus"
        let body = pegasus ? PixelColor.cream : design.primary
        let mane = pegasus ? PixelColor.lavender : deer ? PixelColor.brown : PixelColor.lavender
        let bodyY = ground - 13 + scale.lift
        let headY = bodyY - 11
        if side == 0 {
            nativeOutlinedPill(&canvas, centerX: x, centerY: bodyY, width: 24, height: 16, fill: body)
            nativeStroke(&canvas, fromX: x, bodyY - 5, dx: 0, dy: -1, length: 10, width: 6, color: body)
            nativeOutlinedPill(&canvas, centerX: x, centerY: headY, width: 15, height: 12, fill: body)
            if deer {
                for offset in [-5, 5] {
                    nativeStroke(&canvas, fromX: x + offset, headY - 6, dx: offset < 0 ? -1 : 1, dy: -1, length: 7, width: 2, color: mane)
                    nativeStroke(&canvas, fromX: x + offset * 2, headY - 10, dx: 0, dy: 1, length: 3, color: mane)
                }
            } else {
                nativeStroke(&canvas, fromX: x, headY - 7, dx: 0, dy: -1, length: 7, width: 3, color: .gold)
                nativeStroke(&canvas, fromX: x - 7, headY - 2, dx: 0, dy: -1, length: 5, width: 2, color: mane)
                nativeStroke(&canvas, fromX: x + 7, headY - 2, dx: 0, dy: -1, length: 5, width: 2, color: mane)
            }
            if pegasus {
                nativeOutlinedPill(&canvas, centerX: x - 13, centerY: bodyY - 2, width: 10, height: 17, fill: mane)
                nativeOutlinedPill(&canvas, centerX: x + 13, centerY: bodyY - 2, width: 10, height: 17, fill: mane)
            }
            drawNativeEyePair(&canvas, centerX: x, centerY: headY, separation: 3)
            for offset in [-8, 8] { nativeStroke(&canvas, fromX: x + offset, bodyY + 6, dx: 0, dy: 1, length: 9, width: 3, color: body) }
            nativeStroke(&canvas, fromX: x + 10, bodyY + 2, dx: 1, dy: 1, length: 8, width: 3, color: mane)
            if direction == .back {
                nativeStroke(&canvas, fromX: x, headY - 5, dx: 0, dy: 1, length: 12, width: 3, color: mane)
                nativePill(&canvas, centerX: x, centerY: bodyY - 3, width: 10, height: 4, color: mane)
            }
        } else {
            let headX = x + side * 12
            nativeOutlinedPill(&canvas, centerX: x - side * 2, centerY: bodyY, width: 30, height: 14, fill: body)
            nativeStroke(&canvas, fromX: x + side * 7, bodyY - 5, dx: side, dy: -1, length: 9, width: 5, color: body)
            nativeOutlinedPill(&canvas, centerX: headX, centerY: headY + 4, width: 15, height: 10, fill: body)
            if deer { nativeStroke(&canvas, fromX: headX - side * 3, headY - 2, dx: -side, dy: -1, length: 8, width: 2, color: mane) }
            else { nativeStroke(&canvas, fromX: headX, headY - 5, dx: side, dy: -1, length: 6, width: 3, color: .gold) }
            if pegasus { nativeOutlinedPill(&canvas, centerX: x - side * 5, centerY: bodyY - 6, width: 17, height: 13, fill: mane) }
            nativeEye(&canvas, centerX: headX + side * 4, centerY: headY + 2, ink: .darkBrown)
            nativeStroke(&canvas, fromX: x - side * 15, bodyY + 2, dx: -side, dy: 1, length: 9, width: 3, color: mane)
            for offset in [-8, 8] { nativeStroke(&canvas, fromX: x + offset, bodyY + 5, dx: 0, dy: 1, length: 8, width: 3, color: body) }
        }
    }

    static func drawNativeAnatomicalCrawler(_ canvas: inout [[PixelColor]], design: Design, direction: SpriteDirection, scale: Scale) {
        let x = nativeGridSize / 2
        let ground = nativeCenter(scale.baseline)
        let side = nativeDirectionSide(direction)
        let turtle = design.trait == "turtle"
        let chameleon = design.trait == "chameleon"
        let gecko = design.trait == "gecko"
        let scorpion = design.trait == "scorpion"
        let bodyY = ground - 10 + scale.lift

        if scorpion {
            let shell = PixelColor.orange
            let claw = PixelColor.darkRed
            if side == 0 {
                nativeOutlinedPill(&canvas, centerX: x, centerY: bodyY, width: 21, height: 14, fill: shell)
                nativeOutlinedPill(&canvas, centerX: x, centerY: bodyY - 9, width: 12, height: 9, fill: shell)
                nativeOutlinedPill(&canvas, centerX: x - 15, centerY: bodyY - 1, width: 9, height: 8, fill: claw)
                nativeOutlinedPill(&canvas, centerX: x + 15, centerY: bodyY - 1, width: 9, height: 8, fill: claw)
                for offset in [-8, -3, 3, 8] {
                    let direction = offset < 0 ? -1 : 1
                    nativeStroke(&canvas, fromX: x + offset, bodyY + 5, dx: direction, dy: 1, length: 5, width: 2, color: .darkRed)
                }
                nativePolyline(&canvas, points: [(x, bodyY - 7), (x, bodyY - 15), (x + 7, bodyY - 20), (x + 5, bodyY - 25)], width: 3, color: claw)
                nativePill(&canvas, centerX: x + 5, centerY: bodyY - 26, width: 4, height: 5, color: .darkRed)
                if direction == .front { drawNativeEyePair(&canvas, centerX: x, centerY: bodyY - 9, separation: 2, ink: .cream) }
            } else {
                let headX = x + side * 12
                nativeOutlinedPill(&canvas, centerX: x, centerY: bodyY, width: 29, height: 12, fill: shell)
                nativeOutlinedPill(&canvas, centerX: headX, centerY: bodyY - 4, width: 11, height: 8, fill: shell)
                nativeOutlinedPill(&canvas, centerX: headX + side * 7, centerY: bodyY, width: 8, height: 7, fill: claw)
                nativeOutlinedPill(&canvas, centerX: x - side * 9, centerY: bodyY + 2, width: 8, height: 7, fill: claw)
                for offset in [-8, -2, 5] { nativeStroke(&canvas, fromX: x + offset, bodyY + 5, dx: -side, dy: 1, length: 5, width: 2, color: .darkRed) }
                nativePolyline(&canvas, points: [(x - side * 10, bodyY - 4), (x - side * 15, bodyY - 13), (x - side * 9, bodyY - 20), (x - side * 11, bodyY - 24)], width: 3, color: claw)
                nativeEye(&canvas, centerX: headX + side * 3, centerY: bodyY - 5, ink: .cream)
            }
            return
        }

        let body = turtle ? PixelColor.green : design.primary
        let accent = turtle ? PixelColor.darkGreen : design.accent
        if side == 0 {
            nativeOutlinedPill(&canvas, centerX: x, centerY: bodyY, width: turtle ? 27 : 25, height: turtle ? 18 : 14, fill: body)
            if turtle {
                nativeOutlinedPill(&canvas, centerX: x, centerY: bodyY - 2, width: 19, height: 14, fill: .darkGreen)
                nativePill(&canvas, centerX: x, centerY: bodyY - 2, width: 11, height: 8, color: .green)
            }
            nativeOutlinedPill(&canvas, centerX: x, centerY: bodyY - 9, width: turtle ? 12 : 13, height: 9, fill: body)
            if chameleon {
                nativePill(&canvas, centerX: x - 6, centerY: bodyY - 12, width: 5, height: 5, color: .lime)
                nativePill(&canvas, centerX: x + 6, centerY: bodyY - 12, width: 5, height: 5, color: .lime)
                nativePolyline(&canvas, points: [(x + 11, bodyY + 2), (x + 17, bodyY + 8), (x + 16, ground - 1), (x + 11, ground)], width: 3, color: accent)
            } else if gecko {
                nativeStroke(&canvas, fromX: x - 10, bodyY + 4, dx: -1, dy: 1, length: 6, width: 3, color: accent)
                nativeStroke(&canvas, fromX: x + 10, bodyY + 4, dx: 1, dy: 1, length: 6, width: 3, color: accent)
                nativeStroke(&canvas, fromX: x + 8, bodyY + 3, dx: 1, dy: 0, length: 7, width: 2, color: accent)
            } else {
                nativeStroke(&canvas, fromX: x - 9, bodyY + 5, dx: -1, dy: 1, length: 5, width: 3, color: body)
                nativeStroke(&canvas, fromX: x + 9, bodyY + 5, dx: 1, dy: 1, length: 5, width: 3, color: body)
                nativeStroke(&canvas, fromX: x, bodyY + 7, dx: 0, dy: 1, length: 5, width: 3, color: body)
            }
            if direction == .front { drawNativeEyePair(&canvas, centerX: x, centerY: bodyY - 10, separation: 2) }
            else { nativePill(&canvas, centerX: x, centerY: bodyY - 2, width: 10, height: 3, color: accent) }
        } else {
            let headX = x + side * 13
            nativeOutlinedPill(&canvas, centerX: x - side * 2, centerY: bodyY, width: turtle ? 31 : 29, height: turtle ? 15 : 12, fill: body)
            if turtle { nativeOutlinedPill(&canvas, centerX: x - side * 3, centerY: bodyY - 2, width: 21, height: 12, fill: .darkGreen) }
            nativeOutlinedPill(&canvas, centerX: headX, centerY: bodyY - 5, width: 12, height: 8, fill: body)
            if chameleon { nativePill(&canvas, centerX: headX + side * 3, centerY: bodyY - 8, width: 5, height: 5, color: .lime) }
            nativeEye(&canvas, centerX: headX + side * 4, centerY: bodyY - 6, ink: .darkBrown)
            nativeStroke(&canvas, fromX: x - side * 15, bodyY + 1, dx: -side, dy: 1, length: chameleon ? 8 : 5, width: 3, color: accent)
            for offset in [-7, 7] { nativeStroke(&canvas, fromX: x + offset, bodyY + 4, dx: 0, dy: 1, length: 5, width: 3, color: body) }
        }
    }

    static func drawNativeAnatomicalSeaLife(_ canvas: inout [[PixelColor]], design: Design, direction: SpriteDirection, scale: Scale) {
        let x = nativeGridSize / 2
        let ground = nativeCenter(scale.baseline)
        let side = nativeDirectionSide(direction)
        let jelly = design.trait == "jellyfish"
        let seal = design.trait == "seal"
        let leviathan = design.trait == "leviathan"
        let bodyY = ground - 13 + scale.lift
        if jelly {
            let bell = PixelColor.pink
            if side == 0 {
                nativeOutlinedPill(&canvas, centerX: x, centerY: bodyY - 4, width: 25, height: 17, fill: bell)
                nativePill(&canvas, centerX: x, centerY: bodyY + 3, width: 20, height: 5, color: .lavender)
                for offset in [-8, -3, 3, 8] {
                    nativePolyline(&canvas, points: [(x + offset, bodyY + 5), (x + offset + (offset < 0 ? -2 : 2), ground - 3), (x + offset, ground)], width: 3, color: .lavender)
                }
                if direction == .front { drawNativeEyePair(&canvas, centerX: x, centerY: bodyY - 3, separation: 4) }
                else { nativePill(&canvas, centerX: x, centerY: bodyY - 2, width: 13, height: 3, color: .purple) }
            } else {
                let bellX = x + side * 3
                nativeOutlinedPill(&canvas, centerX: bellX, centerY: bodyY - 3, width: 25, height: 16, fill: bell)
                nativePill(&canvas, centerX: bellX, centerY: bodyY + 3, width: 18, height: 4, color: .lavender)
                for offset in [-6, 0, 6] { nativePolyline(&canvas, points: [(x + offset, bodyY + 5), (x + offset - side * 2, ground - 3), (x + offset - side, ground)], width: 3, color: .lavender) }
                nativeEye(&canvas, centerX: bellX + side * 4, centerY: bodyY - 3, ink: .darkBrown)
            }
            return
        }
        if leviathan {
            let sea = PixelColor.teal
            if side == 0 {
                nativePolyline(&canvas, points: [(x - 14, ground - 3), (x - 9, bodyY + 4), (x - 3, bodyY - 5), (x + 5, bodyY + 1), (x + 13, bodyY - 8)], width: 9, color: sea)
                nativeOutlinedPill(&canvas, centerX: x + 13, centerY: bodyY - 9, width: 13, height: 10, fill: sea)
                nativeStroke(&canvas, fromX: x - 5, bodyY - 8, dx: 1, dy: -1, length: 5, width: 2, color: .darkBlue)
                nativeStroke(&canvas, fromX: x + 2, bodyY - 4, dx: 1, dy: -1, length: 4, width: 2, color: .darkBlue)
                nativeEye(&canvas, centerX: x + 16, centerY: bodyY - 10, ink: .cream)
                if direction == .back { nativeStroke(&canvas, fromX: x - 10, bodyY - 2, dx: 1, dy: 0, length: 15, width: 2, color: .darkBlue) }
            } else {
                let headX = x + side * 14
                nativePolyline(&canvas, points: [(x - side * 16, ground - 3), (x - side * 8, bodyY + 3), (x, bodyY - 3), (headX, bodyY - 7)], width: 9, color: sea)
                nativeOutlinedPill(&canvas, centerX: headX, centerY: bodyY - 8, width: 14, height: 10, fill: sea)
                nativeStroke(&canvas, fromX: x - side * 5, bodyY - 8, dx: side, dy: -1, length: 4, width: 2, color: .darkBlue)
                nativeEye(&canvas, centerX: headX + side * 4, centerY: bodyY - 9, ink: .cream)
            }
            return
        }
        let body = seal ? PixelColor.lightGray : PixelColor.blue
        let accent = seal ? PixelColor.cream : PixelColor.teal
        if side == 0 {
            nativeOutlinedPill(&canvas, centerX: x, centerY: bodyY, width: seal ? 27 : 29, height: 16, fill: body)
            nativeOutlinedPill(&canvas, centerX: x, centerY: bodyY - 8, width: seal ? 17 : 15, height: 11, fill: body)
            nativeOutlinedPill(&canvas, centerX: x - 14, centerY: bodyY + 3, width: 10, height: 7, fill: accent)
            nativeOutlinedPill(&canvas, centerX: x + 14, centerY: bodyY + 3, width: 10, height: 7, fill: accent)
            if seal {
                nativePill(&canvas, centerX: x, centerY: bodyY + 3, width: 15, height: 7, color: .cream)
                nativeStroke(&canvas, fromX: x - 6, bodyY - 5, dx: -1, dy: 0, length: 5, color: .darkGray)
                nativeStroke(&canvas, fromX: x + 6, bodyY - 5, dx: 1, dy: 0, length: 5, color: .darkGray)
            } else {
                nativeStroke(&canvas, fromX: x - 11, bodyY + 3, dx: -1, dy: 1, length: 7, width: 2, color: accent)
                nativeStroke(&canvas, fromX: x + 11, bodyY + 3, dx: 1, dy: 1, length: 7, width: 2, color: accent)
            }
            if direction == .front { drawNativeEyePair(&canvas, centerX: x, centerY: bodyY - 9, separation: 3) }
        } else {
            let headX = x + side * 12
            nativeOutlinedPill(&canvas, centerX: x, centerY: bodyY, width: 31, height: 13, fill: body)
            nativeOutlinedPill(&canvas, centerX: headX, centerY: bodyY - 5, width: 14, height: 9, fill: body)
            nativeOutlinedPill(&canvas, centerX: x + side * 1, centerY: bodyY + 6, width: 12, height: 6, fill: accent)
            if seal { nativeStroke(&canvas, fromX: x - side * 14, bodyY + 2, dx: -side, dy: 1, length: 5, width: 3, color: accent) }
            else {
                nativePill(&canvas, centerX: x - side * 17, centerY: bodyY - 4, width: 8, height: 6, color: accent)
                nativePill(&canvas, centerX: x - side * 17, centerY: bodyY + 4, width: 8, height: 6, color: accent)
            }
            nativeEye(&canvas, centerX: headX + side * 4, centerY: bodyY - 6, ink: .darkBrown)
        }
    }

    static func drawNativeAnatomicalHybrid(_ canvas: inout [[PixelColor]], design: Design, direction: SpriteDirection, scale: Scale) {
        let x = nativeGridSize / 2
        let ground = nativeCenter(scale.baseline)
        let side = nativeDirectionSide(direction)
        let gryphon = design.trait == "gryphon"
        let body = gryphon ? PixelColor.brown : PixelColor.tan
        let wing = gryphon ? PixelColor.gold : PixelColor.cream
        let bodyY = ground - 11 + scale.lift
        let headY = bodyY - 10
        if side == 0 {
            nativeOutlinedPill(&canvas, centerX: x, centerY: bodyY, width: 27, height: 16, fill: body)
            nativeOutlinedPill(&canvas, centerX: x - 12, centerY: bodyY - 2, width: 10, height: 16, fill: wing)
            nativeOutlinedPill(&canvas, centerX: x + 12, centerY: bodyY - 2, width: 10, height: 16, fill: wing)
            nativeOutlinedPill(&canvas, centerX: x, centerY: headY, width: 17, height: 13, fill: gryphon ? .cream : .tan)
            if gryphon {
                nativePill(&canvas, centerX: x, centerY: headY + 4, width: 7, height: 4, color: .gold)
                nativeStroke(&canvas, fromX: x - 5, headY - 6, dx: -1, dy: -1, length: 3, color: .brown)
                nativeStroke(&canvas, fromX: x + 5, headY - 6, dx: 1, dy: -1, length: 3, color: .brown)
            } else {
                nativePill(&canvas, centerX: x, centerY: headY - 2, width: 13, height: 4, color: .gold)
            }
            if direction == .front { drawNativeEyePair(&canvas, centerX: x, centerY: headY - 1, separation: 3) }
            for offset in [-8, 8] { nativeStroke(&canvas, fromX: x + offset, bodyY + 6, dx: 0, dy: 1, length: 6, width: 3, color: body) }
            nativeStroke(&canvas, fromX: x + 12, bodyY + 2, dx: 1, dy: 1, length: 8, width: 3, color: body)
        } else {
            let headX = x + side * 12
            nativeOutlinedPill(&canvas, centerX: x - side * 2, centerY: bodyY, width: 30, height: 14, fill: body)
            nativeOutlinedPill(&canvas, centerX: x - side * 5, centerY: bodyY - 7, width: 15, height: 15, fill: wing)
            nativeOutlinedPill(&canvas, centerX: headX, centerY: headY + 4, width: 15, height: 11, fill: gryphon ? .cream : .tan)
            nativePill(&canvas, centerX: headX + side * 7, centerY: headY + 6, width: gryphon ? 7 : 5, height: 4, color: .gold)
            nativeEye(&canvas, centerX: headX + side * 3, centerY: headY + 1, ink: .darkBrown)
            nativeStroke(&canvas, fromX: x - side * 15, bodyY + 2, dx: -side, dy: 1, length: 8, width: 3, color: body)
            for offset in [-7, 8] { nativeStroke(&canvas, fromX: x + offset, bodyY + 5, dx: 0, dy: 1, length: 6, width: 3, color: body) }
        }
    }

    static func drawNativeAnatomicalObject(_ canvas: inout [[PixelColor]], design: Design, direction: SpriteDirection, scale: Scale) {
        let x = nativeGridSize / 2
        let ground = nativeCenter(scale.baseline)
        let side = nativeDirectionSide(direction)
        let y = ground - 14 + scale.lift
        switch design.trait {
        case "crystal":
            // Several offset mineral columns read as a crystal cluster rather
            // than the rejected single symmetric diamond body.
            nativePolyline(&canvas, points: [(x - 12, ground), (x - 12, y), (x - 7, y - 9), (x - 3, y), (x - 3, ground)], width: 5, color: .teal)
            nativePolyline(&canvas, points: [(x - 3, ground), (x - 3, y - 8), (x + 4, y - 17), (x + 9, y - 7), (x + 9, ground)], width: 6, color: .mint)
            nativePolyline(&canvas, points: [(x + 8, ground), (x + 8, y - 3), (x + 14, y - 11), (x + 18, y - 3), (x + 18, ground)], width: 5, color: .teal)
            nativeStroke(&canvas, fromX: x + side * 2, y - 11, dx: side == 0 ? 0 : side, dy: 1, length: 8, width: 2, color: .white)
            if direction == .front { nativePill(&canvas, centerX: x - 12, centerY: y + 4, width: 4, height: 7, color: .mint) }
            if direction == .back { nativePill(&canvas, centerX: x + 14, centerY: y + 4, width: 4, height: 8, color: .darkBlue) }
        case "rock":
            nativeOutlinedPill(&canvas, centerX: x - 8, centerY: y + 7, width: 19, height: 15, fill: .darkGray)
            nativeOutlinedPill(&canvas, centerX: x + 8, centerY: y + 8, width: 19, height: 13, fill: .gray)
            nativeOutlinedPill(&canvas, centerX: x + side * 3, centerY: y - 1, width: 17, height: 12, fill: .lightGray)
            nativePolyline(&canvas, points: [(x - 4, y), (x + 1, y + 5), (x - 1, y + 10)], width: 2, color: .darkGray)
            if direction == .front { nativeEye(&canvas, centerX: x, centerY: y + 3, ink: .darkBrown) }
        case "clockwork":
            nativeOutlinedPill(&canvas, centerX: x, centerY: y + 5, width: 22, height: 22, fill: .tan)
            for offset in [-12, 12] { nativeRect(&canvas, x + offset - 2, y + 1, 5, 8, .gold) }
            for offset in [-8, 8] { nativeRect(&canvas, x + offset - 2, y - 8, 5, 5, .gold) }
            nativeOutlinedPill(&canvas, centerX: x, centerY: y + 5, width: 11, height: 11, fill: .darkBrown)
            nativePill(&canvas, centerX: x, centerY: y + 5, width: 5, height: 5, color: .gold)
            nativePolyline(&canvas, points: [(x + 12, y + 9), (x + 18, y + 14), (x + 20, y + 20)], width: 2, color: .darkBrown)
            if direction == .back { nativePill(&canvas, centerX: x, centerY: y + 5, width: 14, height: 4, color: .darkBrown) }
            if side != 0 { nativePill(&canvas, centerX: x + side * 15, centerY: y + 2, width: 5, height: 7, color: .gold) }
        case "orb":
            nativeOutlinedPill(&canvas, centerX: x, centerY: y + 4, width: 25, height: 25, fill: .purple)
            nativePill(&canvas, centerX: x - side * 3, centerY: y, width: 11, height: 11, color: .lavender)
            nativePolyline(&canvas, points: [(x - 17, y + 5), (x - 8, y - 7), (x + 8, y - 7), (x + 17, y + 5)], width: 2, color: .gold)
            nativePolyline(&canvas, points: [(x - 17, y + 6), (x - 8, y + 16), (x + 8, y + 16), (x + 17, y + 6)], width: 2, color: .gold)
            if direction == .front { nativeEye(&canvas, centerX: x, centerY: y + 4, ink: .cream) }
        case "singularity":
            nativeOutlinedPill(&canvas, centerX: x, centerY: y + 5, width: 27, height: 27, fill: .black)
            nativeOval(&canvas, centerX: x, centerY: y + 5, width: 13, height: 13, color: .purple)
            nativePolyline(&canvas, points: [(x - 19, y + 9), (x - 6, y - 3), (x + 13, y - 1), (x + 19, y + 6)], width: 3, color: .lavender)
            nativeStroke(&canvas, fromX: x - 7, y + 12, dx: 1, dy: 0, length: 10, width: 2, color: .darkBlue)
            if direction == .front { nativePill(&canvas, centerX: x - 8, centerY: y + 4, width: 4, height: 4, color: .lavender) }
            if direction == .back { nativePill(&canvas, centerX: x + 8, centerY: y + 6, width: 4, height: 5, color: .darkBlue) }
            if side != 0 { nativeStroke(&canvas, fromX: x + side * 15, y + 2, dx: side, dy: 1, length: 5, width: 2, color: .purple) }
        case "lantern":
            nativePolyline(&canvas, points: [(x - 8, y - 10), (x - 8, y - 16), (x, y - 21), (x + 8, y - 16), (x + 8, y - 10)], width: 3, color: .brown)
            nativeOutlinedPill(&canvas, centerX: x, centerY: y + 4, width: 19, height: 25, fill: .brown)
            nativeRect(&canvas, x - 6, y - 4, 13, 17, .orange)
            nativePill(&canvas, centerX: x + side * 2, centerY: y + 4, width: 7, height: 11, color: .yellow)
            nativeRect(&canvas, x - 9, y - 8, 19, 3, .darkBrown)
            nativeRect(&canvas, x - 9, y + 14, 19, 3, .darkBrown)
            if direction == .back { nativeRect(&canvas, x - 6, y - 4, 13, 17, .darkBrown) }
            if side != 0 { nativePolyline(&canvas, points: [(x - side * 9, y - 6), (x - side * 14, y + 4), (x - side * 9, y + 15)], width: 2, color: .gold) }
        default: // bastion
            nativeOutlinedPill(&canvas, centerX: x, centerY: y + 8, width: 31, height: 19, fill: .gray)
            for offset in [-11, -4, 4, 11] { nativeRect(&canvas, x + offset - 2, y - 5, 5, 7, .darkGray) }
            nativeOutlinedPill(&canvas, centerX: x, centerY: y + 12, width: 10, height: 10, fill: .darkGray)
            nativeRect(&canvas, x - 14, y + 4, 5, 5, .lightGray)
            nativeRect(&canvas, x + 10, y + 4, 5, 5, .lightGray)
            if direction == .front { nativeEye(&canvas, centerX: x, centerY: y + 10, ink: .orange) }
            if direction == .back { nativeRect(&canvas, x - 10, y + 7, 21, 4, .darkGray) }
            if side != 0 { nativeRect(&canvas, x + side * 12, y - 7, 6, 9, .darkGray) }
        }
    }

    static func drawNativeAnatomicalPlant(_ canvas: inout [[PixelColor]], design: Design, direction: SpriteDirection, scale: Scale) {
        let x = nativeGridSize / 2
        let ground = nativeCenter(scale.baseline)
        let side = nativeDirectionSide(direction)
        let y = ground - 17 + scale.lift
        switch design.trait {
        case "lotus", "moonflower":
            let moon = design.trait == "moonflower"
            let petal = moon ? PixelColor.lavender : PixelColor.pink
            nativeStroke(&canvas, fromX: x, y + 9, dx: 0, dy: 1, length: 15, width: 4, color: .green)
            nativeOutlinedPill(&canvas, centerX: x - 9, centerY: y, width: 13, height: 19, fill: petal)
            nativeOutlinedPill(&canvas, centerX: x + 9, centerY: y, width: 13, height: 19, fill: petal)
            nativeOutlinedPill(&canvas, centerX: x, centerY: y - 4, width: 13, height: 21, fill: petal)
            nativePill(&canvas, centerX: x + side * 2, centerY: y + 4, width: 8, height: 8, color: moon ? .gold : .mint)
            nativeOutlinedPill(&canvas, centerX: x - 10, centerY: ground - 1, width: 18, height: 6, fill: .green)
            nativeOutlinedPill(&canvas, centerX: x + 10, centerY: ground - 1, width: 18, height: 6, fill: .green)
            if direction == .front { nativeEye(&canvas, centerX: x, centerY: y + 4, ink: .darkBrown) }
            if moon { nativeStroke(&canvas, fromX: x, y - 13, dx: 0, dy: -1, length: 6, width: 3, color: petal) }
        case "mushroom":
            nativeOutlinedPill(&canvas, centerX: x, centerY: y - 2, width: 29, height: 14, fill: .red)
            nativePill(&canvas, centerX: x - 8, centerY: y - 4, width: 5, height: 4, color: .cream)
            nativePill(&canvas, centerX: x + 7, centerY: y - 1, width: 4, height: 4, color: .cream)
            nativeOutlinedPill(&canvas, centerX: x, centerY: y + 12, width: 13, height: 17, fill: .cream)
            nativeStroke(&canvas, fromX: x - 10, y + 3, dx: 1, dy: 1, length: 6, width: 2, color: .tan)
            nativeStroke(&canvas, fromX: x + 10, y + 3, dx: -1, dy: 1, length: 6, width: 2, color: .tan)
            if direction == .front { drawNativeEyePair(&canvas, centerX: x, centerY: y + 12, separation: 2) }
            if direction == .back { nativeStroke(&canvas, fromX: x - 8, y + 3, dx: 1, dy: 0, length: 9, width: 2, color: .tan) }
            if side != 0 { nativePill(&canvas, centerX: x + side * 12, centerY: y - 1, width: 6, height: 4, color: .red) }
        case "cactus":
            nativeOutlinedPill(&canvas, centerX: x, centerY: y + 4, width: 14, height: 33, fill: .green)
            nativeOutlinedPill(&canvas, centerX: x - 10, centerY: y + 8, width: 8, height: 15, fill: .green)
            nativeOutlinedPill(&canvas, centerX: x + 10, centerY: y + 2, width: 8, height: 15, fill: .green)
            for offset in [-4, 0, 4] { nativeStroke(&canvas, fromX: x + offset, y - 7, dx: 0, dy: 1, length: 22, color: .lime) }
            nativePill(&canvas, centerX: x + side * 2, centerY: y + 7, width: 4, height: 4, color: .coral)
            if direction == .front { drawNativeEyePair(&canvas, centerX: x, centerY: y + 5, separation: 2) }
        case "parrot":
            // Korean display name is 파리지옥: its hinged jaws and ground
            // leaves are the identity, even though the legacy id is parrot.
            nativeStroke(&canvas, fromX: x, y + 7, dx: 0, dy: 1, length: 14, width: 4, color: .green)
            nativeOutlinedPill(&canvas, centerX: x - 8, centerY: y - 2, width: 19, height: 11, fill: .green)
            nativeOutlinedPill(&canvas, centerX: x + 8, centerY: y - 2, width: 19, height: 11, fill: .green)
            for offset in [-7, -2, 2, 7] { nativeRect(&canvas, x + offset - 1, y - 4, 3, 4, .cream) }
            nativePill(&canvas, centerX: x + side * 2, centerY: y + 2, width: 6, height: 5, color: .coral)
            nativeOutlinedPill(&canvas, centerX: x - 9, centerY: ground - 1, width: 18, height: 6, fill: .green)
            nativeOutlinedPill(&canvas, centerX: x + 9, centerY: ground - 1, width: 18, height: 6, fill: .green)
            if direction == .back { nativePill(&canvas, centerX: x, centerY: y - 2, width: 14, height: 3, color: .darkGreen) }
            if side != 0 { nativePill(&canvas, centerX: x + side * 10, centerY: y - 2, width: 5, height: 4, color: .coral) }
        case "peach":
            nativeOutlinedPill(&canvas, centerX: x - 5, centerY: y + 6, width: 17, height: 22, fill: .peach)
            nativeOutlinedPill(&canvas, centerX: x + 5, centerY: y + 6, width: 17, height: 22, fill: .peach)
            nativeStroke(&canvas, fromX: x + side, y - 3, dx: 0, dy: 1, length: 18, width: 2, color: .pink)
            nativeOutlinedPill(&canvas, centerX: x + side * 4, centerY: y - 7, width: 12, height: 6, fill: .green)
            if direction == .front { drawNativeEyePair(&canvas, centerX: x, centerY: y + 6, separation: 3) }
        default: // acorn
            nativeOutlinedPill(&canvas, centerX: x, centerY: y + 7, width: 19, height: 25, fill: .brown)
            nativeOutlinedPill(&canvas, centerX: x, centerY: y - 3, width: 23, height: 10, fill: .tan)
            for offset in [-7, -3, 1, 5] { nativePill(&canvas, centerX: x + offset, centerY: y - 4, width: 3, height: 4, color: .brown) }
            nativeStroke(&canvas, fromX: x + side * 2, y - 9, dx: side == 0 ? 0 : side, dy: -1, length: 5, width: 2, color: .green)
            if direction == .front { drawNativeEyePair(&canvas, centerX: x, centerY: y + 7, separation: 3) }
        }
    }

    static func drawNativeAnatomicalElemental(_ canvas: inout [[PixelColor]], design: Design, direction: SpriteDirection, scale: Scale) {
        let x = nativeGridSize / 2
        let ground = nativeCenter(scale.baseline)
        let side = nativeDirectionSide(direction)
        let y = ground - 14 + scale.lift
        switch design.trait {
        case "flame":
            nativePolyline(&canvas, points: [(x, ground), (x - 9, y + 8), (x - 4, y - 7), (x + 2, y + 1), (x + 8, y - 14), (x + 12, y + 7), (x + 6, ground)], width: 7, color: .orange)
            nativePolyline(&canvas, points: [(x + side, ground - 2), (x - 3 + side, y + 7), (x + 2 + side, y - 1), (x + 6 + side, y + 9)], width: 4, color: .yellow)
            if direction == .front { drawNativeEyePair(&canvas, centerX: x + side, centerY: y + 5, separation: 2, ink: .darkRed) }
        case "comet":
            let coreX = x + side * 5
            nativeOutlinedPill(&canvas, centerX: coreX, centerY: y + 6, width: 16, height: 16, fill: .orange)
            nativePill(&canvas, centerX: coreX - side * 2, centerY: y + 3, width: 8, height: 8, color: .yellow)
            nativePolyline(&canvas, points: [(coreX - side * 8, y + 5), (x - side * 17, y - 2), (x - side * 21, y - 10)], width: 3, color: .blue)
            nativePolyline(&canvas, points: [(coreX - side * 7, y + 9), (x - side * 18, y + 15), (x - side * 22, ground - 2)], width: 2, color: .mistBlue)
            if direction == .front { nativeEye(&canvas, centerX: coreX, centerY: y + 6, ink: .darkBrown) }
        case "cloud":
            nativeOutlinedPill(&canvas, centerX: x - 10, centerY: y + 7, width: 18, height: 12, fill: .cream)
            nativeOutlinedPill(&canvas, centerX: x, centerY: y + 2, width: 21, height: 18, fill: .cream)
            nativeOutlinedPill(&canvas, centerX: x + 11, centerY: y + 7, width: 18, height: 12, fill: .cream)
            nativePill(&canvas, centerX: x, centerY: y + 10, width: 25, height: 6, color: .mint)
            if direction == .front { drawNativeEyePair(&canvas, centerX: x, centerY: y + 5, separation: 4) }
            else { nativePill(&canvas, centerX: x + side * 4, centerY: y + 5, width: 4, height: 3, color: .darkBrown) }
        case "nebula":
            nativeOutlinedPill(&canvas, centerX: x, centerY: y + 7, width: 31, height: 18, fill: .purple)
            nativePolyline(&canvas, points: [(x - 16, y + 7), (x - 5, y - 4), (x + 9, y - 1), (x + 15, y + 10)], width: 4, color: .blue)
            nativePolyline(&canvas, points: [(x - 12, y + 15), (x + 2, y + 19), (x + 16, y + 11)], width: 3, color: .mint)
            nativePill(&canvas, centerX: x + side * 3, centerY: y + 7, width: 8, height: 8, color: .lavender)
            if direction == .front { nativeEye(&canvas, centerX: x, centerY: y + 7, ink: .cream) }
        default: // aurora
            nativePolyline(&canvas, points: [(x - 14, ground), (x - 15, y + 8), (x - 8, y - 5), (x - 4, y + 6), (x + 1, ground)], width: 5, color: .purple)
            nativePolyline(&canvas, points: [(x - 2, ground), (x - 1, y + 5), (x + 7, y - 9), (x + 10, y + 2), (x + 14, ground)], width: 5, color: .mint)
            nativePolyline(&canvas, points: [(x + 7, ground), (x + 11, y + 9), (x + 18, y - 1), (x + 20, y + 7)], width: 3, color: .blue)
            nativePill(&canvas, centerX: x + side * 2, centerY: y + 9, width: 8, height: 6, color: .lavender)
            if direction == .back { nativePill(&canvas, centerX: x, centerY: y + 9, width: 12, height: 3, color: .darkBlue) }
        }
    }

    static func drawNativeAnatomicalHumanoid(_ canvas: inout [[PixelColor]], design: Design, direction: SpriteDirection, scale: Scale) {
        let x = nativeGridSize / 2
        let ground = nativeCenter(scale.baseline)
        let side = nativeDirectionSide(direction)
        let fairy = design.trait == "fairy"
        let celestial = design.trait == "celestial"
        let seraph = design.trait == "seraph"
        let golem = design.trait == "golem"
        let titan = design.trait == "titan"
        let ninja = design.trait == "ninja"
        let voidRunner = design.trait == "void_runner"
        let skin: PixelColor = fairy ? .peach : celestial || seraph ? .cream : design.primary
        let clothes: PixelColor = fairy ? .lavender : celestial || seraph ? .white : design.primary
        let headY = ground - 30 + scale.lift
        let torsoY = ground - 18 + scale.lift
        let torsoWidth = titan ? 21 : golem ? 18 : 14
        let torsoHeight = titan ? 17 : 15
        if side == 0 {
            if fairy || seraph {
                let wing = fairy ? PixelColor.lavender : PixelColor.white
                nativeOutlinedPill(&canvas, centerX: x - 10, centerY: torsoY - 1, width: 12, height: 18, fill: wing)
                nativeOutlinedPill(&canvas, centerX: x + 10, centerY: torsoY - 1, width: 12, height: 18, fill: wing)
            }
            nativeOutlinedPill(&canvas, centerX: x, centerY: torsoY, width: torsoWidth, height: torsoHeight, fill: clothes)
            nativeOutlinedPill(&canvas, centerX: x, centerY: headY, width: golem || titan ? 17 : 15, height: 14, fill: skin)
            if golem || titan {
                nativeOutlinedPill(&canvas, centerX: x - 14, centerY: torsoY + 2, width: 8, height: 13, fill: .gray)
                nativeOutlinedPill(&canvas, centerX: x + 14, centerY: torsoY + 2, width: 8, height: 13, fill: .gray)
                nativeRect(&canvas, x - 5, torsoY - 5, 11, 3, .gold)
            } else {
                nativeStroke(&canvas, fromX: x - torsoWidth / 2 - 1, torsoY - 4, dx: -1, dy: 1, length: 6, width: 3, color: skin)
                nativeStroke(&canvas, fromX: x + torsoWidth / 2 + 1, torsoY - 4, dx: 1, dy: 1, length: 6, width: 3, color: skin)
            }
            if fairy { nativePolyline(&canvas, points: [(x - 7, headY - 6), (x, headY - 10), (x + 7, headY - 6)], width: 3, color: .pink) }
            if celestial || seraph { nativeOutlinedPill(&canvas, centerX: x, centerY: headY - 10, width: 17, height: 4, fill: .gold) }
            if ninja {
                nativePill(&canvas, centerX: x, centerY: headY, width: 14, height: 6, color: .darkGray)
                nativePill(&canvas, centerX: x, centerY: headY, width: 9, height: 3, color: .purple)
                nativePill(&canvas, centerX: x, centerY: headY, width: 4, height: 2, color: .teal)
                nativeStroke(&canvas, fromX: x + 8, headY - 2, dx: 1, dy: 0, length: 7, width: 2, color: .purple)
            } else if voidRunner {
                nativeOutlinedPill(&canvas, centerX: x, centerY: headY, width: 17, height: 15, fill: .darkGray)
                nativePill(&canvas, centerX: x, centerY: headY, width: 11, height: 4, color: .teal)
            } else if direction == .front {
                drawNativeEyePair(&canvas, centerX: x, centerY: headY, separation: 3, ink: golem || titan ? .orange : .darkBrown)
            }
            nativeStroke(&canvas, fromX: x - 5, torsoY + torsoHeight / 2 - 2, dx: 0, dy: 1, length: 8, width: 4, color: clothes)
            nativeStroke(&canvas, fromX: x + 5, torsoY + torsoHeight / 2 - 2, dx: 0, dy: 1, length: 8, width: 4, color: clothes)
            nativePill(&canvas, centerX: x - 5, centerY: ground - 1, width: 7, height: 3, color: .darkGray)
            nativePill(&canvas, centerX: x + 5, centerY: ground - 1, width: 7, height: 3, color: .darkGray)
            if direction == .back { nativePill(&canvas, centerX: x, centerY: torsoY - 1, width: torsoWidth - 4, height: 6, color: design.accent) }
        } else {
            let headX = x + side * 4
            if fairy || seraph { nativeOutlinedPill(&canvas, centerX: x - side * 6, centerY: torsoY, width: 17, height: 17, fill: fairy ? .lavender : .white) }
            nativeOutlinedPill(&canvas, centerX: x, centerY: torsoY, width: torsoWidth, height: torsoHeight, fill: clothes)
            nativeOutlinedPill(&canvas, centerX: headX, centerY: headY, width: golem || titan ? 17 : 15, height: 14, fill: skin)
            if ninja { nativePill(&canvas, centerX: headX + side * 3, centerY: headY, width: 9, height: 3, color: .purple) }
            else if voidRunner { nativePill(&canvas, centerX: headX + side * 3, centerY: headY, width: 10, height: 4, color: .teal) }
            else { nativeEye(&canvas, centerX: headX + side * 3, centerY: headY, ink: golem || titan ? .orange : .darkBrown) }
            nativeStroke(&canvas, fromX: x + side * (torsoWidth / 2), torsoY - 3, dx: side, dy: 1, length: 7, width: 3, color: skin)
            nativeStroke(&canvas, fromX: x - 5, torsoY + torsoHeight / 2 - 2, dx: 0, dy: 1, length: 8, width: 4, color: clothes)
            nativeStroke(&canvas, fromX: x + 5, torsoY + torsoHeight / 2 - 2, dx: 0, dy: 1, length: 8, width: 4, color: clothes)
            if celestial || seraph { nativeOutlinedPill(&canvas, centerX: headX, centerY: headY - 10, width: 16, height: 4, fill: .gold) }
        }
    }

    static func drawNativeFeaturedSpecies(
        _ canvas: inout [[PixelColor]],
        design: Design,
        direction: SpriteDirection,
        scale: Scale
    ) -> Bool {
        switch design.trait {
        case "rabbit", "moonrabbit":
            drawNativeRabbit(&canvas, moon: design.trait == "moonrabbit", direction: direction, scale: scale)
        case "bear":
            drawNativeBear(&canvas, direction: direction, scale: scale)
        case "raccoon":
            drawNativeRaccoon(&canvas, direction: direction, scale: scale)
        default:
            return false
        }
        return true
    }

    /// The featured mammals receive a second material pass tailored to their
    /// anatomy.  It makes the white rabbit read as a soft plush creature,
    /// keeps the bear's ears compact and furry, and separates the raccoon's
    /// gray fur from its dark mask without adding decorative geometry.
    static func drawNativeFeaturedSurface(
        _ canvas: inout [[PixelColor]],
        design: Design,
        direction: SpriteDirection,
        scale: Scale
    ) {
        let centerX = nativeGridSize / 2
        let ground = nativeCenter(scale.baseline)

        switch design.trait {
        case "rabbit", "moonrabbit":
            let moon = design.trait == "moonrabbit"
            let bodyWidth = max(14, scale.value(moon ? 11 : 10, minimum: 7) * 2)
            let bodyHeight = max(12, scale.value(moon ? 10 : 9, minimum: 6) * 2)
            let headWidth = max(14, scale.value(9, minimum: 7) * 2)
            let headHeight = max(13, scale.value(8, minimum: 6) * 2)
            let bodyY = ground - bodyHeight / 2 - 1 + scale.lift
            let headY = bodyY - bodyHeight / 2 - headHeight / 2 + 3
            let profileWidth = bodyWidth + 5
            let headX: Int
            switch direction {
            case .sideLeft: headX = centerX - (profileWidth / 2 - headWidth / 3)
            case .sideRight: headX = centerX + (profileWidth / 2 - headWidth / 3)
            default: headX = centerX
            }
            nativeClusterReplacing(
                &canvas,
                source: .white,
                atX: headX - 7,
                headY - 4,
                color: .cream,
                cells: [(0, 0), (1, 0), (0, 1), (1, 1)]
            )
            nativeClusterReplacing(
                &canvas,
                source: .white,
                atX: centerX + bodyWidth / 4,
                bodyY + bodyHeight / 5,
                color: .warmGray,
                cells: [(0, 0), (1, 0), (0, 1), (1, 1), (2, 1), (1, 2)]
            )
            nativeClusterReplacing(
                &canvas,
                source: .white,
                atX: centerX - bodyWidth / 4 - 1,
                bodyY + bodyHeight / 4,
                color: .cream,
                cells: [(0, 0), (1, 0), (0, 1)]
            )

        case "bear":
            let bodyWidth = max(17, scale.value(13, minimum: 9) * 2)
            let bodyHeight = max(14, scale.value(10, minimum: 7) * 2)
            let headHeight = max(15, scale.value(8, minimum: 6) * 2)
            let bodyY = ground - bodyHeight / 2 - 1 + scale.lift
            let headY = bodyY - bodyHeight / 2 - headHeight / 2 + 3
            nativeClusterReplacing(
                &canvas,
                source: .brown,
                atX: centerX - 7,
                headY - 4,
                color: .tan,
                cells: [(0, 0), (1, 0), (0, 1), (1, 1), (2, 1)]
            )
            nativeClusterReplacing(
                &canvas,
                source: .brown,
                atX: centerX + bodyWidth / 4,
                bodyY + bodyHeight / 5,
                color: .cocoa,
                cells: [(0, 0), (1, 0), (0, 1), (1, 1), (2, 1), (1, 2)]
            )

        case "raccoon":
            let bodyWidth = max(18, scale.value(13, minimum: 9) * 2)
            let bodyHeight = max(13, scale.value(8, minimum: 6) * 2)
            let headHeight = max(15, scale.value(8, minimum: 6) * 2)
            let bodyY = ground - bodyHeight / 2 - 1 + scale.lift
            let headY = bodyY - bodyHeight / 2 - headHeight / 2 + 3
            nativeClusterReplacing(
                &canvas,
                source: .gray,
                atX: centerX - 7,
                headY - 4,
                color: .lightGray,
                cells: [(0, 0), (1, 0), (0, 1), (1, 1), (2, 1)]
            )
            nativeClusterReplacing(
                &canvas,
                source: .gray,
                atX: centerX + bodyWidth / 4,
                bodyY + bodyHeight / 5,
                color: .darkGray,
                cells: [(0, 0), (1, 0), (0, 1), (1, 1), (2, 1), (1, 2)]
            )

        default:
            break
        }
    }

    static func drawNativeRabbit(_ canvas: inout [[PixelColor]], moon: Bool, direction: SpriteDirection, scale: Scale) {
        let centerX = nativeGridSize / 2
        let ground = nativeCenter(scale.baseline)
        let hop = scale.lift
        let bodyWidth = max(14, scale.value(moon ? 11 : 10, minimum: 7) * 2)
        let bodyHeight = max(12, scale.value(moon ? 10 : 9, minimum: 6) * 2)
        let headWidth = max(14, scale.value(9, minimum: 7) * 2)
        let headHeight = max(13, scale.value(8, minimum: 6) * 2)
        let bodyY = ground - bodyHeight / 2 - 1 + hop
        let headY = bodyY - bodyHeight / 2 - headHeight / 2 + 3
        let headTop = headY - headHeight / 2
        let earHeight = max(11, scale.value(moon ? 10 : 8, minimum: 6) * 2)
        let earY = max(earHeight / 2 + 1, headTop - earHeight / 2 + 5)
        let earOffset = moon ? max(6, headWidth / 3) : max(5, headWidth / 3)
        let innerEar = moon ? PixelColor.lavender : .blush

        switch direction {
        case .front:
            for earX in [centerX - earOffset, centerX + earOffset] {
                nativeOutlinedPill(&canvas, centerX: earX, centerY: earY, width: 7, height: earHeight, fill: .white)
                nativePill(&canvas, centerX: earX, centerY: earY + 1, width: 3, height: max(7, earHeight - 7), color: innerEar)
            }
            // The tail sits behind and overlaps the torso, leaving no detached
            // ornament near the rabbit's feet.
            nativeOutlinedPill(&canvas, centerX: centerX - bodyWidth / 2 + 2, centerY: bodyY + 3, width: 8, height: 8, fill: .white)
            nativeOutlinedPill(&canvas, centerX: centerX, centerY: bodyY, width: bodyWidth, height: bodyHeight, fill: .white)
            nativePill(&canvas, centerX: centerX, centerY: bodyY + 2, width: max(8, bodyWidth - 8), height: max(5, bodyHeight / 2), color: .cream)
            nativeOutlinedPill(&canvas, centerX: centerX - bodyWidth / 2 + 2, centerY: bodyY + 3, width: 6, height: 9, fill: .white)
            nativeOutlinedPill(&canvas, centerX: centerX + bodyWidth / 2 - 2, centerY: bodyY + 3, width: 6, height: 9, fill: .white)
            nativeOutlinedPill(&canvas, centerX: centerX, centerY: headY, width: headWidth, height: headHeight, fill: .white)
            nativeRabbitFace(&canvas, centerX: centerX, centerY: headY, moon: moon)
            nativeOutlinedPill(&canvas, centerX: centerX - bodyWidth / 4, centerY: ground - 2 + hop, width: 7, height: 5, fill: .white)
            nativeOutlinedPill(&canvas, centerX: centerX + bodyWidth / 4, centerY: ground - 2, width: 7, height: 5, fill: .white)

        case .back:
            for earX in [centerX - earOffset, centerX + earOffset] {
                nativeOutlinedPill(&canvas, centerX: earX, centerY: earY, width: 7, height: earHeight, fill: .white)
                nativePill(&canvas, centerX: earX, centerY: earY + 1, width: 3, height: max(7, earHeight - 7), color: moon ? .lavender : .lightGray)
            }
            nativeOutlinedPill(&canvas, centerX: centerX, centerY: bodyY, width: bodyWidth, height: bodyHeight, fill: .white)
            nativeOutlinedPill(&canvas, centerX: centerX, centerY: headY, width: headWidth, height: headHeight, fill: .white)
            nativePill(&canvas, centerX: centerX, centerY: bodyY + bodyHeight / 2 - 2, width: 8, height: 7, color: .white)
            nativeRect(&canvas, centerX - 3, bodyY - 2, 7, 2, moon ? .lavender : .lightGray)

        case .sideLeft, .sideRight:
            let side = direction == .sideLeft ? -1 : 1
            let profileBodyWidth = bodyWidth + 5
            let headX = centerX + side * (profileBodyWidth / 2 - headWidth / 3)
            let tailX = centerX - side * (profileBodyWidth / 2 + 2)
            nativeOutlinedPill(&canvas, centerX: tailX, centerY: bodyY + 3, width: 9, height: 8, fill: .white)
            nativeOutlinedPill(&canvas, centerX: centerX, centerY: bodyY, width: profileBodyWidth, height: max(11, bodyHeight - 3), fill: .white)
            // Both ears share the head root; the farther ear is muted but not
            // detached, which makes the profile immediately read as rabbit.
            nativeOutlinedPill(&canvas, centerX: headX - side * 3, centerY: earY + 2, width: 6, height: earHeight - 2, fill: .cream)
            nativeOutlinedPill(&canvas, centerX: headX + side * 2, centerY: earY, width: 7, height: earHeight, fill: .white)
            nativePill(&canvas, centerX: headX + side * 2, centerY: earY + 1, width: 3, height: max(6, earHeight - 8), color: innerEar)
            nativeOutlinedPill(&canvas, centerX: headX, centerY: headY + 2, width: headWidth, height: headHeight, fill: .white)
            nativeRabbitProfileFace(&canvas, centerX: headX, centerY: headY + 2, side: side, moon: moon)
            nativeOutlinedPill(&canvas, centerX: centerX + side * 2, centerY: bodyY + 3, width: 6, height: 8, fill: .white)
            nativeOutlinedPill(&canvas, centerX: centerX - profileBodyWidth / 4, centerY: ground - 2, width: 7, height: 5, fill: .white)
            nativeOutlinedPill(&canvas, centerX: centerX + profileBodyWidth / 4, centerY: ground - 2 + hop, width: 7, height: 5, fill: .white)
        }
    }

    static func nativeRabbitFace(_ canvas: inout [[PixelColor]], centerX: Int, centerY: Int, moon: Bool) {
        let ink = PixelColor.darkBrown
        let eye = PixelColor.darkBlue
        nativePill(&canvas, centerX: centerX - 4, centerY: centerY - 1, width: 3, height: 4, color: eye)
        nativePill(&canvas, centerX: centerX + 4, centerY: centerY - 1, width: 3, height: 4, color: eye)
        nativePixel(&canvas, centerX - 5, centerY - 2, .mistBlue)
        nativePixel(&canvas, centerX + 3, centerY - 2, .mistBlue)
        nativePill(&canvas, centerX: centerX, centerY: centerY + 4, width: 3, height: 2, color: moon ? .lavender : .blush)
        nativePixel(&canvas, centerX - 1, centerY + 6, ink)
        nativePixel(&canvas, centerX + 1, centerY + 6, ink)
        nativeRect(&canvas, centerX - 1, centerY + 7, 3, 1, ink)
        nativePill(&canvas, centerX: centerX - 8, centerY: centerY + 3, width: 3, height: 2, color: moon ? .lavender : .blush)
        nativePill(&canvas, centerX: centerX + 8, centerY: centerY + 3, width: 3, height: 2, color: moon ? .lavender : .blush)
    }

    static func nativeRabbitProfileFace(_ canvas: inout [[PixelColor]], centerX: Int, centerY: Int, side: Int, moon: Bool) {
        let ink = PixelColor.darkBrown
        nativePill(&canvas, centerX: centerX + side * 4, centerY: centerY - 1, width: 3, height: 4, color: .darkBlue)
        nativePixel(&canvas, centerX + side * 3, centerY - 2, .mistBlue)
        nativePill(&canvas, centerX: centerX + side * 8, centerY: centerY + 3, width: 3, height: 2, color: moon ? .lavender : .blush)
        nativePixel(&canvas, centerX + side * 7, centerY + 5, ink)
    }

    static func drawNativeBear(_ canvas: inout [[PixelColor]], direction: SpriteDirection, scale: Scale) {
        let centerX = nativeGridSize / 2
        let ground = nativeCenter(scale.baseline)
        let hop = scale.lift
        let bodyWidth = max(17, scale.value(13, minimum: 9) * 2)
        let bodyHeight = max(14, scale.value(10, minimum: 7) * 2)
        let headWidth = max(16, scale.value(9, minimum: 7) * 2)
        let headHeight = max(15, scale.value(8, minimum: 6) * 2)
        let bodyY = ground - bodyHeight / 2 - 1 + hop
        let headY = bodyY - bodyHeight / 2 - headHeight / 2 + 3

        switch direction {
        case .front:
            drawNativeBearEarsAt(&canvas, centerX: centerX, centerY: headY - headHeight / 2 + 3)
            nativeOutlinedPill(&canvas, centerX: centerX, centerY: bodyY, width: bodyWidth, height: bodyHeight, fill: .brown)
            nativePill(&canvas, centerX: centerX - bodyWidth / 2 - 1, centerY: bodyY + 2, width: 7, height: 10, color: .brown)
            nativePill(&canvas, centerX: centerX + bodyWidth / 2 + 1, centerY: bodyY + 2, width: 7, height: 10, color: .brown)
            nativeOutlinedPill(&canvas, centerX: centerX, centerY: headY, width: headWidth, height: headHeight, fill: .brown)
            nativeBearFace(&canvas, centerX: centerX, centerY: headY)
            nativePill(&canvas, centerX: centerX - bodyWidth / 4, centerY: ground - 2 + hop, width: 7, height: 5, color: .brown)
            nativePill(&canvas, centerX: centerX + bodyWidth / 4, centerY: ground - 2, width: 7, height: 5, color: .brown)

        case .back:
            drawNativeBearEarsAt(&canvas, centerX: centerX, centerY: headY - headHeight / 2 + 3)
            nativeOutlinedPill(&canvas, centerX: centerX, centerY: bodyY, width: bodyWidth, height: bodyHeight, fill: .brown)
            nativeOutlinedPill(&canvas, centerX: centerX, centerY: headY, width: headWidth, height: headHeight, fill: .brown)
            nativePill(&canvas, centerX: centerX, centerY: bodyY + bodyHeight / 2 - 2, width: 7, height: 6, color: .tan)
            nativeRect(&canvas, centerX - bodyWidth / 3, bodyY - 2, bodyWidth * 2 / 3, 2, .tan)

        case .sideLeft, .sideRight:
            let side = direction == .sideLeft ? -1 : 1
            let profileWidth = bodyWidth + 5
            let headX = centerX + side * (profileWidth / 2 - headWidth / 3)
            drawNativeBearEarsAt(&canvas, centerX: headX, centerY: headY - headHeight / 2 + 3)
            nativeOutlinedPill(&canvas, centerX: centerX, centerY: bodyY, width: profileWidth, height: bodyHeight - 2, fill: .brown)
            nativeOutlinedPill(&canvas, centerX: headX, centerY: headY + 2, width: headWidth, height: headHeight, fill: .brown)
            nativeBearProfileFace(&canvas, centerX: headX, centerY: headY + 2, side: side)
            nativePill(&canvas, centerX: centerX - profileWidth / 4, centerY: ground - 2, width: 7, height: 5, color: .brown)
            nativePill(&canvas, centerX: centerX + profileWidth / 4, centerY: ground - 2 + hop, width: 7, height: 5, color: .brown)
        }
    }

    static func drawNativeBearEarsAt(_ canvas: inout [[PixelColor]], centerX: Int, centerY: Int) {
        for earX in [centerX - 7, centerX + 7] {
            nativeOutlinedPill(&canvas, centerX: earX, centerY: centerY, width: 6, height: 6, fill: .brown)
            nativePill(&canvas, centerX: earX, centerY: centerY + 1, width: 3, height: 3, color: .tan)
        }
    }

    static func nativeBearFace(_ canvas: inout [[PixelColor]], centerX: Int, centerY: Int) {
        nativePill(&canvas, centerX: centerX - 4, centerY: centerY - 1, width: 3, height: 4, color: .darkBrown)
        nativePill(&canvas, centerX: centerX + 4, centerY: centerY - 1, width: 3, height: 4, color: .darkBrown)
        nativePixel(&canvas, centerX - 5, centerY - 2, .white)
        nativePixel(&canvas, centerX + 3, centerY - 2, .white)
        nativePill(&canvas, centerX: centerX, centerY: centerY + 5, width: 11, height: 7, color: .tan)
        nativePill(&canvas, centerX: centerX, centerY: centerY + 4, width: 3, height: 2, color: .darkBrown)
        nativePixel(&canvas, centerX - 2, centerY + 7, .darkBrown)
        nativeRect(&canvas, centerX - 1, centerY + 8, 3, 1, .darkBrown)
        nativePill(&canvas, centerX: centerX - 9, centerY: centerY + 4, width: 3, height: 2, color: .blush)
        nativePill(&canvas, centerX: centerX + 9, centerY: centerY + 4, width: 3, height: 2, color: .blush)
    }

    static func nativeBearProfileFace(_ canvas: inout [[PixelColor]], centerX: Int, centerY: Int, side: Int) {
        nativePill(&canvas, centerX: centerX + side * 4, centerY: centerY - 1, width: 3, height: 4, color: .darkBrown)
        nativePixel(&canvas, centerX + side * 3, centerY - 2, .white)
        nativePill(&canvas, centerX: centerX + side * 6, centerY: centerY + 4, width: 8, height: 5, color: .tan)
        nativePixel(&canvas, centerX + side * 9, centerY + 4, .darkBrown)
    }

    static func drawNativeRaccoon(_ canvas: inout [[PixelColor]], direction: SpriteDirection, scale: Scale) {
        let centerX = nativeGridSize / 2
        let ground = nativeCenter(scale.baseline)
        let hop = scale.lift
        let bodyWidth = max(18, scale.value(13, minimum: 9) * 2)
        let bodyHeight = max(13, scale.value(8, minimum: 6) * 2)
        let headWidth = max(17, scale.value(9, minimum: 7) * 2)
        let headHeight = max(15, scale.value(8, minimum: 6) * 2)
        let bodyY = ground - bodyHeight / 2 - 1 + hop
        let headY = bodyY - bodyHeight / 2 - headHeight / 2 + 3

        switch direction {
        case .front:
            drawNativeRaccoonTail(&canvas, centerX: centerX - bodyWidth / 2 - 4, centerY: bodyY + 3, horizontal: true)
            drawNativeRaccoonEars(&canvas, centerX: centerX, centerY: headY - headHeight / 2 + 3)
            nativeOutlinedPill(&canvas, centerX: centerX, centerY: bodyY, width: bodyWidth, height: bodyHeight, fill: .gray)
            nativePill(&canvas, centerX: centerX, centerY: bodyY + 2, width: bodyWidth - 8, height: bodyHeight / 2, color: .lightGray)
            nativeOutlinedPill(&canvas, centerX: centerX, centerY: headY, width: headWidth, height: headHeight, fill: .gray)
            nativeRaccoonFace(&canvas, centerX: centerX, centerY: headY)
            nativePill(&canvas, centerX: centerX - bodyWidth / 4, centerY: ground - 2 + hop, width: 7, height: 5, color: .gray)
            nativePill(&canvas, centerX: centerX + bodyWidth / 4, centerY: ground - 2, width: 7, height: 5, color: .gray)

        case .back:
            drawNativeRaccoonTail(&canvas, centerX: centerX + bodyWidth / 2 + 4, centerY: bodyY + 3, horizontal: true)
            drawNativeRaccoonEars(&canvas, centerX: centerX, centerY: headY - headHeight / 2 + 3)
            nativeOutlinedPill(&canvas, centerX: centerX, centerY: bodyY, width: bodyWidth, height: bodyHeight, fill: .gray)
            nativeOutlinedPill(&canvas, centerX: centerX, centerY: headY, width: headWidth, height: headHeight, fill: .gray)
            nativeRect(&canvas, centerX - 5, headY - 1, 11, 3, .darkGray)
            nativeRect(&canvas, centerX - bodyWidth / 3, bodyY - 2, bodyWidth * 2 / 3, 2, .darkGray)

        case .sideLeft, .sideRight:
            let side = direction == .sideLeft ? -1 : 1
            let profileWidth = bodyWidth + 7
            let headX = centerX + side * (profileWidth / 2 - headWidth / 3)
            let tailX = centerX - side * (profileWidth / 2 + 3)
            drawNativeRaccoonTail(&canvas, centerX: tailX, centerY: bodyY + 3, horizontal: true)
            drawNativeRaccoonEars(&canvas, centerX: headX, centerY: headY - headHeight / 2 + 3)
            nativeOutlinedPill(&canvas, centerX: centerX, centerY: bodyY, width: profileWidth, height: bodyHeight - 2, fill: .gray)
            nativeOutlinedPill(&canvas, centerX: headX, centerY: headY + 2, width: headWidth, height: headHeight, fill: .gray)
            nativeRaccoonProfileFace(&canvas, centerX: headX, centerY: headY + 2, side: side)
            nativePill(&canvas, centerX: centerX - profileWidth / 4, centerY: ground - 2, width: 7, height: 5, color: .gray)
            nativePill(&canvas, centerX: centerX + profileWidth / 4, centerY: ground - 2 + hop, width: 7, height: 5, color: .gray)
        }
    }

    static func drawNativeRaccoonEars(_ canvas: inout [[PixelColor]], centerX: Int, centerY: Int) {
        for earX in [centerX - 7, centerX + 7] {
            nativeOutlinedPill(&canvas, centerX: earX, centerY: centerY, width: 6, height: 6, fill: .gray)
            nativePill(&canvas, centerX: earX, centerY: centerY + 1, width: 3, height: 3, color: .darkGray)
        }
    }

    static func drawNativeRaccoonTail(_ canvas: inout [[PixelColor]], centerX: Int, centerY: Int, horizontal: Bool) {
        nativeOutlinedPill(&canvas, centerX: centerX, centerY: centerY, width: horizontal ? 15 : 8, height: horizontal ? 8 : 15, fill: .gray)
        if horizontal {
            for offset in [-4, 0, 4] {
                nativeRect(&canvas, centerX + offset - 1, centerY - 3, 2, 7, .black)
            }
        } else {
            for offset in [-4, 0, 4] {
                nativeRect(&canvas, centerX - 3, centerY + offset - 1, 7, 2, .black)
            }
        }
    }

    static func nativeRaccoonFace(_ canvas: inout [[PixelColor]], centerX: Int, centerY: Int) {
        nativePill(&canvas, centerX: centerX, centerY: centerY, width: 17, height: 7, color: .darkGray)
        for eyeX in [centerX - 4, centerX + 4] {
            nativePill(&canvas, centerX: eyeX, centerY: centerY - 1, width: 4, height: 4, color: .cream)
            nativePixel(&canvas, eyeX, centerY - 1, .black)
        }
        nativePill(&canvas, centerX: centerX, centerY: centerY + 5, width: 10, height: 5, color: .lightGray)
        nativePill(&canvas, centerX: centerX, centerY: centerY + 4, width: 3, height: 2, color: .darkBrown)
        nativeRect(&canvas, centerX - 1, centerY + 7, 3, 1, .darkBrown)
    }

    static func nativeRaccoonProfileFace(_ canvas: inout [[PixelColor]], centerX: Int, centerY: Int, side: Int) {
        nativePill(&canvas, centerX: centerX + side * 3, centerY: centerY - 1, width: 9, height: 6, color: .darkGray)
        nativePill(&canvas, centerX: centerX + side * 5, centerY: centerY - 1, width: 4, height: 4, color: .cream)
        nativePixel(&canvas, centerX + side * 5, centerY - 1, .black)
        nativePill(&canvas, centerX: centerX + side * 7, centerY: centerY + 4, width: 7, height: 4, color: .lightGray)
        nativePixel(&canvas, centerX + side * 10, centerY + 4, .darkBrown)
    }

    static func drawNativeCharacterFinish(
        _ canvas: inout [[PixelColor]],
        design: Design,
        direction: SpriteDirection,
        scale: Scale
    ) {
        guard canvas.count >= nativeGridSize,
              let anchor = faceAnchor(for: design, direction: direction, scale: scale) else { return }

        drawNativeSignature(&canvas, design: design, direction: direction, scale: scale, anchor: anchor)

        switch direction {
        case .front:
            drawNativeFrontFace(&canvas, design: design, anchor: anchor)
        case .sideLeft, .sideRight:
            drawNativeProfileFace(&canvas, design: design, anchor: anchor, side: direction == .sideLeft ? -1 : 1)
        case .back:
            drawNativeBackAccent(&canvas, design: design, anchor: anchor)
        }
    }

    /// The normal face finish intentionally varies with a species' existing
    /// face style.  This adds readable, tiny game-character expressions without
    /// turning every pet into the same large-eyed mascot.
    static func drawNativeFrontFace(_ canvas: inout [[PixelColor]], design: Design, anchor: FaceAnchor) {
        switch design.trait {
        case "raccoon":
            drawNativeRaccoonFace(&canvas, anchor: anchor)
            return
        case "bear":
            drawNativeBearFace(&canvas, anchor: anchor)
            return
        case "rabbit", "moonrabbit":
            drawNativeRabbitFace(&canvas, design: design, anchor: anchor)
            return
        case "owl":
            drawNativeOwlFace(&canvas, anchor: anchor)
            return
        default:
            break
        }

        let x = nativeCenter(anchor.x)
        let y = nativeCenter(anchor.y)
        let logicalSeparation: Int
        if design.faceStyle == .beak && design.trait == "owl" {
            logicalSeparation = max(2, anchor.span / 3)
        } else {
            logicalSeparation = max(1, min(2, anchor.span / 4))
        }
        let separation = logicalSeparation * 2
        let ink = faceInk(for: design)

        switch design.faceStyle {
        case .visor:
            let panel = (design.trait == "ninja" || design.trait == "void_runner") ? PixelColor.darkGray : .darkBlue
            nativePill(&canvas, centerX: x, centerY: y, width: max(9, anchor.span * 2), height: 5, color: panel)
            let light: PixelColor = design.trait == "void_runner" ? design.accent : (design.trait == "ninja" ? .cream : .mint)
            nativePill(&canvas, centerX: x - 3, centerY: y, width: 3, height: 2, color: light)
            nativePill(&canvas, centerX: x + 3, centerY: y, width: 3, height: 2, color: light)
        case .relic:
            let eye = ["crystal", "orb", "singularity"].contains(design.trait) ? PixelColor.cream : ink
            nativeEye(&canvas, centerX: x - separation, centerY: y, ink: eye)
            nativeEye(&canvas, centerX: x + separation, centerY: y, ink: eye)
            nativeSmile(&canvas, centerX: x, centerY: y + 5, ink: eye, expression: .warm)
        case .beak:
            nativeEye(&canvas, centerX: x - separation, centerY: y, ink: ink)
            nativeEye(&canvas, centerX: x + separation, centerY: y, ink: ink)
            nativePill(&canvas, centerX: x, centerY: y + 5, width: 4, height: 3, color: design.accent)
            nativePixel(&canvas, x, y + 4, .cream)
        default:
            if design.expression == .sleepy {
                nativeSleepyEye(&canvas, centerX: x - separation, centerY: y, ink: ink)
                nativeSleepyEye(&canvas, centerX: x + separation, centerY: y, ink: ink)
            } else {
                nativeEye(&canvas, centerX: x - separation, centerY: y, ink: ink)
                nativeEye(&canvas, centerX: x + separation, centerY: y, ink: ink)
            }
            if [.muzzle, .sea, .bloom, .elemental, .draconic, .merfolk, .ray, .insect].contains(design.faceStyle) {
                nativeSmile(&canvas, centerX: x, centerY: y + 5, ink: ink, expression: design.expression)
            }
        }
    }

    static func drawNativeProfileFace(_ canvas: inout [[PixelColor]], design: Design, anchor: FaceAnchor, side: Int) {
        let x = nativeCenter(anchor.x) + side * max(2, anchor.span / 2)
        let y = nativeCenter(anchor.y)
        let ink: PixelColor = design.trait == "raccoon" ? .cream : faceInk(for: design)
        if design.expression == .sleepy {
            nativeSleepyEye(&canvas, centerX: x, centerY: y, ink: ink)
        } else {
            nativeEye(&canvas, centerX: x, centerY: y, ink: ink)
        }
        if [.muzzle, .sea, .merfolk, .ray, .draconic].contains(design.faceStyle) {
            nativePixel(&canvas, x + side * 3, y + 4, ink)
            nativePixel(&canvas, x + side * 2, y + 5, ink)
        }
    }

    static func nativeEye(_ canvas: inout [[PixelColor]], centerX: Int, centerY: Int, ink: PixelColor) {
        nativePill(&canvas, centerX: centerX, centerY: centerY, width: 3, height: 4, color: ink)
        let glint: PixelColor = (ink == .cream || ink == .white || ink == .gold) ? .darkBlue : .white
        nativePixel(&canvas, centerX - 1, centerY - 1, glint)
    }

    static func nativeSleepyEye(_ canvas: inout [[PixelColor]], centerX: Int, centerY: Int, ink: PixelColor) {
        nativeRect(&canvas, centerX - 2, centerY, 4, 1, ink)
        nativePixel(&canvas, centerX + 1, centerY + 1, ink)
    }

    static func nativeSmile(
        _ canvas: inout [[PixelColor]],
        centerX: Int,
        centerY: Int,
        ink: PixelColor,
        expression: Expression
    ) {
        switch expression {
        case .sleepy:
            nativeRect(&canvas, centerX - 1, centerY, 3, 1, ink)
        case .brave:
            nativeRect(&canvas, centerX - 2, centerY, 5, 1, ink)
        default:
            nativePixel(&canvas, centerX - 3, centerY, ink)
            nativePixel(&canvas, centerX - 2, centerY + 1, ink)
            nativeRect(&canvas, centerX - 1, centerY + 2, 3, 1, ink)
            nativePixel(&canvas, centerX + 2, centerY + 1, ink)
            nativePixel(&canvas, centerX + 3, centerY, ink)
        }
    }

    static func drawNativeSignature(
        _ canvas: inout [[PixelColor]],
        design: Design,
        direction: SpriteDirection,
        scale: Scale,
        anchor: FaceAnchor
    ) {
        switch design.trait {
        case "raccoon":
            drawNativeRaccoonSignature(&canvas, direction: direction, scale: scale, anchor: anchor)
        case "bear":
            drawNativeBearEars(&canvas, scale: scale, anchor: anchor)
        case "rabbit", "moonrabbit":
            drawNativeRabbitEars(&canvas, design: design, scale: scale, anchor: anchor)
        case "owl":
            drawNativeOwlRings(&canvas, anchor: anchor)
        case "skate":
            drawNativeSkateDetails(&canvas, direction: direction, scale: scale)
        case "mermaid":
            drawNativeMermaidDetails(&canvas, direction: direction, scale: scale)
        case "wolf", "fox", "starfox":
            drawNativeFurDetail(&canvas, design: design, direction: direction, scale: scale)
        case "octopus", "jellyfish", "kraken":
            drawNativeTentacleDetails(&canvas, design: design, direction: direction, scale: scale)
        case "teapot":
            drawNativeTeapotDetails(&canvas, direction: direction, scale: scale)
        case "world_tree":
            drawNativeTreeDetails(&canvas, scale: scale)
        default:
            drawNativeMaterialAccent(&canvas, design: design, anchor: anchor)
        }
    }

    static func drawNativeBackAccent(_ canvas: inout [[PixelColor]], design: Design, anchor: FaceAnchor) {
        let x = nativeCenter(anchor.x)
        let y = nativeCenter(anchor.y)
        switch design.trait {
        case "raccoon":
            nativeRect(&canvas, x - 6, y - 1, 13, 2, .darkGray)
        case "rabbit", "moonrabbit":
            nativePill(&canvas, centerX: x, centerY: y + 2, width: 5, height: 3, color: .white)
        case "bear":
            nativePill(&canvas, centerX: x, centerY: y + 3, width: 6, height: 3, color: .tan)
        default:
            drawNativeMaterialAccent(&canvas, design: design, anchor: anchor)
        }
    }

    static func drawNativeMaterialAccent(_ canvas: inout [[PixelColor]], design: Design, anchor: FaceAnchor) {
        let x = nativeCenter(anchor.x) - max(3, anchor.span)
        let y = nativeCenter(anchor.y) - 3
        guard canvas.indices.contains(y), canvas[y].indices.contains(x), !canvas[y][x].isTransparent else { return }
        nativePixel(&canvas, x, y, materialHighlight(for: design.primary))
        nativePixel(&canvas, x + 1, y, materialHighlight(for: design.primary))
        nativePixel(&canvas, x, y + 1, materialHighlight(for: design.primary))
    }

    static func drawNativeRaccoonSignature(_ canvas: inout [[PixelColor]], direction: SpriteDirection, scale: Scale, anchor: FaceAnchor) {
        let x = nativeCenter(anchor.x)
        let y = nativeCenter(anchor.y)
        if direction != .back {
            nativePill(&canvas, centerX: x, centerY: y, width: 17, height: 6, color: .darkGray)
            nativePixel(&canvas, x - 8, y - 1, .gray)
            nativePixel(&canvas, x + 8, y - 1, .gray)
        }

        let bodyY = scale.baseline - scale.value(3, minimum: 2)
        let tailY = nativeCenter(bodyY)
        let tailSide: Int
        switch direction {
        case .sideLeft: tailSide = 1
        case .sideRight: tailSide = -1
        case .front: tailSide = -1
        case .back: tailSide = 1
        }
        for index in 0..<3 {
            let bandX = nativeCenter(12 + tailSide * (3 + index * 2))
            nativeRect(&canvas, bandX - 1, tailY - 2, 2, 5, .black)
        }
    }

    static func drawNativeRaccoonFace(_ canvas: inout [[PixelColor]], anchor: FaceAnchor) {
        let x = nativeCenter(anchor.x)
        let y = nativeCenter(anchor.y)
        nativePill(&canvas, centerX: x - 4, centerY: y, width: 4, height: 4, color: .cream)
        nativePill(&canvas, centerX: x + 4, centerY: y, width: 4, height: 4, color: .cream)
        nativePixel(&canvas, x - 4, y, .black)
        nativePixel(&canvas, x + 4, y, .black)
        nativePill(&canvas, centerX: x, centerY: y + 5, width: 8, height: 3, color: .lightGray)
        nativePixel(&canvas, x, y + 4, .darkBrown)
        nativeRect(&canvas, x - 1, y + 7, 3, 1, .darkBrown)
    }

    static func drawNativeBearEars(_ canvas: inout [[PixelColor]], scale: Scale, anchor: FaceAnchor) {
        let headHeight = scale.value(7, minimum: 3)
        let crownY = nativeCenter(anchor.y - headHeight / 2 + 1)
        let x = nativeCenter(anchor.x)
        for earX in [x - 4, x + 4] {
            nativePill(&canvas, centerX: earX, centerY: crownY, width: 5, height: 5, color: .brown)
            nativePill(&canvas, centerX: earX, centerY: crownY + 1, width: 2, height: 2, color: .tan)
        }
    }

    static func drawNativeBearFace(_ canvas: inout [[PixelColor]], anchor: FaceAnchor) {
        let x = nativeCenter(anchor.x)
        let y = nativeCenter(anchor.y)
        nativeEye(&canvas, centerX: x - 3, centerY: y, ink: .darkBrown)
        nativeEye(&canvas, centerX: x + 3, centerY: y, ink: .darkBrown)
        nativePill(&canvas, centerX: x, centerY: y + 5, width: 9, height: 5, color: .tan)
        nativePill(&canvas, centerX: x, centerY: y + 4, width: 3, height: 2, color: .darkBrown)
        nativeSmile(&canvas, centerX: x, centerY: y + 7, ink: .darkBrown, expression: .warm)
    }

    static func drawNativeRabbitEars(_ canvas: inout [[PixelColor]], design: Design, scale: Scale, anchor: FaceAnchor) {
        let height = scale.value(design.trait == "moonrabbit" ? 9 : 7, minimum: 4)
        let headHeight = scale.value(design.headHeight, minimum: 3)
        let crown = anchor.y - headHeight / 2
        let earCenterY = crown - height / 2 + 2
        let offset = design.trait == "moonrabbit" ? 4 : 3
        let inner = design.trait == "moonrabbit" ? PixelColor.lavender : .pink
        for earX in [anchor.x - offset, anchor.x + offset] {
            nativePill(
                &canvas,
                centerX: nativeCenter(earX),
                centerY: nativeCenter(earCenterY),
                width: 3,
                height: max(5, height * 2 - 4),
                color: inner
            )
        }
    }

    static func drawNativeRabbitFace(_ canvas: inout [[PixelColor]], design: Design, anchor: FaceAnchor) {
        let x = nativeCenter(anchor.x)
        let y = nativeCenter(anchor.y)
        // Repaint the small muzzle panel before adding the face.  Without this
        // cleanup the 24px fallback eyes and smile merge into a dark moustache
        // when viewed at 48px, which makes a rabbit look stern rather than
        // soft and playful.
        nativePill(&canvas, centerX: x, centerY: y + 2, width: 13, height: 8, color: .cream)
        nativePill(&canvas, centerX: x - 4, centerY: y, width: 2, height: 3, color: .darkBrown)
        nativePill(&canvas, centerX: x + 4, centerY: y, width: 2, height: 3, color: .darkBrown)
        nativePixel(&canvas, x - 4, y - 1, .white)
        nativePixel(&canvas, x + 4, y - 1, .white)
        nativePill(&canvas, centerX: x, centerY: y + 4, width: 2, height: 2, color: design.trait == "moonrabbit" ? .lavender : .pink)
        nativePixel(&canvas, x - 1, y + 6, .darkBrown)
        nativePixel(&canvas, x + 1, y + 6, .darkBrown)
        nativePixel(&canvas, x, y + 7, .darkBrown)
    }

    static func drawNativeOwlRings(_ canvas: inout [[PixelColor]], anchor: FaceAnchor) {
        let x = nativeCenter(anchor.x)
        let y = nativeCenter(anchor.y)
        nativePill(&canvas, centerX: x - 5, centerY: y, width: 7, height: 7, color: .cream)
        nativePill(&canvas, centerX: x + 5, centerY: y, width: 7, height: 7, color: .cream)
    }

    static func drawNativeOwlFace(_ canvas: inout [[PixelColor]], anchor: FaceAnchor) {
        let x = nativeCenter(anchor.x)
        let y = nativeCenter(anchor.y)
        nativePill(&canvas, centerX: x - 5, centerY: y, width: 3, height: 4, color: .darkBrown)
        nativePill(&canvas, centerX: x + 5, centerY: y, width: 3, height: 4, color: .darkBrown)
        nativePixel(&canvas, x - 6, y - 1, .white)
        nativePixel(&canvas, x + 4, y - 1, .white)
        nativePill(&canvas, centerX: x, centerY: y + 5, width: 4, height: 3, color: .orange)
    }

    static func drawNativeSkateDetails(_ canvas: inout [[PixelColor]], direction: SpriteDirection, scale: Scale) {
        let x = nativeCenter(scale.centerX)
        let wingY = nativeCenter(scale.baseline - scale.value(7, minimum: 4))
        if direction == .front {
            nativePill(&canvas, centerX: x - 4, centerY: wingY + 1, width: 3, height: 3, color: .darkBlue)
            nativePill(&canvas, centerX: x + 4, centerY: wingY + 1, width: 3, height: 3, color: .darkBlue)
            nativePixel(&canvas, x - 5, wingY, .white)
            nativePixel(&canvas, x + 3, wingY, .white)
            nativeSmile(&canvas, centerX: x, centerY: wingY + 5, ink: .darkBlue, expression: .warm)
        }
        for wingX in [x - 12, x + 12] {
            nativePixel(&canvas, wingX, wingY + 2, .mint)
            nativePixel(&canvas, wingX + (wingX < x ? 1 : -1), wingY + 3, .blue)
        }
    }

    static func drawNativeMermaidDetails(_ canvas: inout [[PixelColor]], direction: SpriteDirection, scale: Scale) {
        let x = nativeCenter(scale.centerX)
        let finY = nativeCenter(scale.baseline - scale.value(2, minimum: 1))
        nativePixel(&canvas, x - 5, finY - 1, .mint)
        nativePixel(&canvas, x + 5, finY - 1, .mint)
        if direction == .front {
            nativePixel(&canvas, x - 6, finY - 5, .lavender)
            nativePixel(&canvas, x + 6, finY - 4, .lavender)
        }
    }

    static func drawNativeFurDetail(_ canvas: inout [[PixelColor]], design: Design, direction: SpriteDirection, scale: Scale) {
        let x = nativeCenter(scale.centerX)
        let y = nativeCenter(scale.baseline - scale.value(design.bodyHeight, minimum: 4) / 2 - 2)
        let highlight = materialHighlight(for: design.primary)
        nativePixel(&canvas, x - 5, y - 3, highlight)
        nativePixel(&canvas, x - 4, y - 3, highlight)
        nativePixel(&canvas, x - 5, y - 2, highlight)
        if direction == .front && design.trait == "wolf" {
            nativeRect(&canvas, x - 1, y + 2, 3, 1, .cream)
        }
    }

    static func drawNativeTentacleDetails(_ canvas: inout [[PixelColor]], design: Design, direction: SpriteDirection, scale: Scale) {
        let x = nativeCenter(scale.centerX)
        let base = nativeCenter(scale.baseline - 2)
        let spot = design.trait == "kraken" ? PixelColor.mint : .lavender
        let sideShift = direction == .sideLeft ? -2 : direction == .sideRight ? 2 : 0
        for offset in [-5, 0, 5] {
            nativePill(&canvas, centerX: x + offset + sideShift, centerY: base, width: 2, height: 2, color: spot)
        }
    }

    static func drawNativeTeapotDetails(_ canvas: inout [[PixelColor]], direction: SpriteDirection, scale: Scale) {
        let x = nativeCenter(scale.centerX)
        let y = nativeCenter(scale.baseline - scale.value(10, minimum: 5) / 2 - 2)
        nativePill(&canvas, centerX: x, centerY: y, width: 9, height: 5, color: .darkBlue)
        if direction != .back {
            nativeEye(&canvas, centerX: x - 3, centerY: y, ink: .cream)
            nativeEye(&canvas, centerX: x + 3, centerY: y, ink: .cream)
        }
        nativePixel(&canvas, x - 4, y - 3, .mint)
    }

    static func drawNativeTreeDetails(_ canvas: inout [[PixelColor]], scale: Scale) {
        let x = nativeCenter(scale.centerX)
        let trunkTop = nativeCenter(scale.baseline - scale.value(18, minimum: 10) + 5)
        nativePill(&canvas, centerX: x, centerY: trunkTop, width: 7, height: 5, color: .tan)
        nativePixel(&canvas, x - 2, trunkTop - 1, .darkBrown)
        nativePixel(&canvas, x + 2, trunkTop - 1, .darkBrown)
    }

    static func faceStyle(for trait: String, form: Form) -> FaceStyle {
        switch trait {
        case "android", "robot", "ninja", "void_runner":
            return .visor
        case "octopus", "jellyfish", "kraken", "fish", "seal", "leviathan", "dream_whale":
            return .sea
        case "butterfly", "luna_moth", "atlas_beetle", "scorpion":
            return .insect
        case "crystal", "rock", "clockwork", "orb", "singularity", "teapot", "lantern", "bastion":
            return .relic
        case "lotus", "mushroom", "cactus", "peach", "moonflower", "acorn", "world_tree":
            return .bloom
        case "flame", "lightning", "comet", "cloud", "nebula", "aurora":
            return .elemental
        case "dragon", "gryphon", "chrono_dragon", "pegasus", "wyvern":
            return .draconic
        case "mermaid":
            return .merfolk
        case "skate":
            return .ray
        case "owl", "phoenix", "penguin", "parrot", "raven", "parakeet", "thunderbird", "bat":
            return .beak
        default:
            switch form {
            case .bird: return .beak
            case .swimmer, .cephalopod: return .sea
            case .insect: return .insect
            case .humanoid: return .muzzle
            case .object: return .relic
            case .plant: return .bloom
            case .elemental: return .elemental
            case .dragon: return .draconic
            case .mermaid: return .merfolk
            case .skate: return .ray
            case .quadruped: return .muzzle
            }
        }
    }

    static func expression(for trait: String) -> Expression {
        switch trait {
        case "owl", "seal", "koala", "capybara", "dream_whale", "cloud", "moonrabbit":
            return .sleepy
        case "fox", "cat", "puppy", "raccoon", "otter", "ferret", "gecko", "chameleon", "bat", "ninja":
            return .playful
        case "crystal", "orb", "celestial", "aurora", "nebula", "moonflower", "luna_moth", "starfox":
            return .sparkling
        case "dragon", "gryphon", "leviathan", "chrono_dragon", "wyvern", "thunderbird", "titan", "golem", "bastion", "void_runner", "kraken":
            return .brave
        case "android", "robot", "clockwork", "teapot", "lantern":
            return .mechanical
        default:
            return .warm
        }
    }

    /// Returns the actual anatomical location of a face.  This is not a
    /// universal head offset: each form keeps its own head, bell, visor,
    /// flower centre, trunk knot or elemental core.
    static func faceAnchor(for design: Design, direction: SpriteDirection, scale: Scale) -> FaceAnchor? {
        let x = scale.centerX
        let side = direction == .sideLeft ? -1 : direction == .sideRight ? 1 : 0

        switch design.form {
        case .quadruped:
            let naturalBodyWidth = scale.value(design.bodyWidth, minimum: 6)
            let naturalBodyHeight = scale.value(design.bodyHeight, minimum: 4)
            let headWidth = scale.value(design.headWidth, minimum: 4)
            let headHeight = scale.value(design.headHeight, minimum: 3)
            let legs = scale.value(design.limbLength, minimum: design.limbLength == 0 ? 0 : 1)
            let body = quadrupedBodyMetrics(
                for: design,
                naturalWidth: naturalBodyWidth,
                naturalHeight: naturalBodyHeight,
                headWidth: headWidth,
                headHeight: headHeight,
                isProfile: side != 0
            )
            let bodyWidth = body.width
            let bodyHeight = body.height
            let bodyY = scale.baseline - legs - bodyHeight / 2
            let headY = bodyY - bodyHeight / 2 - headHeight / 2 + 1
            return FaceAnchor(x: side == 0 ? x : x + side * (bodyWidth / 2 - 1), y: headY, span: headWidth)

        case .bird:
            let naturalBodyWidth = scale.value(design.bodyWidth, minimum: 5)
            let naturalBodyHeight = scale.value(design.bodyHeight, minimum: 6)
            let headWidth = scale.value(design.headWidth, minimum: 4)
            let headHeight = scale.value(design.headHeight, minimum: 3)
            let legs = scale.value(design.limbLength, minimum: design.limbLength == 0 ? 0 : 1)
            let body = birdBodyMetrics(
                for: design,
                naturalWidth: naturalBodyWidth,
                naturalHeight: naturalBodyHeight,
                headWidth: headWidth,
                headHeight: headHeight,
                isProfile: side != 0
            )
            let bodyWidth = body.width
            let bodyHeight = body.height
            let bodyY = scale.baseline - legs - bodyHeight / 2
            let headY = bodyY - bodyHeight / 2 - headHeight / 2 + 1
            return FaceAnchor(x: side == 0 ? x : x + side * (bodyWidth / 2 - 1), y: headY, span: headWidth)

        case .swimmer:
            let width = scale.value(design.bodyWidth, minimum: 7)
            let height = scale.value(design.bodyHeight, minimum: 4)
            let y = scale.baseline - height / 2 - 2
            return FaceAnchor(
                x: side == 0 ? x : x + side * (width / 2 - 2),
                y: y,
                span: side == 0 ? max(6, width - 5) : max(4, width / 2)
            )

        case .cephalopod:
            let width = scale.value(design.bodyWidth, minimum: 7)
            let height = scale.value(design.bodyHeight, minimum: 4)
            let bellY = scale.baseline - scale.value(design.limbLength, minimum: 3) - height / 2
            return FaceAnchor(x: side == 0 ? x : x + side * 2, y: bellY, span: width)

        case .insect:
            let bodyWidth = scale.value(design.bodyWidth, minimum: 5)
            let bodyHeight = scale.value(design.bodyHeight, minimum: 5)
            let y = scale.baseline - bodyHeight / 2 - 3
            switch design.trait {
            case "butterfly", "luna_moth", "atlas_beetle":
                return FaceAnchor(x: side == 0 ? x : x + side * 3, y: y - bodyHeight / 3, span: bodyWidth)
            default:
                return FaceAnchor(x: side == 0 ? x : x + side * 5, y: y - 1, span: 5)
            }

        case .humanoid:
            let naturalTorsoWidth = scale.value(design.bodyWidth, minimum: 5)
            let naturalTorsoHeight = scale.value(design.bodyHeight, minimum: 6)
            let headWidth = scale.value(design.headWidth, minimum: 4)
            let headHeight = scale.value(design.headHeight, minimum: 4)
            let legs = scale.value(design.limbLength, minimum: 2)
            let torso = humanoidTorsoMetrics(
                for: design,
                naturalWidth: naturalTorsoWidth,
                naturalHeight: naturalTorsoHeight,
                headWidth: headWidth,
                headHeight: headHeight
            )
            let torsoHeight = torso.height
            let torsoTop = scale.baseline - legs - torsoHeight
            let headY = torsoTop - headHeight / 2 - 1
            return FaceAnchor(x: side == 0 ? x : x + side * 3, y: headY, span: headWidth)

        case .object:
            let height = scale.value(design.bodyHeight, minimum: 6)
            let y = scale.baseline - height / 2 - 2
            switch design.trait {
            case "crystal":
                let h = scale.value(15, minimum: 8)
                return FaceAnchor(x: x + side, y: scale.baseline - h / 2 + 2, span: 6)
            case "rock":
                return FaceAnchor(x: x + side, y: y + 1, span: scale.value(9, minimum: 5))
            case "bastion":
                return FaceAnchor(x: x + side, y: y - 1, span: scale.value(10, minimum: 6))
            default:
                return FaceAnchor(x: x + side, y: y, span: max(5, scale.value(design.bodyWidth, minimum: 6) - 2))
            }

        case .plant:
            switch design.trait {
            case "lotus":
                return FaceAnchor(x: x + side, y: scale.baseline - scale.value(8, minimum: 5), span: 7)
            case "mushroom":
                let capHeight = scale.value(6, minimum: 3)
                let stemHeight = scale.value(7, minimum: 4)
                let capY = scale.baseline - stemHeight - capHeight / 2
                return FaceAnchor(x: x + side, y: capY + 2, span: scale.value(14, minimum: 7))
            case "cactus":
                let height = scale.value(16, minimum: 8)
                return FaceAnchor(x: x + side, y: scale.baseline - height / 2, span: 5)
            case "peach":
                let radius = scale.value(5, minimum: 3)
                return FaceAnchor(x: x + side, y: scale.baseline - radius - 2, span: radius * 2)
            case "moonflower":
                return FaceAnchor(x: x + side, y: scale.baseline - scale.value(10, minimum: 6), span: 7)
            case "acorn":
                return FaceAnchor(x: x + side, y: scale.baseline - scale.value(7, minimum: 5) + 1, span: scale.value(6, minimum: 4))
            default:
                let height = scale.value(18, minimum: 10)
                return FaceAnchor(x: x + side * 2, y: scale.baseline - height + height / 3, span: 8)
            }

        case .elemental:
            switch design.trait {
            case "flame":
                let height = scale.value(14, minimum: 7)
                return FaceAnchor(x: x + side, y: scale.baseline - height / 2 + 2, span: 5)
            case "lightning":
                let top = scale.baseline - scale.value(17, minimum: 9)
                return FaceAnchor(x: x + side * 2, y: top + 5, span: 4)
            case "comet":
                let y = scale.baseline - scale.value(7, minimum: 4)
                return FaceAnchor(x: side == 0 ? x : x + side * 4, y: y, span: 6)
            case "cloud":
                return FaceAnchor(x: x + side * 3, y: scale.baseline - scale.value(7, minimum: 4), span: 9)
            case "nebula":
                return FaceAnchor(x: x + side * 3, y: scale.baseline - scale.value(8, minimum: 5), span: 9)
            default:
                return FaceAnchor(x: x + side * 2, y: scale.baseline - scale.value(15, minimum: 8) + 7, span: 5)
            }

        case .dragon:
            let naturalBodyWidth = scale.value(design.bodyWidth, minimum: 7)
            let naturalBodyHeight = scale.value(design.bodyHeight, minimum: 4)
            let headWidth = scale.value(design.headWidth, minimum: 4)
            let headHeight = scale.value(design.headHeight, minimum: 3)
            let legs = scale.value(design.limbLength, minimum: 2)
            let body = dragonBodyMetrics(
                for: design,
                naturalWidth: naturalBodyWidth,
                naturalHeight: naturalBodyHeight,
                headWidth: headWidth,
                headHeight: headHeight,
                isProfile: side != 0
            )
            let bodyWidth = body.width
            let bodyHeight = body.height
            let bodyY = scale.baseline - legs - bodyHeight / 2
            let headY = bodyY - bodyHeight / 2 - 3
            return FaceAnchor(
                x: side == 0 ? x : x + side * (bodyWidth / 2 - 2),
                y: headY,
                span: scale.value(design.headWidth, minimum: 4)
            )

        case .mermaid:
            let finY = scale.baseline - scale.value(2, minimum: 1)
            let tailTop = finY - scale.value(7, minimum: 4)
            let torsoTop = tailTop - scale.value(6, minimum: 4)
            let headY = torsoTop - scale.value(7, minimum: 4) / 2 - 1
            return FaceAnchor(x: side == 0 ? x : x + side * 2, y: headY + 1, span: 7)

        case .skate:
            let wingY = scale.baseline - scale.value(7, minimum: 4)
            return FaceAnchor(x: x + side * 2, y: wingY + 1, span: 8)
        }
    }

    static func drawCharacterFinish(_ canvas: inout [[PixelColor]], _ design: Design, _ direction: SpriteDirection, _ scale: Scale) {
        guard let anchor = faceAnchor(for: design, direction: direction, scale: scale) else { return }

        switch direction {
        case .front:
            switch design.faceStyle {
            case .visor:
                drawVisorExpression(&canvas, design: design, anchor: anchor)
            case .relic:
                drawRelicExpression(&canvas, design: design, anchor: anchor)
            default:
                drawFriendlyExpression(&canvas, design: design, anchor: anchor)
            }
            drawCharacterHighlight(&canvas, design: design, anchor: anchor)

        case .sideLeft, .sideRight:
            let side = direction == .sideLeft ? -1 : 1
            drawProfileExpression(&canvas, design: design, anchor: anchor, side: side)

        case .back:
            // A back view intentionally shows a real back, shell, wing, tail
            // or garment rather than a copied face.
            break
        }
    }

    static func drawFriendlyExpression(_ canvas: inout [[PixelColor]], design: Design, anchor: FaceAnchor) {
        let separation: Int
        if design.faceStyle == .beak && design.trait == "owl" {
            separation = max(2, anchor.span / 3)
        } else {
            separation = max(1, min(2, anchor.span / 4))
        }
        let ink = faceInk(for: design)

        drawFacePatch(&canvas, design: design, anchor: anchor)
        drawEyePair(&canvas, x: anchor.x, y: anchor.y, separation: separation, span: anchor.span, ink: ink, expression: design.expression)

        switch design.faceStyle {
        case .beak:
            // The beak already supplies the mouth; a light feather/eye-rim
            // makes birds read as characters without giving them mammal lips.
            if design.trait == "owl" && anchor.span >= 6 {
                pixel(&canvas, anchor.x - separation - 1, anchor.y - 1, .cream)
                pixel(&canvas, anchor.x + separation + 1, anchor.y - 1, .cream)
            }

        case .insect:
            if design.trait == "butterfly" || design.trait == "luna_moth" {
                drawTinySmile(&canvas, x: anchor.x, y: anchor.y + 2, ink: ink, expression: .warm)
            }

        case .draconic:
            drawTinySmile(&canvas, x: anchor.x, y: anchor.y + 2, ink: ink, expression: .brave)
            if anchor.span >= 6 {
                pixel(&canvas, anchor.x - 1, anchor.y + 2, design.accent)
                pixel(&canvas, anchor.x + 1, anchor.y + 2, design.accent)
            }

        case .elemental:
            if design.trait != "lightning" && design.trait != "aurora" {
                drawTinySmile(&canvas, x: anchor.x, y: anchor.y + 2, ink: ink, expression: design.expression)
            }

        case .muzzle, .sea, .bloom, .merfolk, .ray:
            if ["wolf", "fox", "starfox", "cat", "puppy", "rabbit", "moonrabbit", "bear", "koala", "capybara"].contains(design.trait) {
                pixel(&canvas, anchor.x, anchor.y + 1, ink)
            }
            drawTinySmile(&canvas, x: anchor.x, y: anchor.y + 2, ink: ink, expression: design.expression)
            if anchor.span >= 7 && shouldHaveCheeks(design) {
                let cheek = cheekTone(for: design)
                pixel(&canvas, anchor.x - separation - 2, anchor.y + 1, cheek)
                pixel(&canvas, anchor.x + separation + 2, anchor.y + 1, cheek)
            }

        case .visor, .relic:
            break
        }
    }

    static func drawFacePatch(_ canvas: inout [[PixelColor]], design: Design, anchor: FaceAnchor) {
        let patchWidth = max(3, min(5, anchor.span - 1))
        switch design.faceStyle {
        case .beak where design.trait == "owl":
            // Owl eyes are a defining species cue, so the eye discs are
            // actual feather rings rather than two dark dots on brown.
            oval(&canvas, anchor.x - 2, anchor.y, 4, 4, .cream)
            oval(&canvas, anchor.x + 2, anchor.y, 4, 4, .cream)
        case .muzzle:
            guard anchor.span >= 5 else { return }
            oval(&canvas, anchor.x, anchor.y + 1, patchWidth, 3, muzzleTone(for: design))
        case .sea:
            guard anchor.span >= 5 else { return }
            oval(&canvas, anchor.x, anchor.y + 1, patchWidth, 3, seaTone(for: design))
        case .bloom:
            guard anchor.span >= 5 else { return }
            oval(&canvas, anchor.x, anchor.y + 1, patchWidth, 3, design.trait == "world_tree" ? .tan : .cream)
        case .elemental:
            guard design.trait == "lightning" || design.trait == "flame" else { return }
            oval(&canvas, anchor.x, anchor.y + 1, 3, 3, design.trait == "lightning" ? .cream : .yellow)
        case .draconic:
            guard anchor.span >= 5 else { return }
            oval(&canvas, anchor.x, anchor.y + 2, patchWidth, 3, design.trait == "gryphon" ? .cream : .orange)
        case .merfolk:
            oval(&canvas, anchor.x, anchor.y + 1, patchWidth, 3, .peach)
        case .ray:
            oval(&canvas, anchor.x, anchor.y + 1, patchWidth, 3, .mint)
        case .insect:
            guard anchor.span >= 4 else { return }
            let plate: PixelColor = design.trait == "atlas_beetle" ? .mint : design.trait == "scorpion" ? .peach : .lavender
            oval(&canvas, anchor.x, anchor.y + 1, max(3, patchWidth - 1), 3, plate)
        case .beak, .visor, .relic:
            break
        }
    }

    static func muzzleTone(for design: Design) -> PixelColor {
        switch design.trait {
        case "wolf", "elephant", "mammoth", "koala", "raccoon", "badger":
            return .lightGray
        case "bear", "otter", "ferret", "beaver", "capybara", "deer":
            return .tan
        case "turtle", "gecko", "chameleon":
            return .mint
        default:
            return .cream
        }
    }

    static func seaTone(for design: Design) -> PixelColor {
        switch design.trait {
        case "octopus", "jellyfish", "kraken":
            return .lavender
        case "seal":
            return .cream
        default:
            return .mint
        }
    }

    static func drawVisorExpression(_ canvas: inout [[PixelColor]], design: Design, anchor: FaceAnchor) {
        let panelWidth = max(4, min(7, anchor.span + 1))
        let panel: PixelColor = design.trait == "ninja" || design.trait == "void_runner" ? .darkGray : .darkBlue
        oval(&canvas, anchor.x, anchor.y, panelWidth, 3, panel)

        if design.trait == "ninja" || design.trait == "void_runner" {
            let eye = design.trait == "void_runner" ? design.accent : .cream
            oval(&canvas, anchor.x - 2, anchor.y, 2, 2, eye)
            oval(&canvas, anchor.x + 2, anchor.y, 2, 2, eye)
        } else {
            let light: PixelColor = design.trait == "android" ? .mint : .yellow
            oval(&canvas, anchor.x - 2, anchor.y, 2, 2, light)
            oval(&canvas, anchor.x + 2, anchor.y, 2, 2, light)
            pixel(&canvas, anchor.x, anchor.y + 1, light)
        }
    }

    static func drawRelicExpression(_ canvas: inout [[PixelColor]], design: Design, anchor: FaceAnchor) {
        let ink = faceInk(for: design)
        let separation = max(1, min(2, anchor.span / 4))

        switch design.trait {
        case "crystal", "orb", "singularity":
            // Living relics use a paired core glow instead of a pasted-on
            // animal muzzle.  Their facets and rings remain their identity.
            drawEyePair(&canvas, x: anchor.x, y: anchor.y, separation: separation, span: anchor.span, ink: .cream, expression: .sparkling)
            pixel(&canvas, anchor.x, anchor.y + 2, design.accent)
        case "bastion":
            drawEyePair(&canvas, x: anchor.x, y: anchor.y, separation: max(2, separation), span: anchor.span, ink: design.accent, expression: .mechanical)
            rect(&canvas, anchor.x - 1, anchor.y + 2, 3, 1, .darkGray)
        default:
            drawEyePair(&canvas, x: anchor.x, y: anchor.y, separation: separation, span: anchor.span, ink: ink, expression: design.expression)
            drawTinySmile(&canvas, x: anchor.x, y: anchor.y + 2, ink: ink, expression: .warm)
        }
    }

    static func drawProfileExpression(_ canvas: inout [[PixelColor]], design: Design, anchor: FaceAnchor, side: Int) {
        let ink = faceInk(for: design)
        let eyeX = anchor.x + side * max(1, anchor.span / 4)
        drawSingleEye(&canvas, x: eyeX, y: anchor.y, ink: ink, expression: design.expression)

        switch design.faceStyle {
        case .muzzle, .sea, .bloom, .merfolk, .ray, .draconic:
            pixel(&canvas, anchor.x + side, anchor.y + 2, ink)
            if shouldHaveCheeks(design) && anchor.span >= 6 {
                pixel(&canvas, anchor.x - side, anchor.y + 1, cheekTone(for: design))
            }
        case .beak, .insect, .visor, .relic, .elemental:
            break
        }
    }

    static func drawEyePair(_ canvas: inout [[PixelColor]], x: Int, y: Int, separation: Int, span: Int, ink: PixelColor, expression: Expression) {
        // At this resolution a one-pixel pair reads as a UI marker.  Two-pixel
        // eyes are used whenever the real face has room, while tiny or sleepy
        // creatures retain their deliberately smaller eyelids.
        let largeEyes = span >= 5 && expression != .sleepy
        let eyeWidth = largeEyes ? 2 : 1
        let eyeHeight = largeEyes ? 2 : 1

        for eyeCenter in [x - separation, x + separation] {
            let startX = eyeCenter - (eyeWidth - 1) / 2
            if expression == .sleepy {
                line(&canvas, startX, y, 1, 0, max(1, eyeWidth + 1), ink)
                continue
            }

            rect(&canvas, startX, y, eyeWidth, eyeHeight, ink)
            if eyeWidth > 1 {
                if ink == .cream || ink == .white || ink == .gold {
                    pixel(&canvas, startX, y + eyeHeight - 1, .darkBlue)
                } else {
                    pixel(&canvas, startX, y, .white)
                }
            }
        }
    }

    static func drawSingleEye(_ canvas: inout [[PixelColor]], x: Int, y: Int, ink: PixelColor, expression: Expression) {
        if expression == .sleepy {
            line(&canvas, x - 1, y, 1, 0, 2, ink)
            return
        }
        rect(&canvas, x, y, 2, 2, ink)
        if ink != .cream && ink != .white && ink != .gold {
            pixel(&canvas, x, y, .white)
        }
    }

    static func drawTinySmile(_ canvas: inout [[PixelColor]], x: Int, y: Int, ink: PixelColor, expression: Expression) {
        switch expression {
        case .sleepy:
            pixel(&canvas, x, y, ink)
        case .brave:
            line(&canvas, x - 1, y, 1, 0, 3, ink)
        default:
            pixel(&canvas, x - 1, y, ink)
            pixel(&canvas, x, y + 1, ink)
            pixel(&canvas, x + 1, y, ink)
        }
    }

    static func drawCharacterHighlight(_ canvas: inout [[PixelColor]], design: Design, anchor: FaceAnchor) {
        switch design.expression {
        case .sparkling:
            pixel(&canvas, anchor.x - max(2, anchor.span / 2), anchor.y - 1, .white)
            pixel(&canvas, anchor.x - max(2, anchor.span / 2) + 1, anchor.y - 1, .white)
        case .mechanical:
            pixel(&canvas, anchor.x - max(2, anchor.span / 2), anchor.y - 1, design.accent)
        default:
            break
        }
    }

    static func faceInk(for design: Design) -> PixelColor {
        switch design.primary {
        case .darkGray, .darkBlue, .darkRed, .purple, .black:
            return .cream
        case .white, .cream, .peach, .mint, .lime, .yellow, .gold, .lightGray, .tan:
            return .darkBrown
        default:
            return .darkBrown
        }
    }

    static func cheekTone(for design: Design) -> PixelColor {
        switch design.primary {
        case .pink, .red, .coral, .orange:
            return .peach
        case .blue, .darkBlue, .purple, .lavender, .teal:
            return .lavender
        case .green, .darkGreen, .lime, .mint:
            return .cream
        default:
            return .coral
        }
    }

    static func shouldHaveCheeks(_ design: Design) -> Bool {
        switch design.expression {
        case .brave, .mechanical, .sparkling:
            return false
        case .warm, .sleepy, .playful:
            return true
        }
    }

    /// Adds a restrained, palette-matched light/shadow edge before facial
    /// details are painted.  It rounds large flat colour fields into small
    /// sprite volumes without altering a species' silhouette or proportions.
    static func drawMaterialVolume(_ canvas: inout [[PixelColor]], design: Design) {
        let source = canvas
        let highlight = materialHighlight(for: design.primary)
        let shadow = softOutline(for: design.primary)

        for y in 1..<(canvas.count - 1) {
            for x in 1..<(canvas[y].count - 1) where source[y][x] == design.primary {
                let topLeftAir = source[y - 1][x].isTransparent && source[y][x - 1].isTransparent
                let bottomRightAir = source[y + 1][x].isTransparent && source[y][x + 1].isTransparent
                if topLeftAir {
                    canvas[y][x] = highlight
                } else if bottomRightAir {
                    canvas[y][x] = shadow
                }
            }
        }
    }

    static func materialHighlight(for primary: PixelColor) -> PixelColor {
        switch primary {
        case .darkGray, .gray, .lightGray:
            return .white
        case .brown, .darkBrown, .ginger, .tan, .cocoa:
            return .cream
        case .red, .darkRed, .orange, .gold, .yellow, .blush:
            return .yellow
        case .green, .darkGreen, .lime, .teal, .mint:
            return .mint
        case .blue, .darkBlue, .mistBlue:
            return .mint
        case .purple, .lavender, .pink, .coral:
            return .lavender
        case .white, .cream, .peach, .warmGray:
            return .white
        default:
            return .white
        }
    }

    /// Keep volume shades within the character palette. Using the outline
    /// colour for every shadow made light fur look like a stamped symbol; a
    /// muted material shade reads much closer to layered pixel illustration.
    static func materialShadow(for primary: PixelColor) -> PixelColor {
        switch primary {
        case .white, .cream, .peach, .warmGray:
            return .warmGray
        case .brown, .darkBrown, .ginger, .tan, .cocoa:
            return .cocoa
        case .red, .darkRed, .orange, .gold, .yellow, .blush:
            return .coral
        case .green, .darkGreen, .lime, .teal, .mint:
            return .darkGreen
        case .blue, .darkBlue, .mistBlue:
            return .darkBlue
        case .purple, .lavender, .pink:
            return .purple
        case .gray, .lightGray, .darkGray:
            return .darkGray
        default:
            return softOutline(for: primary)
        }
    }

    /// A direction is expressed through a real exterior part—such as a folded
    /// wing, dorsal plate, leaf, handle or trailing limb—not a swapped eye or
    /// a decorative pixel. Only species whose base anatomy is symmetric need
    /// this additional four-view contour.
    static func drawDirectionalContour(_ canvas: inout [[PixelColor]], _ design: Design, _ direction: SpriteDirection, _ scale: Scale) {
        let x = scale.centerX
        let base = scale.baseline
        let accent = design.accent

        switch design.trait {
        case "crystal":
            switch direction {
            case .front: line(&canvas, x - 4, base - 15, -1, -1, scale.value(4, minimum: 2), accent)
            case .back: line(&canvas, x + 4, base - 15, 1, -1, scale.value(4, minimum: 2), accent)
            case .sideLeft: line(&canvas, x - 9, base - 6, -1, 0, scale.value(3, minimum: 2), accent)
            case .sideRight: line(&canvas, x + 9, base - 6, 1, 0, scale.value(3, minimum: 2), accent)
            }

        case "octopus", "kraken":
            switch direction {
            case .front: line(&canvas, x - 6, base - 2, -1, 1, scale.value(3, minimum: 2), accent)
            case .back: line(&canvas, x, base - 10, 0, -1, scale.value(3, minimum: 2), accent)
            case .sideLeft: line(&canvas, x - 7, base - 4, -1, 0, scale.value(4, minimum: 2), accent)
            case .sideRight: line(&canvas, x + 7, base - 4, 1, 0, scale.value(4, minimum: 2), accent)
            }

        case "android", "golem", "titan":
            switch direction {
            case .front: line(&canvas, x - 6, base - 13, -1, 0, scale.value(3, minimum: 2), accent)
            case .back: line(&canvas, x + 6, base - 13, 1, 0, scale.value(3, minimum: 2), accent)
            case .sideLeft: line(&canvas, x - 8, base - 7, -1, 0, scale.value(3, minimum: 2), accent)
            case .sideRight: line(&canvas, x + 8, base - 7, 1, 0, scale.value(4, minimum: 2), accent)
            }

        case "nebula":
            switch direction {
            case .front: line(&canvas, x - 8, base - 7, -1, 0, scale.value(3, minimum: 2), accent)
            case .back: line(&canvas, x + 8, base - 7, 1, 0, scale.value(3, minimum: 2), accent)
            case .sideLeft: line(&canvas, x - 7, base - 5, -1, 1, scale.value(3, minimum: 2), accent)
            case .sideRight: line(&canvas, x + 7, base - 5, 1, 1, scale.value(4, minimum: 2), accent)
            }

        case "cloud":
            switch direction {
            case .front: oval(&canvas, x - 8, base - 5, 4, 3, accent)
            case .back: oval(&canvas, x + 8, base - 5, 4, 3, accent)
            case .sideLeft: line(&canvas, x - 8, base - 4, -1, 1, scale.value(3, minimum: 2), accent)
            case .sideRight: line(&canvas, x + 8, base - 4, 1, 1, scale.value(3, minimum: 2), accent)
            }

        case "flame":
            switch direction {
            case .front: line(&canvas, x - 7, base - 9, -1, -1, scale.value(4, minimum: 2), accent)
            case .back: line(&canvas, x + 7, base - 9, 1, -1, scale.value(4, minimum: 2), accent)
            case .sideLeft: line(&canvas, x - 8, base - 6, -1, 0, scale.value(3, minimum: 2), accent)
            case .sideRight: line(&canvas, x + 8, base - 6, 1, 0, scale.value(3, minimum: 2), accent)
            }

        case "butterfly", "luna_moth":
            switch direction {
            case .front: line(&canvas, x - 2, base - 1, 0, 1, scale.value(3, minimum: 2), accent)
            case .back: line(&canvas, x + 2, base - 1, 0, 1, scale.value(4, minimum: 2), accent)
            case .sideLeft: line(&canvas, x - 8, base - 4, -1, 0, scale.value(4, minimum: 2), accent)
            case .sideRight: line(&canvas, x + 8, base - 4, 1, 0, scale.value(4, minimum: 2), accent)
            }

        case "atlas_beetle", "scorpion":
            switch direction {
            case .front: line(&canvas, x - 7, base - 7, -1, -1, scale.value(4, minimum: 2), accent)
            case .back: line(&canvas, x + 7, base - 7, 1, -1, scale.value(4, minimum: 2), accent)
            case .sideLeft: line(&canvas, x - 7, base - 2, -1, 0, scale.value(4, minimum: 2), accent)
            case .sideRight: line(&canvas, x + 7, base - 2, 1, 0, scale.value(4, minimum: 2), accent)
            }

        case "jellyfish":
            switch direction {
            case .front: line(&canvas, x - 6, base - 4, -1, 1, scale.value(3, minimum: 2), accent)
            case .back: line(&canvas, x + 6, base - 4, 1, 1, scale.value(3, minimum: 2), accent)
            case .sideLeft: line(&canvas, x - 7, base - 5, -1, 0, scale.value(3, minimum: 2), accent)
            case .sideRight: line(&canvas, x + 7, base - 5, 1, 0, scale.value(3, minimum: 2), accent)
            }

        case "lotus", "moonflower":
            switch direction {
            case .front: diamond(&canvas, x - 7, base - 7, 2, 2, accent)
            case .back: diamond(&canvas, x + 7, base - 7, 2, 2, accent)
            case .sideLeft: line(&canvas, x - 5, base - 4, -1, 0, scale.value(4, minimum: 2), accent)
            case .sideRight: line(&canvas, x + 5, base - 4, 1, 0, scale.value(4, minimum: 2), accent)
            }

        case "mushroom":
            switch direction {
            case .front: diamond(&canvas, x - 8, base - 9, 2, 1, accent)
            case .back: diamond(&canvas, x + 8, base - 9, 2, 1, accent)
            case .sideLeft: line(&canvas, x - 7, base - 8, -1, 0, scale.value(3, minimum: 2), accent)
            case .sideRight: line(&canvas, x + 7, base - 8, 1, 0, scale.value(3, minimum: 2), accent)
            }

        case "cactus":
            switch direction {
            case .front: line(&canvas, x - 2, base - 16, 0, -1, scale.value(3, minimum: 2), accent)
            case .back: line(&canvas, x + 2, base - 16, 0, -1, scale.value(3, minimum: 2), accent)
            case .sideLeft: line(&canvas, x - 1, base - 17, -1, -1, scale.value(3, minimum: 2), accent)
            case .sideRight: line(&canvas, x + 1, base - 17, 1, -1, scale.value(3, minimum: 2), accent)
            }

        case "peach", "acorn":
            switch direction {
            case .front: line(&canvas, x - 4, base - 11, -1, -1, scale.value(3, minimum: 2), accent)
            case .back: line(&canvas, x + 4, base - 11, 1, -1, scale.value(3, minimum: 2), accent)
            case .sideLeft: diamond(&canvas, x - 6, base - 8, 2, 1, accent)
            case .sideRight: diamond(&canvas, x + 6, base - 8, 2, 1, accent)
            }

        case "world_tree":
            switch direction {
            case .front: line(&canvas, x - 8, base - 12, -1, -1, scale.value(3, minimum: 2), accent)
            case .back: line(&canvas, x + 8, base - 12, 1, -1, scale.value(3, minimum: 2), accent)
            case .sideLeft: line(&canvas, x - 8, base - 8, -1, 0, scale.value(4, minimum: 2), accent)
            case .sideRight: line(&canvas, x + 8, base - 8, 1, 0, scale.value(4, minimum: 2), accent)
            }

        case "turtle":
            switch direction {
            case .front: rect(&canvas, x - 1, base - 13, 3, 2, accent)
            case .back: line(&canvas, x, base - 4, 0, 1, scale.value(3, minimum: 2), accent)
            case .sideLeft: line(&canvas, x - 8, base - 7, -1, 0, scale.value(3, minimum: 2), accent)
            case .sideRight: line(&canvas, x + 8, base - 7, 1, 0, scale.value(4, minimum: 2), accent)
            }

        case "rock":
            switch direction {
            case .front: diamond(&canvas, x - 7, base - 5, 2, 1, accent)
            case .back: diamond(&canvas, x + 7, base - 5, 2, 1, accent)
            case .sideLeft: line(&canvas, x - 8, base - 4, -1, 0, scale.value(3, minimum: 2), accent)
            case .sideRight: line(&canvas, x + 8, base - 4, 1, 0, scale.value(3, minimum: 2), accent)
            }

        case "clockwork", "orb", "singularity":
            switch direction {
            case .front: line(&canvas, x - 5, base - 15, -1, -1, scale.value(3, minimum: 2), accent)
            case .back: line(&canvas, x + 5, base - 15, 1, -1, scale.value(3, minimum: 2), accent)
            case .sideLeft: line(&canvas, x - 9, base - 7, -1, 0, scale.value(3, minimum: 2), accent)
            case .sideRight: line(&canvas, x + 9, base - 7, 1, 0, scale.value(3, minimum: 2), accent)
            }

        case "teapot", "lantern", "bastion":
            switch direction {
            case .front: line(&canvas, x - 7, base - 7, -1, -1, scale.value(3, minimum: 2), accent)
            case .back: line(&canvas, x + 7, base - 7, 1, -1, scale.value(3, minimum: 2), accent)
            case .sideLeft: line(&canvas, x - 8, base - 5, -1, 0, scale.value(3, minimum: 2), accent)
            case .sideRight: line(&canvas, x + 8, base - 5, 1, 0, scale.value(3, minimum: 2), accent)
            }

        case "mermaid":
            switch direction {
            case .front: line(&canvas, x - 6, base - 15, -1, 0, scale.value(3, minimum: 2), accent)
            case .back: line(&canvas, x + 6, base - 15, 1, 0, scale.value(3, minimum: 2), accent)
            case .sideLeft: line(&canvas, x - 6, base - 12, -1, -1, scale.value(3, minimum: 2), accent)
            case .sideRight: line(&canvas, x + 6, base - 12, 1, -1, scale.value(3, minimum: 2), accent)
            }

        case "skate":
            switch direction {
            case .front: line(&canvas, x - 9, base - 8, -1, -1, scale.value(3, minimum: 2), accent)
            case .back: line(&canvas, x + 9, base - 8, 1, -1, scale.value(3, minimum: 2), accent)
            case .sideLeft: line(&canvas, x - 9, base - 6, -1, 0, scale.value(3, minimum: 2), accent)
            case .sideRight: line(&canvas, x + 9, base - 6, 1, 0, scale.value(3, minimum: 2), accent)
            }

        default:
            break
        }
    }

    // MARK: - Land animals

    static func drawQuadruped(_ canvas: inout [[PixelColor]], _ design: Design, _ direction: SpriteDirection, _ scale: Scale) {
        let naturalBodyWidth = scale.value(design.bodyWidth, minimum: 6)
        let naturalBodyHeight = scale.value(design.bodyHeight, minimum: 4)
        let headWidth = scale.value(design.headWidth, minimum: 4)
        let headHeight = scale.value(design.headHeight, minimum: 3)
        let legs = scale.value(design.limbLength, minimum: design.limbLength == 0 ? 0 : 1)
        let x = scale.centerX
        let side = direction == .sideLeft ? -1 : direction == .sideRight ? 1 : 0
        let body = quadrupedBodyMetrics(
            for: design,
            naturalWidth: naturalBodyWidth,
            naturalHeight: naturalBodyHeight,
            headWidth: headWidth,
            headHeight: headHeight,
            isProfile: side != 0
        )
        let bodyWidth = body.width
        let bodyHeight = body.height
        let bodyY = scale.baseline - legs - bodyHeight / 2
        let headY = bodyY - bodyHeight / 2 - headHeight / 2 + 1

        if side == 0 {
            // A frontal animal shows its chest and paired paws rather than a
            // flattened side-view torso.  The side view below keeps the full
            // long body for species such as wolves, ferrets and otters.
            outlinedOval(&canvas, x, bodyY, bodyWidth, bodyHeight, design.primary)
            let shoulderY = bodyY - bodyHeight / 2 + 2
            outlinedOval(&canvas, x, headY, headWidth, headHeight, design.primary)
            drawQuadrupedEars(&canvas, trait: design.trait, x: x, y: headY - headHeight / 2, side: 0, scale: scale, color: design.accent)
            drawQuadrupedLegs(&canvas, trait: design.trait, x: x, y: bodyY + bodyHeight / 2, width: bodyWidth, length: legs, direction: direction, scale: scale, color: design.primary)
            drawQuadrupedTail(&canvas, trait: design.trait, x: x, y: bodyY + 1, side: direction == .front ? -1 : 1, scale: scale, color: design.accent)
            if direction == .front {
                animalEyes(&canvas, x: x, y: headY, separation: max(1, headWidth / 4), color: .black)
                drawQuadrupedFrontMark(&canvas, trait: design.trait, x: x, y: headY, shoulderY: shoulderY, scale: scale, color: design.accent)
            } else {
                drawQuadrupedBackMark(&canvas, trait: design.trait, x: x, y: bodyY, shoulderY: shoulderY, width: bodyWidth, scale: scale, color: design.accent)
            }
        } else {
            // The profile exposes a horizontally extended spine, a forward
            // head, separate fore/hind legs and a trailing tail.
            let headX = x + side * (bodyWidth / 2 - 1)
            let rumpX = x - side * (bodyWidth / 2 - 2)
            outlinedOval(&canvas, x, bodyY, bodyWidth, bodyHeight, design.primary)
            outlinedOval(&canvas, headX, headY + 2, headWidth, headHeight, design.primary)
            drawQuadrupedEars(&canvas, trait: design.trait, x: headX, y: headY - headHeight / 2, side: side, scale: scale, color: design.accent)
            drawQuadrupedLegs(&canvas, trait: design.trait, x: x, y: bodyY + bodyHeight / 2, width: bodyWidth, length: legs, direction: direction, scale: scale, color: design.primary)
            drawQuadrupedTail(&canvas, trait: design.trait, x: rumpX, y: bodyY, side: -side, scale: scale, color: design.accent)
            pixel(&canvas, headX + side * max(1, headWidth / 4), headY + 1, .black)
            drawQuadrupedProfileMark(&canvas, trait: design.trait, x: headX, y: bodyY, side: side, scale: scale, color: design.accent)
        }
    }

    /// A front-facing pet reads as a character when the face and torso carry
    /// comparable visual weight.  Profiles retain a little extra length for
    /// species such as ferrets and elephants, while ears, shells, tails and
    /// markings still communicate the real animal.
    static func quadrupedBodyMetrics(
        for design: Design,
        naturalWidth: Int,
        naturalHeight: Int,
        headWidth: Int,
        headHeight: Int,
        isProfile: Bool
    ) -> (width: Int, height: Int) {
        let widthAllowance: Int
        switch design.trait {
        case "otter", "ferret":
            widthAllowance = isProfile ? 6 : 3
        case "elephant", "mammoth":
            widthAllowance = isProfile ? 5 : 3
        case "turtle", "capybara":
            widthAllowance = isProfile ? 4 : 3
        case "chameleon", "gecko":
            widthAllowance = isProfile ? 4 : 2
        default:
            widthAllowance = isProfile ? 4 : 2
        }

        return (
            max(headWidth + 1, min(naturalWidth, headWidth + widthAllowance)),
            max(headHeight, min(naturalHeight, headHeight + 1))
        )
    }

    static func animalEyes(_ canvas: inout [[PixelColor]], x: Int, y: Int, separation: Int, color: PixelColor) {
        // Fallback for any species-specific drawing that paints its eyes
        // before the final character pass.  The finish pass can still choose
        // a different treatment, but a missed face never collapses to two
        // anonymous one-pixel dots.
        let eyeHeight = separation >= 2 ? 2 : 1
        for eyeX in [x - separation, x + separation] {
            rect(&canvas, eyeX, y, 1, eyeHeight, color)
            if eyeHeight > 1 && color != .cream && color != .white && color != .gold {
                pixel(&canvas, eyeX, y, .white)
            }
        }
    }

    static func drawQuadrupedEars(_ canvas: inout [[PixelColor]], trait: String, x: Int, y: Int, side: Int, scale: Scale, color: PixelColor) {
        switch trait {
        case "rabbit":
            let height = scale.value(7, minimum: 3)
            // The ears overlap the crown by two cells.  Previously their
            // centres were placed too high, which made a rabbit look like it
            // had two detached accessories floating above its head.
            let earY = y - height / 2 + 2
            outlinedOval(&canvas, x - 3, earY, 3, height, .white)
            outlinedOval(&canvas, x + 3, earY, 3, height, .white)
            rect(&canvas, x - 4, y, 2, 2, .white)
            rect(&canvas, x + 3, y, 2, 2, .white)
        case "moonrabbit":
            let height = scale.value(9, minimum: 4)
            let earY = y - height / 2 + 2
            outlinedOval(&canvas, x - 4, earY, 3, height, .white)
            outlinedOval(&canvas, x + 4, earY, 3, height, .white)
            rect(&canvas, x - 5, y, 2, 2, .white)
            rect(&canvas, x + 4, y, 2, 2, .white)
            // The crescent-like ear tips are part of the moon rabbit's
            // anatomy, not a direction-only decorative protrusion.
            oval(&canvas, x - 5, y - height / 2 + 1, 2, 3, .white)
            oval(&canvas, x + 5, y - height / 2 + 1, 2, 3, .white)
        case "elephant":
            outlinedOval(&canvas, x - 4, y + 2, 5, 5, color)
            outlinedOval(&canvas, x + 4, y + 2, 5, 5, color)
        case "mammoth":
            outlinedOval(&canvas, x - 4, y + 2, 4, 4, color)
            outlinedOval(&canvas, x + 4, y + 2, 4, 4, color)
            oval(&canvas, x, y - 1, 7, 3, color)
        case "raccoon":
            // Rounded ears plus the connected face mask prevent the raccoon
            // from borrowing a cat/rat-like pointed-ear silhouette.
            outlinedOval(&canvas, x - 2, y + 1, 2, 2, .gray)
            outlinedOval(&canvas, x + 2, y + 1, 2, 2, .gray)
        case "bear":
            // Bear ears are compact, round and rooted in the head silhouette;
            // koalas keep their deliberately larger disc ears below.
            outlinedOval(&canvas, x - 2, y + 1, 2, 2, color)
            outlinedOval(&canvas, x + 2, y + 1, 2, 2, color)
        case "koala":
            outlinedOval(&canvas, x - 3, y, 4, 4, color)
            outlinedOval(&canvas, x + 3, y, 4, 4, color)
        case "hedgehog":
            line(&canvas, x - 4, y + 3, -1, -1, 4, color)
            line(&canvas, x + 4, y + 3, 1, -1, 4, color)
        case "wolf":
            // Short, triangular wolf ears stay distinct from a rabbit's tall
            // ears while keeping the face rounded and friendly.
            diamond(&canvas, x - 3, y + 1, 2, 2, color)
            diamond(&canvas, x + 3, y + 1, 2, 2, color)
            pixel(&canvas, x - 3, y - 1, color)
            pixel(&canvas, x + 3, y - 1, color)
        case "sphinx":
            // A rounded ceremonial mane gives the sphinx a recognisable
            // ancient guardian silhouette instead of a second generic cat.
            outlinedOval(&canvas, x - 4, y + 3, 4, 5, color)
            outlinedOval(&canvas, x + 4, y + 3, 4, 5, color)
            line(&canvas, x - 2, y, -1, -1, scale.value(3, minimum: 2), color)
            line(&canvas, x + 2, y, 1, -1, scale.value(3, minimum: 2), color)
        case "turtle", "gecko", "chameleon":
            rect(&canvas, x - 4, y + 2, 2, 2, color)
            rect(&canvas, x + 3, y + 2, 2, 2, color)
        default:
            let slant = side == 0 ? 1 : side
            diamond(&canvas, x - 3, y, 2, 3, color)
            diamond(&canvas, x + 3, y, 2, 3, color)
            pixel(&canvas, x - 3 - slant, y - 2, color)
            pixel(&canvas, x + 3 + slant, y - 2, color)
        }
    }

    static func drawQuadrupedLegs(_ canvas: inout [[PixelColor]], trait: String, x: Int, y: Int, width: Int, length: Int, direction: SpriteDirection, scale: Scale, color: PixelColor) {
        guard length > 0 else { return }
        let spread = max(2, width / 3)
        let stride = scale.lift == 0 ? 0 : -1
        let leftLength: Int
        let rightLength: Int
        switch direction {
        case .front, .back:
            leftLength = length
            rightLength = max(1, length + stride)
        case .sideLeft, .sideRight:
            leftLength = max(1, length + stride)
            rightLength = length
        }
        rect(&canvas, x - spread, y, 2, leftLength, color)
        rect(&canvas, x + spread - 1, y, 2, rightLength, color)
        // A small rounded paw keeps the real leg count while avoiding the
        // matchstick look of a bare rectangular limb.
        oval(&canvas, x - spread + 1, y + leftLength - 1, 3, 2, color)
        oval(&canvas, x + spread, y + rightLength - 1, 3, 2, color)
        if trait == "turtle" || trait == "gecko" {
            rect(&canvas, x - spread - 1, y + max(0, length - 1), 3, 1, color)
            rect(&canvas, x + spread - 1, y + max(0, length - 1), 3, 1, color)
        }
    }

    static func drawQuadrupedTail(_ canvas: inout [[PixelColor]], trait: String, x: Int, y: Int, side: Int, scale: Scale, color: PixelColor) {
        let direction = side == 0 ? 1 : side
        switch trait {
        case "rabbit", "moonrabbit":
            // A rabbit's cotton tail sits against the rump.  Keep it white
            // and compact so it reads as anatomy rather than a floating pink
            // badge beside the body.
            outlinedOval(&canvas, x + direction * 3, y + 2, 3, 3, .white)
        case "bear":
            outlinedOval(&canvas, x + direction * 3, y + 2, 3, 3, .brown)
        case "fox":
            diamond(&canvas, x + direction * 4, y, scale.value(4, minimum: 2), scale.value(3, minimum: 2), color)
            line(&canvas, x + direction * 2, y, direction, 0, scale.value(4, minimum: 2), color)
        case "wolf":
            // A wolf's tail stays visibly bushier and longer than a fox's,
            // which also keeps its broad, canine side read after body
            // balancing brings the torso closer to the head size.
            diamond(&canvas, x + direction * 5, y + 1, scale.value(5, minimum: 3), scale.value(3, minimum: 2), color)
            line(&canvas, x + direction * 2, y, direction, 0, scale.value(5, minimum: 2), color)
        case "starfox":
            diamond(&canvas, x + direction * 4, y, scale.value(4, minimum: 2), scale.value(3, minimum: 2), color)
            line(&canvas, x + direction * 2, y, direction, 0, scale.value(4, minimum: 2), color)
            line(&canvas, x + direction * 7, y, direction, -1, scale.value(3, minimum: 2), .yellow)
            line(&canvas, x + direction * 7, y, direction, 1, scale.value(3, minimum: 2), .yellow)
        case "beaver":
            diamond(&canvas, x + direction * 5, y + 2, scale.value(4, minimum: 2), scale.value(2, minimum: 1), color)
        case "otter", "ferret":
            oval(&canvas, x + direction * 5, y + 1, scale.value(7, minimum: 3), scale.value(3, minimum: 2), color)
            pixel(&canvas, x + direction * 8, y + 2, color)
        case "raccoon":
            // A broad, rounded, banded tail is a raccoon's primary silhouette
            // cue.  A thin line with two dots was easily mistaken for a rat
            // tail at the former 24px output size.
            let tailLength = scale.value(7, minimum: 4)
            let tailX = x + direction * (tailLength / 2 + 3)
            outlinedOval(&canvas, tailX, y + 1, tailLength, 3, color)
            for offset in [2, 4, 6] where offset < tailLength + 1 {
                line(&canvas, x + direction * (offset + 2), y - 1, 0, 1, 3, .black)
            }
        case "chameleon":
            line(&canvas, x + direction * 3, y, direction, 1, scale.value(3, minimum: 2), color)
            line(&canvas, x + direction * 5, y + 2, -direction, 1, scale.value(2, minimum: 1), color)
        case "elephant", "mammoth":
            line(&canvas, x + direction * 4, y, direction, 1, scale.value(3, minimum: 2), color)
        case "turtle":
            line(&canvas, x + direction * 3, y + 1, direction, 0, scale.value(3, minimum: 2), color)
        case "hedgehog":
            line(&canvas, x + direction * 3, y, direction, -1, scale.value(4, minimum: 2), color)
        default:
            oval(&canvas, x + direction * 4, y + 2, scale.value(5, minimum: 3), scale.value(3, minimum: 2), color)
        }
    }

    static func drawQuadrupedFrontMark(_ canvas: inout [[PixelColor]], trait: String, x: Int, y: Int, shoulderY: Int, scale: Scale, color: PixelColor) {
        switch trait {
        case "wolf": rect(&canvas, x - 1, y + 2, 3, 1, color)
        case "fox", "starfox": diamond(&canvas, x, y + 2, 2, 1, color)
        case "cat": rect(&canvas, x - 3, y + 2, 7, 2, color)
        case "puppy": oval(&canvas, x, y + 2, 4, 3, color)
        case "turtle":
            outlinedDiamond(&canvas, x, shoulderY + 4, 5, 4, color)
            rect(&canvas, x - 2, shoulderY + 4, 5, 1, .darkGreen)
        case "hedgehog":
            line(&canvas, x - 5, shoulderY + 2, -1, -1, 4, color)
            line(&canvas, x + 5, shoulderY + 2, 1, -1, 4, color)
        case "elephant":
            rect(&canvas, x - 1, y + 2, 3, scale.value(7, minimum: 3), color)
            line(&canvas, x - 3, y + 5, -1, 0, scale.value(3, minimum: 2), .cream)
            line(&canvas, x + 3, y + 5, 1, 0, scale.value(3, minimum: 2), .cream)
        case "mammoth":
            rect(&canvas, x - 1, y + 2, 3, scale.value(7, minimum: 3), color)
            line(&canvas, x - 3, y + 5, -1, 1, scale.value(3, minimum: 2), .cream)
            line(&canvas, x + 3, y + 5, 1, 1, scale.value(3, minimum: 2), .cream)
            oval(&canvas, x, y - 2, 7, 2, .darkGray)
        case "sphinx":
            oval(&canvas, x, y + 3, 7, 2, color)
            line(&canvas, x, y - 3, 0, -1, scale.value(2, minimum: 1), color)
        case "deer":
            line(&canvas, x - 3, y - 2, -1, -1, scale.value(4, minimum: 2), color)
            line(&canvas, x + 3, y - 2, 1, -1, scale.value(4, minimum: 2), color)
        case "beaver": rect(&canvas, x - 1, y + 2, 3, 2, .white)
        case "koala": oval(&canvas, x, y + 2, 3, 3, .black)
        case "badger": rect(&canvas, x - 3, y - 1, 7, 2, color)
        case "raccoon":
            // Keep the dark eye mask as a connected face patch, not a flat
            // decorative stripe.  The high-resolution pass carves eye glints
            // and the little muzzle into this band.
            outlinedOval(&canvas, x, y - 1, 9, 3, color)
        case "capybara": oval(&canvas, x, y + 2, 5, 3, color)
        default: break
        }
    }

    static func drawQuadrupedBackMark(_ canvas: inout [[PixelColor]], trait: String, x: Int, y: Int, shoulderY: Int, width: Int, scale: Scale, color: PixelColor) {
        switch trait {
        case "turtle":
            outlinedDiamond(&canvas, x, shoulderY + 4, 5, 4, color)
        case "hedgehog":
            for offset in stride(from: -width / 2, through: width / 2, by: 3) {
                line(&canvas, x + offset, y - 2, offset < 0 ? -1 : 1, -1, 3, color)
            }
        case "zebra":
            rect(&canvas, x - 3, y - 1, 7, 1, color)
        default:
            rect(&canvas, x - max(2, width / 4), y - 1, max(5, width / 2), 1, color)
        }
    }

    static func drawQuadrupedProfileMark(_ canvas: inout [[PixelColor]], trait: String, x: Int, y: Int, side: Int, scale: Scale, color: PixelColor) {
        switch trait {
        case "elephant", "mammoth":
            line(&canvas, x + side * 3, y - 1, side, 1, scale.value(5, minimum: 2), color)
            line(&canvas, x + side * 2, y + 2, side, 0, scale.value(3, minimum: 2), .cream)
        case "deer":
            line(&canvas, x, y - 5, side, -1, scale.value(4, minimum: 2), color)
            line(&canvas, x - side, y - 4, -side, -1, scale.value(2, minimum: 1), color)
        case "turtle":
            outlinedDiamond(&canvas, x - side * 2, y + 1, 4, 3, color)
        case "gecko":
            line(&canvas, x - side * 3, y + 2, -side, 0, scale.value(5, minimum: 2), color)
        case "chameleon":
            oval(&canvas, x + side * 2, y - 1, 3, 3, color)
        case "badger":
            rect(&canvas, x + side, y - 3, 3, 2, color)
        default: break
        }
    }

    // MARK: - Birds and flying mammals

    static func drawBird(_ canvas: inout [[PixelColor]], _ design: Design, _ direction: SpriteDirection, _ scale: Scale) {
        let naturalBodyWidth = scale.value(design.bodyWidth, minimum: 5)
        let naturalBodyHeight = scale.value(design.bodyHeight, minimum: 6)
        let headWidth = scale.value(design.headWidth, minimum: 4)
        let headHeight = scale.value(design.headHeight, minimum: 3)
        let legs = scale.value(design.limbLength, minimum: design.limbLength == 0 ? 0 : 1)
        let x = scale.centerX
        let side = direction == .sideLeft ? -1 : direction == .sideRight ? 1 : 0
        let body = birdBodyMetrics(
            for: design,
            naturalWidth: naturalBodyWidth,
            naturalHeight: naturalBodyHeight,
            headWidth: headWidth,
            headHeight: headHeight,
            isProfile: side != 0
        )
        let bodyWidth = body.width
        let bodyHeight = body.height
        let bodyY = scale.baseline - legs - bodyHeight / 2
        let headY = bodyY - bodyHeight / 2 - headHeight / 2 + 1

        if design.trait == "bat" {
            drawBat(&canvas, design, direction, scale, bodyY: bodyY, headY: headY)
            return
        }

        if side == 0 {
            outlinedOval(&canvas, x, bodyY, bodyWidth, bodyHeight, design.primary)
            outlinedOval(&canvas, x, headY, headWidth, headHeight, design.primary)
            drawBirdWings(&canvas, trait: design.trait, x: x, y: bodyY, side: 0, scale: scale, color: design.accent)
            drawBirdTail(&canvas, trait: design.trait, x: x, y: bodyY + bodyHeight / 2, side: direction == .front ? 1 : -1, scale: scale, color: design.accent)
            if direction == .front {
                animalEyes(&canvas, x: x, y: headY, separation: max(1, headWidth / 4), color: .black)
                drawBirdBeak(&canvas, trait: design.trait, x: x, y: headY + 2, side: 0, color: design.accent)
                drawBirdCrest(&canvas, trait: design.trait, x: x, y: headY - headHeight / 2, scale: scale, color: design.accent)
            } else {
                rect(&canvas, x - bodyWidth / 3, bodyY - 1, max(4, bodyWidth * 2 / 3), 1, design.accent)
                drawBirdCrest(&canvas, trait: design.trait, x: x, y: headY - headHeight / 2, scale: scale, color: design.accent)
            }
        } else {
            let headX = x + side * (bodyWidth / 2 - 1)
            outlinedOval(&canvas, x, bodyY, bodyWidth, max(4, bodyHeight - 2), design.primary)
            outlinedOval(&canvas, headX, headY + 2, headWidth, headHeight, design.primary)
            drawBirdWings(&canvas, trait: design.trait, x: x - side, y: bodyY, side: side, scale: scale, color: design.accent)
            drawBirdTail(&canvas, trait: design.trait, x: x - side * (bodyWidth / 2 - 1), y: bodyY + 2, side: -side, scale: scale, color: design.accent)
            drawBirdBeak(&canvas, trait: design.trait, x: headX + side * (headWidth / 2), y: headY + 2, side: side, color: design.accent)
            pixel(&canvas, headX + side, headY + 1, .black)
            drawBirdCrest(&canvas, trait: design.trait, x: headX, y: headY - headHeight / 2, scale: scale, color: design.accent)
        }
    }

    static func birdBodyMetrics(
        for design: Design,
        naturalWidth: Int,
        naturalHeight: Int,
        headWidth: Int,
        headHeight: Int,
        isProfile: Bool
    ) -> (width: Int, height: Int) {
        let widthAllowance: Int
        switch design.trait {
        case "phoenix", "thunderbird":
            widthAllowance = isProfile ? 4 : 3
        case "owl", "penguin":
            widthAllowance = isProfile ? 3 : 2
        default:
            widthAllowance = isProfile ? 3 : 2
        }
        return (
            max(headWidth + 1, min(naturalWidth, headWidth + widthAllowance)),
            max(headHeight, min(naturalHeight, headHeight + 2))
        )
    }

    static func drawBirdWings(_ canvas: inout [[PixelColor]], trait: String, x: Int, y: Int, side: Int, scale: Scale, color: PixelColor) {
        let spread = trait == "thunderbird" || trait == "phoenix" ? 6 : trait == "owl" ? 4 : 3
        if side == 0 {
            for direction in [-1, 1] {
                let wingWidth = scale.value(trait == "owl" ? 4 : spread + 2, minimum: 3)
                let wingHeight = scale.value(max(3, spread), minimum: 2)
                let offset = trait == "owl" ? 3 : 3 + wingWidth / 3
                outlinedOval(&canvas, x + direction * offset, y + 1, wingWidth, wingHeight, color)
                pixel(&canvas, x + direction * (offset + wingWidth / 2), y + wingHeight / 2, color)
            }
        } else {
            let wingWidth = scale.value(trait == "owl" ? 4 : spread + 2, minimum: 3)
            let wingHeight = scale.value(max(3, spread), minimum: 2)
            outlinedOval(&canvas, x - side * 3, y + 1, wingWidth, wingHeight, color)
            pixel(&canvas, x - side * (3 + wingWidth / 2), y + wingHeight / 2, color)
        }
    }

    static func drawBirdTail(_ canvas: inout [[PixelColor]], trait: String, x: Int, y: Int, side: Int, scale: Scale, color: PixelColor) {
        let direction = side == 0 ? 1 : side
        let length = trait == "phoenix" ? 7 : trait == "parrot" ? 7 : trait == "parakeet" ? 5 : trait == "raven" ? 5 : 3
        line(&canvas, x, y, direction, 1, scale.value(length, minimum: 2), color)
        if trait == "phoenix" {
            line(&canvas, x + direction, y + 1, direction, 0, scale.value(5, minimum: 2), .yellow)
        } else if trait == "parrot" {
            // A long, rounded red tail makes the parrot read differently
            // from the shorter green parakeet at thumbnail size.
            oval(&canvas, x + direction * scale.value(length, minimum: 2), y + scale.value(length, minimum: 2), 3, 4, color)
        }
    }

    static func drawBirdBeak(_ canvas: inout [[PixelColor]], trait: String, x: Int, y: Int, side: Int, color: PixelColor) {
        let beakColor: PixelColor = trait == "raven" ? .darkGray : trait == "penguin" ? .orange : trait == "owl" ? .gold : color
        if side == 0 {
            diamond(&canvas, x, y, 2, 1, beakColor)
        } else {
            line(&canvas, x, y, side, 0, trait == "raven" ? 4 : 3, beakColor)
        }
    }

    static func drawBirdCrest(_ canvas: inout [[PixelColor]], trait: String, x: Int, y: Int, scale: Scale, color: PixelColor) {
        switch trait {
        case "owl":
            line(&canvas, x - 3, y + 2, -1, -1, scale.value(3, minimum: 2), color)
            line(&canvas, x + 3, y + 2, 1, -1, scale.value(3, minimum: 2), color)
        case "phoenix", "thunderbird":
            line(&canvas, x, y, 0, -1, scale.value(4, minimum: 2), color)
            line(&canvas, x - 1, y + 1, -1, -1, scale.value(2, minimum: 1), color)
        case "parrot", "parakeet":
            line(&canvas, x, y, 1, -1, scale.value(3, minimum: 2), color)
            if trait == "parrot" {
                oval(&canvas, x + 2, y - 2, 3, 3, color)
            }
        default: break
        }
    }

    static func drawBat(_ canvas: inout [[PixelColor]], _ design: Design, _ direction: SpriteDirection, _ scale: Scale, bodyY: Int, headY: Int) {
        let x = scale.centerX
        let side = direction == .sideLeft ? -1 : direction == .sideRight ? 1 : 0
        let wing = scale.value(8, minimum: 4)
        outlinedOval(&canvas, x, bodyY, scale.value(6, minimum: 4), scale.value(7, minimum: 4), design.primary)
        if side == 0 {
            for directionSign in [-1, 1] {
                line(&canvas, x + directionSign * 2, bodyY - 2, directionSign, 1, wing, design.accent)
                line(&canvas, x + directionSign * 4, bodyY + 1, directionSign, -1, max(2, wing - 3), design.accent)
            }
            if direction == .front {
                animalEyes(&canvas, x: x, y: headY, separation: 1, color: .white)
                line(&canvas, x - 2, headY - 1, -1, -1, 3, design.accent)
                line(&canvas, x + 2, headY - 1, 1, -1, 3, design.accent)
            } else {
                rect(&canvas, x - 3, headY - 1, 7, 2, .black)
                rect(&canvas, x - 1, bodyY - 1, 3, 5, design.accent)
            }
        } else {
            line(&canvas, x - side, bodyY - 2, -side, 1, wing, design.accent)
            line(&canvas, x - side * 3, bodyY + 1, -side, -1, max(2, wing - 3), design.accent)
            pixel(&canvas, x + side * 2, headY, .white)
            line(&canvas, x + side, headY - 1, side, -1, 3, design.accent)
        }
    }

    // MARK: - Water creatures

    static func drawSwimmer(_ canvas: inout [[PixelColor]], _ design: Design, _ direction: SpriteDirection, _ scale: Scale) {
        let width = scale.value(design.bodyWidth, minimum: 7)
        let height = scale.value(design.bodyHeight, minimum: 4)
        let x = scale.centerX
        let y = scale.baseline - height / 2 - 2
        let side = direction == .sideLeft ? -1 : direction == .sideRight ? 1 : 0

        if side == 0 {
            outlinedOval(&canvas, x, y, max(6, width - 5), height + 1, design.primary)
            drawSwimmerFins(&canvas, trait: design.trait, x: x, y: y, side: 0, scale: scale, color: design.accent)
            if direction == .front {
                animalEyes(&canvas, x: x, y: y, separation: max(1, width / 7), color: .black)
            } else {
                rect(&canvas, x - max(2, width / 5), y - 1, max(5, width / 3), 1, design.accent)
            }
            drawSwimmerTail(&canvas, trait: design.trait, x: x, y: y + height / 2 + 1, side: direction == .front ? 1 : -1, scale: scale, color: design.accent)
        } else {
            let headX = x + side * (width / 2 - 2)
            let tailX = x - side * (width / 2 - 2)
            outlinedOval(&canvas, x, y, width, height, design.primary)
            drawSwimmerFins(&canvas, trait: design.trait, x: x, y: y, side: side, scale: scale, color: design.accent)
            drawSwimmerTail(&canvas, trait: design.trait, x: tailX, y: y, side: -side, scale: scale, color: design.accent)
            pixel(&canvas, headX, y - 1, .black)
            if design.trait == "leviathan" {
                line(&canvas, headX, y - height / 2, side, -1, scale.value(3, minimum: 2), design.accent)
            } else if design.trait == "seal" {
                rect(&canvas, headX + side, y + 1, 2, 2, .cream)
            } else if design.trait == "dream_whale" {
                rect(&canvas, x, y - height / 2 - 1, 2, 3, design.accent)
            }
        }
    }

    static func drawSwimmerFins(_ canvas: inout [[PixelColor]], trait: String, x: Int, y: Int, side: Int, scale: Scale, color: PixelColor) {
        if trait == "seal" {
            oval(&canvas, x - (side == 0 ? 4 : side * 2), y + 2, 5, 3, color)
            oval(&canvas, x + (side == 0 ? 4 : -side * 2), y + 2, 5, 3, color)
        } else {
            if side == 0 {
                diamond(&canvas, x - 4, y + 1, scale.value(3, minimum: 2), 2, color)
                diamond(&canvas, x + 4, y + 1, scale.value(3, minimum: 2), 2, color)
            } else {
                line(&canvas, x - side, y, -side, -1, scale.value(4, minimum: 2), color)
            }
        }
    }

    static func drawSwimmerTail(_ canvas: inout [[PixelColor]], trait: String, x: Int, y: Int, side: Int, scale: Scale, color: PixelColor) {
        let direction = side == 0 ? 1 : side
        if trait == "dream_whale" {
            diamond(&canvas, x + direction * 3, y + 2, scale.value(4, minimum: 2), scale.value(3, minimum: 2), color)
        } else if trait == "leviathan" {
            line(&canvas, x + direction * 2, y + 1, direction, 1, scale.value(6, minimum: 3), color)
            line(&canvas, x + direction * 5, y + 4, direction, -1, scale.value(3, minimum: 2), color)
        } else {
            diamond(&canvas, x + direction * 3, y, scale.value(4, minimum: 2), scale.value(3, minimum: 2), color)
        }
    }

    static func drawCephalopod(_ canvas: inout [[PixelColor]], _ design: Design, _ direction: SpriteDirection, _ scale: Scale) {
        let width = scale.value(design.bodyWidth, minimum: 7)
        let height = scale.value(design.bodyHeight, minimum: 4)
        let x = scale.centerX
        let bellY = scale.baseline - scale.value(design.limbLength, minimum: 3) - height / 2
        let side = direction == .sideLeft ? -1 : direction == .sideRight ? 1 : 0

        if design.trait == "jellyfish" {
            outlinedOval(&canvas, x, bellY, width, height, design.primary)
            rect(&canvas, x - width / 2 + 1, bellY, max(4, width - 2), 2, design.accent)
            drawTentacles(&canvas, x: x, y: bellY + height / 2, count: 5, side: side, scale: scale, color: design.accent)
            if direction == .front { animalEyes(&canvas, x: x, y: bellY + 1, separation: 2, color: .black) }
            else if direction == .back { rect(&canvas, x - 3, bellY + 1, 7, 1, .purple) }
            else { pixel(&canvas, x + side * 3, bellY + 1, .black) }
            return
        }

        let headX = side == 0 ? x : x + side * 2
        outlinedOval(&canvas, headX, bellY, width, height, design.primary)
        if direction == .front {
            animalEyes(&canvas, x: headX, y: bellY, separation: max(1, width / 5), color: .black)
        } else if direction == .back {
            rect(&canvas, headX - width / 3, bellY - 1, max(4, width * 2 / 3), 1, design.accent)
        } else {
            pixel(&canvas, headX + side * 2, bellY, .black)
        }
        let count = design.trait == "kraken" ? 6 : 4
        drawTentacles(&canvas, x: headX, y: bellY + height / 2, count: count, side: side, scale: scale, color: design.accent)
        if design.trait == "kraken" {
            line(&canvas, headX - 3, bellY - 2, -1, -1, scale.value(3, minimum: 2), design.accent)
            line(&canvas, headX + 3, bellY - 2, 1, -1, scale.value(3, minimum: 2), design.accent)
        }
    }

    static func drawTentacles(_ canvas: inout [[PixelColor]], x: Int, y: Int, count: Int, side: Int, scale: Scale, color: PixelColor) {
        let spread = max(2, count)
        for index in 0..<count {
            let offset = index - count / 2
            let horizontal = side == 0 ? (offset < 0 ? -1 : 1) : (index.isMultiple(of: 2) ? -side : side)
            let length = scale.value(3 + abs(offset % 2), minimum: 2)
            let startX = x + offset * 2
            line(&canvas, startX, y, horizontal, 1, max(1, length - 1), color)
            let tipX = startX + horizontal * max(0, length - 2)
            let tipY = y + max(1, length - 1)
            // The capped tip turns a straight scratch into a soft, connected
            // tentacle without changing the creature's tentacle count.
            oval(&canvas, tipX, tipY, 2, 2, color)
        }
        rect(&canvas, x - spread / 2, y, max(2, spread), 1, color)
    }

    // MARK: - Arthropods

    static func drawInsect(_ canvas: inout [[PixelColor]], _ design: Design, _ direction: SpriteDirection, _ scale: Scale) {
        let x = scale.centerX
        let side = direction == .sideLeft ? -1 : direction == .sideRight ? 1 : 0
        let bodyWidth = scale.value(design.bodyWidth, minimum: 5)
        let bodyHeight = scale.value(design.bodyHeight, minimum: 5)
        let y = scale.baseline - bodyHeight / 2 - 3

        switch design.trait {
        case "butterfly", "luna_moth":
            let wingWidth = design.trait == "butterfly" ? 7 : 8
            if side == 0 {
                outlinedOval(&canvas, x, y, bodyWidth, bodyHeight, design.primary)
                outlinedDiamond(&canvas, x - 5, y, scale.value(wingWidth, minimum: 3), scale.value(6, minimum: 3), design.accent)
                outlinedDiamond(&canvas, x + 5, y, scale.value(wingWidth, minimum: 3), scale.value(6, minimum: 3), design.accent)
                line(&canvas, x - 1, y - bodyHeight / 2, -1, -1, scale.value(3, minimum: 2), .black)
                line(&canvas, x + 1, y - bodyHeight / 2, 1, -1, scale.value(3, minimum: 2), .black)
                if direction == .front { animalEyes(&canvas, x: x, y: y - bodyHeight / 3, separation: 1, color: .white) }
                else { rect(&canvas, x - 1, y - 2, 3, 6, .darkGray) }
            } else {
                outlinedOval(&canvas, x, y, bodyWidth + 2, max(4, bodyHeight - 2), design.primary)
                outlinedDiamond(&canvas, x - side * 2, y, scale.value(wingWidth, minimum: 3), scale.value(4, minimum: 2), design.accent)
                line(&canvas, x - side * 3, y + 2, -side, 1, scale.value(4, minimum: 2), design.accent)
                pixel(&canvas, x + side * 3, y - 2, .white)
            }
        case "atlas_beetle":
            if side == 0 {
                outlinedOval(&canvas, x, y, bodyWidth, bodyHeight, design.primary)
                rect(&canvas, x - 1, y - bodyHeight / 2 + 1, 3, bodyHeight - 1, design.accent)
                line(&canvas, x, y - bodyHeight / 2, 0, -1, scale.value(5, minimum: 3), design.accent)
                drawInsectLegs(&canvas, x: x, y: y + bodyHeight / 3, side: 0, scale: scale, color: .black)
                if direction == .front {
                    animalEyes(&canvas, x: x, y: y - bodyHeight / 3, separation: 1, color: .white)
                } else {
                    rect(&canvas, x - 3, y - 1, 7, 1, .darkBlue)
                    line(&canvas, x - 2, y + 2, 1, 0, 5, .black)
                }
            } else {
                outlinedOval(&canvas, x, y, bodyWidth + 3, max(5, bodyHeight - 3), design.primary)
                line(&canvas, x + side * (bodyWidth / 2), y - 1, side, -1, scale.value(5, minimum: 3), design.accent)
                drawInsectLegs(&canvas, x: x, y: y + 1, side: side, scale: scale, color: .black)
                pixel(&canvas, x + side * (bodyWidth / 2 - 1), y - 2, .white)
            }
        default: // scorpion
            let headX = side == 0 ? x : x + side * 5
            outlinedOval(&canvas, x, y, bodyWidth, bodyHeight, design.primary)
            outlinedOval(&canvas, headX, y - 1, 5, 4, design.primary)
            drawInsectLegs(&canvas, x: x, y: y + 2, side: side, scale: scale, color: .black)
            if side == 0 {
                diamond(&canvas, x - 6, y, 3, 2, design.accent)
                diamond(&canvas, x + 6, y, 3, 2, design.accent)
                if direction == .front {
                    animalEyes(&canvas, x: x, y: y - 1, separation: 1, color: .black)
                } else {
                    rect(&canvas, x - 2, y - 2, 5, 1, .darkRed)
                    line(&canvas, x - 3, y + 1, 1, 0, 7, .darkRed)
                }
                line(&canvas, x + 3, y + 2, 1, -1, scale.value(6, minimum: 3), design.accent)
            } else {
                diamond(&canvas, headX + side * 3, y, 3, 2, design.accent)
                pixel(&canvas, headX + side, y - 1, .black)
                line(&canvas, x - side * 5, y + 1, -side, -1, scale.value(6, minimum: 3), design.accent)
            }
        }
    }

    static func drawInsectLegs(_ canvas: inout [[PixelColor]], x: Int, y: Int, side: Int, scale: Scale, color: PixelColor) {
        for offset in [-3, 0, 3] {
            let direction = side == 0 ? (offset < 0 ? -1 : 1) : -side
            line(&canvas, x + offset, y, direction, 1, scale.value(3, minimum: 2), color)
        }
    }
}

private extension SpeciesAnatomySprites {
    // MARK: - Humanoids and constructs with limbs

    static func drawHumanoid(_ canvas: inout [[PixelColor]], _ design: Design, _ direction: SpriteDirection, _ scale: Scale) {
        let x = scale.centerX
        let side = direction == .sideLeft ? -1 : direction == .sideRight ? 1 : 0
        let naturalTorsoWidth = scale.value(design.bodyWidth, minimum: 5)
        let naturalTorsoHeight = scale.value(design.bodyHeight, minimum: 6)
        let headWidth = scale.value(design.headWidth, minimum: 4)
        let headHeight = scale.value(design.headHeight, minimum: 4)
        let legs = scale.value(design.limbLength, minimum: 2)
        let torso = humanoidTorsoMetrics(
            for: design,
            naturalWidth: naturalTorsoWidth,
            naturalHeight: naturalTorsoHeight,
            headWidth: headWidth,
            headHeight: headHeight
        )
        let torsoWidth = torso.width
        let torsoHeight = torso.height
        let torsoTop = scale.baseline - legs - torsoHeight
        let headY = torsoTop - headHeight / 2 - 1
        let softTorso = design.trait != "golem" && design.trait != "titan"

        if side == 0 {
            if ["fairy", "celestial", "seraph"].contains(design.trait) {
                // Wings sit behind the balanced torso so these remain
                // human-like companions rather than a large wing silhouette
                // with a tiny pasted-on face.
                drawHumanoidWings(&canvas, trait: design.trait, x: x, y: torsoTop + 2, side: 0, scale: scale, color: design.accent)
            }
            if softTorso {
                outlinedOval(&canvas, x, torsoTop + torsoHeight / 2, torsoWidth, torsoHeight, design.primary)
            } else {
                rect(&canvas, x - torsoWidth / 2 - 1, torsoTop - 1, torsoWidth + 2, torsoHeight + 2, softOutline(for: design.primary))
                rect(&canvas, x - torsoWidth / 2, torsoTop, torsoWidth, torsoHeight, design.primary)
            }
            outlinedOval(&canvas, x, headY, headWidth, headHeight, design.primary)
            drawHumanoidArms(&canvas, trait: design.trait, x: x, y: torsoTop + 2, side: 0, scale: scale, color: design.accent)
            drawHumanoidLegs(&canvas, x: x, y: torsoTop + torsoHeight, length: legs, direction: direction, color: design.primary)
            if direction == .front {
                drawHumanoidFace(&canvas, trait: design.trait, x: x, y: headY, scale: scale, color: design.accent)
            } else {
                drawHumanoidBack(&canvas, trait: design.trait, x: x, y: torsoTop, width: torsoWidth, height: torsoHeight, scale: scale, color: design.accent)
            }
        } else {
            let profileX = x + side * 2
            if softTorso {
                outlinedOval(&canvas, profileX, torsoTop + torsoHeight / 2, torsoWidth, torsoHeight, design.primary)
            } else {
                rect(&canvas, profileX - torsoWidth / 2 - 1, torsoTop - 1, torsoWidth + 2, torsoHeight + 2, softOutline(for: design.primary))
                rect(&canvas, profileX - torsoWidth / 2, torsoTop, torsoWidth, torsoHeight, design.primary)
            }
            outlinedOval(&canvas, profileX + side, headY, headWidth, headHeight, design.primary)
            drawHumanoidArms(&canvas, trait: design.trait, x: profileX, y: torsoTop + 2, side: side, scale: scale, color: design.accent)
            drawHumanoidLegs(&canvas, x: profileX, y: torsoTop + torsoHeight, length: legs, direction: direction, color: design.primary)
            pixel(&canvas, profileX + side * (headWidth / 3 + 1), headY, .black)
            drawHumanoidProfile(&canvas, trait: design.trait, x: profileX, y: torsoTop, side: side, scale: scale, color: design.accent)
        }
    }

    static func humanoidTorsoMetrics(
        for design: Design,
        naturalWidth: Int,
        naturalHeight: Int,
        headWidth: Int,
        headHeight: Int
    ) -> (width: Int, height: Int) {
        let allowance = design.trait == "golem" || design.trait == "titan" ? 3 : 1
        return (
            max(headWidth, min(naturalWidth, headWidth + allowance)),
            max(headHeight, min(naturalHeight, headHeight + allowance))
        )
    }

    static func drawHumanoidArms(_ canvas: inout [[PixelColor]], trait: String, x: Int, y: Int, side: Int, scale: Scale, color: PixelColor) {
        let reach = trait == "titan" || trait == "golem" ? 5 : 3
        if side == 0 {
            line(&canvas, x - 3, y, -1, 1, scale.value(reach, minimum: 2), color)
            line(&canvas, x + 3, y, 1, 1, scale.value(reach, minimum: 2), color)
            oval(&canvas, x - 3 - scale.value(reach, minimum: 2), y + scale.value(reach, minimum: 2), 3, 2, color)
            oval(&canvas, x + 3 + scale.value(reach, minimum: 2), y + scale.value(reach, minimum: 2), 3, 2, color)
        } else {
            line(&canvas, x + side * 2, y, side, 1, scale.value(reach, minimum: 2), color)
            line(&canvas, x - side * 2, y + 1, -side, 1, scale.value(max(2, reach - 1), minimum: 1), color)
            oval(&canvas, x + side * (2 + scale.value(reach, minimum: 2)), y + scale.value(reach, minimum: 2), 3, 2, color)
        }
        if trait == "ninja" {
            line(&canvas, x + (side == 0 ? 4 : side * 4), y, side == 0 ? 1 : side, 0, scale.value(4, minimum: 2), color)
        }
    }

    static func drawHumanoidLegs(_ canvas: inout [[PixelColor]], x: Int, y: Int, length: Int, direction: SpriteDirection, color: PixelColor) {
        let step = direction == .sideLeft ? -1 : direction == .sideRight ? 1 : 0
        rect(&canvas, x - 3, y, 2, length, color)
        rect(&canvas, x + 2, y + (step < 0 ? -1 : 0), 2, max(1, length + (step > 0 ? -1 : 0)), color)
        oval(&canvas, x - 2, y + length - 1, 4, 2, color)
        oval(&canvas, x + 3, y + length - 1, 4, 2, color)
    }

    static func drawHumanoidFace(_ canvas: inout [[PixelColor]], trait: String, x: Int, y: Int, scale: Scale, color: PixelColor) {
        switch trait {
        case "android", "robot":
            rect(&canvas, x - 3, y - 1, 7, 3, .black)
            pixel(&canvas, x - 2, y, color)
            pixel(&canvas, x + 2, y, color)
            if trait == "robot" { line(&canvas, x, y - 4, 0, -1, scale.value(3, minimum: 2), color) }
        case "ninja":
            rect(&canvas, x - 4, y - 1, 9, 2, .black)
            pixel(&canvas, x - 2, y, .white)
            pixel(&canvas, x + 2, y, .white)
            rect(&canvas, x - 5, y - 2, 11, 1, color)
        case "titan":
            animalEyes(&canvas, x: x, y: y, separation: 2, color: .gold)
            rect(&canvas, x - 3, y + 2, 7, 1, color)
        case "fairy", "celestial", "seraph":
            animalEyes(&canvas, x: x, y: y, separation: 2, color: .black)
            if trait == "celestial" || trait == "seraph" {
                line(&canvas, x - 4, y - 5, 1, 0, 9, .gold)
            }
        case "void_runner":
            rect(&canvas, x - 3, y - 1, 7, 2, .black)
            pixel(&canvas, x, y, color)
        default:
            animalEyes(&canvas, x: x, y: y, separation: 1, color: .black)
        }
    }

    static func drawHumanoidBack(_ canvas: inout [[PixelColor]], trait: String, x: Int, y: Int, width: Int, height: Int, scale: Scale, color: PixelColor) {
        switch trait {
        case "fairy", "celestial", "seraph":
            drawHumanoidWings(&canvas, trait: trait, x: x, y: y + 2, side: 0, scale: scale, color: color)
            rect(&canvas, x - 1, y, 3, height, color)
        case "ninja", "void_runner":
            rect(&canvas, x - width / 3, y, max(4, width * 2 / 3), height, .black)
            line(&canvas, x + width / 3, y + 2, 1, 0, scale.value(4, minimum: 2), color)
        case "android", "robot":
            rect(&canvas, x - 3, y + 2, 7, 3, .darkGray)
            rect(&canvas, x - 1, y + 6, 3, 3, color)
        case "golem", "titan":
            rect(&canvas, x - width / 3, y + 2, max(5, width * 2 / 3), 2, .darkGray)
            rect(&canvas, x - 1, y + 5, 3, height - 4, color)
        default:
            rect(&canvas, x - 2, y + 2, 5, 1, color)
        }
    }

    static func drawHumanoidProfile(_ canvas: inout [[PixelColor]], trait: String, x: Int, y: Int, side: Int, scale: Scale, color: PixelColor) {
        switch trait {
        case "fairy", "celestial", "seraph":
            drawHumanoidWings(&canvas, trait: trait, x: x, y: y + 2, side: side, scale: scale, color: color)
        case "ninja":
            line(&canvas, x - side * 3, y + 1, -side, 0, scale.value(5, minimum: 2), color)
        case "void_runner":
            line(&canvas, x - side * 3, y + 1, -side, 1, scale.value(6, minimum: 3), color)
        case "android", "robot":
            rect(&canvas, x - side * 2, y + 3, 2, 4, color)
        case "golem", "titan":
            rect(&canvas, x - side * 3, y + 3, 3, 5, color)
        default: break
        }
    }

    static func drawHumanoidWings(_ canvas: inout [[PixelColor]], trait: String, x: Int, y: Int, side: Int, scale: Scale, color: PixelColor) {
        let wingWidth: Int
        let wingHeight: Int
        switch trait {
        case "fairy":
            wingWidth = scale.value(4, minimum: 3)
            wingHeight = scale.value(5, minimum: 3)
        case "celestial":
            wingWidth = scale.value(5, minimum: 3)
            wingHeight = scale.value(7, minimum: 4)
        default: // seraph
            wingWidth = scale.value(7, minimum: 4)
            wingHeight = scale.value(8, minimum: 4)
        }

        if side == 0 {
            for sign in [-1, 1] {
                let offset = 3 + wingWidth / 3
                outlinedOval(&canvas, x + sign * offset, y + 1, wingWidth, wingHeight, color)
                line(&canvas, x + sign * offset, y + 1, sign, 1, max(2, wingHeight - 2), softOutline(for: color))
            }
        } else {
            outlinedOval(&canvas, x - side * 3, y + 1, wingWidth, wingHeight, color)
            line(&canvas, x - side * 3, y + 1, -side, 1, max(2, wingHeight - 2), softOutline(for: color))
        }
    }

    // MARK: - Objects, architecture and relics

    static func drawObject(_ canvas: inout [[PixelColor]], _ design: Design, _ direction: SpriteDirection, _ scale: Scale) {
        let x = scale.centerX
        let side = direction == .sideLeft ? -1 : direction == .sideRight ? 1 : 0
        let height = scale.value(design.bodyHeight, minimum: 6)
        let y = scale.baseline - height / 2 - 2

        switch design.trait {
        case "crystal":
            drawCrystal(&canvas, x: x, y: scale.baseline, direction: direction, side: side, scale: scale, primary: design.primary, accent: design.accent)
        case "rock":
            drawRock(&canvas, x: x, y: y + 2, direction: direction, side: side, scale: scale, primary: design.primary, accent: design.accent)
        case "clockwork":
            drawClockwork(&canvas, x: x, y: y, direction: direction, scale: scale, primary: design.primary, accent: design.accent)
        case "orb":
            drawOrb(&canvas, x: x, y: y, direction: direction, scale: scale, primary: design.primary, accent: design.accent)
        case "singularity":
            drawSingularity(&canvas, x: x, y: y, direction: direction, scale: scale, primary: design.primary, accent: design.accent)
        case "teapot":
            drawTeapot(&canvas, x: x, y: y, direction: direction, side: side, scale: scale, primary: design.primary, accent: design.accent)
        case "lantern":
            drawLantern(&canvas, x: x, y: y, direction: direction, scale: scale, primary: design.primary, accent: design.accent)
        default: // bastion
            drawBastion(&canvas, x: x, y: y, direction: direction, scale: scale, primary: design.primary, accent: design.accent)
        }
    }

    static func drawCrystal(_ canvas: inout [[PixelColor]], x: Int, y: Int, direction: SpriteDirection, side: Int, scale: Scale, primary: PixelColor, accent: PixelColor) {
        let h = scale.value(15, minimum: 8)
        outlinedDiamond(&canvas, x, y - h / 2, scale.value(5, minimum: 3), h / 2, primary)
        outlinedDiamond(&canvas, x - 5, y - h / 3, scale.value(3, minimum: 2), scale.value(6, minimum: 3), accent)
        outlinedDiamond(&canvas, x + 5, y - h / 4, scale.value(3, minimum: 2), scale.value(5, minimum: 3), accent)
        switch direction {
        case .front:
            line(&canvas, x - 1, y - h + 2, 1, 1, scale.value(7, minimum: 3), .white)
        case .back:
            line(&canvas, x + 1, y - h + 2, -1, 1, scale.value(7, minimum: 3), .darkBlue)
            rect(&canvas, x - 2, y - h / 2, 5, 1, accent)
        case .sideLeft, .sideRight:
            line(&canvas, x + side, y - h + 2, side, 1, scale.value(6, minimum: 3), .white)
        }
    }

    static func drawRock(_ canvas: inout [[PixelColor]], x: Int, y: Int, direction: SpriteDirection, side: Int, scale: Scale, primary: PixelColor, accent: PixelColor) {
        let w = scale.value(15, minimum: 8)
        let h = scale.value(9, minimum: 5)
        outlinedDiamond(&canvas, x - (side == 0 ? 0 : side), y, w / 2, h / 2, primary)
        diamond(&canvas, x - 3, y - 1, 3, 2, accent)
        switch direction {
        case .front:
            line(&canvas, x + 2, y - h / 3, 1, 1, scale.value(4, minimum: 2), .black)
        case .back:
            line(&canvas, x - 2, y - h / 3, -1, 1, scale.value(4, minimum: 2), .darkGray)
            rect(&canvas, x - 4, y + 1, 7, 1, accent)
        case .sideLeft, .sideRight:
            line(&canvas, x + 2, y - h / 3, side, 1, scale.value(4, minimum: 2), .black)
        }
        line(&canvas, x - 4, y + 1, 1, 0, scale.value(3, minimum: 2), accent)
    }

    static func drawClockwork(_ canvas: inout [[PixelColor]], x: Int, y: Int, direction: SpriteDirection, scale: Scale, primary: PixelColor, accent: PixelColor) {
        let radius = scale.value(5, minimum: 3)
        outlinedOval(&canvas, x, y, radius * 2, radius * 2, primary)
        for offset in [-radius, 0, radius] {
            rect(&canvas, x + offset - 1, y - radius - 1, 3, 2, accent)
            rect(&canvas, x + offset - 1, y + radius, 3, 2, accent)
        }
        rect(&canvas, x - radius - 1, y - 1, 2, 3, accent)
        rect(&canvas, x + radius, y - 1, 2, 3, accent)
        if direction == .front { animalEyes(&canvas, x: x, y: y, separation: 2, color: .darkBrown) }
        else if direction == .back { rect(&canvas, x - 2, y - 2, 5, 5, .darkBrown) }
        else { pixel(&canvas, x + (direction == .sideLeft ? -2 : 2), y, .darkBrown) }
    }

    static func drawOrb(_ canvas: inout [[PixelColor]], x: Int, y: Int, direction: SpriteDirection, scale: Scale, primary: PixelColor, accent: PixelColor) {
        let radius = scale.value(6, minimum: 4)
        outlinedOval(&canvas, x, y, radius * 2, radius * 2, primary)
        outlinedOval(&canvas, x, y, radius + 1, radius + 1, .darkBlue)
        if direction == .front {
            rect(&canvas, x - 1, y - 2, 3, 5, accent)
        } else if direction == .back {
            line(&canvas, x - radius, y, 1, 0, radius * 2 + 1, accent)
        } else {
            line(&canvas, x, y - radius, direction == .sideLeft ? -1 : 1, 1, radius + 2, accent)
        }
    }

    static func drawSingularity(_ canvas: inout [[PixelColor]], x: Int, y: Int, direction: SpriteDirection, scale: Scale, primary: PixelColor, accent: PixelColor) {
        let radius = scale.value(7, minimum: 4)
        outlinedDiamond(&canvas, x, y, radius, radius, primary)
        outlinedDiamond(&canvas, x, y, max(2, radius - 3), max(2, radius - 3), .purple)
        if direction == .front {
            line(&canvas, x - radius, y - radius, 1, 1, radius * 2, accent)
        } else if direction == .back {
            line(&canvas, x + radius, y - radius, -1, 1, radius * 2, accent)
        } else {
            let sign = direction == .sideLeft ? -1 : 1
            line(&canvas, x, y - radius, sign, 0, radius, accent)
            line(&canvas, x + sign * radius, y - radius, 0, 1, radius * 2, accent)
        }
    }

    static func drawTeapot(_ canvas: inout [[PixelColor]], x: Int, y: Int, direction: SpriteDirection, side: Int, scale: Scale, primary: PixelColor, accent: PixelColor) {
        let width = scale.value(12, minimum: 7)
        let height = scale.value(8, minimum: 5)
        outlinedOval(&canvas, x, y, width, height, primary)
        // The lid, knob, handle and short spout are deliberately separate
        // exterior parts so the pet reads as a teapot, not a round bug with
        // two symmetrical antennae.
        outlinedOval(&canvas, x, y - height / 2 - 2, 7, 2, accent)
        oval(&canvas, x, y - height / 2 - 4, 3, 2, accent)
        if side == 0 {
            let handleX = x - width / 2 - 2
            outlinedOval(&canvas, handleX, y + 1, 5, 7, primary)
            oval(&canvas, handleX, y + 1, 2, 3, .clear)
            line(&canvas, x - width / 2, y + 1, -1, 0, 3, primary)
            line(&canvas, x + width / 2 - 1, y - 1, 1, -1, scale.value(4, minimum: 2), primary)
            oval(&canvas, x + width / 2 + 3, y - 4, 4, 3, accent)
            if direction == .front {
                animalEyes(&canvas, x: x, y: y, separation: 2, color: .cream)
            } else {
                rect(&canvas, x - 3, y - 1, 7, 2, .darkBlue)
                rect(&canvas, x - 1, y + 2, 3, 2, accent)
            }
        } else {
            line(&canvas, x + side * (width / 2 - 1), y - 1, side, -1, scale.value(5, minimum: 3), primary)
            oval(&canvas, x + side * (width / 2 + 3), y - 4, 4, 3, accent)
            outlinedOval(&canvas, x - side * (width / 2 - 1), y + 1, 4, 6, primary)
            oval(&canvas, x - side * (width / 2 - 1), y + 1, 2, 2, .clear)
            pixel(&canvas, x + side * 2, y, .cream)
        }
    }

    static func drawLantern(_ canvas: inout [[PixelColor]], x: Int, y: Int, direction: SpriteDirection, scale: Scale, primary: PixelColor, accent: PixelColor) {
        let width = scale.value(8, minimum: 5)
        let height = scale.value(12, minimum: 7)
        rect(&canvas, x - width / 2 - 1, y - height / 2 - 1, width + 2, height + 2, softOutline(for: primary))
        rect(&canvas, x - width / 2, y - height / 2, width, height, primary)
        rect(&canvas, x - 2, y - height / 2 - 4, 5, 3, accent)
        rect(&canvas, x - width / 2 - 2, y - height / 2 - 5, width + 4, 2, .brown)
        rect(&canvas, x - 2, y - 2, 4, 5, accent)
        if direction == .back { rect(&canvas, x - 3, y - 1, 7, 2, .brown) }
        if direction == .sideLeft { line(&canvas, x - 2, y, -1, 0, 3, .cream) }
        if direction == .sideRight { line(&canvas, x + 2, y, 1, 0, 3, .cream) }
    }

    static func drawBastion(_ canvas: inout [[PixelColor]], x: Int, y: Int, direction: SpriteDirection, scale: Scale, primary: PixelColor, accent: PixelColor) {
        let width = scale.value(16, minimum: 9)
        let height = scale.value(11, minimum: 6)
        rect(&canvas, x - width / 2, y - height / 2, width, height, primary)
        rect(&canvas, x - width / 2 - 1, y - height / 2 - 1, width + 2, 2, softOutline(for: primary))
        for offset in stride(from: -width / 2, through: width / 2 - 2, by: 4) {
            rect(&canvas, x + offset, y - height / 2 - 3, 3, 3, primary)
        }
        switch direction {
        case .front:
            rect(&canvas, x - 2, y + 1, 5, height / 2, .darkGray)
            rect(&canvas, x - width / 3, y - 1, 3, 2, accent)
            rect(&canvas, x + width / 3 - 2, y - 1, 3, 2, accent)
        case .back:
            rect(&canvas, x - width / 3, y, width * 2 / 3, 2, .darkGray)
        case .sideLeft, .sideRight:
            let side = direction == .sideLeft ? -1 : 1
            rect(&canvas, x + side * (width / 2 - 2), y - 2, 3, 5, accent)
            line(&canvas, x - side * (width / 2), y + 2, -side, 0, 3, .darkGray)
        }
    }
}

private extension SpeciesAnatomySprites {
    // MARK: - Plants, fruit and fungi

    static func drawPlant(_ canvas: inout [[PixelColor]], _ design: Design, _ direction: SpriteDirection, _ scale: Scale) {
        let x = scale.centerX
        let side = direction == .sideLeft ? -1 : direction == .sideRight ? 1 : 0
        switch design.trait {
        case "lotus":
            drawLotus(&canvas, x: x, direction: direction, scale: scale, primary: design.primary, accent: design.accent)
        case "mushroom":
            drawMushroom(&canvas, x: x, direction: direction, scale: scale, primary: design.primary, accent: design.accent)
        case "cactus":
            drawCactus(&canvas, x: x, direction: direction, scale: scale, primary: design.primary, accent: design.accent)
        case "peach":
            drawPeach(&canvas, x: x, direction: direction, scale: scale, primary: design.primary, accent: design.accent)
        case "moonflower":
            drawMoonflower(&canvas, x: x, direction: direction, scale: scale, primary: design.primary, accent: design.accent)
        case "acorn":
            drawAcorn(&canvas, x: x, direction: direction, scale: scale, primary: design.primary, accent: design.accent)
        default:
            drawWorldTree(&canvas, x: x, side: side, direction: direction, scale: scale, primary: design.primary, accent: design.accent)
        }
    }

    static func drawLotus(_ canvas: inout [[PixelColor]], x: Int, direction: SpriteDirection, scale: Scale, primary: PixelColor, accent: PixelColor) {
        let y = scale.baseline - scale.value(8, minimum: 5)
        let side = direction == .sideLeft ? -1 : direction == .sideRight ? 1 : 0
        // Petals are the entire body: the stem only supports them.
        for offset in [-5, -2, 2, 5] {
            diamond(&canvas, x + offset, y + abs(offset) / 3, scale.value(3, minimum: 2), scale.value(4, minimum: 2), primary)
        }
        outlinedDiamond(&canvas, x, y - 1, scale.value(4, minimum: 2), scale.value(4, minimum: 2), primary)
        diamond(&canvas, x, y - 1, scale.value(2, minimum: 1), scale.value(2, minimum: 1), accent)
        rect(&canvas, x - 1, y + 3, 3, scale.value(7, minimum: 3), .darkGreen)
        if direction == .front {
            animalEyes(&canvas, x: x, y: y, separation: 1, color: .black)
        } else if direction == .back {
            rect(&canvas, x - 4, y + 1, 9, 1, accent)
        } else {
            pixel(&canvas, x + side * 3, y, .black)
            diamond(&canvas, x - side * 4, y + 1, 3, 2, accent)
        }
    }

    static func drawMushroom(_ canvas: inout [[PixelColor]], x: Int, direction: SpriteDirection, scale: Scale, primary: PixelColor, accent: PixelColor) {
        let capWidth = scale.value(14, minimum: 7)
        let capHeight = scale.value(6, minimum: 3)
        let stemHeight = scale.value(7, minimum: 4)
        let capY = scale.baseline - stemHeight - capHeight / 2
        outlinedOval(&canvas, x, capY, capWidth, capHeight, primary)
        rect(&canvas, x - 3, capY + capHeight / 3, 7, stemHeight, accent)
        if direction == .front {
            diamond(&canvas, x - 4, capY - 1, 2, 1, .cream)
            diamond(&canvas, x + 4, capY - 1, 2, 1, .cream)
            animalEyes(&canvas, x: x, y: capY + 2, separation: 1, color: .black)
        } else if direction == .back {
            rect(&canvas, x - capWidth / 3, capY, capWidth * 2 / 3, 2, .darkRed)
        } else {
            let side = direction == .sideLeft ? -1 : 1
            line(&canvas, x - side * 2, capY - 1, -side, 0, scale.value(4, minimum: 2), primary)
            pixel(&canvas, x + side * 2, capY + 2, .black)
        }
    }

    static func drawCactus(_ canvas: inout [[PixelColor]], x: Int, direction: SpriteDirection, scale: Scale, primary: PixelColor, accent: PixelColor) {
        let height = scale.value(16, minimum: 8)
        let top = scale.baseline - height
        let side = direction == .sideLeft ? -1 : direction == .sideRight ? 1 : 0
        // A cactus is tall by nature, but its body and raised arms need soft
        // caps so it reads as a plant companion rather than a phone-shaped
        // green rectangle.
        outlinedOval(&canvas, x, top + height / 2, 7, height, primary)
        outlinedOval(&canvas, x - 5, top + height / 2 + 1, 5, 4, primary)
        outlinedOval(&canvas, x + 5, top + height / 3 + 1, 5, 4, primary)
        oval(&canvas, x - 7, top + height / 2 - 1, 3, 5, primary)
        oval(&canvas, x + 7, top + height / 3 - 1, 3, 5, primary)
        for row in stride(from: top + 2, to: top + height - 1, by: 3) {
            pixel(&canvas, x - 2, row, accent)
            pixel(&canvas, x + 2, row + 1, accent)
        }
        if direction == .front {
            animalEyes(&canvas, x: x, y: top + height / 2, separation: 1, color: .black)
        } else if direction == .back {
            rect(&canvas, x - 1, top + 2, 3, height - 4, .darkGreen)
        } else {
            pixel(&canvas, x + side * 3, top + height / 2, .black)
            line(&canvas, x - side * 4, top + height / 2, -side, -1, scale.value(3, minimum: 2), accent)
        }
    }

    static func drawPeach(_ canvas: inout [[PixelColor]], x: Int, direction: SpriteDirection, scale: Scale, primary: PixelColor, accent: PixelColor) {
        let radius = scale.value(5, minimum: 3)
        let y = scale.baseline - radius - 2
        outlinedOval(&canvas, x, y, radius * 2, radius * 2 + 2, primary)
        line(&canvas, x, y - radius, 0, -1, scale.value(3, minimum: 2), .brown)
        diamond(&canvas, x + 3, y - radius - 1, 3, 2, accent)
        switch direction {
        case .front:
            line(&canvas, x, y - 2, 0, 1, radius * 2 + 1, .pink)
            animalEyes(&canvas, x: x, y: y, separation: 2, color: .black)
        case .back:
            line(&canvas, x, y - radius + 1, 0, 1, radius * 2, .pink)
        case .sideLeft:
            pixel(&canvas, x - 2, y, .black)
            line(&canvas, x - 1, y - 2, -1, 1, scale.value(4, minimum: 2), .pink)
        case .sideRight:
            pixel(&canvas, x + 2, y, .black)
            line(&canvas, x + 1, y - 2, 1, 1, scale.value(4, minimum: 2), .pink)
        }
    }

    static func drawMoonflower(_ canvas: inout [[PixelColor]], x: Int, direction: SpriteDirection, scale: Scale, primary: PixelColor, accent: PixelColor) {
        let y = scale.baseline - scale.value(10, minimum: 6)
        let side = direction == .sideLeft ? -1 : direction == .sideRight ? 1 : 0
        for offset in [-5, -2, 2, 5] {
            diamond(&canvas, x + offset, y + abs(offset) / 3, scale.value(4, minimum: 2), scale.value(5, minimum: 3), primary)
        }
        outlinedDiamond(&canvas, x, y, scale.value(4, minimum: 2), scale.value(4, minimum: 2), accent)
        rect(&canvas, x - 1, y + 4, 3, scale.value(8, minimum: 3), .darkGreen)
        if direction == .front {
            animalEyes(&canvas, x: x, y: y, separation: 1, color: .gold)
        } else if direction == .back {
            rect(&canvas, x - 4, y + 1, 9, 1, .purple)
        } else {
            pixel(&canvas, x + side * 2, y, .gold)
            diamond(&canvas, x - side * 4, y + 1, 3, 3, .purple)
        }
    }

    static func drawAcorn(_ canvas: inout [[PixelColor]], x: Int, direction: SpriteDirection, scale: Scale, primary: PixelColor, accent: PixelColor) {
        let y = scale.baseline - scale.value(7, minimum: 5)
        let body = scale.value(6, minimum: 4)
        outlinedOval(&canvas, x, y, body, body + 4, primary)
        rect(&canvas, x - body / 2, y - body / 2 - 1, body + 1, 3, accent)
        line(&canvas, x, y - body / 2 - 2, direction == .sideLeft ? -1 : 1, -1, scale.value(3, minimum: 2), .darkGreen)
        switch direction {
        case .front: animalEyes(&canvas, x: x, y: y + 1, separation: 1, color: .black)
        case .back: rect(&canvas, x - 2, y, 5, 1, .darkBrown)
        case .sideLeft: pixel(&canvas, x - 2, y + 1, .black)
        case .sideRight: pixel(&canvas, x + 2, y + 1, .black)
        }
    }

    static func drawWorldTree(_ canvas: inout [[PixelColor]], x: Int, side: Int, direction: SpriteDirection, scale: Scale, primary: PixelColor, accent: PixelColor) {
        let height = scale.value(18, minimum: 10)
        let top = scale.baseline - height
        rect(&canvas, x - 2, top + height / 2, 5, height / 2, accent)
        line(&canvas, x - 1, top + height - 2, -1, 1, 3, accent)
        line(&canvas, x + 1, top + height - 2, 1, 1, 3, accent)
        outlinedOval(&canvas, x - 5, top + height / 3, 9, 8, primary)
        outlinedOval(&canvas, x + 5, top + height / 3, 9, 8, primary)
        outlinedOval(&canvas, x, top + 1, 10, 8, .lime)
        if direction == .front {
            animalEyes(&canvas, x: x, y: top + height / 3, separation: 2, color: .black)
        } else if direction == .back {
            rect(&canvas, x - 1, top + 3, 3, height / 2, .darkGreen)
        } else {
            pixel(&canvas, x + side * 3, top + height / 3, .black)
            line(&canvas, x - side * 4, top + height / 2, -side, -1, scale.value(5, minimum: 2), accent)
        }
    }

    // MARK: - Elements and cosmic phenomena

    static func drawElemental(_ canvas: inout [[PixelColor]], _ design: Design, _ direction: SpriteDirection, _ scale: Scale) {
        let x = scale.centerX
        switch design.trait {
        case "flame":
            drawFlame(&canvas, x: x, direction: direction, scale: scale, primary: design.primary, accent: design.accent)
        case "lightning":
            drawLightning(&canvas, x: x, direction: direction, scale: scale, primary: design.primary, accent: design.accent)
        case "comet":
            drawComet(&canvas, x: x, direction: direction, scale: scale, primary: design.primary, accent: design.accent)
        case "cloud":
            drawCloud(&canvas, x: x, direction: direction, scale: scale, primary: design.primary, accent: design.accent)
        case "nebula":
            drawNebula(&canvas, x: x, direction: direction, scale: scale, primary: design.primary, accent: design.accent)
        default:
            drawAurora(&canvas, x: x, direction: direction, scale: scale, primary: design.primary, accent: design.accent)
        }
    }

    static func drawFlame(_ canvas: inout [[PixelColor]], x: Int, direction: SpriteDirection, scale: Scale, primary: PixelColor, accent: PixelColor) {
        let height = scale.value(14, minimum: 7)
        let base = scale.baseline
        outlinedDiamond(&canvas, x, base - height / 2, scale.value(5, minimum: 3), height / 2, primary)
        line(&canvas, x - 2, base - 2, -1, -1, scale.value(5, minimum: 3), accent)
        line(&canvas, x + 2, base - 2, 1, -1, scale.value(4, minimum: 2), accent)
        if direction == .front { animalEyes(&canvas, x: x, y: base - height / 2 + 2, separation: 1, color: .black) }
        if direction == .back { line(&canvas, x, base - height + 2, 0, 1, height - 3, .red) }
        if direction == .sideLeft { pixel(&canvas, x - 2, base - height / 2 + 2, .black) }
        if direction == .sideRight { pixel(&canvas, x + 2, base - height / 2 + 2, .black) }
    }

    static func drawLightning(_ canvas: inout [[PixelColor]], x: Int, direction: SpriteDirection, scale: Scale, primary: PixelColor, accent: PixelColor) {
        let top = scale.baseline - scale.value(17, minimum: 9)
        let side = direction == .sideLeft ? -1 : direction == .sideRight ? 1 : 0
        let bias = side == 0 ? 0 : side
        // The bolt is a lively character with a warm electric core, not an
        // isolated UI effect made entirely from diagonal strokes.
        outlinedOval(&canvas, x + bias, top + 6, scale.value(5, minimum: 3), scale.value(5, minimum: 3), primary)
        line(&canvas, x + bias * 2, top + 1, -1 + bias, 1, scale.value(4, minimum: 2), primary)
        line(&canvas, x - 3 + bias * 2, top + 8, 1, 1, scale.value(4, minimum: 2), primary)
        line(&canvas, x + 2 + bias * 2, top + 10, -1, 1, scale.value(4, minimum: 2), primary)
        if direction == .front {
            pixel(&canvas, x - 1, top + 6, .darkBrown)
            pixel(&canvas, x + 1, top + 6, .darkBrown)
        } else if direction == .back {
            line(&canvas, x - 3, top + 6, 1, 0, 6, accent)
        } else {
            pixel(&canvas, x + side * 2, top + 6, .darkBrown)
        }
    }

    static func drawComet(_ canvas: inout [[PixelColor]], x: Int, direction: SpriteDirection, scale: Scale, primary: PixelColor, accent: PixelColor) {
        let y = scale.baseline - scale.value(7, minimum: 4)
        let side = direction == .sideLeft ? -1 : direction == .sideRight ? 1 : 0
        let headX = side == 0 ? x : x + side * 4
        outlinedOval(&canvas, headX, y, scale.value(7, minimum: 4), scale.value(7, minimum: 4), primary)
        let trail = side == 0 ? (direction == .back ? -1 : 1) : -side
        line(&canvas, headX - trail * 3, y + 1, -trail, 1, scale.value(8, minimum: 4), accent)
        line(&canvas, headX - trail * 2, y - 1, -trail, 0, scale.value(6, minimum: 3), accent)
        if direction == .front { animalEyes(&canvas, x: headX, y: y, separation: 1, color: .black) }
        if direction == .back { rect(&canvas, headX - 2, y, 5, 1, accent) }
        if side != 0 { pixel(&canvas, headX + side, y, .black) }
    }

    static func drawCloud(_ canvas: inout [[PixelColor]], x: Int, direction: SpriteDirection, scale: Scale, primary: PixelColor, accent: PixelColor) {
        let y = scale.baseline - scale.value(7, minimum: 4)
        let side = direction == .sideLeft ? -1 : direction == .sideRight ? 1 : 0
        outlinedOval(&canvas, x - 5, y, scale.value(8, minimum: 4), scale.value(6, minimum: 3), primary)
        outlinedOval(&canvas, x + 5, y, scale.value(8, minimum: 4), scale.value(6, minimum: 3), primary)
        outlinedOval(&canvas, x, y - 3, scale.value(9, minimum: 4), scale.value(7, minimum: 3), primary)
        if direction == .front { animalEyes(&canvas, x: x, y: y, separation: 2, color: .darkGray) }
        if direction == .back { rect(&canvas, x - 4, y, 9, 1, accent) }
        if side != 0 { pixel(&canvas, x + side * 4, y, .darkGray) }
    }

    static func drawNebula(_ canvas: inout [[PixelColor]], x: Int, direction: SpriteDirection, scale: Scale, primary: PixelColor, accent: PixelColor) {
        let y = scale.baseline - scale.value(8, minimum: 5)
        let side = direction == .sideLeft ? -1 : direction == .sideRight ? 1 : 0
        // A nebula is a clustered gas cloud, not a single symmetrical badge.
        // Overlapping lobes retain its broad cosmic footprint while breaking
        // the old one-piece diamond silhouette.
        outlinedOval(&canvas, x - 4, y, scale.value(10, minimum: 5), scale.value(7, minimum: 4), primary)
        outlinedOval(&canvas, x + 4, y, scale.value(10, minimum: 5), scale.value(7, minimum: 4), primary)
        oval(&canvas, x, y - 2, scale.value(11, minimum: 6), scale.value(6, minimum: 3), primary)
        line(&canvas, x - 6, y - 2, 1, 0, scale.value(12, minimum: 6), accent)
        line(&canvas, x - 4, y + 2, 1, 0, scale.value(8, minimum: 4), .lavender)
        if direction == .front {
            oval(&canvas, x, y, 3, 3, .white)
        } else if direction == .back {
            oval(&canvas, x, y, 5, 3, .darkBlue)
        } else {
            oval(&canvas, x + side * 4, y, 3, 3, .white)
            line(&canvas, x - side * 3, y + 2, -side, 1, scale.value(3, minimum: 2), accent)
        }
    }

    static func drawAurora(_ canvas: inout [[PixelColor]], x: Int, direction: SpriteDirection, scale: Scale, primary: PixelColor, accent: PixelColor) {
        let top = scale.baseline - scale.value(15, minimum: 8)
        let side = direction == .sideLeft ? -1 : direction == .sideRight ? 1 : 0
        for offset in [-4, 0, 4] {
            line(&canvas, x + offset, top + 2, side == 0 ? 1 : side, 1, scale.value(9, minimum: 4), primary)
            line(&canvas, x + offset + 1, top + 1, side == 0 ? 1 : side, 1, scale.value(7, minimum: 3), accent)
        }
        if direction == .front {
            diamond(&canvas, x, top + 7, 2, 2, .white)
        } else if direction == .back {
            line(&canvas, x - 5, top + 7, 1, 0, 11, .darkBlue)
        } else {
            diamond(&canvas, x + side * 3, top + 6, 2, 2, .white)
        }
    }
}

private extension SpeciesAnatomySprites {
    // MARK: - Mythic animals

    static func drawDragon(_ canvas: inout [[PixelColor]], _ design: Design, _ direction: SpriteDirection, _ scale: Scale) {
        let x = scale.centerX
        let side = direction == .sideLeft ? -1 : direction == .sideRight ? 1 : 0
        let naturalBodyWidth = scale.value(design.bodyWidth, minimum: 7)
        let naturalBodyHeight = scale.value(design.bodyHeight, minimum: 4)
        let headWidth = scale.value(design.headWidth, minimum: 4)
        let headHeight = scale.value(design.headHeight, minimum: 3)
        let legs = scale.value(design.limbLength, minimum: 2)
        let body = dragonBodyMetrics(
            for: design,
            naturalWidth: naturalBodyWidth,
            naturalHeight: naturalBodyHeight,
            headWidth: headWidth,
            headHeight: headHeight,
            isProfile: side != 0
        )
        let bodyWidth = body.width
        let bodyHeight = body.height
        let bodyY = scale.baseline - legs - bodyHeight / 2
        let headY = bodyY - bodyHeight / 2 - 3

        if side == 0 {
            // Membrane wings sit behind the body, like a sprite character's
            // cape, instead of covering the chest as two flat orange blocks.
            drawDragonWings(&canvas, trait: design.trait, x: x, y: bodyY - 1, side: 0, scale: scale, color: design.accent)
            outlinedOval(&canvas, x, bodyY, bodyWidth, bodyHeight, design.primary)
            outlinedOval(&canvas, x, headY, headWidth, headHeight, design.primary)
            drawDragonLegs(&canvas, x: x, y: bodyY + bodyHeight / 2, length: legs, color: design.primary)
            drawDragonTail(&canvas, trait: design.trait, x: x, y: bodyY + 1, side: direction == .front ? 1 : -1, scale: scale, color: design.accent)
            if direction == .front {
                if design.trait == "gryphon" {
                    diamond(&canvas, x, headY + 2, 2, 1, .gold)
                    animalEyes(&canvas, x: x, y: headY, separation: 1, color: .black)
                } else {
                    animalEyes(&canvas, x: x, y: headY, separation: 2, color: .black)
                    drawDragonHorns(&canvas, x: x, y: headY - 3, side: 0, scale: scale, color: design.accent)
                }
            } else {
                drawDragonSpine(&canvas, x: x, y: bodyY, side: 0, scale: scale, color: design.accent)
            }
        } else {
            let headX = x + side * (bodyWidth / 2 - 2)
            let tailX = x - side * (bodyWidth / 2 - 2)
            drawDragonWings(&canvas, trait: design.trait, x: x - side, y: bodyY - 1, side: side, scale: scale, color: design.accent)
            outlinedOval(&canvas, x, bodyY, bodyWidth, bodyHeight, design.primary)
            outlinedOval(&canvas, headX, headY + 2, headWidth, headHeight, design.primary)
            drawDragonLegs(&canvas, x: x, y: bodyY + bodyHeight / 2, length: legs, color: design.primary)
            drawDragonTail(&canvas, trait: design.trait, x: tailX, y: bodyY + 1, side: -side, scale: scale, color: design.accent)
            if design.trait == "gryphon" {
                line(&canvas, headX + side * 2, headY + 2, side, 0, scale.value(3, minimum: 2), .gold)
            } else {
                drawDragonHorns(&canvas, x: headX, y: headY - 2, side: side, scale: scale, color: design.accent)
            }
            pixel(&canvas, headX + side, headY + 1, .black)
            drawDragonSpine(&canvas, x: x, y: bodyY, side: side, scale: scale, color: design.accent)
        }
    }

    static func dragonBodyMetrics(
        for design: Design,
        naturalWidth: Int,
        naturalHeight: Int,
        headWidth: Int,
        headHeight: Int,
        isProfile: Bool
    ) -> (width: Int, height: Int) {
        let widthAllowance: Int
        switch design.trait {
        case "chrono_dragon", "wyvern":
            widthAllowance = isProfile ? 5 : 3
        case "gryphon":
            widthAllowance = isProfile ? 4 : 3
        default:
            widthAllowance = isProfile ? 5 : 3
        }
        return (
            max(headWidth + 2, min(naturalWidth, headWidth + widthAllowance)),
            max(headHeight + 1, min(naturalHeight, headHeight + 2))
        )
    }

    static func drawDragonWings(_ canvas: inout [[PixelColor]], trait: String, x: Int, y: Int, side: Int, scale: Scale, color: PixelColor) {
        let span = trait == "gryphon" ? 6 : trait == "wyvern" ? 8 : 7
        if side == 0 {
            for sign in [-1, 1] {
                let wingWidth = scale.value(span, minimum: 3)
                let wingHeight = scale.value(max(4, span - 2), minimum: 2)
                outlinedDiamond(&canvas, x + sign * (3 + wingWidth / 3), y - wingHeight / 2, wingWidth / 2, wingHeight / 2, color)
                pixel(&canvas, x + sign * (3 + wingWidth / 2), y - wingHeight / 2, color)
            }
        } else {
            let wingWidth = scale.value(span, minimum: 3)
            let wingHeight = scale.value(max(4, span - 2), minimum: 2)
            outlinedDiamond(&canvas, x - side * 4, y - wingHeight / 2, wingWidth / 2, wingHeight / 2, color)
            pixel(&canvas, x - side * (4 + wingWidth / 2), y - wingHeight / 2, color)
        }
    }

    static func drawDragonLegs(_ canvas: inout [[PixelColor]], x: Int, y: Int, length: Int, color: PixelColor) {
        rect(&canvas, x - 4, y, 2, length, color)
        rect(&canvas, x + 3, y, 2, max(1, length - 1), color)
        line(&canvas, x - 4, y + length - 1, -1, 0, 2, color)
        line(&canvas, x + 4, y + max(0, length - 2), 1, 0, 2, color)
    }

    static func drawDragonTail(_ canvas: inout [[PixelColor]], trait: String, x: Int, y: Int, side: Int, scale: Scale, color: PixelColor) {
        let direction = side == 0 ? 1 : side
        let length = trait == "wyvern" ? 8 : trait == "chrono_dragon" ? 7 : 6
        line(&canvas, x + direction * 2, y, direction, 1, scale.value(length, minimum: 3), color)
        if trait == "chrono_dragon" {
            outlinedDiamond(&canvas, x + direction * (length + 1), y + scale.value(length, minimum: 3), 2, 2, .gold)
        } else {
            diamond(&canvas, x + direction * (length + 1), y + scale.value(length, minimum: 3), 3, 2, color)
        }
    }

    static func drawDragonHorns(_ canvas: inout [[PixelColor]], x: Int, y: Int, side: Int, scale: Scale, color: PixelColor) {
        if side == 0 {
            line(&canvas, x - 2, y, -1, -1, scale.value(3, minimum: 2), color)
            line(&canvas, x + 2, y, 1, -1, scale.value(3, minimum: 2), color)
        } else {
            line(&canvas, x, y, side, -1, scale.value(4, minimum: 2), color)
        }
    }

    static func drawDragonSpine(_ canvas: inout [[PixelColor]], x: Int, y: Int, side: Int, scale: Scale, color: PixelColor) {
        let offset = side == 0 ? 0 : side * 2
        for index in 0..<4 {
            line(&canvas, x - 4 + index * 3 + offset, y - 3, 0, -1, scale.value(2, minimum: 1), color)
        }
    }

    // MARK: - Signature anatomy (human + tail, and ray)

    static func drawMermaid(_ canvas: inout [[PixelColor]], _ design: Design, _ direction: SpriteDirection, _ scale: Scale) {
        let x = scale.centerX
        let side = direction == .sideLeft ? -1 : direction == .sideRight ? 1 : 0
        let finY = scale.baseline - scale.value(2, minimum: 1)
        let tailHeight = scale.value(7, minimum: 4)
        let torsoHeight = scale.value(6, minimum: 4)
        let headHeight = scale.value(7, minimum: 4)
        let tailTop = finY - tailHeight
        let torsoTop = tailTop - torsoHeight
        let headY = torsoTop - headHeight / 2 - 1

        if side == 0 {
            outlinedOval(&canvas, x, headY, scale.value(9, minimum: 5), headHeight, .pink)
            outlinedOval(&canvas, x, headY + 1, scale.value(7, minimum: 4), max(4, headHeight - 2), .peach)
            rect(&canvas, x - 4, headY, 2, headHeight + 2, .pink)
            rect(&canvas, x + 3, headY, 2, headHeight + 2, .pink)
            rect(&canvas, x - 3, torsoTop, 7, torsoHeight, softOutline(for: design.primary))
            rect(&canvas, x - 2, torsoTop + 1, 5, torsoHeight - 1, design.primary)
            line(&canvas, x - 3, torsoTop + 2, -1, 1, scale.value(3, minimum: 2), .peach)
            line(&canvas, x + 3, torsoTop + 2, 1, 1, scale.value(3, minimum: 2), .peach)
            rect(&canvas, x - 3, tailTop, 7, tailHeight, softOutline(for: design.primary))
            rect(&canvas, x - 2, tailTop, 5, tailHeight, design.primary)
            diamond(&canvas, x - 3, finY, scale.value(4, minimum: 2), scale.value(3, minimum: 2), .mint)
            diamond(&canvas, x + 3, finY, scale.value(4, minimum: 2), scale.value(3, minimum: 2), .mint)
            if direction == .front {
                animalEyes(&canvas, x: x, y: headY + 1, separation: 2, color: .black)
                rect(&canvas, x - 1, torsoTop + 2, 3, 1, .mint)
            } else {
                rect(&canvas, x - 3, headY + 3, 7, 1, .darkRed)
                rect(&canvas, x - 2, torsoTop + 3, 5, 1, .mint)
                rect(&canvas, x - 1, tailTop + 2, 3, 1, .darkBlue)
            }
        } else {
            let headX = x + side * 2
            let hairX = x - side * 4
            outlinedOval(&canvas, headX, headY, scale.value(8, minimum: 5), headHeight, .pink)
            outlinedOval(&canvas, headX + side, headY + 1, scale.value(6, minimum: 4), max(4, headHeight - 2), .peach)
            rect(&canvas, hairX - side, headY - 2, 3, headHeight + 4, .pink)
            pixel(&canvas, headX + side * 2, headY + 1, .black)
            line(&canvas, headX + side * 4, headY + 3, side, 0, 2, .peach)
            rect(&canvas, x - 2 + side, torsoTop, 4, torsoHeight, softOutline(for: design.primary))
            rect(&canvas, x - 1 + side, torsoTop + 1, 3, torsoHeight - 1, design.primary)
            line(&canvas, headX + side * 2, torsoTop + 2, side, 1, scale.value(3, minimum: 2), .peach)
            rect(&canvas, x - 2 + side, tailTop, 5, tailHeight, softOutline(for: design.primary))
            rect(&canvas, x - 1 + side, tailTop, 3, tailHeight, design.primary)
            diamond(&canvas, x - side * 4, finY, scale.value(5, minimum: 3), scale.value(3, minimum: 2), .mint)
            pixel(&canvas, x + side * 3, torsoTop + 3, side < 0 ? .lavender : .gold)
        }
    }

    static func drawSkate(_ canvas: inout [[PixelColor]], _ design: Design, _ direction: SpriteDirection, _ scale: Scale) {
        let x = scale.centerX
        let side = direction == .sideLeft ? -1 : direction == .sideRight ? 1 : 0
        let wingRadius = scale.value(10, minimum: 5)
        let wingY = scale.baseline - scale.value(7, minimum: 4)
        let tailStart = wingY + scale.value(4, minimum: 2)
        let tailLength = max(2, min(scale.value(7, minimum: 3), 22 - tailStart))

        if side == 0 {
            // Build the ray from two broad, rounded pectoral fins joined by a
            // small face/body core.  This reads as a manta at a glance and
            // removes the decorative diamond used by the earlier version.
            let wingOffset = scale.value(4, minimum: 3)
            let wingWidth = scale.value(11, minimum: 6)
            let wingHeight = scale.value(6, minimum: 4)
            outlinedOval(&canvas, x - wingOffset, wingY, wingWidth, wingHeight, design.primary)
            outlinedOval(&canvas, x + wingOffset, wingY, wingWidth, wingHeight, design.primary)
            oval(&canvas, x - wingOffset - 1, wingY + 1, scale.value(4, minimum: 2), scale.value(3, minimum: 2), design.accent)
            oval(&canvas, x + wingOffset + 1, wingY + 1, scale.value(4, minimum: 2), scale.value(3, minimum: 2), design.accent)
            outlinedOval(&canvas, x, wingY + 1, scale.value(7, minimum: 4), scale.value(4, minimum: 3), .darkBlue)
            if direction == .front {
                animalEyes(&canvas, x: x, y: wingY + 1, separation: 2, color: .black)
            } else {
                rect(&canvas, x - 4, wingY, 9, 1, design.accent)
                pixel(&canvas, x - 3, wingY + 2, .mint)
                pixel(&canvas, x + 3, wingY + 2, .mint)
            }
            line(&canvas, x, tailStart, 0, 1, tailLength, .black)
            line(&canvas, x, tailStart, 0, 1, max(1, tailLength - 1), .darkBlue)
        } else {
            let nose = x + side * (wingRadius / 2 + 1)
            let rear = x - side * (wingRadius / 2)
            outlinedOval(&canvas, x + side, wingY, scale.value(12, minimum: 6), scale.value(6, minimum: 3), design.primary)
            outlinedOval(&canvas, x - side * 4, wingY + 1, scale.value(7, minimum: 4), scale.value(4, minimum: 2), design.primary)
            oval(&canvas, x - 2 + side, wingY - 2, 5, 3, design.accent)
            line(&canvas, nose - side, wingY, side, 0, scale.value(4, minimum: 2), design.primary)
            pixel(&canvas, nose - side, wingY - 1, .black)
            line(&canvas, rear, tailStart - 2, -side, 1, tailLength, .black)
            line(&canvas, rear, tailStart - 2, -side, 1, max(1, tailLength - 1), .darkBlue)
            pixel(&canvas, x + (side < 0 ? -1 : 2), wingY + 2, side < 0 ? .mint : .blue)
        }
    }
}

private extension PixelColor {
    static let darkBrown = PixelColor(0xFF4D260C)
}
