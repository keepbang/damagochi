import Testing
import Foundation
@testable import DamagochiCore
@testable import DamagochiMonitor

@Test func eventBridgeFileRoundTrip() throws {
    let testDir = NSTemporaryDirectory() + "damagochi-bridge-test-\(UUID().uuidString)"
    let testFile = testDir + "/pending-events.jsonl"
    try FileManager.default.createDirectory(atPath: testDir, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(atPath: testDir) }

    let event1 = BehaviorEvent(kind: .prompt)
    let event2 = BehaviorEvent(kind: .toolUse)

    let encoder = JSONEncoder()
    var lines = ""
    lines += String(data: try encoder.encode(event1), encoding: .utf8)! + "\n"
    lines += String(data: try encoder.encode(event2), encoding: .utf8)! + "\n"
    try lines.write(toFile: testFile, atomically: true, encoding: .utf8)

    let decoder = JSONDecoder()
    let content = try String(contentsOfFile: testFile, encoding: .utf8)
    let events = content.split(separator: "\n").compactMap { line in
        guard let data = line.data(using: .utf8) else { return nil as BehaviorEvent? }
        return try? decoder.decode(BehaviorEvent.self, from: data)
    }

    #expect(events.count == 2)
    #expect(events[0].kind == .prompt)
    #expect(events[1].kind == .toolUse)
}

@Test func behaviorEventCodable() throws {
    let event = BehaviorEvent(kind: .sessionStart, metadata: ["source": "hook"])
    let data = try JSONEncoder().encode(event)
    let decoded = try JSONDecoder().decode(BehaviorEvent.self, from: data)

    #expect(decoded.kind == .sessionStart)
    #expect(decoded.metadata?["source"] == "hook")
}

@Test func legacyPetStateWithoutSourceStatsStillDecodes() throws {
    let state = PetState(machineId: "legacy")
    var json = try JSONSerialization.jsonObject(with: JSONEncoder().encode(state)) as! [String: Any]
    json.removeValue(forKey: "claudeStats")
    json.removeValue(forKey: "codexStats")

    let decoded = try JSONDecoder().decode(
        PetState.self,
        from: JSONSerialization.data(withJSONObject: json)
    )

    #expect(decoded.stats(for: .claude) == ActivityStats())
    #expect(decoded.stats(for: .codex) == ActivityStats())
}

@Test func sessionDeltaHasActivity() {
    let empty = SessionDelta()
    #expect(!empty.hasActivity)

    let withPrompt = SessionDelta(newPrompts: 1)
    #expect(withPrompt.hasActivity)

    let withTool = SessionDelta(newToolUses: 3)
    #expect(withTool.hasActivity)

    let withSession = SessionDelta(newSessions: 1)
    #expect(withSession.hasActivity)
}
