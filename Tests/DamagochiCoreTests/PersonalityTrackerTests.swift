import Testing
@testable import DamagochiCore

@Test func mbtiAxesReceiveEvidenceWhenOptionalHookMetadataIsMissing() {
    var scores = MbtiScores()
    let tracker = PersonalityTracker()

    tracker.updateMbti(scores: &scores, event: BehaviorEvent(kind: .sessionStart))
    tracker.updateMbti(scores: &scores, event: BehaviorEvent(kind: .prompt))
    tracker.updateMbti(scores: &scores, event: BehaviorEvent(kind: .toolUse, metadata: ["tool": "Read"]))

    #expect(scores.extroversion > 0)
    #expect(scores.intuition > 0)
    #expect(scores.thinking > 0)
}
