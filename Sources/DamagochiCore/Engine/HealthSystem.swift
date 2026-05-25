import Foundation

public struct HealthSystem: Sendable {
    public init() {}

    /// 마지막 코딩 에이전트 활동 이후 경과 시간 기반 decay
    /// - 0~4시간: 감소 없음
    /// - 4시간 초과부터 시간당 조금씩 감소
    public func applyDecay(to state: inout PetState, inactiveHours: Int) {
        guard state.phase == .alive, inactiveHours > 4 else { return }
        let h = inactiveHours - 4
        state.hp     = max(0, state.hp     - min(h * 1, 30))
        state.hunger = max(0, state.hunger - min(h * 2, 50))
        state.mood   = max(0, state.mood   - min(h * 1, 20))
    }

    public func applyRecovery(to state: inout PetState) {
        guard state.phase == .alive else { return }
        state.hp = min(100, state.hp + 5)
        state.hunger = min(100, state.hunger + 10)
        state.mood = min(100, state.mood + 3)
    }
}
