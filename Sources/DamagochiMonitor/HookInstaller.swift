import Foundation

public struct HookInstaller: Sendable {
    public static let hookMarker = "damagochi"

    public struct HookEntry: Codable, Sendable {
        public var matcher: String?
        public var command: String

        public init(matcher: String? = nil, command: String) {
            self.matcher = matcher
            self.command = command
        }
    }

    private let settingsPath: String

    public init(settingsPath: String = NSHomeDirectory() + "/.claude/settings.json") {
        self.settingsPath = settingsPath
    }

    public static var defaultHooks: [String: [HookEntry]] {
        [
            "UserPromptSubmit": [HookEntry(command: "damagochi feed prompt --source claude")],
            "PostToolUse": [HookEntry(command: "damagochi feed tool --source claude")],
            "SessionStart": [HookEntry(command: "damagochi feed session --source claude")],
            "Stop": [HookEntry(command: "damagochi feed stop --source claude")],
            "Notification": [HookEntry(command: "damagochi feed notification --source claude")],
        ]
    }

    public func install() throws {
        var settings = try loadSettings()
        var hooks = (settings["hooks"] as? [String: Any]) ?? [:]

        for (event, entries) in Self.defaultHooks {
            var existing = (hooks[event] as? [[String: Any]]) ?? []
            existing.removeAll { entry in
                guard let hooksList = entry["hooks"] as? [[String: Any]] else { return false }
                return hooksList.contains { h in
                    guard let cmd = h["command"] as? String else { return false }
                    return cmd.contains(Self.hookMarker)
                }
            }
            for entry in entries {
                var dict: [String: Any] = [
                    "hooks": [["type": "command", "command": entry.command]]
                ]
                if let matcher = entry.matcher {
                    dict["matcher"] = matcher
                }
                existing.append(dict)
            }
            hooks[event] = existing
        }

        settings["hooks"] = hooks
        try saveSettings(settings)
    }

    public func uninstall() throws {
        var settings = try loadSettings()
        guard var hooks = settings["hooks"] as? [String: Any] else { return }

        for event in Self.defaultHooks.keys {
            guard var entries = hooks[event] as? [[String: Any]] else { continue }
            entries.removeAll { entry in
                guard let hooksList = entry["hooks"] as? [[String: Any]] else { return false }
                return hooksList.contains { h in
                    guard let cmd = h["command"] as? String else { return false }
                    return cmd.contains(Self.hookMarker)
                }
            }
            if entries.isEmpty {
                hooks.removeValue(forKey: event)
            } else {
                hooks[event] = entries
            }
        }

        if hooks.isEmpty {
            settings.removeValue(forKey: "hooks")
        } else {
            settings["hooks"] = hooks
        }
        try saveSettings(settings)
    }

    public func isInstalled() -> Bool {
        guard let settings = try? loadSettings(),
              let hooks = settings["hooks"] as? [String: Any] else { return false }

        for event in Self.defaultHooks.keys {
            guard let entries = hooks[event] as? [[String: Any]] else { return false }
            let hasDamagochi = entries.contains { entry in
                guard let hooksList = entry["hooks"] as? [[String: Any]] else { return false }
                return hooksList.contains { h in
                    guard let cmd = h["command"] as? String else { return false }
                    return cmd.contains(Self.hookMarker)
                }
            }
            if !hasDamagochi { return false }
        }
        return true
    }

    public func hasAnyDamagochiHook() -> Bool {
        guard let settings = try? loadSettings(),
              let hooks = settings["hooks"] as? [String: Any] else { return false }
        for (_, value) in hooks {
            guard let entries = value as? [[String: Any]] else { continue }
            for entry in entries {
                guard let hooksList = entry["hooks"] as? [[String: Any]] else { continue }
                if hooksList.contains(where: { ($0["command"] as? String)?.contains(Self.hookMarker) == true }) {
                    return true
                }
            }
        }
        return false
    }

    private func loadSettings() throws -> [String: Any] {
        let fm = FileManager.default
        guard fm.fileExists(atPath: settingsPath),
              let data = fm.contents(atPath: settingsPath),
              let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return [:]
        }
        return json
    }

    private func saveSettings(_ settings: [String: Any]) throws {
        let dir = (settingsPath as NSString).deletingLastPathComponent
        try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
        let data = try JSONSerialization.data(withJSONObject: settings, options: [.prettyPrinted, .sortedKeys])
        try data.write(to: URL(fileURLWithPath: settingsPath))
    }
}
