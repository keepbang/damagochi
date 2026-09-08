import Foundation

public enum BattleOutcome: String, Codable, Sendable {
    case victory, defeat, draw, interrupted

    public var displayName: String {
        switch self {
        case .victory: return "승리"
        case .defeat: return "패배"
        case .draw: return "무승부"
        case .interrupted: return "중단"
        }
    }
}

/// Profiles are captured at match start so renaming, leveling or losing a pet
/// does not rewrite the historical participants.
public struct BattleHistoryEntry: Codable, Sendable, Identifiable {
    public let id: UUID
    public let startedAt: Date
    public var endedAt: Date?
    public let mode: BattleMode
    public let opponentID: String
    public let opponentName: String
    public var myPets: [BattleProfile]
    public var opponentPets: [BattleProfile]
    public var outcome: BattleOutcome
    public var reason: String?

    public init(id: UUID = UUID(), startedAt: Date = Date(), mode: BattleMode,
                opponentID: String, opponentName: String,
                myPets: [BattleProfile], opponentPets: [BattleProfile],
                outcome: BattleOutcome = .interrupted) {
        self.id = id
        self.startedAt = startedAt
        self.mode = mode
        self.opponentID = opponentID
        self.opponentName = opponentName
        self.myPets = myPets
        self.opponentPets = opponentPets
        self.outcome = outcome
    }
}

public struct BattleRecord: Equatable, Sendable {
    public private(set) var wins = 0
    public private(set) var losses = 0
    public private(set) var draws = 0

    public init(entries: [BattleHistoryEntry]) {
        for entry in entries {
            switch entry.outcome {
            case .victory: wins += 1
            case .defeat: losses += 1
            case .draw: draws += 1
            case .interrupted: break
            }
        }
    }
}

public extension PetRoster {
    /// Updating the same match never creates a second result or inflates totals.
    mutating func recordBattle(_ entry: BattleHistoryEntry) {
        var entries = battleHistory ?? []
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
        } else {
            entries.append(entry)
        }
        battleHistory = entries
    }
}
