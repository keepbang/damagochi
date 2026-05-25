import Foundation

public struct EquipmentDropper: Sendable {
    public init() {}

    public func rollRarity() -> Rarity {
        let roll = Int.random(in: 1...100)
        if roll <= 5 { return .mythic }
        if roll <= 15 { return .legendary }
        if roll <= 40 { return .rare }
        return .common
    }

    public func dropEquipment(forLevel level: Int, excluding: [String] = []) -> Equipment {
        let rarity = rollRarity()
        let slot = EquipmentSlot.allCases.randomElement()!
        return randomItem(slot: slot, rarity: rarity, level: level, excluding: excluding)
    }

    public func dropEquipment(forRarity rarity: Rarity, excluding: [String] = []) -> Equipment {
        let slot = EquipmentSlot.allCases.randomElement()!
        return randomItem(slot: slot, rarity: rarity, level: 0, excluding: excluding)
    }

    private func randomItem(slot: EquipmentSlot, rarity: Rarity, level: Int, excluding: [String]) -> Equipment {
        let pool = Self.itemPool.filter { $0.slot == slot && $0.rarity == rarity && !excluding.contains($0.id) }
        if let picked = pool.randomElement() {
            return picked
        }
        // Every level-up promises a drop; create a unique item after a category is exhausted.
        return Equipment(
            id: "item_\(slot.rawValue)_\(rarity.rawValue)_lv\(level)",
            name: "\(rarity.rawValue) \(slot.rawValue) Lv.\(level)",
            slot: slot,
            rarity: rarity,
            description: "레벨 \(level)에서 획득한 장비"
        )
    }

    public static let itemPool: [Equipment] = [
        // Head - Common
        Equipment(id: "head_common_1", name: "코딩 모자", slot: .head, rarity: .common, description: "평범한 코딩 모자"),
        Equipment(id: "head_common_2", name: "야구 모자", slot: .head, rarity: .common, description: "편안한 야구 모자"),
        Equipment(id: "head_common_3", name: "비니", slot: .head, rarity: .common, description: "따뜻한 비니"),
        // Head - Rare
        Equipment(id: "head_rare_1", name: "빛나는 왕관", slot: .head, rarity: .rare, description: "은은하게 빛나는 왕관"),
        Equipment(id: "head_rare_2", name: "마법사 모자", slot: .head, rarity: .rare, description: "별이 수놓인 마법사 모자"),
        Equipment(id: "head_rare_3", name: "사무라이 투구", slot: .head, rarity: .rare, description: "강철로 만든 사무라이 투구"),
        // Head - Legendary
        Equipment(id: "head_legendary_1", name: "용의 뿔", slot: .head, rarity: .legendary, description: "고대 용의 뿔로 만든 관"),
        Equipment(id: "head_legendary_2", name: "불꽃 왕관", slot: .head, rarity: .legendary, description: "영원히 타오르는 불꽃 왕관"),
        // Head - Mythic
        Equipment(id: "head_mythic_1", name: "천상의 후광", slot: .head, rarity: .mythic, description: "전설적인 천상의 후광"),
        Equipment(id: "head_mythic_2", name: "우주의 고리", slot: .head, rarity: .mythic, description: "행성 고리처럼 빛나는 장식"),
        // Hand - Common
        Equipment(id: "hand_common_1", name: "나무 지팡이", slot: .hand, rarity: .common, description: "평범한 나무 지팡이"),
        Equipment(id: "hand_common_2", name: "작은 방패", slot: .hand, rarity: .common, description: "기본 목재 방패"),
        Equipment(id: "hand_common_3", name: "노트북", slot: .hand, rarity: .common, description: "코딩용 노트북"),
        // Hand - Rare
        Equipment(id: "hand_rare_1", name: "마법 키보드", slot: .hand, rarity: .rare, description: "빛나는 마법 키보드"),
        Equipment(id: "hand_rare_2", name: "수정 지팡이", slot: .hand, rarity: .rare, description: "수정이 박힌 마법 지팡이"),
        Equipment(id: "hand_rare_3", name: "에너지 검", slot: .hand, rarity: .rare, description: "빛의 에너지로 만든 검"),
        // Hand - Legendary
        Equipment(id: "hand_legendary_1", name: "번개 마우스", slot: .hand, rarity: .legendary, description: "번개를 내뿜는 마우스"),
        Equipment(id: "hand_legendary_2", name: "코드 스크롤", slot: .hand, rarity: .legendary, description: "무한한 코드가 담긴 두루마리"),
        // Hand - Mythic
        Equipment(id: "hand_mythic_1", name: "무한의 터미널", slot: .hand, rarity: .mythic, description: "모든 것을 해결하는 터미널"),
        Equipment(id: "hand_mythic_2", name: "시간의 모래시계", slot: .hand, rarity: .mythic, description: "시간을 조종하는 모래시계"),
        // Effect - Common
        Equipment(id: "effect_common_1", name: "작은 반짝임", slot: .effect, rarity: .common, description: "소박한 반짝임 효과"),
        Equipment(id: "effect_common_2", name: "버블 이펙트", slot: .effect, rarity: .common, description: "귀여운 버블 효과"),
        Equipment(id: "effect_common_3", name: "잎사귀 흔들림", slot: .effect, rarity: .common, description: "부드럽게 흔들리는 잎사귀"),
        // Effect - Rare
        Equipment(id: "effect_rare_1", name: "코드 오라", slot: .effect, rarity: .rare, description: "코드가 흐르는 오라"),
        Equipment(id: "effect_rare_2", name: "번개 오라", slot: .effect, rarity: .rare, description: "전기가 흐르는 오라"),
        Equipment(id: "effect_rare_3", name: "불꽃 트레일", slot: .effect, rarity: .rare, description: "이동할 때 불꽃 자국이 남음"),
        // Effect - Legendary
        Equipment(id: "effect_legendary_1", name: "무지개 궤적", slot: .effect, rarity: .legendary, description: "무지개빛 궤적 효과"),
        Equipment(id: "effect_legendary_2", name: "별빛 폭발", slot: .effect, rarity: .legendary, description: "별이 폭발하듯 흩어지는 효과"),
        // Effect - Mythic
        Equipment(id: "effect_mythic_1", name: "우주 먼지", slot: .effect, rarity: .mythic, description: "우주의 먼지가 떠다니는 효과"),
        Equipment(id: "effect_mythic_2", name: "차원 균열", slot: .effect, rarity: .mythic, description: "차원이 찢어지는 듯한 효과"),
    ]
}
