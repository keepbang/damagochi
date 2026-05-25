import Testing
@testable import DamagochiCore

@Test func rarityDistribution() {
    let dropper = EquipmentDropper()
    var counts: [Rarity: Int] = [.common: 0, .rare: 0, .legendary: 0, .mythic: 0]

    for _ in 0..<1000 {
        let rarity = dropper.rollRarity()
        counts[rarity, default: 0] += 1
    }

    #expect(counts[.common]! > 500)
    #expect(counts[.rare]! > 100)
    #expect(counts[.legendary]! > 20)
    #expect(counts[.mythic]! >= 1)
}

@Test func dropEquipmentReturnsValidItem() {
    let dropper = EquipmentDropper()
    let item = dropper.dropEquipment(forLevel: 5)
    #expect(!item.id.isEmpty)
    #expect(!item.name.isEmpty)
    #expect(!item.description.isEmpty)
}

@Test func dropEquipmentCreatesUniqueRewardWhenKnownItemsAreExhausted() {
    let dropper = EquipmentDropper()
    let existingIds = EquipmentDropper.itemPool.map(\.id)

    let item = dropper.dropEquipment(forLevel: 99, excluding: existingIds)

    #expect(!existingIds.contains(item.id))
    #expect(item.id.contains("lv99"))
}

@Test func dropCoversAllSlots() {
    let dropper = EquipmentDropper()
    var slots: Set<EquipmentSlot> = []

    for _ in 0..<100 {
        let item = dropper.dropEquipment(forLevel: 1)
        slots.insert(item.slot)
    }

    #expect(slots.contains(.head))
    #expect(slots.contains(.hand))
    #expect(slots.contains(.effect))
}
