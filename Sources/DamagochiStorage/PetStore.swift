import Foundation
import DamagochiCore

public enum MigrationError: LocalizedError {
    case noData
    case invalidFile

    public var errorDescription: String? {
        switch self {
        case .noData:       return "저장된 펫 데이터가 없습니다."
        case .invalidFile:  return "올바른 다마고치 데이터 파일이 아닙니다."
        }
    }
}

public final class PetStore: Sendable {
    private static let stateKey = "com.damagochi.petState"

    public init() {}

    public func load() -> PetState? {
        guard let data = UserDefaults.standard.data(forKey: Self.stateKey) else { return nil }
        return try? JSONDecoder().decode(PetState.self, from: data)
    }

    public func save(_ state: PetState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        UserDefaults.standard.set(data, forKey: Self.stateKey)
    }

    public func reset() {
        UserDefaults.standard.removeObject(forKey: Self.stateKey)
    }

    public func export(to url: URL) throws {
        guard let state = load() else { throw MigrationError.noData }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(state)
        try data.write(to: url, options: .atomic)
    }

    public func importState(from url: URL) throws -> PetState {
        let data = try Data(contentsOf: url)
        guard let state = try? JSONDecoder().decode(PetState.self, from: data) else {
            throw MigrationError.invalidFile
        }
        return state
    }
}
