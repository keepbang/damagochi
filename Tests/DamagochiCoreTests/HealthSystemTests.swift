import Testing
@testable import DamagochiCore

@Test func decayReducesStats() {
    let system = HealthSystem()
    var state = PetState(machineId: "test")
    state.phase = .alive
    state.hp = 100
    state.hunger = 100
    state.mood = 100

    system.applyDecay(to: &state, inactiveHours: 24)
    #expect(state.hp == 80)
    #expect(state.hunger == 60)
    #expect(state.mood == 80)
}

@Test func decayDoesNotGoBelowZero() {
    let system = HealthSystem()
    var state = PetState(machineId: "test")
    state.phase = .alive
    state.hp = 5
    state.hunger = 10
    state.mood = 3

    system.applyDecay(to: &state, inactiveHours: 48)
    #expect(state.hp == 0)
    #expect(state.hunger == 0)
    #expect(state.mood == 0)
}

@Test func recoveryIncreasesStats() {
    let system = HealthSystem()
    var state = PetState(machineId: "test")
    state.phase = .alive
    state.hp = 50
    state.hunger = 50
    state.mood = 50

    system.applyRecovery(to: &state)
    #expect(state.hp == 55)
    #expect(state.hunger == 60)
    #expect(state.mood == 53)
}

@Test func recoveryDoesNotExceed100() {
    let system = HealthSystem()
    var state = PetState(machineId: "test")
    state.phase = .alive
    state.hp = 98
    state.hunger = 95
    state.mood = 99

    system.applyRecovery(to: &state)
    #expect(state.hp == 100)
    #expect(state.hunger == 100)
    #expect(state.mood == 100)
}

@Test func noDecayForEgg() {
    let system = HealthSystem()
    var state = PetState(machineId: "test")
    state.phase = .egg
    state.hp = 100

    system.applyDecay(to: &state, inactiveHours: 120)
    #expect(state.hp == 100)
}
