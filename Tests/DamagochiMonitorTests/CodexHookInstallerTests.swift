import Testing
import Foundation
@testable import DamagochiMonitor

@Test func installCodexHooksUsesCodexSourceAndSupportedXpEvents() throws {
    let dir = NSTemporaryDirectory() + "damagochi-codex-hook-test-\(UUID().uuidString)"
    try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(atPath: dir) }

    let path = dir + "/hooks.json"
    let installer = CodexHookInstaller(hooksPath: path)
    try installer.install()

    #expect(installer.isInstalled())
    let data = try Data(contentsOf: URL(fileURLWithPath: path))
    let config = try JSONSerialization.jsonObject(with: data) as! [String: Any]
    let hooks = config["hooks"] as! [String: Any]

    #expect(hooks["SessionStart"] != nil)
    #expect(hooks["UserPromptSubmit"] != nil)
    #expect(hooks["PostToolUse"] != nil)
    #expect(hooks["Stop"] == nil)

    let groups = hooks["UserPromptSubmit"] as! [[String: Any]]
    let entries = groups[0]["hooks"] as! [[String: Any]]
    #expect(entries[0]["command"] as? String == "damagochi feed prompt --source codex")
}

@Test func codexHookInstallIsIdempotentAndPreservesOtherHooks() throws {
    let dir = NSTemporaryDirectory() + "damagochi-codex-hook-test-\(UUID().uuidString)"
    try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(atPath: dir) }

    let path = dir + "/hooks.json"
    let existing: [String: Any] = [
        "hooks": [
            "UserPromptSubmit": [
                ["hooks": [["type": "command", "command": "echo existing"]]]
            ]
        ]
    ]
    try JSONSerialization.data(withJSONObject: existing).write(to: URL(fileURLWithPath: path))

    let installer = CodexHookInstaller(hooksPath: path)
    try installer.install()
    try installer.install()

    let data = try Data(contentsOf: URL(fileURLWithPath: path))
    let config = try JSONSerialization.jsonObject(with: data) as! [String: Any]
    let hooks = config["hooks"] as! [String: Any]
    let groups = hooks["UserPromptSubmit"] as! [[String: Any]]
    #expect(groups.count == 2)
}

@Test func uninstallCodexHooksPreservesOtherHooks() throws {
    let dir = NSTemporaryDirectory() + "damagochi-codex-hook-test-\(UUID().uuidString)"
    try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(atPath: dir) }

    let path = dir + "/hooks.json"
    let installer = CodexHookInstaller(hooksPath: path)
    try installer.install()

    var data = try Data(contentsOf: URL(fileURLWithPath: path))
    var config = try JSONSerialization.jsonObject(with: data) as! [String: Any]
    var hooks = config["hooks"] as! [String: Any]
    var promptGroups = hooks["UserPromptSubmit"] as! [[String: Any]]
    promptGroups.append(["hooks": [["type": "command", "command": "echo existing"]]])
    hooks["UserPromptSubmit"] = promptGroups
    config["hooks"] = hooks
    data = try JSONSerialization.data(withJSONObject: config)
    try data.write(to: URL(fileURLWithPath: path))

    try installer.uninstall()
    #expect(!installer.isInstalled())

    let loaded = try JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: path))) as! [String: Any]
    let remainingHooks = loaded["hooks"] as! [String: Any]
    let remainingGroups = remainingHooks["UserPromptSubmit"] as! [[String: Any]]
    #expect(remainingGroups.count == 1)
}
