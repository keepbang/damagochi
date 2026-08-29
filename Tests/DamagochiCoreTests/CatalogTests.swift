import Testing
@testable import DamagochiCore

@Test func speciesCatalogHasEightyUniqueConsistentEntries() {
    let species = Species.allSpecies
    #expect(species.count == 80)
    #expect(Set(species.map(\.id)).count == species.count)
    #expect(Set(species.map(\.name)).count == species.count)
    #expect(species.allSatisfy { !$0.englishName.isEmpty && !$0.spriteKey.isEmpty })
    #expect(Set(species.map(\.spriteKey)).count == species.count)
}

@Test func equipmentCatalogIsDoubledAndHasUniqueIdentifiers() {
    let items = EquipmentDropper.itemPool
    #expect(items.count == 60)
    #expect(Set(items.map(\.id)).count == items.count)
    #expect(items.allSatisfy { $0.slot == .head || $0.slot == .hand || $0.slot == .effect })
}

@Test func unifiedCatalogHasCompleteNonConflictingMetadata() {
    let records = GameCatalog.records

    #expect(records.count == 140)
    #expect(Set(records.map(\.id)).count == records.count)
    #expect(records.allSatisfy { !$0.permanentId.isEmpty && !$0.koreanName.isEmpty && !$0.englishName.isEmpty && !$0.spriteKey.isEmpty })
    #expect(GameCatalog.species.allSatisfy { $0.mbtiGroup != nil && $0.equipmentSlot == nil })
    #expect(GameCatalog.equipment.allSatisfy { $0.mbtiGroup == nil && $0.equipmentSlot != nil })
}
