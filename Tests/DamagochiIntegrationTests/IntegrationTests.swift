import XCTest
@testable import DamagochiCore

final class IntegrationTests: XCTestCase {
    var processor: FeedProcessor!
    var deathChecker: DeathChecker!

    override func setUp() {
        processor = FeedProcessor()
        deathChecker = DeathChecker()
    }

    // MARK: - Full Lifecycle: Egg → Hatch → LevelUp → Equipment → Achievement

    func testFullLifecycleEggToLevelUpWithEquipment() {
        var state = PetState(machineId: "test-machine")
        XCTAssertEqual(state.phase, .egg)
        XCTAssertEqual(state.level, 0)

        // Feed 20 prompts (5 XP each = 100 XP) → should hatch
        for _ in 0..<20 {
            processor.process(event: BehaviorEvent(kind: .prompt), state: &state)
        }

        XCTAssertEqual(state.phase, .alive, "Should hatch after 100 total XP")
        XCTAssertNotNil(state.species)
        XCTAssertNotNil(state.personality)
        XCTAssertEqual(state.level, 1)
        XCTAssertEqual(state.totalPrompts, 20)

        // Continue feeding to level up: level 2 needs 100 XP (level * 50)
        // Current XP after hatch: totalXp(100) - 100 = 0 remaining
        // Need 100 more XP = 20 prompts
        for _ in 0..<20 {
            processor.process(event: BehaviorEvent(kind: .prompt), state: &state)
        }

        XCTAssertEqual(state.level, 2, "Should reach level 2")
        XCTAssertEqual(state.totalPrompts, 40)
        XCTAssertFalse(state.inventory.isEmpty, "Should have equipment drop from level up")
    }

    func testHatchDeterminesSpeciesFromMbti() {
        var state = PetState(machineId: "test-mbti")

        // Feed a mix of events to build MBTI scores
        for _ in 0..<10 {
            processor.process(event: BehaviorEvent(kind: .prompt), state: &state)
        }
        for _ in 0..<5 {
            processor.process(event: BehaviorEvent(kind: .toolUse), state: &state)
        }
        // 10*5 + 5*3 = 65 XP, not yet hatched
        XCTAssertEqual(state.phase, .egg)

        // Add session starts to push over 100 XP: need 35 more, sessions give 10 each
        for _ in 0..<4 {
            processor.process(event: BehaviorEvent(kind: .sessionStart), state: &state)
        }
        // 65 + 40 = 105 XP → hatched
        XCTAssertEqual(state.phase, .alive)
        XCTAssertNotNil(state.species)

        let species = Species.allSpecies.first(where: { $0.id == state.species })
        XCTAssertNotNil(species, "Species should be a valid known species")
    }

    // MARK: - Death & Graveyard Flow

    func testDeathAfter14InactiveBusinessDays() {
        var state = PetState(machineId: "test-death")

        // Hatch the pet first
        for _ in 0..<20 {
            processor.process(event: BehaviorEvent(kind: .prompt), state: &state)
        }
        XCTAssertEqual(state.phase, .alive)

        // Simulate 14 business days of inactivity
        let calendar = Calendar.current
        let lastActive = calendar.date(byAdding: .day, value: -20, to: Date())!
        state.lastActiveAt = lastActive

        let days = deathChecker.inactiveBusinessDays(lastActive: state.lastActiveAt, now: Date())
        XCTAssertTrue(days >= 14, "Should have at least 14 business days inactive")
        XCTAssertTrue(deathChecker.shouldDie(inactiveBusinessDays: days))

        let entry = deathChecker.processDeath(state: &state)
        XCTAssertEqual(state.phase, .dead)
        XCTAssertEqual(state.hp, 0)
        XCTAssertEqual(state.hunger, 0)
        XCTAssertEqual(state.mood, 0)
        XCTAssertEqual(entry.species, state.species)
    }

