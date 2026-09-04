import Testing
@testable import DamagochiCore

@Test func firstHatchAchievement() {
    let checker = AchievementChecker()
    var state = PetState(machineId: "test")
    state.phase = .alive
    state.level = 1

    let achievements = checker.check(state: state)
    #expect(achievements.contains { $0.id == "first_hatch" })
}

@Test func levelAchievements() {
    let checker = AchievementChecker()
    var state = PetState(machineId: "test")
    state.phase = .alive
    state.level = 10

    let achievements = checker.check(state: state)
    let ids = Set(achievements.map(\.id))
    #expect(ids.contains("first_hatch"))
    #expect(ids.contains("level_5"))
    #expect(ids.contains("level_10"))
    #expect(!ids.contains("level_20"))
}

@Test func equipmentAchievements() {
    let checker = AchievementChecker()
    var state = PetState(machineId: "test")
    state.phase = .alive
    state.level = 1

    for i in 0..<3 {
        state.inventory.append(Equipment(id: "item_\(i)", name: "Item \(i)", slot: .head, rarity: .common, description: ""))
    }

    let achievements = checker.check(state: state)
    let ids = Set(achievements.map(\.id))
    #expect(ids.contains("equip_3"))
    #expect(!ids.contains("equip_10"))
}

@Test func legendaryEquipmentAchievement() {
    let checker = AchievementChecker()
    var state = PetState(machineId: "test")
    state.phase = .alive
    state.level = 1
    state.inventory.append(Equipment(id: "leg1", name: "레전드", slot: .hand, rarity: .legendary, description: ""))

    let achievements = checker.check(state: state)
    let ids = Set(achievements.map(\.id))
    #expect(ids.contains("equip_legendary"))
    #expect(!ids.contains("equip_mythic"))
}

@Test func alreadyUnlockedAchievementsAreSkipped() {
    let checker = AchievementChecker()
    var state = PetState(machineId: "test")
    state.phase = .alive
    state.level = 5
    state.unlockedAchievements = ["first_hatch", "level_5"]

    let achievements = checker.check(state: state)
    let ids = Set(achievements.map(\.id))
    #expect(!ids.contains("first_hatch"))
    #expect(!ids.contains("level_5"))
}

@Test func rebirthAchievement() {
    let checker = AchievementChecker()
    var state = PetState(machineId: "test")
    state.phase = .egg
    state.deathCount = 1

    let achievements = checker.check(state: state)
    let ids = Set(achievements.map(\.id))
    #expect(ids.contains("rebirth"))
}

@Test func workdayStreakAchievement() {
    let checker = AchievementChecker()
    var state = PetState(machineId: "test")
    state.phase = .alive
    state.level = 1
    state.consecutiveWorkdays = 30

    let achievements = checker.check(state: state)
    let ids = Set(achievements.map(\.id))
    #expect(ids.contains("workdays_7"))
    #expect(ids.contains("workdays_30"))
    #expect(!ids.contains("workdays_100"))
}

@Test func accountActivityUnlocksExpandedAchievementsWithoutPetLocalCounters() {
    let checker = AchievementChecker()
    var state = PetState(machineId: "test")
    state.phase = .alive
    state.level = 1

    let achievements = checker.check(
        state: state,
        activityStats: ActivityStats(prompts: 5_000, toolUses: 1_000, sessions: 500)
    )
    let ids = Set(achievements.map(\.id))
    #expect(ids.contains("prompts_5000"))
    #expect(ids.contains("tools_1000"))
    #expect(ids.contains("sessions_500"))
}
