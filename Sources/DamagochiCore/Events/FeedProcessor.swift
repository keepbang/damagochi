import Foundation

public struct FeedResult: Sendable {
    public var xpGained: Int
    public var hatched: Bool
    public var levelsGained: Int
    public var droppedEquipment: [Equipment]
    public var newAchievements: [Achievement]
    public var streakUpdated: Bool
    public var newStreakDays: Int

    public init(xpGained: Int = 0, hatched: Bool = false, levelsGained: Int = 0,
                droppedEquipment: [Equipment] = [], newAchievements: [Achievement] = [],
                streakUpdated: Bool = false, newStreakDays: Int = 0) {
        self.xpGained = xpGained
        self.hatched = hatched
        self.levelsGained = levelsGained
        self.droppedEquipment = droppedEquipment
        self.newAchievements = newAchievements
        self.streakUpdated = streakUpdated
        self.newStreakDays = newStreakDays
    }

    public func merged(with other: FeedResult) -> FeedResult {
        FeedResult(
            xpGained: xpGained + other.xpGained,
            hatched: hatched || other.hatched,
            levelsGained: levelsGained + other.levelsGained,
            droppedEquipment: droppedEquipment + other.droppedEquipment,
            newAchievements: newAchievements + other.newAchievements,
            streakUpdated: streakUpdated || other.streakUpdated,
            newStreakDays: max(newStreakDays, other.newStreakDays)
        )
    }
}

public struct FeedProcessor: Sendable {
    private let xpEngine: XPEngine
    private let healthSystem: HealthSystem
    private let personalityTracker: PersonalityTracker
    private let evolutionEngine: EvolutionEngine
    private let equipmentDropper: EquipmentDropper
    private let achievementChecker: AchievementChecker

    public init(
        xpEngine: XPEngine = XPEngine(),
        healthSystem: HealthSystem = HealthSystem(),
        personalityTracker: PersonalityTracker = PersonalityTracker(),
        evolutionEngine: EvolutionEngine = EvolutionEngine(),
        equipmentDropper: EquipmentDropper = EquipmentDropper(),
        achievementChecker: AchievementChecker = AchievementChecker()
    ) {
        self.xpEngine = xpEngine
        self.healthSystem = healthSystem
        self.personalityTracker = personalityTracker
        self.evolutionEngine = evolutionEngine
        self.equipmentDropper = equipmentDropper
        self.achievementChecker = achievementChecker
    }

    @discardableResult
    public func process(
        event: BehaviorEvent,
        state: inout PetState,
        xpOverride: Int? = nil
    ) -> FeedResult {
        if case .stop = event.kind { return FeedResult() }
        if case .notification = event.kind { return FeedResult() }

        var streakUpdated = false
        var newStreakDays = 0
        if case .sessionStart = event.kind {
            let prevLastDate = state.lastStreakDate
            updateStreak(state: &state, now: event.timestamp)
            updateWorkdays(state: &state, now: event.timestamp)
            if state.lastStreakDate != prevLastDate {
                streakUpdated = true
                newStreakDays = state.streakDays
            }
        }

        let xp = xpOverride ?? xpEngine.xpForEvent(event, streakDays: state.streakDays)
        state.totalXp += xp
        if state.phase != .egg {
            state.xp += xp
        }
        state.lastActiveAt = event.timestamp

        switch event.kind {
        case .prompt: state.totalPrompts += 1
        case .toolUse: state.totalToolUses += 1
        case .sessionStart: state.totalSessions += 1
        case .stop, .notification: break
        }
        state.recordActivity(event.kind, source: event.source)

        personalityTracker.updateMbti(scores: &state.mbtiScores, event: event)

        var hatched = false
        if state.phase == .egg && xpEngine.shouldHatch(totalXp: state.totalXp) {
            evolutionEngine.evolve(state: &state)
            state.xp = state.totalXp - 100
            hatched = true
        }

        var levelsGained = 0
        var droppedEquipment: [Equipment] = []
        if state.phase == .alive {
            let prevLevel = state.level
            let result = xpEngine.checkLevelUp(currentLevel: state.level, currentXp: state.xp)
            state.level = result.newLevel
            state.xp = result.remainingXp
            levelsGained = state.level - prevLevel

            if levelsGained > 0 {
                for lv in (prevLevel + 1)...(prevLevel + levelsGained) {
                    let item = equipmentDropper.dropEquipment(forLevel: lv, excluding: state.inventory.map(\.id))
                    if !state.inventory.contains(where: { $0.id == item.id }) {
                        state.inventory.append(item)
                        droppedEquipment.append(item)
                    }
                }
            }

            healthSystem.applyRecovery(to: &state)
        }

        let newAchievements = achievementChecker.check(state: state)
        for achievement in newAchievements {
            state.unlockedAchievements.append(achievement.id)
        }

        return FeedResult(
            xpGained: xp,
            hatched: hatched,
            levelsGained: levelsGained,
            droppedEquipment: droppedEquipment,
            newAchievements: newAchievements,
            streakUpdated: streakUpdated,
            newStreakDays: newStreakDays
        )
    }

