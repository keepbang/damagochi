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
