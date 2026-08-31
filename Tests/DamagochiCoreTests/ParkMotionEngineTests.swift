import Testing
@testable import DamagochiCore

@Test func parkInitialPositionsAreDistinctAndInsideBounds() {
    let states = ParkMotionEngine().initialMotions(count: 4, width: 640, height: 640)

    #expect(Set(states.map { "\($0.x),\($0.y)" }).count == 4)
    #expect(states.allSatisfy { (42...598).contains($0.x) && (42...598).contains($0.y) })
}

@Test func parkTargetUsesInjectedRandomValuesAndClampsPreviousDestination() {
    let values = [0.0, 1.0, 0.5]
    var index = 0
    let engine = ParkMotionEngine(randomUnit: {
        defer { index += 1 }
        return values[index]
    })
    let current = ParkPetMotion(x: -20, y: 900, targetX: 0, targetY: 0, speed: 0, direction: .right)

    let next = engine.nextMotion(from: current, width: 640, height: 640)

    #expect(next.x == 42)
    #expect(next.y == 42)
    #expect(next.targetX == 42)
    #expect(next.targetY == 598)
    #expect(abs(next.speed - 1.85) < 0.000_001)
    #expect(next.direction == .right)
}

@Test func parkNextMoveStartsAtThePreviousDestination() {
    let values = [0.0, 0.5, 0.0]
    var index = 0
    let engine = ParkMotionEngine(randomUnit: {
        defer { index += 1 }
        return values[index]
    })
    let current = ParkPetMotion(x: 100, y: 100, targetX: 500, targetY: 200, speed: 1.8, direction: .right)

    let next = engine.nextMotion(from: current, width: 640, height: 640)

    #expect(next.x == 500)
    #expect(next.y == 200)
    #expect(next.targetX == 42)
    #expect(next.direction == .left)
}

@Test func parkMotionKeepsRelativePositionsWhenResized() {
    let motion = ParkPetMotion(x: 320, y: 320, targetX: 598, targetY: 42, speed: 1.8, direction: .right)

    let resized = ParkMotionEngine().resizedMotion(
        from: motion,
        oldWidth: 640,
        oldHeight: 640,
        width: 320,
        height: 320
    )

    #expect(resized.x == 160)
    #expect(resized.y == 160)
    #expect(resized.targetX == 278)
    #expect(resized.targetY == 42)
    #expect(resized.direction == .right)
}
