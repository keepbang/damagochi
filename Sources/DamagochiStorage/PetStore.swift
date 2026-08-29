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
    private static let rosterKey = "com.damagochi.petRoster"

    public init() {}

    public func load() -> PetState? {
        guard let data = UserDefaults.standard.data(forKey: Self.stateKey) else { return nil }
        return try? JSONDecoder().decode(PetState.self, from: data)
    }

    public func save(_ state: PetState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        UserDefaults.standard.set(data, forKey: Self.stateKey)
    }

    /// Loads the new multi-pet payload and falls back to the legacy single
    /// `PetState` key. The fallback is intentionally non-destructive so an
    /// interrupted upgrade can still recover its old save.
    public func loadRoster() -> PetRoster? {
        if let data = UserDefaults.standard.data(forKey: Self.rosterKey),
           let roster = try? JSONDecoder().decode(PetRoster.self, from: data) {
            return roster
        }
        return load().map(PetRoster.init(legacy:))
    }

    public func save(_ roster: PetRoster) {
        guard let data = try? JSONEncoder().encode(roster) else { return }
        UserDefaults.standard.set(data, forKey: Self.rosterKey)
    }

    public func reset() {
        UserDefaults.standard.removeObject(forKey: Self.stateKey)
        UserDefaults.standard.removeObject(forKey: Self.rosterKey)
    }

    public func export(to url: URL) throws {
        guard let roster = loadRoster() else { throw MigrationError.noData }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(roster)
        try data.write(to: url, options: .atomic)
    }

    public func importRoster(from url: URL) throws -> PetRoster {
        let data = try Data(contentsOf: url)
        if let roster = try? JSONDecoder().decode(PetRoster.self, from: data) { return roster }
        if let state = try? JSONDecoder().decode(PetState.self, from: data) { return PetRoster(legacy: state) }
        throw MigrationError.invalidFile
    }

    /// Compatibility API used by older callers and exported single-pet files.
    public func importState(from url: URL) throws -> PetState {
        guard let state = try importRoster(from: url).selectedPet else {
            throw MigrationError.invalidFile
        }
        return state
    }
}
