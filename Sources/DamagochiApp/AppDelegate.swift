import AppKit
import SwiftUI
import DamagochiCore
import DamagochiRenderer
import Combine

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    let viewModel = PetViewModel()
    private var stateSubscription: AnyCancellable?
    private var walkSubscription: AnyCancellable?
    private var walkingWindowController: WalkingWindowController?
    private var mainWindowController: MainWindowController?
    private var battleViewModel: BattleViewModel?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NotificationManager.shared.requestPermission()
        viewModel.start()

        // The main window and menu bar popover must share one local peer.
        // Creating a transport per window can advertise this Mac twice.
        let battleViewModel = BattleViewModel(petViewModel: viewModel)
        self.battleViewModel = battleViewModel

        let popover = NSPopover()
        popover.contentSize = NSSize(width: 280, height: 420)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: PopoverView(viewModel: viewModel, battleViewModel: battleViewModel)
        )
        self.popover = popover

        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            updateMenuBarIcon(button: button)
            updateTooltip(button: button)
            button.action = #selector(togglePopover(_:))
            button.target = self
            button.setAccessibilityLabel("Damagochi")
            button.setAccessibilityRole(.button)
        }
        self.statusItem = statusItem

        stateSubscription = viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let button = self?.statusItem?.button else { return }
                self?.updateMenuBarIcon(button: button, bugCount: state.activeBugs.count)
                self?.updateTooltip(button: button)
            }

        walkingWindowController = WalkingWindowController(viewModel: viewModel)
        walkSubscription = viewModel.$isWalking
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isWalking in
                if isWalking {
                    self?.walkingWindowController?.show()
                } else {
                    self?.walkingWindowController?.hide()
                }
            }

        mainWindowController = MainWindowController(
            viewModel: viewModel,
            battleViewModel: battleViewModel
        )
        mainWindowController?.show()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            mainWindowController?.show()
        }
        return true
    }

    func applicationWillTerminate(_ notification: Notification) {
        viewModel.stop()
    }

    @objc private func togglePopover(_ sender: AnyObject?) {
        guard let popover = popover, let button = statusItem?.button else { return }
        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    private func updateTooltip(button: NSStatusBarButton) {
        let state = viewModel.state
        switch state.phase {
        case .egg:
            button.toolTip = "Damagochi — 알 (XP: \(state.totalXp)/100)"
        case .alive:
            let name = state.name ?? state.species.flatMap { id in
                Species.allSpecies.first(where: { $0.id == id })?.name
            } ?? "펫"
            let xpNeeded = XPEngine().xpNeededForLevel(state.level + 1)
            button.toolTip = "Damagochi — \(name) Lv.\(state.level) (XP: \(state.xp)/\(xpNeeded))"
        case .dead:
            button.toolTip = "Damagochi — 사망"
        }
    }

    private func updateMenuBarIcon(button: NSStatusBarButton, bugCount: Int = 0) {
        let sprite = SpriteSheet.menuBarIcon(
            phase: viewModel.state.phase,
            stage: viewModel.state.stage
        )
        let scale: CGFloat = 2.0
        let size = CGFloat(sprite.width) * scale
        let image = NSImage(size: NSSize(width: size, height: size), flipped: false) { rect in
            guard let context = NSGraphicsContext.current?.cgContext else { return false }
            for row in 0..<sprite.height {
                for col in 0..<sprite.width {
                    let px = sprite.pixels[row][col]
                    guard !px.isTransparent else { continue }
                    let r = CGFloat((px.rawValue >> 16) & 0xFF) / 255.0
                    let g = CGFloat((px.rawValue >> 8) & 0xFF) / 255.0
                    let b = CGFloat(px.rawValue & 0xFF) / 255.0
                    let a = CGFloat((px.rawValue >> 24) & 0xFF) / 255.0
                    context.setFillColor(CGColor(red: r, green: g, blue: b, alpha: a))
                    let pixelRect = CGRect(
                        x: CGFloat(col) * scale,
                        y: CGFloat(sprite.height - 1 - row) * scale,
                        width: scale,
                        height: scale
                    )
                    context.fill(pixelRect)
                }
            }
            if bugCount > 0 {
                let dotSize: CGFloat = 6.0
                let dotRect = CGRect(x: size - dotSize, y: size - dotSize, width: dotSize, height: dotSize)
                context.setFillColor(NSColor.systemRed.cgColor)
                context.fillEllipse(in: dotRect)
            }
            return true
        }
        image.isTemplate = false
        button.image = image
    }
}
