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
            contentRect: NSRect(x: 0, y: 0, width: 160, height: 180),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.isMovableByWindowBackground = true
        panel.contentViewController = hostingController
        panel.setContentSize(hostingController.view.fittingSize)

        if let screen = NSScreen.main {
            let f = screen.visibleFrame
            let s = panel.frame.size
            panel.setFrameOrigin(NSPoint(x: f.maxX - s.width - 24, y: f.minY + 120))
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
