import Foundation

public struct AchievementChecker: Sendable {
    public init() {}

    public static let allAchievements: [Achievement] = [
        Achievement(id: "first_hatch", name: "첫 부화", description: "첫 번째 알을 부화시켰다", tier: .bronze),
        Achievement(id: "level_5", name: "초보 개발자", description: "레벨 5에 도달했다", tier: .bronze),
        Achievement(id: "level_10", name: "주니어 개발자", description: "레벨 10에 도달했다", tier: .silver),
        Achievement(id: "level_20", name: "시니어 개발자", description: "레벨 20에 도달했다", tier: .gold),
        Achievement(id: "level_30", name: "아키텍트", description: "레벨 30에 도달했다", tier: .diamond),
        Achievement(id: "level_40", name: "테크 리드", description: "레벨 40에 도달했다", tier: .diamond),
        Achievement(id: "level_50", name: "레전드", description: "레벨 50에 도달했다", tier: .diamond),
        Achievement(id: "stage_2", name: "성장기", description: "Stage 2에 진입했다", tier: .silver),
        Achievement(id: "stage_3", name: "완전체", description: "Stage 3에 진입했다", tier: .gold),
        Achievement(id: "equip_3", name: "장비 수집가", description: "장비 3개를 모았다", tier: .bronze),
        Achievement(id: "equip_10", name: "장비 마니아", description: "장비 10개를 모았다", tier: .silver),
        Achievement(id: "equip_25", name: "장비 감정가", description: "장비 25개를 모았다", tier: .gold),
        Achievement(id: "equip_50", name: "보물 창고", description: "장비 50개를 모았다", tier: .diamond),
        Achievement(id: "equip_legendary", name: "전설 획득", description: "전설 등급 장비를 획득했다", tier: .gold),
        Achievement(id: "equip_mythic", name: "신화 획득", description: "신화 등급 장비를 획득했다", tier: .diamond),
        Achievement(id: "prompts_100", name: "대화의 달인", description: "프롬프트 100회 제출", tier: .bronze),
        Achievement(id: "prompts_500", name: "질문의 기술", description: "프롬프트 500회 제출", tier: .silver),
        Achievement(id: "prompts_1000", name: "끝없는 대화", description: "프롬프트 1000회 제출", tier: .gold),
        Achievement(id: "prompts_5000", name: "프롬프트 마스터", description: "프롬프트 5,000회 제출", tier: .diamond),
        Achievement(id: "tools_100", name: "도구 벨트", description: "툴 100회 사용", tier: .bronze),
        Achievement(id: "tools_1000", name: "자동화 장인", description: "툴 1,000회 사용", tier: .gold),
        Achievement(id: "sessions_10", name: "단골 손님", description: "세션 10회 시작", tier: .bronze),
        Achievement(id: "sessions_50", name: "꾸준한 출근", description: "세션 50회 시작", tier: .silver),
        Achievement(id: "sessions_100", name: "상주 개발자", description: "세션 100회 시작", tier: .silver),
        Achievement(id: "sessions_500", name: "작업실 주인", description: "세션 500회 시작", tier: .diamond),
        Achievement(id: "workdays_7", name: "일주일 연속", description: "7 영업일 연속 사용", tier: .bronze),
        Achievement(id: "workdays_30", name: "한 달 연속", description: "30 영업일 연속 사용", tier: .silver),
        Achievement(id: "workdays_100", name: "백일의 약속", description: "100 영업일 연속 사용", tier: .diamond),
        Achievement(id: "streak_14", name: "2주 연속", description: "14일 스트릭을 달성했다", tier: .silver),
        Achievement(id: "streak_60", name: "두 달의 집중", description: "60일 스트릭을 달성했다", tier: .gold),
        Achievement(id: "rebirth", name: "불사조", description: "사망 후 다시 시작했다", tier: .silver),
        Achievement(id: "xp_1000", name: "성장의 시작", description: "총 XP 1,000 달성", tier: .silver),
        Achievement(id: "xp_10000", name: "경험의 대가", description: "총 XP 10,000 달성", tier: .gold),
        Achievement(id: "xp_50000", name: "경험의 전설", description: "총 XP 50,000 달성", tier: .diamond),
        Achievement(id: "bug_scout", name: "첫 버그", description: "버그 1마리 잡기", tier: .bronze),
        Achievement(id: "bug_hunter", name: "버그 헌터", description: "버그 10마리 잡기", tier: .bronze),
        Achievement(id: "exterminator", name: "익스터미네이터", description: "버그 100마리 잡기", tier: .silver),
        Achievement(id: "bug_500", name: "버그 종결자", description: "버그 500마리 잡기", tier: .diamond),
        Achievement(id: "golden_hand", name: "황금 손", description: "황금 버그 잡기", tier: .gold),
        Achievement(id: "golden_collector", name: "황금 수집가", description: "황금 버그 5마리 잡기", tier: .diamond),
        Achievement(id: "legendary_hunter", name: "전설의 사냥꾼", description: "레인보우 버그 잡기", tier: .diamond),
    ]

