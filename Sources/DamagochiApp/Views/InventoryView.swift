import AppKit
import SwiftUI
import DamagochiCore
import DamagochiRenderer

struct InventoryView: View {
    @ObservedObject var viewModel: PetViewModel
    @StateObject private var adjustCtrl = ItemAdjustmentController()

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()

            if viewModel.state.inventory.isEmpty {
                emptyState
            } else {
                inventoryContent
            }
        }
        .onDisappear {
            adjustCtrl.deactivate(viewModel: viewModel)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("장비")
                .font(.headline)
            Spacer()
            Text("\(viewModel.state.inventory.count)개 보유")
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - Content

    private var inventoryContent: some View {
        ScrollView {
            VStack(spacing: 10) {
                if viewModel.state.phase == .alive && hasEquippedItems {
                    positionSection
                    Divider()
                }
                equippedSection
                Divider()
                fusionSection
                Divider()
                allItemsSection
            }
            .padding(10)
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Position Adjustment Section

    private var hasEquippedItems: Bool {
        viewModel.state.equippedItems.head != nil ||
        viewModel.state.equippedItems.hand != nil ||
        viewModel.state.equippedItems.effect != nil
    }

    private var positionSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("위치 조정")
                .font(.caption.bold())
                .foregroundStyle(.secondary)

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.quaternary.opacity(0.3))

                EquippedPetView(
                    viewModel: viewModel,
                    scale: 14.0 / 3.0,
                    interval: 0.5,
                    highlightedSlot: adjustCtrl.slot
                )
            }
            .frame(height: 128)

            positionHint
        }
    }

    @ViewBuilder
    private var positionHint: some View {
        if let slot = adjustCtrl.slot {
            let off = viewModel.equipmentOffset(for: slot)
            HStack(spacing: 6) {
                Image(systemName: "arrow.up.and.down.and.arrow.left.and.right")
                    .font(.caption2)
                    .foregroundStyle(.blue)
                Text("← → ↑ ↓ 이동  ·  위치: (\(off.x), \(off.y))")
                    .font(.caption2)
                    .foregroundStyle(.blue)
                Spacer()
                Button("초기화") {
                    viewModel.resetEquipmentOffset(for: slot)
                }
                .font(.caption2)
                .foregroundStyle(.orange)
                .buttonStyle(.plain)
                Text("·")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Button("완료") {
                    adjustCtrl.deactivate(viewModel: viewModel)
                }
                .font(.caption2.bold())
                .foregroundStyle(.blue)
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 4)
        } else {
            Text("슬롯 옆 위치조정 아이콘을 눌러 키보드로 이동하세요")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    // MARK: - Equipped Slots

    private var fusionSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("아이템 합성")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            Text("장착하지 않은 같은 단계 아이템 10개를 다음 단계 아이템 1개로 합성합니다.")
                .font(.system(size: 9))
                .foregroundStyle(.tertiary)

            ForEach([Rarity.common, .rare, .legendary], id: \.self) { rarity in
                let count = viewModel.fusionMaterialCount(for: rarity)
                let nextName = rarity.next?.rawValue ?? ""
                HStack(spacing: 6) {
                    Text("\(rarityEmoji(rarity)) \(rarityLabel(rarity))")
                        .font(.system(size: 10, weight: .medium))
                    Spacer()
                    Text("\(count)/10 → \(nextName)")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(count >= EquipmentFusion.materialCount ? .teal : .secondary)
                    Button("합성") { viewModel.fuseItems(rarity: rarity) }
                        .font(.system(size: 9, weight: .semibold))
                        .buttonStyle(.bordered)
                        .controlSize(.mini)
                        .disabled(count < EquipmentFusion.materialCount)
                }
            }
            Text("🌈 미식 아이템은 최상위 단계라 합성할 수 없습니다.")
                .font(.system(size: 9))
                .foregroundStyle(.tertiary)
        }
    }

    private var equippedSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("장착 중")
                .font(.caption.bold())
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                ForEach(EquipmentSlot.allCases, id: \.self) { slot in
                    equippedSlotCard(slot)
                }
            }
        }
    }

    private func equippedSlotCard(_ slot: EquipmentSlot) -> some View {
        let item = viewModel.equippedItem(for: slot)
        let isAdjusting = adjustCtrl.slot == slot
        return VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(item != nil ? rarityColor(item!.rarity).opacity(0.15) : Color.secondary.opacity(0.08))
                    .frame(height: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                isAdjusting
                                    ? Color.accentColor.opacity(0.6)
                                    : (item != nil ? rarityColor(item!.rarity).opacity(0.4) : Color.clear),
                                lineWidth: isAdjusting ? 1.5 : 1
                            )
                    )

                if let item {
                    VStack(spacing: 2) {
                        Text(rarityEmoji(item.rarity))
                            .font(.title3)
                        Text(item.name)
                            .font(.system(size: 8))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 2)
                } else {
                    VStack(spacing: 2) {
                        Image(systemName: slotIcon(slot))
                            .font(.system(size: 14))
                            .foregroundStyle(.tertiary)
                        Text(slotLabel(slot))
                            .font(.system(size: 8))
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            HStack(spacing: 6) {
                Button("해제") {
                    if item != nil { viewModel.unequip(slot: slot) }
                }
                .font(.system(size: 9))
                .foregroundStyle(.red)
                .buttonStyle(.plain)
                .opacity(item != nil ? 1 : 0)

                if item != nil {
                    Button(action: {
                        if isAdjusting {
                            adjustCtrl.deactivate(viewModel: viewModel)
                        } else {
                            adjustCtrl.activate(slot: slot, viewModel: viewModel)
                        }
                    }) {
                        Image(systemName: isAdjusting
                              ? "scope"
                              : "arrow.up.and.down.and.arrow.left.and.right")
                            .font(.system(size: 9))
                            .foregroundStyle(isAdjusting ? .blue : .secondary)
                    }
                    .buttonStyle(.plain)
                    .help(isAdjusting ? "위치 조정 완료" : "키보드로 위치 조정")
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var allItemsSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("인벤토리")
                .font(.caption.bold())
                .foregroundStyle(.secondary)

            VStack(spacing: 0) {
                ForEach(viewModel.state.inventory) { item in
                    ItemRow(item: item, isEquipped: isItemEquipped(item)) {
                        if isItemEquipped(item) {
                            viewModel.unequip(slot: item.slot)
                        } else {
                            viewModel.equip(itemId: item.id)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 10) {
            Spacer()
            Image(systemName: "bag")
                .font(.system(size: 32))
                .foregroundStyle(.quaternary)
            Text("장비가 없습니다")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            Text("레벨업 시 장비를 획득할 수 있어요")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
    }

    // MARK: - Helpers

    private func isItemEquipped(_ item: Equipment) -> Bool {
        switch item.slot {
        case .head:   return viewModel.state.equippedItems.head == item.id
        case .hand:   return viewModel.state.equippedItems.hand == item.id
        case .effect: return viewModel.state.equippedItems.effect == item.id
        }
    }

    private func rarityEmoji(_ rarity: Rarity) -> String {
        switch rarity {
        case .common:    return "⚪"
        case .rare:      return "🔵"
        case .legendary: return "🟡"
        case .mythic:    return "🌈"
        }
    }

    private func rarityColor(_ rarity: Rarity) -> Color {
        switch rarity {
        case .common:    return .gray
        case .rare:      return .blue
        case .legendary: return .yellow
        case .mythic:    return .purple
        }
    }

    private func rarityLabel(_ rarity: Rarity) -> String {
        switch rarity {
        case .common: return "커먼"
        case .rare: return "레어"
        case .legendary: return "레전더리"
        case .mythic: return "미식"
        }
    }

    private func slotIcon(_ slot: EquipmentSlot) -> String {
        switch slot {
        case .head:   return "crown"
        case .hand:   return "hand.raised"
        case .effect: return "sparkle"
        }
    }

    private func slotLabel(_ slot: EquipmentSlot) -> String {
        switch slot {
        case .head:   return "머리"
        case .hand:   return "손"
        case .effect: return "효과"
        }
    }
}

// MARK: - Keyboard Adjustment Controller

@MainActor
private final class ItemAdjustmentController: ObservableObject {
    @Published var slot: EquipmentSlot? = nil
    private var monitor: Any?

    func activate(slot: EquipmentSlot, viewModel: PetViewModel) {
        deactivate(viewModel: viewModel)
        self.slot = slot
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            MainActor.assumeIsolated {
                guard let self, let s = self.slot else { return event }
                switch event.keyCode {
                case 123: // ← left
                    let off = viewModel.equipmentOffset(for: s)
                    viewModel.setEquipmentOffset(PixelOffset(x: off.x - 1, y: off.y), for: s)
                    return nil
                case 124: // → right
                    let off = viewModel.equipmentOffset(for: s)
                    viewModel.setEquipmentOffset(PixelOffset(x: off.x + 1, y: off.y), for: s)
                    return nil
                case 126: // ↑ up
                    let off = viewModel.equipmentOffset(for: s)
                    viewModel.setEquipmentOffset(PixelOffset(x: off.x, y: off.y - 1), for: s)
                    return nil
                case 125: // ↓ down
                    let off = viewModel.equipmentOffset(for: s)
                    viewModel.setEquipmentOffset(PixelOffset(x: off.x, y: off.y + 1), for: s)
                    return nil
                case 36, 76: // Return / numpad Enter
                    self.deactivate(viewModel: viewModel)
                    return nil
                case 53: // Escape
                    self.deactivate(viewModel: viewModel)
                    return nil
                default:
                    return event
                }
            }
        }
    }

    func deactivate(viewModel: PetViewModel) {
        if let m = monitor { NSEvent.removeMonitor(m); monitor = nil }
        if slot != nil { viewModel.save(); slot = nil }
    }

    deinit {
        if let m = monitor { NSEvent.removeMonitor(m) }
    }
}

// MARK: - Item Row

private struct ItemRow: View {
    let item: Equipment
    let isEquipped: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(rarityColor.opacity(0.12))
                    .frame(width: 32, height: 32)
                Text(rarityEmoji)
                    .font(.body)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(item.name)
                        .font(.caption.bold())
                    Text("[\(slotLabel)]")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                    if isEquipped {
                        Text("장착")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(rarityColor, in: Capsule())
                    }
                }
                Text(item.description)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }

            Spacer()

            Button(isEquipped ? "해제" : "장착") {
                onToggle()
            }
            .buttonStyle(.bordered)
            .controlSize(.mini)
            .tint(isEquipped ? .red : rarityColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isEquipped ? rarityColor.opacity(0.06) : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isEquipped ? rarityColor.opacity(0.3) : Color.clear, lineWidth: 0.5)
                )
        )
    }

    private var rarityEmoji: String {
        switch item.rarity {
        case .common:    return "⚪"
        case .rare:      return "🔵"
        case .legendary: return "🟡"
        case .mythic:    return "🌈"
        }
    }

    private var rarityColor: Color {
        switch item.rarity {
        case .common:    return .gray
        case .rare:      return .blue
        case .legendary: return .orange
        case .mythic:    return .purple
        }
    }

    private var slotLabel: String {
        switch item.slot {
        case .head:   return "머리"
        case .hand:   return "손"
        case .effect: return "효과"
        }
    }
}