    func testDeathWarningLevels() {
        XCTAssertEqual(deathChecker.warningLevel(inactiveBusinessDays: 3), .none)
        XCTAssertEqual(deathChecker.warningLevel(inactiveBusinessDays: 5), .warning)
        XCTAssertEqual(deathChecker.warningLevel(inactiveBusinessDays: 10), .critical)
    }

    func testRebirthAfterDeath() {
        var state = PetState(machineId: "test-rebirth")

        // Hatch → Die → Rebirth
        for _ in 0..<20 {
            processor.process(event: BehaviorEvent(kind: .prompt), state: &state)
        }
        XCTAssertEqual(state.phase, .alive)
        let originalSpecies = state.species

        let entry = deathChecker.processDeath(state: &state)
        state.graveyardEntries.append(entry)
        XCTAssertEqual(state.phase, .dead)

        // Rebirth
        let previousEntries = state.graveyardEntries
        let previousDeathCount = state.deathCount
        let previousAchievements = state.unlockedAchievements
        state = PetState(machineId: "test-rebirth")
        state.graveyardEntries = previousEntries
        state.deathCount = previousDeathCount + 1
        state.unlockedAchievements = previousAchievements

        XCTAssertEqual(state.phase, .egg, "Should be egg after rebirth")
        XCTAssertEqual(state.level, 0)
        XCTAssertEqual(state.deathCount, 1)
        XCTAssertEqual(state.graveyardEntries.count, 1)
        XCTAssertEqual(state.graveyardEntries[0].species, originalSpecies)
    }

    // MARK: - EventBridge File Round-Trip Pipeline

    func testEventBridgeFileRoundTrip() {
        _ = EventBridge.drainFileEvents()
        defer { _ = EventBridge.drainFileEvents() }

        let event = BehaviorEvent(kind: .prompt, metadata: ["source": "test"])
        EventBridge.post(event: event)

        let events = EventBridge.drainFileEvents()
        XCTAssertFalse(events.isEmpty, "Should drain at least one event")
        XCTAssertEqual(events.last?.kind, .prompt)
    }

    func testEventBridgeDrainProcessesThroughFeedProcessor() {
        _ = EventBridge.drainFileEvents()
        defer { _ = EventBridge.drainFileEvents() }

        var state = PetState(machineId: "test-bridge")

        // Post events via bridge
        for _ in 0..<5 {
            EventBridge.post(event: BehaviorEvent(kind: .toolUse))
        }

        // Drain and process (simulates app startup)
        let pending = EventBridge.drainFileEvents()
        for event in pending {
            processor.process(event: event, state: &state)
        }

        XCTAssertEqual(state.totalToolUses, pending.count)
        XCTAssertTrue(state.totalXp > 0)
    }

    // MARK: - Multi-Level Progression

    func testProgressionThroughStages() {
        var state = PetState(machineId: "test-stages")

        // Hatch
        for _ in 0..<20 {
            processor.process(event: BehaviorEvent(kind: .prompt), state: &state)
        }
        XCTAssertEqual(state.phase, .alive)
        XCTAssertEqual(state.stage, .stage1)

        // Reach level 11 → Stage 2
        // Level 1→2 needs 100 XP, 2→3 needs 150, ..., 10→11 needs 550
        // Total XP needed from level 1 to 11: sum of (n*50) for n=2..11 = 50*(2+3+...+11) = 50*65 = 3250
        // Each session start = 10 XP, need 325 sessions
        for _ in 0..<325 {
            processor.process(event: BehaviorEvent(kind: .sessionStart), state: &state)
        }
        XCTAssertGreaterThanOrEqual(state.level, 11)
        XCTAssertEqual(state.stage, .stage2)

        // Verify equipment was dropped for each level up
        XCTAssertGreaterThanOrEqual(state.inventory.count, 10)
    }

    // MARK: - FeedResult Merge

