import Foundation

public enum PetPhase: String, Codable, Sendable {
    case egg
    case alive
    case dead
}

public enum Stage: Int, Codable, Sendable {
    case stage1 = 1
    case stage2 = 2
    case stage3 = 3
}

public struct MbtiScores: Codable, Sendable {
    public var extroversion: Int
    public var intuition: Int
    public var thinking: Int
    public var judging: Int

    public init(extroversion: Int = 0, intuition: Int = 0, thinking: Int = 0, judging: Int = 0) {
        self.extroversion = extroversion
        self.intuition = intuition
        self.thinking = thinking
        self.judging = judging
    }
}

public struct EquippedItems: Codable, Sendable {
    public var head: String?
    public var hand: String?
    public var effect: String?

    public init(head: String? = nil, hand: String? = nil, effect: String? = nil) {
        self.head = head
        self.hand = hand
        self.effect = effect
    }
}

public struct ActivityStats: Codable, Sendable, Equatable {
    public var prompts: Int
    public var toolUses: Int
    public var sessions: Int

    public init(prompts: Int = 0, toolUses: Int = 0, sessions: Int = 0) {
        self.prompts = prompts
        self.toolUses = toolUses
        self.sessions = sessions
    }

    public mutating func record(_ kind: EventKind) {
        switch kind {
        case .prompt: prompts += 1
        case .toolUse: toolUses += 1
        case .sessionStart: sessions += 1
        case .stop, .notification: break
        }
    }
}

public struct PetState: Codable, Sendable {
    /// Stable identity for this individual pet. The machine identifier remains
    /// shared by all slots on one device; this ID keeps roster slots distinct
    /// in battle snapshots.
    public var petId: String?
    public var machineId: String
    public var phase: PetPhase
    public var species: String?
    public var name: String?
    public var level: Int
    public var xp: Int
    public var totalXp: Int
    public var hp: Int
    public var hunger: Int
    public var mood: Int
    public var mbtiScores: MbtiScores
    public var personality: String?
    public var equippedItems: EquippedItems
    public var inventory: [Equipment]
    public var unlockedAchievements: [String]
    public var graveyardEntries: [GraveyardEntry]
    public var createdAt: Date
    public var lastActiveAt: Date
    public var totalPrompts: Int
    public var totalToolUses: Int
    public var totalSessions: Int
    // Optional so pets saved before source tracking continue to decode.
    public var claudeStats: ActivityStats?
    public var codexStats: ActivityStats?
    public var consecutiveWorkdays: Int
    public var deathCount: Int
    public var streakDays: Int
    public var longestStreak: Int
    public var lastStreakDate: Date?
    public var lastWorkdayDate: Date?
    public var bugsCaught: Int
    public var goldenBugsCaught: Int
    public var rainbowBugsCaught: Int
    public var activeBugs: [ActiveBug]

    public var stage: Stage {
        if level >= 26 { return .stage3 }
        if level >= 11 { return .stage2 }
        return .stage1
    }

    public func stats(for source: ActivitySource) -> ActivityStats {
        switch source {
        case .claude: return claudeStats ?? ActivityStats()
        case .codex: return codexStats ?? ActivityStats()
        }
    }

    public var unclassifiedStats: ActivityStats {
        let claude = stats(for: .claude)
        let codex = stats(for: .codex)
        return ActivityStats(
            prompts: max(0, totalPrompts - claude.prompts - codex.prompts),
            toolUses: max(0, totalToolUses - claude.toolUses - codex.toolUses),
            sessions: max(0, totalSessions - claude.sessions - codex.sessions)
        )
    }

    public mutating func recordActivity(_ kind: EventKind, source: ActivitySource?) {
        guard let source else { return }
        switch source {
        case .claude:
            var stats = claudeStats ?? ActivityStats()
            stats.record(kind)
            claudeStats = stats
        case .codex:
            var stats = codexStats ?? ActivityStats()
            stats.record(kind)
            codexStats = stats
        }
    }

    public init(machineId: String) {
        self.petId = UUID().uuidString
        self.machineId = machineId
        self.phase = .egg
        self.species = nil
        self.name = nil
        self.level = 0
        self.xp = 0
        self.totalXp = 0
        self.hp = 100
        self.hunger = 100
        self.mood = 100
        self.mbtiScores = MbtiScores()
        self.personality = nil
        self.equippedItems = EquippedItems()
        self.inventory = []
        self.unlockedAchievements = []
        self.graveyardEntries = []
        self.createdAt = Date()
        self.lastActiveAt = Date()
        self.totalPrompts = 0
        self.totalToolUses = 0
        self.totalSessions = 0
        self.claudeStats = ActivityStats()
        self.codexStats = ActivityStats()
        self.consecutiveWorkdays = 0
        self.deathCount = 0
        self.streakDays = 0
        self.longestStreak = 0
        self.lastStreakDate = nil
        self.lastWorkdayDate = nil
        self.bugsCaught = 0
        self.goldenBugsCaught = 0
        self.rainbowBugsCaught = 0
        self.activeBugs = []
    }
}

