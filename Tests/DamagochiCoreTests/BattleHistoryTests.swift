import Foundation
import Testing
@testable import DamagochiCore

private func historyEntry(_ outcome: BattleOutcome, mode: BattleMode = .single) -> BattleHistoryEntry {
    var pet = PetState(machineId: "device")
    pet.phase = .alive
    pet.species = Species.allSpecies[0].id
    pet.name = "출전 당시 이름"
    let profile = BattleProfile.from(pet)!
    return BattleHistoryEntry(mode: mode, opponentID: "peer", opponentName: "상대",
                              myPets: [profile], opponentPets: [profile], outcome: outcome)
}

@Test func oldRosterWithoutHistoryStillDecodes() throws {
    let original = PetRoster(pets: [PetState(machineId: "old")])
    let data = try JSONEncoder().encode(original)
    var json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
    json.removeValue(forKey: "battleHistory")
    let restored = try JSONDecoder().decode(PetRoster.self, from: JSONSerialization.data(withJSONObject: json))
    #expect(restored.battleHistory == nil)
    #expect(BattleRecord(entries: restored.battleHistory ?? []).wins == 0)
    #expect(restored.pets.count == 1)
}

@Test func historyPreservesParticipantsAndResultsAcrossSaveAndPetChanges() throws {
    var roster = PetRoster(pets: [PetState(machineId: "device")])
    var entry = historyEntry(.victory, mode: .team)
    entry.endedAt = Date()
    entry.reason = "상대 기권"
    roster.recordBattle(entry)
    roster.pets[0].name = "변경된 이름"
    _ = roster.addPet(machineId: "device")
    let restored = try JSONDecoder().decode(PetRoster.self, from: JSONEncoder().encode(roster))
    let saved = try #require(restored.battleHistory?.first)
    #expect(saved.id == entry.id)
    #expect(saved.startedAt == entry.startedAt)
    #expect(saved.endedAt == entry.endedAt)
    #expect(saved.opponentID == "peer")
    #expect(saved.opponentName == "상대")
    #expect(saved.myPets.first?.petName == "출전 당시 이름")
    #expect(saved.opponentPets.count == 1)
    #expect(saved.mode == .team)
    #expect(saved.outcome == .victory)
    #expect(saved.reason == "상대 기권")
}

@Test func battleTotalsIncludeDrawsButExcludeInterruptedMatches() {
    let entries = [historyEntry(.victory), historyEntry(.victory), historyEntry(.defeat),
                   historyEntry(.draw), historyEntry(.interrupted)]
    let record = BattleRecord(entries: entries)
    #expect(record.wins == 2)
    #expect(record.losses == 1)
    #expect(record.draws == 1)
}

@Test func finalizingAndRepeatedSavingNeverDuplicateTheMatch() throws {
    var roster = PetRoster(pets: [PetState(machineId: "device")])
    var entry = historyEntry(.interrupted)
    roster.recordBattle(entry)
    #expect(BattleRecord(entries: roster.battleHistory ?? []).losses == 0)
    entry.outcome = .defeat
    entry.endedAt = Date()
    roster.recordBattle(entry)
    roster.recordBattle(entry)
    #expect(roster.battleHistory?.count == 1)
    #expect(BattleRecord(entries: roster.battleHistory ?? []).losses == 1)
    #expect(try #require(roster.battleHistory?.first).endedAt != nil)
}
