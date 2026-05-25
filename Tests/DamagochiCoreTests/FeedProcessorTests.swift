import Testing
import Foundation
@testable import DamagochiCore

@Test func feedProcessorAddsXp() {
    let processor = FeedProcessor()
    var state = PetState(machineId: "test")
    let event = BehaviorEvent(kind: .prompt)

    processor.process(event: event, state: &state)
    #expect(state.totalXp == 5)
    #expect(state.totalPrompts == 1)
}

@Test func feedProcessorHatchesAt100Xp() {
    let processor = FeedProcessor()
    var state = PetState(machineId: "test")
    state.xp = 95
    state.totalXp = 95

    let event = BehaviorEvent(kind: .sessionStart)
    let result = processor.process(event: event, state: &state)

    #expect(result.hatched)
    #expect(state.phase == .alive)
    #expect(state.species != nil)
    #expect(state.level == 1)
}

@Test func feedProcessorLevelUpDropsEquipment() {
    let processor = FeedProcessor()
    var state = PetState(machineId: "test")
    state.phase = .alive
    state.level = 1
    state.xp = 95

    let event = BehaviorEvent(kind: .sessionStart)
    let result = processor.process(event: event, state: &state)

    #expect(result.levelsGained == 1)
    #expect(result.droppedEquipment.count == 1)
    #expect(state.inventory.count == 1)
}

@Test func feedProcessorTracksToolUses() {
    let processor = FeedProcessor()
    var state = PetState(machineId: "test")

    let event = BehaviorEvent(kind: .toolUse, metadata: ["tool": "Read"])
    processor.process(event: event, state: &state)

    #expect(state.totalToolUses == 1)
    #expect(state.totalXp == 3)
}

@Test func feedProcessorTracksStatsSeparatelyByActivitySource() {
    let processor = FeedProcessor()
    var state = PetState(machineId: "test-sources")

    processor.process(
        event: BehaviorEvent(kind: .prompt, metadata: ["source": "claude"]),
        state: &state
    )
    processor.process(
        event: BehaviorEvent(kind: .toolUse, metadata: ["source": "codex"]),
        state: &state
    )
    processor.process(
        event: BehaviorEvent(kind: .sessionStart, metadata: ["source": "codex"]),
        state: &state
    )

    #expect(state.totalPrompts == 1)
    #expect(state.totalToolUses == 1)
    #expect(state.totalSessions == 1)
    #expect(state.stats(for: .claude) == ActivityStats(prompts: 1))
    #expect(state.stats(for: .codex) == ActivityStats(toolUses: 1, sessions: 1))
    #expect(state.unclassifiedStats == ActivityStats())
}

@Test func sourceStatsRemainCompatibleWithLegacyUnclassifiedEvents() {
    let processor = FeedProcessor()
    var state = PetState(machineId: "test-legacy-sources")

    processor.process(event: BehaviorEvent(kind: .prompt), state: &state)
    processor.process(
        event: BehaviorEvent(kind: .prompt, metadata: ["source": "codex"]),
        state: &state
    )

    #expect(state.stats(for: .codex) == ActivityStats(prompts: 1))
    #expect(state.unclassifiedStats == ActivityStats(prompts: 1))
}

@Test func feedProcessorUpdatesMbti() {
    let processor = FeedProcessor()
    var state = PetState(machineId: "test")

    let event = BehaviorEvent(kind: .toolUse, metadata: ["tool": "Grep"])
    processor.process(event: event, state: &state)

    #expect(state.mbtiScores.thinking == 1)
}

@Test func feedProcessorUnlocksAchievements() {
    let processor = FeedProcessor()
    var state = PetState(machineId: "test")
    state.phase = .alive
    state.level = 4
    state.xp = 245

    let event = BehaviorEvent(kind: .sessionStart)
    let result = processor.process(event: event, state: &state)

    #expect(state.level >= 5)
    let ids = Set(result.newAchievements.map(\.id))
    #expect(ids.contains("level_5"))
}

@Test func feedProcessorInitializesWorkdaysOnFirstBusinessDaySession() throws {
    let processor = FeedProcessor()
    var state = PetState(machineId: "test-workdays")
    state.phase = .alive

    // 월요일 (weekday == 2)
    let components = DateComponents(year: 2026, month: 1, day: 5, hour: 10)
    let monday = try #require(Calendar.current.date(from: components))

    processor.process(event: BehaviorEvent(kind: .sessionStart, timestamp: monday), state: &state)

    #expect(state.consecutiveWorkdays == 1)
    #expect(state.lastWorkdayDate != nil)
}

@Test func feedProcessorIncrementsWorkdaysOnConsecutiveBusinessDays() throws {
    let processor = FeedProcessor()
    var state = PetState(machineId: "test-workdays")
    state.phase = .alive

    let calendar = Calendar.current
    let monday = try #require(calendar.date(from: DateComponents(year: 2026, month: 1, day: 5, hour: 10)))
    let tuesday = try #require(calendar.date(from: DateComponents(year: 2026, month: 1, day: 6, hour: 10)))
    let wednesday = try #require(calendar.date(from: DateComponents(year: 2026, month: 1, day: 7, hour: 10)))

    processor.process(event: BehaviorEvent(kind: .sessionStart, timestamp: monday), state: &state)
    processor.process(event: BehaviorEvent(kind: .sessionStart, timestamp: tuesday), state: &state)
    processor.process(event: BehaviorEvent(kind: .sessionStart, timestamp: wednesday), state: &state)

    #expect(state.consecutiveWorkdays == 3)
}

