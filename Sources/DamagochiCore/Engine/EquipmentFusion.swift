import Foundation

public enum EquipmentFusionError: LocalizedError, Equatable {
    case highestRarity
    case insufficientMaterials
    case noRewardCandidate

    public var errorDescription: String? {
        switch self {
        case .highestRarity: return "최상위 아이템은 합성할 수 없습니다."
        case .insufficientMaterials: return "장착하지 않은 같은 단계 아이템 10개가 필요합니다."
        case .noRewardCandidate: return "합성 보상을 만들 수 없습니다."
        }
    }
}

public struct EquipmentFusion: Sendable {
    public static let materialCount = 10

    public init() {}

    public func eligibleMaterials(for rarity: Rarity, in state: PetState) -> [Equipment] {
        let equipped = Set([state.equippedItems.head, state.equippedItems.hand, state.equippedItems.effect].compactMap { $0 })
        return state.inventory.filter { $0.rarity == rarity && !equipped.contains($0.id) }
    }

    @discardableResult
    public func fuse(
        rarity: Rarity,
        state: inout PetState,
        itemPool: [Equipment] = EquipmentDropper.itemPool,
        chooser: @Sendable ([Equipment]) -> Equipment? = { $0.randomElement() }
    ) throws -> Equipment {
        guard let targetRarity = rarity.next else { throw EquipmentFusionError.highestRarity }
        let materials = eligibleMaterials(for: rarity, in: state)
        guard materials.count >= Self.materialCount else { throw EquipmentFusionError.insufficientMaterials }
        let candidates = itemPool.filter { $0.rarity == targetRarity }
        guard let template = chooser(candidates) else { throw EquipmentFusionError.noRewardCandidate }

        let consumedIDs = Set(materials.prefix(Self.materialCount).map(\.id))
        let reward: Equipment
        if state.inventory.contains(where: { $0.id == template.id }) {
            reward = Equipment(
                id: "\(template.id)_fusion_\(UUID().uuidString.prefix(8))",
                name: template.name,
                englishName: template.englishName,
                catalogId: template.spriteId,
                slot: template.slot,
                rarity: template.rarity,
                description: template.description
            )
        } else {
            reward = template
        }
        state.inventory.removeAll { consumedIDs.contains($0.id) }
        state.inventory.append(reward)
        return reward
    }
}
