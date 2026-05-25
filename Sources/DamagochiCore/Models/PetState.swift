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

public struct PixelOffset: Codable, Sendable, Equatable {
    public var x: Int
    public var y: Int

    public init(x: Int = 0, y: Int = 0) {
        self.x = x
        self.y = y
    }

    public static let zero = PixelOffset(x: 0, y: 0)
}

public struct EquipmentOffsets: Codable, Sendable, Equatable {
    public var head: PixelOffset
    public var hand: PixelOffset
    public var effect: PixelOffset

    public init(
        head: PixelOffset = .zero,
        hand: PixelOffset = .zero,
        effect: PixelOffset = .zero
    ) {
        self.head = head
        self.hand = hand
        self.effect = effect
    }

    public func offset(for slot: EquipmentSlot) -> PixelOffset {
        switch slot {
        case .head:   return head
        case .hand:   return hand
        case .effect: return effect
        }
    }

    public mutating func setOffset(_ offset: PixelOffset, for slot: EquipmentSlot) {
        switch slot {
        case .head:   head = offset
        case .hand:   hand = offset
        case .effect: effect = offset
        }
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

    mutating func record(_ kind: EventKind) {
        switch kind {
        case .prompt: prompts += 1
        case .toolUse: toolUses += 1
        case .sessionStart: sessions += 1
        case .stop, .notification: break
        }
    }
}

public struct PetState: Codable, Sendable {
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
    public var equipmentOffsets: EquipmentOffsets?
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
        self.equipmentOffsets = EquipmentOffsets()
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
