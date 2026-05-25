import Foundation

public struct CodexHookInstaller: Sendable {
    public static let hookMarker = "damagochi"

    private let hooksPath: String

    public init(hooksPath: String = NSHomeDirectory() + "/.codex/hooks.json") {
        self.hooksPath = hooksPath
    }

    public static var defaultHooks: [String: String] {
        [
            "UserPromptSubmit": "damagochi feed prompt --source codex",
            "PostToolUse": "damagochi feed tool --source codex",
            "SessionStart": "damagochi feed session --source codex",
        ]
    }

    public func install() throws {
        var config = try loadConfig()
        var hooks = (config["hooks"] as? [String: Any]) ?? [:]

        for (event, command) in Self.defaultHooks {
            var groups = (hooks[event] as? [[String: Any]]) ?? []
            groups.removeAll(where: containsDamagochiCommand)
            groups.append([
                "hooks": [[
                    "type": "command",
                    "command": command,
                ]],
            ])
            hooks[event] = groups
        }

        config["hooks"] = hooks
        try saveConfig(config)
    }

    public func uninstall() throws {
        var config = try loadConfig()
        guard var hooks = config["hooks"] as? [String: Any] else { return }

        for event in Self.defaultHooks.keys {
            guard var groups = hooks[event] as? [[String: Any]] else { continue }
            groups.removeAll(where: containsDamagochiCommand)
            if groups.isEmpty {
                hooks.removeValue(forKey: event)
            } else {
                hooks[event] = groups
            }
        }

        if hooks.isEmpty {
            config.removeValue(forKey: "hooks")
        } else {
            config["hooks"] = hooks
        }
        try saveConfig(config)
    }

    public func isInstalled() -> Bool {
        guard let config = try? loadConfig(),
              let hooks = config["hooks"] as? [String: Any] else { return false }
        return Self.defaultHooks.keys.allSatisfy { event in
            guard let groups = hooks[event] as? [[String: Any]] else { return false }
            return groups.contains(where: containsDamagochiCommand)
        }
    }

    private func containsDamagochiCommand(_ group: [String: Any]) -> Bool {
        guard let entries = group["hooks"] as? [[String: Any]] else { return false }
        return entries.contains {
            ($0["command"] as? String)?.contains(Self.hookMarker) == true
        }
    }

    private func loadConfig() throws -> [String: Any] {
        let fm = FileManager.default
        guard fm.fileExists(atPath: hooksPath),
              let data = fm.contents(atPath: hooksPath),
              let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return [:]
        }
        return json
    }

    private func saveConfig(_ config: [String: Any]) throws {
        let directory = (hooksPath as NSString).deletingLastPathComponent
        try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true)
        let data = try JSONSerialization.data(withJSONObject: config, options: [.prettyPrinted, .sortedKeys])
        try data.write(to: URL(fileURLWithPath: hooksPath))
    }
}
