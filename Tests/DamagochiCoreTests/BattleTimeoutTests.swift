import Testing
@testable import DamagochiCore

@Test func battleTimeoutDurationsMatchRealtimeFlow() {
    #expect(BattleTimeout.skillSelectSeconds == 10)
    #expect(BattleTimeout.connectionSeconds == 15)
    #expect(BattleTimeout.opponentResponseSeconds == 15)
}

@Test func battleTimeoutDefaultSkillsAreValidAttacks() {
    for group in [MbtiGroup.nt, .nf, .sj, .sp] {
        let skillId = BattleTimeout.defaultSkillId(for: group)
        let skill = BattleSkill.skills(for: group).first { $0.id == skillId }
        #expect(skill?.isAttack == true)
    }
}
