import Foundation
import Testing
@testable import DamagochiCore

@Test func legacyPetMigratesIntoFirstSlot() {
    var legacy = PetState(machineId: "legacy")
    legacy.level = 12
    legacy.unlockedAchievements = ["first"]

    let roster = PetRoster(legacy: legacy)

    #expect(roster.pets.count == 1)
    #expect(roster.selectedIndex == 0)
    #expect(roster.selectedPet?.level == 12)
    #expect(roster.globalUnlockedAchievements == ["first"])
}

@Test func rosterMigratesMirroredLegacyActivityToOneAccountStat() {
    var first = PetState(machineId: "device")
    first.totalPrompts = 12
    first.totalToolUses = 9
    first.totalSessions = 3
    var second = first
    second.petId = UUID().uuidString

    var roster = PetRoster(pets: [first, second])
    roster.migrateAccountActivityStatsIfNeeded()

    #expect(roster.activityStats == ActivityStats(prompts: 12, toolUses: 9, sessions: 3))
    roster.recordAccountActivity(.prompt)
    #expect(roster.activityStats.prompts == 13)
    #expect(roster.pets[0].totalPrompts == 12)
    #expect(roster.pets[1].totalPrompts == 12)
}

@Test func petRosterEnforcesFourSlotLimit() {
    var roster = PetRoster(pets: [PetState(machineId: "one")])

    let secondAdded = roster.addPet(machineId: "one")
    let thirdAdded = roster.addPet(machineId: "one")
    let fourthAdded = roster.addPet(machineId: "one")
    let fifthAdded = roster.addPet(machineId: "one")
    #expect(secondAdded)
    #expect(thirdAdded)
    #expect(fourthAdded)
    #expect(!fifthAdded)
    #expect(roster.pets.count == 4)
    #expect(Set(roster.pets.compactMap(\.petId)).count == 4)
}

@Test func rosterCodableRoundTripRestoresSlotsAndSelection() throws {
    var roster = PetRoster(pets: [PetState(machineId: "device")])
    let added = roster.addPet(machineId: "device")
    #expect(added)
    roster.pets[0].name = "첫째"
    roster.pets[1].name = "둘째"

    let restored = try JSONDecoder().decode(PetRoster.self, from: JSONEncoder().encode(roster))

    #expect(restored.selectedIndex == 1)
    #expect(restored.pets.map(\.name) == ["첫째", "둘째"])
    #expect(restored.pets[0].petId != restored.pets[1].petId)
}

@Test func petStateWithoutSlotIdentityStillDecodes() throws {
    let original = PetState(machineId: "legacy-device")
    let encoded = try JSONEncoder().encode(original)
    var object = try #require(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
    object.removeValue(forKey: "petId")
    let legacyData = try JSONSerialization.data(withJSONObject: object)

    let restored = try JSONDecoder().decode(PetState.self, from: legacyData)
    #expect(restored.machineId == "legacy-device")
    #expect(restored.petId == nil)
}

@Test func xpSplitPreservesTotalAndRotatesRemainder() {
    var first = PetState(machineId: "test")
    first.phase = .alive
    var second = PetState(machineId: "test")
    second.phase = .alive
    var third = PetState(machineId: "test")
    third.phase = .dead
    var roster = PetRoster(pets: [first, second, third])

    let firstSplit = roster.distributeXP(5)
    let secondSplit = roster.distributeXP(5)

    #expect(firstSplit.values.reduce(0, +) == 5)
    #expect(secondSplit.values.reduce(0, +) == 5)
    #expect(firstSplit[2] == nil)
    #expect(firstSplit[0] == 3)
    #expect(firstSplit[1] == 2)
    #expect(secondSplit[0] == 2)
    #expect(secondSplit[1] == 3)
}
