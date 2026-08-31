import SwiftUI
import DamagochiCore

// MARK: - Pixel Color

public struct PixelColor: Sendable, Equatable {
    public let rawValue: UInt32

    public init(_ rawValue: UInt32) {
        self.rawValue = rawValue
    }

    public var isTransparent: Bool { (rawValue >> 24) & 0xFF == 0 }

    public static let clear     = PixelColor(0x00000000)
    public static let black     = PixelColor(0xFF000000)
    public static let white     = PixelColor(0xFFFFFFFF)
    public static let darkGray  = PixelColor(0xFF555555)
    public static let gray      = PixelColor(0xFF888888)
    public static let lightGray = PixelColor(0xFFBBBBBB)

    public static let red       = PixelColor(0xFFCC3333)
    public static let orange    = PixelColor(0xFFFFA500)
    public static let yellow    = PixelColor(0xFFFFD700)
    public static let gold      = PixelColor(0xFFDAA520)
    public static let cream     = PixelColor(0xFFFFF8DC)
    public static let peach     = PixelColor(0xFFFFDAB9)

    public static let blue      = PixelColor(0xFF4A9EFF)
    public static let darkBlue  = PixelColor(0xFF2255AA)
    public static let green     = PixelColor(0xFF44BB44)
    public static let darkGreen = PixelColor(0xFF228822)
    public static let teal      = PixelColor(0xFF44BBBB)
    public static let mint      = PixelColor(0xFF88DDAA)

    public static let brown     = PixelColor(0xFF8B4513)
    public static let tan       = PixelColor(0xFFD2B48C)
    public static let pink      = PixelColor(0xFFFF69B4)
    public static let purple    = PixelColor(0xFF9B59B6)
    public static let lavender  = PixelColor(0xFFBB88FF)
    public static let coral     = PixelColor(0xFFFF6B6B)
    public static let ginger    = PixelColor(0xFFCD853F)
    public static let darkRed   = PixelColor(0xFF881111)
    public static let lime      = PixelColor(0xFF88CC44)

    // Muted supporting tones keep the native-resolution pets from reading as
    // flat UI glyphs. They are intentionally softer than the legacy palette:
    // use them for compact fur/fabric clusters, not as a new silhouette colour.
    public static let warmGray  = PixelColor(0xFFC9B8B4)
    public static let blush     = PixelColor(0xFFE9A7B4)
    public static let mistBlue  = PixelColor(0xFF789BC2)
    public static let cocoa     = PixelColor(0xFF6D3B2C)

    public func grayed() -> PixelColor {
        guard !isTransparent else { return self }
        let a = (rawValue >> 24) & 0xFF
        let r = (rawValue >> 16) & 0xFF
        let g = (rawValue >> 8) & 0xFF
        let b = rawValue & 0xFF
        let lum = (r * 30 + g * 59 + b * 11) / 100
        return PixelColor(a << 24 | lum << 16 | lum << 8 | lum)
    }
}

// MARK: - Pixel Sprite

public struct PixelSprite: Sendable {
    public let width: Int
    public let height: Int
    public let pixels: [[PixelColor]]

    public init(width: Int, height: Int, pixels: [[PixelColor]]) {
        self.width = width
        self.height = height
        self.pixels = pixels
    }

    public init(palette: [Character: PixelColor], rows: [String]) {
        self.height = rows.count
        self.width = rows.first?.count ?? 0
        self.pixels = rows.map { row in
            row.map { ch in palette[ch] ?? .clear }
        }
    }

    public func grayed() -> PixelSprite {
        PixelSprite(
            width: width, height: height,
            pixels: pixels.map { row in row.map { $0.grayed() } }
        )
    }

    public func mirrored() -> PixelSprite {
        PixelSprite(width: width, height: height, pixels: pixels.map { Array($0.reversed()) })
    }

    /// Expands legacy code sprites into the renderer's native grid while
    /// retaining hard pixel edges. All rendering callers can therefore use one
    /// grid size even while eggs and equipment keep their original art source.
    public func nearestResized(width targetWidth: Int, height targetHeight: Int) -> PixelSprite {
        guard width > 0, height > 0, targetWidth > 0, targetHeight > 0 else { return .empty }
        let resized = (0..<targetHeight).map { targetY in
            (0..<targetWidth).map { targetX in
                let sourceY = min(height - 1, targetY * height / targetHeight)
                let sourceX = min(width - 1, targetX * width / targetWidth)
                return pixels[sourceY][sourceX]
            }
        }
        return PixelSprite(width: targetWidth, height: targetHeight, pixels: resized)
    }

    public func overlaid(with overlay: PixelSprite) -> PixelSprite {
        var result = pixels
        for row in 0..<min(height, overlay.height) {
            for col in 0..<min(width, overlay.width) {
                let px = overlay.pixels[row][col]
                if !px.isTransparent {
                    result[row][col] = px
                }
            }
        }
        return PixelSprite(width: width, height: height, pixels: result)
    }

    /// Tight bounding box of non-transparent pixels, in pixel-grid coordinates.
    public var visibleBounds: CGRect? {
        var minX = width, minY = height, maxX = -1, maxY = -1
        for row in 0..<height {
            for col in 0..<width {
                if !pixels[row][col].isTransparent {
                    if col < minX { minX = col }
                    if col > maxX { maxX = col }
                    if row < minY { minY = row }
                    if row > maxY { maxY = row }
                }
            }
        }
        guard maxX >= 0 else { return nil }
        return CGRect(x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1)
    }

    public static let empty = PixelSprite(width: 0, height: 0, pixels: [])
}

// MARK: - Pixel Art View

public struct PixelArtView: View {
    let sprite: PixelSprite
    let scale: CGFloat

    public init(sprite: PixelSprite, scale: CGFloat = 4.0) {
        self.sprite = sprite
        self.scale = scale
    }

    public var body: some View {
        let effectiveScale = scale * SpriteSheet.pointScale
        Canvas { context, _ in
            for row in 0..<sprite.height {
                for col in 0..<sprite.width {
                    let color = sprite.pixels[row][col]
                    guard !color.isTransparent else { continue }
                    let rect = CGRect(
                        x: CGFloat(col) * effectiveScale,
                        y: CGFloat(row) * effectiveScale,
                        width: effectiveScale,
                        height: effectiveScale
                    )
                    context.fill(Path(rect), with: .color(Color(hex: color.rawValue)))
                }
            }
        }
        .frame(width: CGFloat(sprite.width) * effectiveScale, height: CGFloat(sprite.height) * effectiveScale)
        .drawingGroup()
    }
}

// MARK: - Animated Pet View

public struct AnimatedPetView: View {
    let frames: [PixelSprite]
    let scale: CGFloat
    let interval: TimeInterval

    @State private var currentFrame = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(frames: [PixelSprite], scale: CGFloat = 8.0, interval: TimeInterval = 0.5) {
        self.frames = frames
        self.scale = scale
        self.interval = interval
    }

    public var body: some View {
        Group {
            if frames.isEmpty {
                Color.clear.frame(width: 128, height: 128)
            } else {
                PixelArtView(sprite: frames[currentFrame % frames.count], scale: scale)
            }
        }
        .onReceive(
            Timer.publish(every: interval, on: .main, in: .common).autoconnect()
        ) { _ in
            guard !reduceMotion, frames.count > 1 else { return }
            currentFrame = (currentFrame + 1) % frames.count
        }
        .onChange(of: reduceMotion) { _, isReduced in
            if isReduced { currentFrame = 0 }
        }
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: UInt32) {
        let a = Double((hex >> 24) & 0xFF) / 255.0
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
