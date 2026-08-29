import Foundation

public enum Rarity: String, Codable, Sendable, Hashable {
    case common
    case rare
    case legendary
    case mythic
}

public struct Equipment: Codable, Sendable, Identifiable {
    public let id: String
    public let name: String
    /// Human-readable catalog name. Optional keeps saves written before the
    /// catalog expansion decodable.
    public let englishName: String?
    /// For generated duplicate rewards, points back to the artwork/catalog ID.
    public let catalogId: String?
    public let slot: EquipmentSlot
    public let rarity: Rarity
    public let description: String

    public init(
        id: String,
        name: String,
        englishName: String? = nil,
        catalogId: String? = nil,
        slot: EquipmentSlot,
        rarity: Rarity,
        description: String
    ) {
        self.id = id
        self.name = name
        self.englishName = englishName
        self.catalogId = catalogId
        self.slot = slot
        self.rarity = rarity
        self.description = description
    }

    public var spriteId: String { catalogId ?? id }
}

public enum EquipmentSlot: String, Codable, Sendable, CaseIterable {
    case head
    case hand
    case effect
}

public extension Rarity {
    var next: Rarity? {
        switch self {
        case .common: return .rare
        case .rare: return .legendary
        case .legendary: return .mythic
        case .mythic: return nil
        }
    }
}
