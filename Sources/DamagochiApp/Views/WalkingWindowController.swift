import AppKit
import SwiftUI

@MainActor
final class WalkingWindowController {
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
            contentRect: NSRect(origin: .zero, size: WalkingPetView.defaultContentSize),
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
}