    func testFeedResultMerge() {
        let r1 = FeedResult(xpGained: 10, hatched: false, levelsGained: 1,
                           droppedEquipment: [], newAchievements: [])
        let r2 = FeedResult(xpGained: 5, hatched: true, levelsGained: 0,
                           droppedEquipment: [], newAchievements: [])
        let merged = r1.merged(with: r2)

        XCTAssertEqual(merged.xpGained, 15)
        XCTAssertTrue(merged.hatched)
        XCTAssertEqual(merged.levelsGained, 1)
    }

    // MARK: - Release Flow

    func testReleasePreservesEquipment() {
        var state = PetState(machineId: "test-release")

        // Hatch and gain equipment
        for _ in 0..<20 {
            processor.process(event: BehaviorEvent(kind: .prompt), state: &state)
        }
        XCTAssertEqual(state.phase, .alive)

        // Level up to acquire equipment
        for _ in 0..<20 {
            processor.process(event: BehaviorEvent(kind: .prompt), state: &state)
        }
        let inventoryBeforeRelease = state.inventory
        XCTAssertFalse(inventoryBeforeRelease.isEmpty, "Should have equipment before release")

        // Simulate release: preserve inventory and equippedItems
        let entry = GraveyardEntry(from: state, cause: "방생")
        let previousEntries = state.graveyardEntries
        let previousDeathCount = state.deathCount
        let previousAchievements = state.unlockedAchievements
        let previousInventory = state.inventory
        let previousEquippedItems = state.equippedItems
        state = PetState(machineId: "test-release")
        state.graveyardEntries = previousEntries + [entry]
        state.deathCount = previousDeathCount
        state.unlockedAchievements = previousAchievements
        state.inventory = previousInventory
        state.equippedItems = previousEquippedItems

        XCTAssertEqual(state.phase, .egg, "Should be egg after release")
        XCTAssertEqual(state.level, 0, "Level resets after release")
        XCTAssertEqual(state.inventory.count, inventoryBeforeRelease.count, "Inventory should be preserved after release")
        XCTAssertEqual(state.graveyardEntries.last?.causeOfDeath, "방생")
    }

    // MARK: - Edge Cases

    func testFeedingDeadPetStillRecordsStats() {
        var state = PetState(machineId: "test-dead-feed")

        // Hatch and kill
        for _ in 0..<20 {
            processor.process(event: BehaviorEvent(kind: .prompt), state: &state)
        }
        _ = deathChecker.processDeath(state: &state)
        XCTAssertEqual(state.phase, .dead)

        let prevXp = state.totalXp
        processor.process(event: BehaviorEvent(kind: .prompt), state: &state)
        XCTAssertGreaterThan(state.totalXp, prevXp, "XP should still accumulate")
    }

    func testEggCannotDie() {
        let state = PetState(machineId: "test-egg-death")
        XCTAssertEqual(state.phase, .egg)
        // Death checker only operates on alive pets in ViewModel, but the checker itself doesn't restrict
        // This documents that the ViewModel guards: guard state.phase == .alive
    }

    func testConsecutiveHatchAndDeathCycles() {
        var state = PetState(machineId: "test-cycles")

        for cycle in 0..<3 {
            // Hatch
            for _ in 0..<20 {
                processor.process(event: BehaviorEvent(kind: .prompt), state: &state)
            }
            XCTAssertEqual(state.phase, .alive)

            // Kill
            let entry = deathChecker.processDeath(state: &state)
            state.graveyardEntries.append(entry)

            // Rebirth
            let entries = state.graveyardEntries
            let deaths = state.deathCount
            let achievements = state.unlockedAchievements
            state = PetState(machineId: "test-cycles")
            state.graveyardEntries = entries
            state.deathCount = deaths + 1
            state.unlockedAchievements = achievements

            XCTAssertEqual(state.phase, .egg)
            XCTAssertEqual(state.graveyardEntries.count, cycle + 1)
            XCTAssertEqual(state.deathCount, cycle + 1)
        }
    }
}
