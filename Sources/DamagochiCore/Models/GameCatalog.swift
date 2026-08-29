import Foundation

/// A normalized read model for every permanent character and equipment record.
/// Legacy `Species` and `Equipment` APIs remain available so old save IDs and
/// callers do not change, while new features share this one catalog surface.
public struct CatalogRecord: Sendable, Equatable, Identifiable {
    public enum Kind: String, Sendable, Equatable {
        case species
        case equipment
    }

    public let kind: Kind
    public let permanentId: String
    public let koreanName: String
    public let englishName: String
    public let spriteKey: String
    public let rarity: Rarity
    public let mbtiGroup: MbtiGroup?
    public let equipmentSlot: EquipmentSlot?
    public let description: String
    public let atkBonus: Int
    public let defBonus: Int

    public var id: String { "\(kind.rawValue):\(permanentId)" }

    public init(
        kind: Kind,
        permanentId: String,
        koreanName: String,
        englishName: String,
        spriteKey: String,
        rarity: Rarity,
        mbtiGroup: MbtiGroup? = nil,
        equipmentSlot: EquipmentSlot? = nil,
        description: String = "",
        atkBonus: Int = 0,
        defBonus: Int = 0
    ) {
        self.kind = kind
        self.permanentId = permanentId
        self.koreanName = koreanName
        self.englishName = englishName
        self.spriteKey = spriteKey
        self.rarity = rarity
        self.mbtiGroup = mbtiGroup
        self.equipmentSlot = equipmentSlot
        self.description = description
        self.atkBonus = atkBonus
        self.defBonus = defBonus
    }
}

public enum GameCatalog {
    public static let records: [CatalogRecord] = species + equipment

    public static let species: [CatalogRecord] = Species.allSpecies.map { species in
        CatalogRecord(
            kind: .species,
            permanentId: species.id,
            koreanName: species.name,
            englishName: species.englishName,
            spriteKey: species.spriteKey,
            rarity: species.rarity,
            mbtiGroup: species.group,
            description: "\(species.name) 캐릭터"
        )
    }

    public static let equipment: [CatalogRecord] = EquipmentDropper.itemPool.map { item in
        CatalogRecord(
            kind: .equipment,
            permanentId: item.id,
            koreanName: item.name,
            englishName: item.englishName ?? item.name,
            spriteKey: item.spriteId,
            rarity: item.rarity,
            equipmentSlot: item.slot,
            description: item.description,
            atkBonus: item.slot == .hand ? item.rarity.handAtkBonus : 0,
            defBonus: (item.slot == .head ? item.rarity.headDef : 0) + (item.slot == .effect ? item.rarity.effectDef : 0)
        )
    }
}
