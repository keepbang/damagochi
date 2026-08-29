import Foundation

// MARK: - Battle Stats

public struct BattleStats: Codable, Sendable, Equatable {
    public let atk: Int      // 물리 공격 (totalToolUses 기반)
    public let int_: Int     // 마법 공격 (totalPrompts 기반)
    public let maxHp: Int    // 최대 HP (totalSessions 기반)
    public let spd: Int      // 스피드 (streakDays 기반)
    public let def: Int      // 방어력 (장비 등급 기반)
    public var currentHp: Int

    public init(atk: Int, int_: Int, maxHp: Int, spd: Int, def: Int) {
        self.atk = atk
        self.int_ = int_
        self.maxHp = maxHp
        self.spd = spd
        self.def = def
        self.currentHp = maxHp
    }
}

// MARK: - Battle Profile

public struct BattleProfile: Codable, Sendable, Identifiable {
    public let id: String
    public let petName: String
    public let speciesId: String
    /// Optional so profiles sent by older app versions remain decodable.
    public let stage: Stage?
    /// Battle-only capped level. The stored pet level is never mutated.
    public let battleLevel: Int?
    /// Appearance snapshot captured when the profile is sent.
    public let equippedItems: EquippedItems?
    public let equipmentOffsets: EquipmentOffsets?
    /// At most three equipped instances; keeps generated fusion item artwork
    /// resolvable without transmitting the full inventory.
    public let equippedEquipment: [Equipment]?
    public let mbtiGroup: MbtiGroup
    public let speciesRarity: Rarity
    public var stats: BattleStats

    public init(
        id: String,
        petName: String,
        speciesId: String,
        mbtiGroup: MbtiGroup,
        speciesRarity: Rarity,
        stats: BattleStats,
        stage: Stage? = nil,
        battleLevel: Int? = nil,
        equippedItems: EquippedItems? = nil,
        equipmentOffsets: EquipmentOffsets? = nil,
        equippedEquipment: [Equipment]? = nil
    ) {
        self.id = id
        self.petName = petName
        self.speciesId = speciesId
        self.stage = stage
        self.mbtiGroup = mbtiGroup
        self.speciesRarity = speciesRarity
        self.stats = stats
        self.battleLevel = battleLevel
        self.equippedItems = equippedItems
        self.equipmentOffsets = equipmentOffsets
        self.equippedEquipment = equippedEquipment
    }
}

// MARK: - PetState → BattleProfile

public extension BattleProfile {
    static func from(_ state: PetState) -> BattleProfile? {
        guard state.phase == .alive,
              let speciesId = state.species,
              let species = Species.allSpecies.first(where: { $0.id == speciesId })
        else { return nil }

        let effectiveBattleLevel = min(max(state.level, 0), 50)
        let levelMult  = 1.0 + Double(effectiveBattleLevel) * 0.1
        let rarityMult = species.rarity.battleMultiplier

        let handBonus = handAtkBonus(equipped: state.equippedItems, inventory: state.inventory)
        let atk  = max(1, Int(log(Double(state.totalToolUses + 1)) * 10.0 * levelMult * rarityMult)) + handBonus
        let int_ = max(1, Int(log(Double(state.totalPrompts  + 1)) * 10.0 * levelMult * rarityMult))
        let hp   = max(100, Int(log(Double(state.totalSessions + 1)) * 150.0 * levelMult * rarityMult))
        let spd  = max(1, Int(Double(state.streakDays) * 5.0 * levelMult * rarityMult))
        let def  = calcDef(equipped: state.equippedItems, inventory: state.inventory)

        let stats = BattleStats(atk: atk, int_: int_, maxHp: hp, spd: spd, def: def)
        return BattleProfile(
            // PetState saves before slots have no petId, so machineId remains
            // the backwards-compatible identity fallback.
            id: state.petId ?? state.machineId,
            petName: state.name ?? species.name,
            speciesId: speciesId,
            mbtiGroup: species.group,
            speciesRarity: species.rarity,
            stats: stats,
            stage: state.stage,
            battleLevel: effectiveBattleLevel,
            equippedItems: state.equippedItems,
            equipmentOffsets: state.equipmentOffsets,
            equippedEquipment: equippedEquipment(from: state)
        )
    }

    // HEAD → DEF, HAND → ATK 보너스, EFFECT → DEF
    private static func calcDef(equipped: EquippedItems, inventory: [Equipment]) -> Int {
        var def = 0
        if let id = equipped.head, let item = inventory.first(where: { $0.id == id }) {
            def += item.rarity.headDef
        }
        if let id = equipped.effect, let item = inventory.first(where: { $0.id == id }) {
            def += item.rarity.effectDef
        }
        return def
    }

    // HAND 장비 ATK 보너스 (BattleEngine에서 사용)
    static func handAtkBonus(equipped: EquippedItems, inventory: [Equipment]) -> Int {
        guard let id = equipped.hand,
              let item = inventory.first(where: { $0.id == id })
        else { return 0 }
        return item.rarity.handAtkBonus
    }

    private static func equippedEquipment(from state: PetState) -> [Equipment] {
        let ids = Set([state.equippedItems.head, state.equippedItems.hand, state.equippedItems.effect].compactMap { $0 })
        return state.inventory.filter { ids.contains($0.id) }
    }
}

// MARK: - Rarity 배틀 수치

extension Rarity {
    public var battleMultiplier: Double {
        switch self {
        case .common:    return 1.0
        case .rare:      return 1.1
        case .legendary: return 1.25
        case .mythic:    return 1.5
        }
    }

    var headDef: Int {
        switch self {
        case .common:    return 5
        case .rare:      return 15
        case .legendary: return 30
        case .mythic:    return 50
        }
    }

    var effectDef: Int {
        switch self {
        case .common:    return 3
        case .rare:      return 10
        case .legendary: return 20
        case .mythic:    return 35
        }
    }

    var handAtkBonus: Int {
        switch self {
        case .common:    return 5
        case .rare:      return 15
        case .legendary: return 30
        case .mythic:    return 50
        }
    }
}