    public func check(state: PetState, activityStats: ActivityStats? = nil) -> [Achievement] {
        let unlocked = Set(state.unlockedAchievements)
        var newlyUnlocked: [Achievement] = []

        for achievement in Self.allAchievements {
            guard !unlocked.contains(achievement.id) else { continue }
            if isSatisfied(achievement: achievement, state: state, activityStats: activityStats) {
                var a = achievement
                a.unlockedAt = Date()
                newlyUnlocked.append(a)
            }
        }
        return newlyUnlocked
    }

    private func isSatisfied(achievement: Achievement, state: PetState, activityStats: ActivityStats?) -> Bool {
        let stats = activityStats ?? ActivityStats(
            prompts: state.totalPrompts,
            toolUses: state.totalToolUses,
            sessions: state.totalSessions
        )
        switch achievement.id {
        case "first_hatch":
            return state.phase == .alive && state.level >= 1
        case "level_5":
            return state.level >= 5
        case "level_10":
            return state.level >= 10
        case "level_20":
            return state.level >= 20
        case "level_30":
            return state.level >= 30
        case "level_40":
            return state.level >= 40
        case "level_50":
            return state.level >= 50
        case "stage_2":
            return state.level >= 11
        case "stage_3":
            return state.level >= 26
        case "equip_3":
            return state.inventory.count >= 3
        case "equip_10":
            return state.inventory.count >= 10
        case "equip_25":
            return state.inventory.count >= 25
        case "equip_50":
            return state.inventory.count >= 50
        case "equip_legendary":
            return state.inventory.contains { $0.rarity == .legendary }
        case "equip_mythic":
            return state.inventory.contains { $0.rarity == .mythic }
        case "prompts_100":
            return stats.prompts >= 100
        case "prompts_1000":
            return stats.prompts >= 1000
        case "prompts_500":
            return stats.prompts >= 500
        case "prompts_5000":
            return stats.prompts >= 5000
        case "tools_100":
            return stats.toolUses >= 100
        case "tools_1000":
            return stats.toolUses >= 1000
        case "sessions_10":
            return stats.sessions >= 10
        case "sessions_100":
            return stats.sessions >= 100
        case "sessions_50":
            return stats.sessions >= 50
        case "sessions_500":
            return stats.sessions >= 500
        case "workdays_7":
            return state.consecutiveWorkdays >= 7
        case "workdays_30":
            return state.consecutiveWorkdays >= 30
        case "workdays_100":
            return state.consecutiveWorkdays >= 100
        case "streak_14":
            return state.longestStreak >= 14
        case "streak_60":
            return state.longestStreak >= 60
        case "rebirth":
            return state.deathCount >= 1 && state.phase == .egg
        case "xp_10000":
            return state.totalXp >= 10000
        case "xp_1000":
            return state.totalXp >= 1000
        case "xp_50000":
            return state.totalXp >= 50000
        case "bug_scout":
            return state.bugsCaught >= 1
        case "bug_hunter":
            return state.bugsCaught >= 10
        case "exterminator":
            return state.bugsCaught >= 100
        case "bug_500":
            return state.bugsCaught >= 500
        case "golden_hand":
            return state.goldenBugsCaught >= 1
        case "golden_collector":
            return state.goldenBugsCaught >= 5
        case "legendary_hunter":
            return state.rainbowBugsCaught >= 1
        default:
            return false
        }
    }
}
