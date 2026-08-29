import Foundation

public enum HorizontalMotionDirection: String, Codable, Sendable, Equatable {
    case left
    case right
}

/// Per-pet state used by the walking presentation. It is deliberately UI-free
/// so movement bounds and random target generation can be unit tested.
public struct ParkPetMotion: Codable, Sendable, Equatable {
    public var x: Double
    public var y: Double
    public var targetX: Double
    public var targetY: Double
    public var speed: Double
    public var direction: HorizontalMotionDirection

    public init(x: Double, y: Double, targetX: Double, targetY: Double, speed: Double, direction: HorizontalMotionDirection) {
        self.x = x
        self.y = y
        self.targetX = targetX
        self.targetY = targetY
        self.speed = speed
        self.direction = direction
    }
}

/// Supplies deterministic starting positions and bounded random targets for
/// park walking. Passing a fixed closure makes every random decision testable.
public struct ParkMotionEngine {
    private let randomUnit: () -> Double

    public init(randomUnit: @escaping () -> Double = { Double.random(in: 0...1) }) {
        self.randomUnit = randomUnit
    }

    public func initialMotions(count: Int, width: Double, height: Double, margin: Double = 42) -> [ParkPetMotion] {
        guard count > 0 else { return [] }
        let columns = min(2, count)
        let rows = Int(ceil(Double(count) / Double(columns)))
        return (0..<count).map { index in
            let column = index % columns
            let row = index / columns
            let x = bounded(
                (Double(column + 1) / Double(columns + 1)) * width,
                lower: margin,
                upper: width - margin
            )
            let y = bounded(
                (Double(row + 1) / Double(rows + 1)) * height,
                lower: margin,
                upper: height - margin
            )
            return ParkPetMotion(x: x, y: y, targetX: x, targetY: y, speed: 1.8, direction: .right)
        }
    }

    public func nextMotion(from current: ParkPetMotion, width: Double, height: Double, margin: Double = 42) -> ParkPetMotion {
        let x = randomCoordinate(lower: margin, upper: width - margin)
        let y = randomCoordinate(lower: margin, upper: height - margin)
        return ParkPetMotion(
            x: bounded(current.x, lower: margin, upper: width - margin),
            y: bounded(current.y, lower: margin, upper: height - margin),
            targetX: x,
            targetY: y,
            speed: 1.4 + randomUnit() * 0.9,
            direction: x < current.x ? .left : .right
        )
    }

    private func randomCoordinate(lower: Double, upper: Double) -> Double {
        guard upper > lower else { return lower }
        return lower + min(max(randomUnit(), 0), 1) * (upper - lower)
    }

    private func bounded(_ value: Double, lower: Double, upper: Double) -> Double {
        guard upper > lower else { return lower }
        return min(max(value, lower), upper)
    }
}
