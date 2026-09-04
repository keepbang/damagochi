import SwiftUI
import DamagochiCore
import DamagochiRenderer

struct InventoryView: View {
    @ObservedObject var viewModel: PetViewModel

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()

            petEquipmentRoster
            Divider()

            if viewModel.state.inventory.isEmpty {
                emptyState
            } else {
                inventoryContent
            }
        }
    }

    private var petEquipmentRoster: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 5) {
            ForEach(Array(viewModel.pets.enumerated()), id: \.offset) { index, pet in
                Button(action: {
                    viewModel.selectPet(at: index)
                }) {
                    let equippedCount = [pet.equippedItems.head, pet.equippedItems.hand, pet.equippedItems.effect].compactMap { $0 }.count
                    let profile = viewModel.battleProfile(for: pet)
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text("슬롯 \(index + 1)").font(.system(size: 8, weight: .bold)).foregroundStyle(.secondary)
                            Text(pet.name ?? pet.species ?? "알").font(.system(size: 10, weight: .semibold)).lineLimit(1)
                            Spacer(minLength: 0)
                        }
                        Text("장비 \(equippedCount)/3 · \(pet.inventory.count)개")
                            .font(.system(size: 8)).foregroundStyle(.secondary)
                        if let profile {
                            Text("ATK \(profile.stats.atk) DEF \(profile.stats.def)")
                                .font(.system(size: 8, design: .monospaced)).foregroundStyle(.teal)
                        }
                    }
                    .padding(5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(index == viewModel.selectedPetIndex ? Color.accentColor.opacity(0.14) : Color.primary.opacity(0.035), in: RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
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
        return VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(item != nil ? rarityColor(item!.rarity).opacity(0.15) : Color.secondary.opacity(0.08))
                    .frame(height: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                item != nil ? rarityColor(item!.rarity).opacity(0.4) : Color.clear,
                                lineWidth: 1
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
