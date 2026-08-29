import Foundation

public enum MbtiGroup: String, Codable, Sendable {
    case nt
    case nf
    case sj
    case sp
}

public struct Species: Sendable {
    public let id: String
    public let name: String
    public let englishName: String
    public let spriteKey: String
    public let group: MbtiGroup
    public let rarity: Rarity

    public init(
        id: String,
        name: String,
        englishName: String? = nil,
        spriteKey: String? = nil,
        group: MbtiGroup,
        rarity: Rarity
    ) {
        self.id = id
        self.name = name
        self.englishName = englishName ?? id
        self.spriteKey = spriteKey ?? id
        self.group = group
        self.rarity = rarity
    }

    public static let allSpecies: [Species] = [
        // NT - Analytical / Theoretical
        Species(id: "owl",       name: "올빼미",   group: .nt, rarity: .common),
        Species(id: "wolf",      name: "늑대",     group: .nt, rarity: .common),
        Species(id: "crystal",   name: "수정",     group: .nt, rarity: .common),
        Species(id: "octopus",   name: "문어",     group: .nt, rarity: .rare),
        Species(id: "android",   name: "안드로이드", group: .nt, rarity: .rare),
        Species(id: "phoenix",   name: "불사조",   group: .nt, rarity: .rare),
        Species(id: "dragon",    name: "드래곤",   group: .nt, rarity: .legendary),
        Species(id: "sphinx",    name: "스핑크스",  group: .nt, rarity: .legendary),
        Species(id: "robot",     name: "로봇",     group: .nt, rarity: .mythic),
        Species(id: "nebula",    name: "성운",     group: .nt, rarity: .mythic),
        // NF - Idealistic / Creative
        Species(id: "butterfly", name: "나비",     group: .nf, rarity: .common),
        Species(id: "cloud",     name: "구름",     group: .nf, rarity: .common),
        Species(id: "lotus",     name: "연꽃",     group: .nf, rarity: .common),
        Species(id: "jellyfish", name: "해파리",   group: .nf, rarity: .rare),
        Species(id: "fox",       name: "여우",     group: .nf, rarity: .rare),
        Species(id: "unicorn",   name: "유니콘",   group: .nf, rarity: .rare),
        Species(id: "mushroom",  name: "버섯",     group: .nf, rarity: .legendary),
        Species(id: "fairy",     name: "요정",     group: .nf, rarity: .legendary),
        Species(id: "celestial", name: "천상",     group: .nf, rarity: .mythic),
        Species(id: "aurora",    name: "오로라",   group: .nf, rarity: .mythic),
        // SJ - Traditional / Responsible
        Species(id: "turtle",    name: "거북이",   group: .sj, rarity: .common),
        Species(id: "penguin",   name: "펭귄",     group: .sj, rarity: .common),
        Species(id: "bear",      name: "곰",       group: .sj, rarity: .common),
        Species(id: "rock",      name: "돌",       group: .sj, rarity: .rare),
        Species(id: "cactus",    name: "선인장",   group: .sj, rarity: .rare),
        Species(id: "hedgehog",  name: "고슴도치",  group: .sj, rarity: .rare),
        Species(id: "parrot",    name: "파리지옥",  group: .sj, rarity: .legendary),
        Species(id: "golem",     name: "골렘",     group: .sj, rarity: .legendary),
        Species(id: "elephant",  name: "코끼리",   group: .sj, rarity: .mythic),
        Species(id: "kraken",    name: "크라켄",   group: .sj, rarity: .mythic),
        // SP - Adventurous / Free
        Species(id: "cat",       name: "고양이",   group: .sp, rarity: .common),
        Species(id: "puppy",     name: "강아지",   group: .sp, rarity: .common),
        Species(id: "rabbit",    name: "토끼",     group: .sp, rarity: .common),
        Species(id: "flame",     name: "불꽃",     group: .sp, rarity: .rare),
        Species(id: "bat",       name: "박쥐",     group: .sp, rarity: .rare),
        Species(id: "scorpion",  name: "전갈",     group: .sp, rarity: .rare),
        Species(id: "fish",      name: "물고기",   group: .sp, rarity: .legendary),
        Species(id: "lightning", name: "번개",     group: .sp, rarity: .legendary),
        Species(id: "moonrabbit", name: "달토끼",  group: .sp, rarity: .mythic),
        Species(id: "comet",     name: "혜성",     group: .sp, rarity: .mythic),

        // NT expansion — analytical / theoretical
        Species(id: "raven", name: "큰까마귀", englishName: "Raven", group: .nt, rarity: .common),
        Species(id: "otter", name: "수달", englishName: "Otter", group: .nt, rarity: .common),
        Species(id: "chameleon", name: "카멜레온", englishName: "Chameleon", group: .nt, rarity: .common),
        Species(id: "atlas_beetle", name: "장수풍뎅이", englishName: "Atlas Beetle", group: .nt, rarity: .rare),
        Species(id: "clockwork", name: "태엽 인형", englishName: "Clockwork Doll", group: .nt, rarity: .rare),
        Species(id: "orb", name: "지식의 구체", englishName: "Knowledge Orb", group: .nt, rarity: .rare),
        Species(id: "gryphon", name: "그리폰", englishName: "Gryphon", group: .nt, rarity: .legendary),
        Species(id: "leviathan", name: "레비아탄", englishName: "Leviathan", group: .nt, rarity: .legendary),
        Species(id: "singularity", name: "특이점", englishName: "Singularity", group: .nt, rarity: .mythic),
        Species(id: "chrono_dragon", name: "시간용", englishName: "Chrono Dragon", group: .nt, rarity: .mythic),

        // NF expansion — idealistic / creative
        Species(id: "deer", name: "사슴", englishName: "Deer", group: .nf, rarity: .common),
        Species(id: "seal", name: "물개", englishName: "Seal", group: .nf, rarity: .common),
        Species(id: "peach", name: "복숭아", englishName: "Peach", group: .nf, rarity: .common),
        Species(id: "luna_moth", name: "달나방", englishName: "Luna Moth", group: .nf, rarity: .rare),
        Species(id: "capybara", name: "카피바라", englishName: "Capybara", group: .nf, rarity: .rare),
        Species(id: "mermaid", name: "인어", englishName: "Mermaid", group: .nf, rarity: .rare),
        Species(id: "pegasus", name: "페가수스", englishName: "Pegasus", group: .nf, rarity: .legendary),
        Species(id: "moonflower", name: "달꽃", englishName: "Moonflower", group: .nf, rarity: .legendary),
        Species(id: "seraph", name: "세라프", englishName: "Seraph", group: .nf, rarity: .mythic),
        Species(id: "dream_whale", name: "꿈고래", englishName: "Dream Whale", group: .nf, rarity: .mythic),

        // SJ expansion — responsible / steady
        Species(id: "beaver", name: "비버", englishName: "Beaver", group: .sj, rarity: .common),
        Species(id: "koala", name: "코알라", englishName: "Koala", group: .sj, rarity: .common),
        Species(id: "acorn", name: "도토리", englishName: "Acorn", group: .sj, rarity: .common),
        Species(id: "badger", name: "오소리", englishName: "Badger", group: .sj, rarity: .rare),
        Species(id: "teapot", name: "찻주전자", englishName: "Teapot", group: .sj, rarity: .rare),
        Species(id: "lantern", name: "등불", englishName: "Lantern", group: .sj, rarity: .rare),
        Species(id: "mammoth", name: "매머드", englishName: "Mammoth", group: .sj, rarity: .legendary),
        Species(id: "bastion", name: "요새", englishName: "Bastion", group: .sj, rarity: .legendary),
        Species(id: "world_tree", name: "세계수", englishName: "World Tree", group: .sj, rarity: .mythic),
        Species(id: "titan", name: "타이탄", englishName: "Titan", group: .sj, rarity: .mythic),

        // SP expansion — adventurous / free
        Species(id: "raccoon", name: "너구리", englishName: "Raccoon", group: .sp, rarity: .common),
        Species(id: "ferret", name: "페럿", englishName: "Ferret", group: .sp, rarity: .common),
        Species(id: "gecko", name: "도마뱀", englishName: "Gecko", group: .sp, rarity: .common),
        Species(id: "skate", name: "가오리", englishName: "Skate", group: .sp, rarity: .rare),
        Species(id: "parakeet", name: "앵무새", englishName: "Parakeet", group: .sp, rarity: .rare),
        Species(id: "ninja", name: "닌자", englishName: "Ninja", group: .sp, rarity: .rare),
        Species(id: "wyvern", name: "와이번", englishName: "Wyvern", group: .sp, rarity: .legendary),
        Species(id: "thunderbird", name: "썬더버드", englishName: "Thunderbird", group: .sp, rarity: .legendary),
        Species(id: "starfox", name: "별여우", englishName: "Star Fox", group: .sp, rarity: .mythic),
        Species(id: "void_runner", name: "공허 질주자", englishName: "Void Runner", group: .sp, rarity: .mythic),
    ]
}
