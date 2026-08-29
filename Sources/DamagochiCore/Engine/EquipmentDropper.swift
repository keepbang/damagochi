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
    ] + expandedItemPool

    private static let expandedItemPool: [Equipment] = [
        Equipment(id: "head_common_4", name: "탐험가 모자", englishName: "Explorer Cap", slot: .head, rarity: .common, description: "가벼운 탐험가 모자"),
        Equipment(id: "head_common_5", name: "헤드폰", englishName: "Headphones", slot: .head, rarity: .common, description: "집중을 돕는 헤드폰"),
        Equipment(id: "head_common_6", name: "꽃 장식", englishName: "Flower Pin", slot: .head, rarity: .common, description: "기분 좋은 꽃 장식"),
        Equipment(id: "head_rare_4", name: "네온 바이저", englishName: "Neon Visor", slot: .head, rarity: .rare, description: "빛나는 네온 바이저"),
        Equipment(id: "head_rare_5", name: "별 관측 모자", englishName: "Stargazer Hat", slot: .head, rarity: .rare, description: "별을 보는 모자"),
        Equipment(id: "head_rare_6", name: "해적 모자", englishName: "Pirate Hat", slot: .head, rarity: .rare, description: "용감한 해적 모자"),
        Equipment(id: "head_legendary_3", name: "태양 왕관", englishName: "Solar Crown", slot: .head, rarity: .legendary, description: "태양빛 왕관"),
        Equipment(id: "head_legendary_4", name: "월계관", englishName: "Laurel Crown", slot: .head, rarity: .legendary, description: "승리의 월계관"),
        Equipment(id: "head_mythic_3", name: "은하 왕관", englishName: "Galaxy Crown", slot: .head, rarity: .mythic, description: "은하가 흐르는 왕관"),
        Equipment(id: "head_mythic_4", name: "시간의 후광", englishName: "Chrono Halo", slot: .head, rarity: .mythic, description: "시간을 품은 후광"),

        Equipment(id: "hand_common_4", name: "픽셀 붓", englishName: "Pixel Brush", slot: .hand, rarity: .common, description: "픽셀을 그리는 붓"),
        Equipment(id: "hand_common_5", name: "작은 랜턴", englishName: "Pocket Lantern", slot: .hand, rarity: .common, description: "어둠을 밝히는 랜턴"),
        Equipment(id: "hand_common_6", name: "메모장", englishName: "Notebook", slot: .hand, rarity: .common, description: "아이디어를 적는 메모장"),
        Equipment(id: "hand_rare_4", name: "레이저 펜", englishName: "Laser Pen", slot: .hand, rarity: .rare, description: "빛으로 쓰는 펜"),
        Equipment(id: "hand_rare_5", name: "드론 리모컨", englishName: "Drone Remote", slot: .hand, rarity: .rare, description: "탐색 드론 리모컨"),
        Equipment(id: "hand_rare_6", name: "음파 기타", englishName: "Sonic Guitar", slot: .hand, rarity: .rare, description: "리듬을 만드는 기타"),
        Equipment(id: "hand_legendary_3", name: "별빛 창", englishName: "Starlight Spear", slot: .hand, rarity: .legendary, description: "별빛으로 만든 창"),
        Equipment(id: "hand_legendary_4", name: "룬 해머", englishName: "Rune Hammer", slot: .hand, rarity: .legendary, description: "룬이 새겨진 망치"),
        Equipment(id: "hand_mythic_3", name: "우주 큐브", englishName: "Cosmic Cube", slot: .hand, rarity: .mythic, description: "공간을 접는 큐브"),
        Equipment(id: "hand_mythic_4", name: "운명의 카드", englishName: "Fate Cards", slot: .hand, rarity: .mythic, description: "운명을 바꾸는 카드"),

        Equipment(id: "effect_common_4", name: "눈송이", englishName: "Snowflakes", slot: .effect, rarity: .common, description: "포근한 눈송이"),
        Equipment(id: "effect_common_5", name: "음표", englishName: "Music Notes", slot: .effect, rarity: .common, description: "경쾌한 음표"),
        Equipment(id: "effect_common_6", name: "반딧불", englishName: "Fireflies", slot: .effect, rarity: .common, description: "작은 반딧불"),
        Equipment(id: "effect_rare_4", name: "오로라 오라", englishName: "Aurora Aura", slot: .effect, rarity: .rare, description: "오로라빛 오라"),
        Equipment(id: "effect_rare_5", name: "파도 이펙트", englishName: "Wave Effect", slot: .effect, rarity: .rare, description: "잔잔한 파도"),
        Equipment(id: "effect_rare_6", name: "꽃잎 소용돌이", englishName: "Petal Swirl", slot: .effect, rarity: .rare, description: "꽃잎이 도는 효과"),
        Equipment(id: "effect_legendary_3", name: "태양 플레어", englishName: "Solar Flare", slot: .effect, rarity: .legendary, description: "강렬한 태양 플레어"),
        Equipment(id: "effect_legendary_4", name: "얼음 폭풍", englishName: "Ice Storm", slot: .effect, rarity: .legendary, description: "차가운 얼음 폭풍"),
        Equipment(id: "effect_mythic_3", name: "별자리", englishName: "Constellation", slot: .effect, rarity: .mythic, description: "별자리의 힘"),
        Equipment(id: "effect_mythic_4", name: "꿈의 문", englishName: "Dream Gate", slot: .effect, rarity: .mythic, description: "꿈으로 통하는 문"),
    ]
}
