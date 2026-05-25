import Testing
import Foundation
@testable import DamagochiMonitor

@Test func installHooksIntoEmptySettings() throws {
    let dir = NSTemporaryDirectory() + "damagochi-hook-test-\(UUID().uuidString)"
    try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(atPath: dir) }

    let path = dir + "/settings.json"
    let installer = HookInstaller(settingsPath: path)

    try installer.install()

    #expect(installer.isInstalled())

    let data = try Data(contentsOf: URL(fileURLWithPath: path))
    let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
    let hooks = json["hooks"] as! [String: Any]

    #expect(hooks["UserPromptSubmit"] != nil)
    #expect(hooks["PostToolUse"] != nil)
    #expect(hooks["SessionStart"] != nil)

    let promptHooks = hooks["UserPromptSubmit"] as! [[String: Any]]
    #expect(promptHooks.count == 1)
    let commands = promptHooks[0]["hooks"] as! [[String: Any]]
    #expect((commands[0]["command"] as? String) == "damagochi feed prompt --source claude")
}

@Test func installPreservesExistingHooks() throws {
    let dir = NSTemporaryDirectory() + "damagochi-hook-test-\(UUID().uuidString)"
    try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(atPath: dir) }

    let path = dir + "/settings.json"
    let existing: [String: Any] = [
        "hooks": [
            "UserPromptSubmit": [
                ["hooks": [["type": "command", "command": "echo existing"]]]
            ]
        ],
        "otherSetting": true
    ]
    let data = try JSONSerialization.data(withJSONObject: existing)
    try data.write(to: URL(fileURLWithPath: path))

    let installer = HookInstaller(settingsPath: path)
    try installer.install()

    let loaded = try Data(contentsOf: URL(fileURLWithPath: path))
    let json = try JSONSerialization.jsonObject(with: loaded) as! [String: Any]

    #expect(json["otherSetting"] as? Bool == true)

    let hooks = json["hooks"] as! [String: Any]
    let promptHooks = hooks["UserPromptSubmit"] as! [[String: Any]]
    #expect(promptHooks.count == 2)

    let commands = promptHooks.compactMap {
        ($0["hooks"] as? [[String: Any]])?.first?["command"] as? String
    }
    #expect(commands.contains("echo existing"))
    #expect(commands.contains("damagochi feed prompt --source claude"))
}

@Test func uninstallRemovesDamagochiHooks() throws {
    let dir = NSTemporaryDirectory() + "damagochi-hook-test-\(UUID().uuidString)"
    try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(atPath: dir) }

    let path = dir + "/settings.json"
    let installer = HookInstaller(settingsPath: path)

    try installer.install()
    #expect(installer.isInstalled())

    try installer.uninstall()
    #expect(!installer.isInstalled())
}

@Test func uninstallPreservesOtherHooks() throws {
    let dir = NSTemporaryDirectory() + "damagochi-hook-test-\(UUID().uuidString)"
    try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(atPath: dir) }

    let path = dir + "/settings.json"
    let existing: [String: Any] = [
        "hooks": [
            "UserPromptSubmit": [
                ["hooks": [["type": "command", "command": "echo existing"]]],
                ["hooks": [["type": "command", "command": "damagochi feed prompt --source claude"]]]
            ]
        ]
    ]
    let data = try JSONSerialization.data(withJSONObject: existing)
    try data.write(to: URL(fileURLWithPath: path))

    let installer = HookInstaller(settingsPath: path)
    try installer.uninstall()

    let loaded = try Data(contentsOf: URL(fileURLWithPath: path))
    let json = try JSONSerialization.jsonObject(with: loaded) as! [String: Any]
    let hooks = json["hooks"] as! [String: Any]
    let promptHooks = hooks["UserPromptSubmit"] as! [[String: Any]]
    #expect(promptHooks.count == 1)
    let commands = promptHooks[0]["hooks"] as! [[String: Any]]
    #expect((commands[0]["command"] as? String) == "echo existing")
}

@Test func installIsIdempotent() throws {
    let dir = NSTemporaryDirectory() + "damagochi-hook-test-\(UUID().uuidString)"
    try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(atPath: dir) }

    let path = dir + "/settings.json"
    let installer = HookInstaller(settingsPath: path)

    try installer.install()
    try installer.install()

    let data = try Data(contentsOf: URL(fileURLWithPath: path))
    let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
    let hooks = json["hooks"] as! [String: Any]
    let promptHooks = hooks["UserPromptSubmit"] as! [[String: Any]]
    #expect(promptHooks.count == 1)
}
