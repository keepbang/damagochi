import Testing
@testable import DamagochiCore

@Test func parkInitialPositionsAreDistinctAndInsideBounds() {
    let states = ParkMotionEngine().initialMotions(count: 4, width: 640, height: 640)

    #expect(Set(states.map { "\($0.x),\($0.y)" }).count == 4)
    #expect(states.allSatisfy { (42...598).contains($0.x) && (42...598).contains($0.y) })
}

@Test func parkTargetUsesInjectedRandomValuesAndClampsCurrentPosition() {
    let values = [0.0, 1.0, 0.5]
    var index = 0
    let engine = ParkMotionEngine(randomUnit: {
        defer { index += 1 }
        return values[index]
    })
    let current = ParkPetMotion(x: -20, y: 900, targetX: 0, targetY: 0, speed: 0, direction: .right)

    let next = engine.nextMotion(from: current, width: 640, height: 640)

    #expect(next.x == 42)
    #expect(next.y == 598)
    #expect(next.targetX == 42)
    #expect(next.targetY == 598)
    #expect(abs(next.speed - 1.85) < 0.000_001)
    #expect(next.direction == .right)
}
