import Foundation
import Testing
@testable import DamagochiCore

@Test func battleProfileDecodesWithoutStage() throws {
    let legacyJSON = """
    {
      "id": "legacy-machine",
      "petName": "레거시 펫",
      "speciesId": "cat",
      "mbtiGroup": "sp",
      "speciesRarity": "common",
      "stats": {
        "atk": 12,
        "int_": 8,
        "maxHp": 100,
        "spd": 4,
        "def": 3,
        "currentHp": 90
      }
    }
    """

    let profile = try JSONDecoder().decode(BattleProfile.self, from: Data(legacyJSON.utf8))

    #expect(profile.stage == nil)
    #expect(profile.petName == "레거시 펫")
}

@Test func battleProfileIncludesCurrentPetStage() {
    var state = PetState(machineId: "current-machine")
    state.phase = .alive
    state.species = "cat"
    state.level = 15

    let profile = BattleProfile.from(state)

    #expect(profile?.stage == .stage2)
}

@Test func battleLevelCapsAtFiftyWithoutChangingStoredPet() {
    var levelFifty = PetState(machineId: "fifty")
    levelFifty.phase = .alive
    levelFifty.species = "cat"
    levelFifty.level = 50
    levelFifty.totalToolUses = 100
    levelFifty.totalPrompts = 100
    levelFifty.totalSessions = 10

    var levelNinetyNine = levelFifty
    levelNinetyNine.level = 99

    let capped = BattleProfile.from(levelFifty)
    let overCapped = BattleProfile.from(levelNinetyNine)

    #expect(capped?.battleLevel == 50)
    #expect(overCapped?.battleLevel == 50)
    #expect(capped?.stats.atk == overCapped?.stats.atk)
    #expect(capped?.stats.int_ == overCapped?.stats.int_)
    #expect(capped?.stats.maxHp == overCapped?.stats.maxHp)
    #expect(capped?.stats.spd == overCapped?.stats.spd)
    #expect(levelNinetyNine.level == 99)
}

@Test func battleProfilesUseSlotIdentityWhenAvailable() {
    var first = PetState(machineId: "same-device")
    first.phase = .alive
    first.species = "cat"
    var second = first
    second.petId = UUID().uuidString

    #expect(BattleProfile.from(first)?.id != BattleProfile.from(second)?.id)
}

@Test func battleProfileContainsOnlyEquippedEffectAppearanceInstance() {
    var state = PetState(machineId: "appearance")
    state.phase = .alive
    state.species = "cat"
    let head = Equipment(id: "head", name: "모자", slot: .head, rarity: .common, description: "테스트")
    let hand = Equipment(id: "hand", name: "지팡이", slot: .hand, rarity: .rare, description: "테스트")
    let spare = Equipment(id: "spare", name: "여분", slot: .effect, rarity: .common, description: "테스트")
    state.inventory = [head, hand, spare]
    state.equippedItems = EquippedItems(head: head.id, hand: hand.id, effect: spare.id)

    let profile = BattleProfile.from(state)

    #expect(profile?.equippedItems?.head == nil)
    #expect(profile?.equippedItems?.hand == nil)
    #expect(profile?.equippedItems?.effect == "spare")
    #expect(profile?.equippedEquipment?.map(\.id) == ["spare"])
}

@Test func battleProfileUsesAccountActivityWithoutChangingPetXPStats() {
    var state = PetState(machineId: "account")
    state.phase = .alive
    state.species = "cat"
    let profile = BattleProfile.from(
        state,
        activityStats: ActivityStats(prompts: 100, toolUses: 200, sessions: 20)
    )

    #expect(profile?.stats.atk ?? 0 > 1)
    #expect(profile?.stats.int_ ?? 0 > 1)
    #expect(profile?.stats.maxHp ?? 0 > 100)
}