/// Persisted owner-level state. `PetState` remains the unit used by the core
/// game engines, while this roster owns slot selection and cross-pet rewards.
/// Keeping the two types separate makes legacy single-pet JSON trivially
/// migratable and avoids coupling battle/evolution code to UI slot concerns.
public struct PetRoster: Codable, Sendable {
    public static let maximumPets = 4

    public var pets: [PetState]
    public var selectedIndex: Int
    /// Rotates integer XP remainders so the lowest slot is not always favored.
    public var xpRemainderCursor: Int
    /// Owner-level history copied from legacy state during migration. Existing
    /// per-pet values are retained for backward compatibility with old views.
    public var globalUnlockedAchievements: [String]
    public var globalGraveyardEntries: [GraveyardEntry]
    /// Account-wide coding activity. Optional keeps existing multi-pet saves
    /// decodable; the first save after upgrade persists the migrated value.
    public var accountActivityStats: ActivityStats?

    public init(
        pets: [PetState],
        selectedIndex: Int = 0,
        xpRemainderCursor: Int = 0,
        globalUnlockedAchievements: [String] = [],
        globalGraveyardEntries: [GraveyardEntry] = [],
        accountActivityStats: ActivityStats? = nil
    ) {
        self.pets = Array(pets.prefix(Self.maximumPets))
        self.selectedIndex = min(max(0, selectedIndex), max(0, self.pets.count - 1))
        self.xpRemainderCursor = max(0, xpRemainderCursor)
        self.globalUnlockedAchievements = globalUnlockedAchievements
        self.globalGraveyardEntries = globalGraveyardEntries
        self.accountActivityStats = accountActivityStats
    }

    public init(legacy state: PetState) {
        self.init(
            pets: [state],
            globalUnlockedAchievements: state.unlockedAchievements,
            globalGraveyardEntries: state.graveyardEntries,
            accountActivityStats: ActivityStats(
                prompts: state.totalPrompts,
                toolUses: state.totalToolUses,
                sessions: state.totalSessions
            )
        )
    }

    public var selectedPet: PetState? {
        guard pets.indices.contains(selectedIndex) else { return nil }
        return pets[selectedIndex]
    }

    public var eligibleXPIndices: [Int] {
        pets.indices.filter { pets[$0].phase == .egg || pets[$0].phase == .alive }
    }

    public var walkableIndices: [Int] {
        pets.indices.filter { pets[$0].phase == .alive && pets[$0].stage != .stage1 }
    }

    public var canAddPet: Bool { pets.count < Self.maximumPets }

    public var activityStats: ActivityStats {
        accountActivityStats ?? legacyActivityStats
    }

    /// Older multi-pet builds mirrored every event into every active slot.
    /// Taking each high-water mark prevents that mirrored history from being
    /// counted multiple times during the account-stat migration.
    public mutating func migrateAccountActivityStatsIfNeeded() {
        guard accountActivityStats == nil else { return }
        accountActivityStats = legacyActivityStats
    }

    public mutating func recordAccountActivity(_ kind: EventKind) {
        var stats = activityStats
        stats.record(kind)
        accountActivityStats = stats
    }

    /// Returns a deterministic, fair integer split and advances the remainder
    /// cursor. The sum of all returned shares always equals `totalXP`.
    public mutating func distributeXP(_ totalXP: Int) -> [Int: Int] {
        guard totalXP > 0 else { return [:] }
        let recipients = eligibleXPIndices
        guard !recipients.isEmpty else { return [:] }

        let base = totalXP / recipients.count
        let remainder = totalXP % recipients.count
        var shares = Dictionary(uniqueKeysWithValues: recipients.map { ($0, base) })
        let start = xpRemainderCursor % recipients.count
        for offset in 0..<remainder {
            let index = recipients[(start + offset) % recipients.count]
            shares[index, default: 0] += 1
        }
        xpRemainderCursor = (start + remainder) % recipients.count
        return shares
    }

    public mutating func replaceSelectedPet(with pet: PetState) {
        guard pets.indices.contains(selectedIndex) else { return }
        pets[selectedIndex] = pet
        syncGlobalHistory(from: pet)
    }

    public mutating func addPet(machineId: String) -> Bool {
        guard canAddPet else { return false }
        pets.append(PetState(machineId: machineId))
        selectedIndex = pets.count - 1
        return true
    }

    public mutating func syncGlobalHistory(from pet: PetState) {
        globalUnlockedAchievements = Array(Set(globalUnlockedAchievements + pet.unlockedAchievements)).sorted()
        let knownIds = Set(globalGraveyardEntries.map(\.id))
        globalGraveyardEntries += pet.graveyardEntries.filter { !knownIds.contains($0.id) }
    }

    private var legacyActivityStats: ActivityStats {
        ActivityStats(
            prompts: pets.map(\.totalPrompts).max() ?? 0,
            toolUses: pets.map(\.totalToolUses).max() ?? 0,
            sessions: pets.map(\.totalSessions).max() ?? 0
        )
    }
}