@Test func feedProcessorBridgesWeekendForWorkdays() throws {
    // 금요일 → 월요일은 주말을 건너뛰지만 영업일 기준으로는 연속이다.
    let processor = FeedProcessor()
    var state = PetState(machineId: "test-workdays")
    state.phase = .alive

    let calendar = Calendar.current
    let friday = try #require(calendar.date(from: DateComponents(year: 2026, month: 1, day: 2, hour: 10)))
    let monday = try #require(calendar.date(from: DateComponents(year: 2026, month: 1, day: 5, hour: 10)))

    processor.process(event: BehaviorEvent(kind: .sessionStart, timestamp: friday), state: &state)
    #expect(state.consecutiveWorkdays == 1)
    processor.process(event: BehaviorEvent(kind: .sessionStart, timestamp: monday), state: &state)
    #expect(state.consecutiveWorkdays == 2)
}

@Test func feedProcessorResetsWorkdaysWhenBusinessDayMissed() throws {
    // 월요일 → 수요일은 화요일을 건너뛰었으므로 카운터 리셋.
    let processor = FeedProcessor()
    var state = PetState(machineId: "test-workdays")
    state.phase = .alive

    let calendar = Calendar.current
    let monday = try #require(calendar.date(from: DateComponents(year: 2026, month: 1, day: 5, hour: 10)))
    let wednesday = try #require(calendar.date(from: DateComponents(year: 2026, month: 1, day: 7, hour: 10)))

    processor.process(event: BehaviorEvent(kind: .sessionStart, timestamp: monday), state: &state)
    processor.process(event: BehaviorEvent(kind: .sessionStart, timestamp: wednesday), state: &state)

    #expect(state.consecutiveWorkdays == 1)
}

@Test func feedProcessorIgnoresWeekendSessionForWorkdays() throws {
    // 주말 세션은 영업일 카운터에 영향을 주지 않는다.
    let processor = FeedProcessor()
    var state = PetState(machineId: "test-workdays")
    state.phase = .alive

    let calendar = Calendar.current
    let friday = try #require(calendar.date(from: DateComponents(year: 2026, month: 1, day: 2, hour: 10)))
    let saturday = try #require(calendar.date(from: DateComponents(year: 2026, month: 1, day: 3, hour: 10)))

    processor.process(event: BehaviorEvent(kind: .sessionStart, timestamp: friday), state: &state)
    let workdaysBefore = state.consecutiveWorkdays
    let lastWorkdayBefore = state.lastWorkdayDate
    processor.process(event: BehaviorEvent(kind: .sessionStart, timestamp: saturday), state: &state)

    #expect(state.consecutiveWorkdays == workdaysBefore)
    #expect(state.lastWorkdayDate == lastWorkdayBefore)
}

@Test func feedProcessorIgnoresStaleSessionStartForWorkdays() throws {
    // 과거 타임스탬프의 sessionStart가 replay 되어도 영업일 카운터가 거꾸로 가지 않는다.
    let processor = FeedProcessor()
    var state = PetState(machineId: "test-workdays")
    state.phase = .alive

    let calendar = Calendar.current
    let monday = try #require(calendar.date(from: DateComponents(year: 2026, month: 1, day: 5, hour: 10)))
    let tuesday = try #require(calendar.date(from: DateComponents(year: 2026, month: 1, day: 6, hour: 10)))
    let wednesday = try #require(calendar.date(from: DateComponents(year: 2026, month: 1, day: 7, hour: 10)))

    state.consecutiveWorkdays = 3
    state.lastWorkdayDate = wednesday

    processor.process(event: BehaviorEvent(kind: .sessionStart, timestamp: monday), state: &state)
    processor.process(event: BehaviorEvent(kind: .sessionStart, timestamp: tuesday), state: &state)

    #expect(state.consecutiveWorkdays == 3)
    #expect(state.lastWorkdayDate == wednesday)
}

@Test func feedProcessorIgnoresStaleSessionStartForStreak() throws {
    // 앱 재시작 시 pending 파일에서 과거 타임스탬프의 sessionStart 이벤트가 replay 되어도
    // 이미 누적된 streakDays가 거꾸로 깎이지 않아야 한다.
    let processor = FeedProcessor()
    var state = PetState(machineId: "test-streak")
    state.phase = .alive

    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let twoDaysAgo = try #require(calendar.date(byAdding: .day, value: -2, to: today))
    let yesterday = try #require(calendar.date(byAdding: .day, value: -1, to: today))

    state.streakDays = 4
    state.longestStreak = 4
    state.lastStreakDate = today

    processor.process(event: BehaviorEvent(kind: .sessionStart, timestamp: twoDaysAgo), state: &state)
    processor.process(event: BehaviorEvent(kind: .sessionStart, timestamp: yesterday), state: &state)

    #expect(state.streakDays == 4)
    #expect(state.lastStreakDate == today)
}
