import Foundation

/// The two supported online battle rulesets. `single` preserves the existing
/// selected-pet duel; `team` sends every alive roster pet in slot order.
public enum BattleMode: String, Codable, Sendable, CaseIterable, Equatable {
    case single
    case team

    public var displayName: String {
        switch self {
        case .single: return "싱글"
        case .team: return "토너먼트"
        }
    }
}

/// Compact, immutable team snapshot sent to a peer. It contains only battle
/// profiles, never the full roster or inventories.
public struct BattleTeamProfile: Codable, Sendable, Identifiable {
    public let id: String
    public let members: [BattleProfile]

    public init(id: String, members: [BattleProfile]) {
        self.id = id
        self.members = Array(members.prefix(4))
    }
}

public enum TeamBattleStatus: Codable, Sendable, Equatable {
    case ongoing
    case victory
    case defeat
}

/// Chains normal BattleState duels into a Pokémon-style team battle. Defeated
/// members remain at 0 HP; the surviving active member carries its HP forward.
public struct TeamBattleState: Sendable {
    public var myTeam: [BattleProfile]
    public var opponentTeam: [BattleProfile]
    public private(set) var myActiveIndex: Int
    public private(set) var opponentActiveIndex: Int
    public private(set) var activeBattle: BattleState
    public private(set) var status: TeamBattleStatus
    public private(set) var log: [String]

    public init?(myTeam: [BattleProfile], opponentTeam: [BattleProfile]) {
        let mine = Array(myTeam.prefix(4))
        let opponent = Array(opponentTeam.prefix(4))
        guard !mine.isEmpty, !opponent.isEmpty else { return nil }
        self.myTeam = mine
        self.opponentTeam = opponent
        self.myActiveIndex = 0
        self.opponentActiveIndex = 0
        self.activeBattle = BattleState(me: mine[0], opponent: opponent[0])
        self.status = .ongoing
        self.log = ["팀 배틀 시작: \(mine[0].petName) vs \(opponent[0].petName)"]
    }

    public var myActiveProfile: BattleProfile { activeBattle.myProfile }
    public var opponentActiveProfile: BattleProfile { activeBattle.opponentProfile }
    public var myRemainingCount: Int { myTeam.filter { $0.stats.currentHp > 0 }.count }
    public var opponentRemainingCount: Int { opponentTeam.filter { $0.stats.currentHp > 0 }.count }

    public mutating func resolveTurn(mySkillId: String, opponentSkillId: String) {
        guard status == .ongoing else { return }
        BattleEngine.resolveTurn(state: &activeBattle, mySkillId: mySkillId, opponentSkillId: opponentSkillId)
        myTeam[myActiveIndex] = activeBattle.myProfile
        opponentTeam[opponentActiveIndex] = activeBattle.opponentProfile

        switch activeBattle.status {
        case .ongoing:
            return
        case .victory:
            guard let nextOpponent = nextAliveIndex(in: opponentTeam, after: opponentActiveIndex) else {
                status = .victory
                log.append("\(activeBattle.myProfile.petName)이(가) 상대 팀을 전멸시켰습니다!")
                return
            }
            opponentActiveIndex = nextOpponent
            startNextDuel(message: "상대가 \(opponentTeam[nextOpponent].petName)을(를) 내보냈습니다!")
        case .defeat:
            guard let nextMine = nextAliveIndex(in: myTeam, after: myActiveIndex) else {
                status = .defeat
                log.append("내 팀의 모든 펫이 쓰러졌습니다.")
                return
            }
            myActiveIndex = nextMine
            startNextDuel(message: "\(myTeam[nextMine].petName)을(를) 내보냈습니다!")
        case .draw:
            // BattleEngine currently does not produce draws, but preserve a
            // deterministic safe state if a future effect introduces one.
            status = myRemainingCount >= opponentRemainingCount ? .victory : .defeat
        }
    }

    private mutating func startNextDuel(message: String) {
        activeBattle = BattleState(me: myTeam[myActiveIndex], opponent: opponentTeam[opponentActiveIndex])
        log.append(message)
        log.append("다음 대결: \(activeBattle.myProfile.petName) vs \(activeBattle.opponentProfile.petName)")
    }

    private func nextAliveIndex(in team: [BattleProfile], after index: Int) -> Int? {
        team.indices.first(where: { $0 > index && team[$0].stats.currentHp > 0 })
    }
}
