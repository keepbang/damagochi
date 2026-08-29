import AppKit
import DamagochiCore
import DamagochiRenderer

let arguments = Array(CommandLine.arguments.dropFirst())
let directions = arguments.first == "--directions"
let outputPath = arguments.last(where: { $0 != "--directions" })
    ?? (directions ? "docs/assets/expanded-character-directions.png" : "docs/assets/character-catalog.png")
let outputURL = URL(fileURLWithPath: outputPath, relativeTo: URL(fileURLWithPath: FileManager.default.currentDirectoryPath))
let speciesList = directions ? Array(Species.allSpecies.dropFirst(40)) : Species.allSpecies
let columns = directions ? 8 : 10
let cardSize = 252
let scale = directions ? 4 : 8
let rows = Int(ceil(Double(speciesList.count) / Double(columns)))
let imageSize = NSSize(width: columns * cardSize, height: rows * cardSize)

guard let bitmap = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: Int(imageSize.width),
    pixelsHigh: Int(imageSize.height),
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
) else {
    fatalError("도감 비트맵을 만들 수 없습니다.")
}
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
NSColor(calibratedWhite: 0.96, alpha: 1).setFill()
NSBezierPath(rect: NSRect(origin: .zero, size: imageSize)).fill()

for (index, species) in speciesList.enumerated() {
    let column = index % columns
    let row = index / columns
    let originX = column * cardSize
    let originY = Int(imageSize.height) - (row + 1) * cardSize
    let card = NSRect(x: originX + 6, y: originY + 6, width: cardSize - 12, height: cardSize - 12)
    NSColor.white.setFill()
    NSBezierPath(roundedRect: card, xRadius: 12, yRadius: 12).fill()
    NSColor(calibratedWhite: 0.84, alpha: 1).setStroke()
    NSBezierPath(roundedRect: card, xRadius: 12, yRadius: 12).stroke()

    let label = "#\(directions ? index + 41 : index + 1)  \(species.name)"
    label.draw(at: NSPoint(x: originX + 16, y: originY + 218), withAttributes: [
        .font: NSFont.systemFont(ofSize: 16, weight: .semibold),
        .foregroundColor: NSColor.labelColor,
    ])

    if directions {
        for (directionIndex, direction) in SpriteDirection.allCases.enumerated() {
            guard let sprite = SpriteSheet.frames(species: species.id, stage: .stage3, phase: .alive, direction: direction).first else { continue }
            let localX = 20 + (directionIndex % 2) * 112
            let localY = 24 + (1 - directionIndex / 2) * 100
            let marker = ["정", "후", "좌", "우"][directionIndex]
            marker.draw(at: NSPoint(x: originX + localX, y: originY + localY + 60), withAttributes: [.font: NSFont.systemFont(ofSize: 10), .foregroundColor: NSColor.secondaryLabelColor])
            draw(sprite, atX: originX + localX, y: originY + localY, scale: scale)
        }
    } else if let sprite = SpriteSheet.frames(species: species.id, stage: .stage3, phase: .alive, direction: .front).first {
        draw(sprite, atX: originX + (cardSize - sprite.width * scale) / 2, y: originY + 30, scale: scale)
    }
}

NSGraphicsContext.restoreGraphicsState()
guard let data = bitmap.representation(using: .png, properties: [:]) else {
    fatalError("카탈로그 PNG를 만들 수 없습니다.")
}
try FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)
try data.write(to: outputURL)
print(outputURL.path)

private func draw(_ sprite: PixelSprite, atX originX: Int, y originY: Int, scale: Int) {
    for y in 0..<sprite.height {
        for x in 0..<sprite.width {
            let pixel = sprite.pixels[y][x]
            guard !pixel.isTransparent else { continue }
            NSColor(red: CGFloat((pixel.rawValue >> 16) & 0xFF) / 255, green: CGFloat((pixel.rawValue >> 8) & 0xFF) / 255, blue: CGFloat(pixel.rawValue & 0xFF) / 255, alpha: CGFloat((pixel.rawValue >> 24) & 0xFF) / 255).setFill()
            NSBezierPath(rect: NSRect(x: originX + x * scale, y: originY + (sprite.height - 1 - y) * scale, width: scale, height: scale)).fill()
        }
    }
}
