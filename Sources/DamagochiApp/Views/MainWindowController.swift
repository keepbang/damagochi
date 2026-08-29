import AppKit
import SwiftUI

@MainActor
final class MainWindowController: NSObject, NSWindowDelegate {
    private var window: NSWindow?
    private let viewModel: PetViewModel
    private let battleViewModel: BattleViewModel

    init(viewModel: PetViewModel, battleViewModel: BattleViewModel) {
        self.viewModel = viewModel
        self.battleViewModel = battleViewModel
    }

    func show() {
        if let window = window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let hostingController = NSHostingController(
            rootView: PopoverView(viewModel: viewModel, battleViewModel: battleViewModel)
        )

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 280, height: 500),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Damagochi"
        window.contentViewController = hostingController
        window.isReleasedWhenClosed = false
        window.delegate = self
        window.center()
        window.setFrameAutosaveName("DamagochiMainWindow")

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        self.window = window
    }

    func toggle() {
        if let window = window, window.isVisible {
            window.orderOut(nil)
        } else {
            show()
        }
    }

    func windowWillClose(_ notification: Notification) {
        // Keep the window object so re-opening preserves state and frame.
    }
}
