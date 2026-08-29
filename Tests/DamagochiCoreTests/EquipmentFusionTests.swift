import Testing
@testable import DamagochiCore

@Test func fusionConsumesTenMaterialsAndAddsNextRarity() throws {
    var state = PetState(machineId: "fusion")
    state.inventory = (0..<10).map {
        Equipment(id: "common_\($0)", name: "재료", slot: .head, rarity: .common, description: "테스트")
    }
    let rewardTemplate = Equipment(id: "rare_reward", name: "보상", slot: .hand, rarity: .rare, description: "테스트")

    let reward = try EquipmentFusion().fuse(
        rarity: .common,
        state: &state,
        itemPool: [rewardTemplate],
        chooser: { $0.first }
    )

    #expect(reward.id == "rare_reward")
    #expect(state.inventory.count == 1)
    #expect(state.inventory.first?.rarity == .rare)
}

@Test func fusionRejectsInsufficientOrMythicMaterialsWithoutMutation() {
    var state = PetState(machineId: "fusion")
    state.inventory = [Equipment(id: "one", name: "하나", slot: .head, rarity: .common, description: "테스트")]
    let original = state.inventory.map(\.id)

    #expect(throws: EquipmentFusionError.insufficientMaterials) {
        try EquipmentFusion().fuse(rarity: .common, state: &state)
    }
    #expect(state.inventory.map(\.id) == original)
    #expect(throws: EquipmentFusionError.highestRarity) {
        try EquipmentFusion().fuse(rarity: .mythic, state: &state)
    }
}
