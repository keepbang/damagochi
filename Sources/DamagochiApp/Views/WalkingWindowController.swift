import AppKit
import SwiftUI

@MainActor
final class WalkingWindowController: NSObject, NSWindowDelegate {
    private static let frameKey = "com.damagochi.walkingWindow.frame"
    private var panel: NSPanel?
    private var hostingController: NSHostingController<WalkingPetView>?
    private let viewModel: PetViewModel

    init(viewModel: PetViewModel) {
        self.viewModel = viewModel
    }

    func show() {
        guard panel == nil else { return }

        let hostingController = NSHostingController(rootView: WalkingPetView(viewModel: viewModel))

        let panel = NSPanel(
            contentRect: NSRect(origin: .zero, size: restoredSize),
            styleMask: [.borderless, .nonactivatingPanel, .resizable],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.isMovableByWindowBackground = true
        panel.minSize = WalkingPetView.minimumContentSize
        panel.maxSize = NSSize(width: 1_200, height: 1_000)
        panel.delegate = self
        panel.contentViewController = hostingController

        if let screen = NSScreen.main {
            let f = screen.visibleFrame
            let s = panel.frame.size
            panel.setFrameOrigin(NSPoint(x: f.maxX - s.width - 24, y: max(f.minY + 24, f.maxY - s.height - 24)))
        }

        panel.orderFront(nil)
        self.panel = panel
        self.hostingController = hostingController
    }

    func hide() {
        panel?.close()
        panel = nil
        hostingController = nil
    }

    func windowDidResize(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }
        let size = window.frame.size
        UserDefaults.standard.set(["width": size.width, "height": size.height], forKey: Self.frameKey)
    }

    private var restoredSize: NSSize {
        guard let frame = UserDefaults.standard.dictionary(forKey: Self.frameKey),
              let width = frame["width"] as? Double,
              let height = frame["height"] as? Double
        else { return WalkingPetView.defaultContentSize }

        return NSSize(
            width: min(max(width, WalkingPetView.minimumContentSize.width), 1_200),
            height: min(max(height, WalkingPetView.minimumContentSize.height), 1_000)
        )
    }
}