    // MARK: - Streak

    private func updateStreak(state: inout PetState, now: Date) {
        let calendar = Calendar.current
        guard let lastDate = state.lastStreakDate else {
            state.streakDays = 1
            state.lastStreakDate = now
            state.longestStreak = max(state.longestStreak, 1)
            grantStreakMilestone(state: &state)
            return
        }

        let lastDay = calendar.startOfDay(for: lastDate)
        let today = calendar.startOfDay(for: now)

        guard lastDay != today else { return }

        let dayDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
        // 과거 타임스탬프 이벤트가 들어와도 스트릭이 거꾸로 가지 않도록 방어.
        guard dayDiff > 0 else { return }
        if dayDiff == 1 {
            state.streakDays += 1
        } else {
            state.streakDays = 1
        }
        state.lastStreakDate = now
        state.longestStreak = max(state.longestStreak, state.streakDays)
        grantStreakMilestone(state: &state)
    }

    // MARK: - Workdays (영업일 연속 카운터)

    private func updateWorkdays(state: inout PetState, now: Date) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        // 주말(토/일) 세션은 영업일 카운터에 영향을 주지 않는다.
        let weekday = calendar.component(.weekday, from: today)
        guard weekday != 1 && weekday != 7 else { return }

        guard let lastDate = state.lastWorkdayDate else {
            state.consecutiveWorkdays = 1
            state.lastWorkdayDate = today
            return
        }

        let lastDay = calendar.startOfDay(for: lastDate)
        guard lastDay != today else { return }

        let businessDayDiff = countBusinessDays(from: lastDay, to: today)
        // 과거 타임스탬프 이벤트가 들어와도 카운터가 거꾸로 가지 않도록 방어.
        guard businessDayDiff > 0 else { return }
        if businessDayDiff == 1 {
            state.consecutiveWorkdays += 1
        } else {
            state.consecutiveWorkdays = 1
        }
        state.lastWorkdayDate = today
    }

    private func countBusinessDays(from start: Date, to end: Date) -> Int {
        let calendar = Calendar.current
        var count = 0
        var date = start
        while date < end {
            date = calendar.date(byAdding: .day, value: 1, to: date)!
            let weekday = calendar.component(.weekday, from: date)
            if weekday != 1 && weekday != 7 {
                count += 1
            }
        }
        return count
    }

    private func grantStreakMilestone(state: inout PetState) {
        let milestones: [(Int, Rarity)] = [(7, .rare), (30, .legendary), (100, .mythic)]
        for (days, rarity) in milestones {
            let milestoneKey = "streak_milestone_\(days)"
            if state.streakDays == days && !state.unlockedAchievements.contains(milestoneKey) {
                state.unlockedAchievements.append(milestoneKey)
                let item = equipmentDropper.dropEquipment(forRarity: rarity, excluding: state.inventory.map(\.id))
                if !state.inventory.contains(where: { $0.id == item.id }) {
                    state.inventory.append(item)
                }
            }
        }
    }
}
