import Foundation

public struct PersonalityTracker: Sendable {
    public init() {}

    public func updateMbti(scores: inout MbtiScores, event: BehaviorEvent) {
        switch event.kind {
        case .sessionStart:
            if let interval = event.metadata?["sessionInterval"],
               let minutes = Double(interval) {
                scores.extroversion += minutes < 30 ? 1 : -1
            } else {
                // Hooks do not always provide an interval. Counting a session
                // as lightweight E evidence prevents E/I from being frozen at
                // its default value for an entire pet lifecycle.
                scores.extroversion += 1
            }
            if let hour = event.metadata?["hour"], let value = Int(hour) {
                scores.judging += (value >= 9 && value < 18) ? 1 : -1
            }
        case .toolUse:
            if let tool = event.metadata?["tool"] {
                let normalizedTool = tool.lowercased()
                let analyticTools: Set<String> = ["grep", "read", "glob", "lsp", "search"]
                let creativeTools: Set<String> = ["edit", "write", "apply_patch"]
                let exploratoryTools: Set<String> = ["webfetch", "websearch", "task", "agent", "bash", "terminal"]
                if analyticTools.contains(normalizedTool) {
                    scores.thinking += 1
                    scores.intuition += 1
                } else if creativeTools.contains(normalizedTool) {
                    scores.thinking -= 1
                    scores.intuition -= 1
                } else if exploratoryTools.contains(normalizedTool) {
                    scores.intuition += 1
                }
            }
            trackUniqueTools(scores: &scores, event: event)
        case .prompt:
            if let hour = event.metadata?["hour"], let h = Int(hour) {
                scores.judging += (h >= 9 && h < 18) ? 1 : -1
            }
            if let length = event.metadata?["promptLength"], let count = Int(length) {
                scores.intuition += count >= 160 ? 1 : -1
                scores.judging += count >= 160 ? 1 : 0
            } else {
                // A prompt without token metadata is still evidence that the
                // owner is interacting, instead of leaving every axis static.
                scores.extroversion += 1
            }
        case .stop, .notification:
            break
        }
    }

    private func trackUniqueTools(scores: inout MbtiScores, event: BehaviorEvent) {
        if let uniqueCount = event.metadata?["uniqueToolCount"],
           let count = Int(uniqueCount), count > 5 {
            scores.intuition += 1
        }
    }

    public func determineMbtiGroup(from scores: MbtiScores) -> MbtiGroup {
        let n = scores.intuition > 0
        let t = scores.thinking > 0

        if n && t { return .nt }
        if n && !t { return .nf }
        if !n && t { return .sj }
        return .sp
    }

    public func determineMbtiString(from scores: MbtiScores) -> String {
        let e = scores.extroversion > 0 ? "E" : "I"
        let n = scores.intuition > 0 ? "N" : "S"
        let t = scores.thinking > 0 ? "T" : "F"
        let j = scores.judging > 0 ? "J" : "P"
        return e + n + t + j
    }
}
