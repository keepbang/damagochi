import Foundation
import Testing
@testable import DamagochiCore

private func teamProfile(
    _ id: String,
    name: String,
    hp: Int = 20,
    spd: Int = 10,
    atk: Int = 200
) -> BattleProfile {
    BattleProfile(
        id: id,
        petName: name,
        speciesId: "cat",
        mbtiGroup: .sp,
        speciesRarity: .common,
        stats: BattleStats(atk: atk, int_: 1, maxHp: hp, spd: spd, def: 0)
    )
}

@Test func teamBattleKeepsSurvivorHealthForTheNextOpponent() throws {
    var team = try #require(TeamBattleState(
        myTeam: [teamProfile("m1", name: "내 첫째", hp: 100, spd: 30)],
        opponentTeam: [
            teamProfile("o1", name: "상대 첫째", hp: 100, spd: 1, atk: 1),
            teamProfile("o2", name: "상대 둘째", hp: 100, spd: 1)
        ]
    ))

    // Two speed attacks defeat the first opponent. It gets one weak attack
    // between them, so the survivor must carry less than max HP forward.
    team.resolveTurn(mySkillId: "sp_ambush", opponentSkillId: "sp_ambush")
    team.resolveTurn(mySkillId: "sp_ambush", opponentSkillId: "sp_ambush")

    #expect(team.opponentActiveIndex == 1)
    #expect(team.myActiveProfile.stats.currentHp < team.myActiveProfile.stats.maxHp)
    #expect(team.myTeam[0].stats.currentHp == team.myActiveProfile.stats.currentHp)
}

@Test func teamBattleSwitchesToNextAlivePetAfterKnockout() throws {
    var team = try #require(TeamBattleState(
        myTeam: [teamProfile("m1", name: "내 첫째", spd: 30), teamProfile("m2", name: "내 둘째", spd: 30)],
        opponentTeam: [teamProfile("o1", name: "상대 첫째", hp: 1, spd: 1), teamProfile("o2", name: "상대 둘째", hp: 40, spd: 1)]
    ))

    team.resolveTurn(mySkillId: "sp_combo", opponentSkillId: "sp_combo")

    #expect(team.status == .ongoing)
    #expect(team.opponentActiveIndex == 1)
    #expect(team.opponentActiveProfile.id == "o2")
    #expect(team.opponentTeam[0].stats.currentHp == 0)
}

@Test func teamBattleEndsOnlyWhenEntireOpponentTeamIsDefeated() throws {
    var team = try #require(TeamBattleState(
        myTeam: [teamProfile("m1", name: "내 펫", spd: 30)],
        opponentTeam: [teamProfile("o1", name: "상대 첫째", hp: 1, spd: 1), teamProfile("o2", name: "상대 둘째", hp: 1, spd: 1)]
    ))

    team.resolveTurn(mySkillId: "sp_combo", opponentSkillId: "sp_combo")
    #expect(team.status == .ongoing)
    team.resolveTurn(mySkillId: "sp_combo", opponentSkillId: "sp_combo")

    #expect(team.status == .victory)
    #expect(team.opponentRemainingCount == 0)
}

@Test func battleTeamProfileLimitsNetworkSnapshotToFourMembers() {
    let profiles = (0..<5).map { teamProfile("p\($0)", name: "펫\($0)") }
    let snapshot = BattleTeamProfile(id: "device", members: profiles)

    #expect(snapshot.members.count == 4)
}

@Test func battleTeamProfileRoundTripsThroughNetworkCoding() throws {
    let original = BattleTeamProfile(
        id: "device",
        members: [teamProfile("p1", name: "첫째"), teamProfile("p2", name: "둘째")]
    )

    let decoded = try JSONDecoder().decode(BattleTeamProfile.self, from: JSONEncoder().encode(original))

    #expect(decoded.id == original.id)
    #expect(decoded.members.map(\.id) == ["p1", "p2"])
}
