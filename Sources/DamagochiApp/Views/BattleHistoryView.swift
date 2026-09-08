import SwiftUI
import DamagochiCore

struct BattleHistoryView: View {
    let entries: [BattleHistoryEntry]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("배틀 이력").font(.headline)
                Spacer()
                Button("닫기") { dismiss() }
            }
            let record = BattleRecord(entries: entries)
            Text("\(record.wins)승 · \(record.losses)패 · \(record.draws)무승부")
                .font(.title3.bold())
                .monospacedDigit()
            Divider()
            if entries.isEmpty {
                ContentUnavailableView("아직 배틀 이력이 없어요", systemImage: "clock",
                                       description: Text("앞으로 참여하는 배틀이 여기에 기록됩니다."))
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(entries.sorted { $0.startedAt > $1.startedAt }) { entry in
                            historyRow(entry)
                        }
                    }
                }
            }
        }
        .padding(16)
        .frame(minWidth: 320, idealWidth: 360, minHeight: 360, idealHeight: 460)
    }

    private func historyRow(_ entry: BattleHistoryEntry) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(entry.mode.displayName).font(.caption).foregroundStyle(.secondary)
                Spacer()
                Text(entry.endedAt == nil ? "미완료" : entry.outcome.displayName).font(.subheadline.bold())
                    .foregroundStyle(outcomeColor(entry.outcome))
            }
            Text("상대: \(entry.opponentName)").font(.subheadline.bold())
            Text(entry.startedAt.formatted(date: .abbreviated, time: .standard))
                .font(.caption).foregroundStyle(.secondary)
            participants("내 출전 펫", profiles: entry.myPets)
            participants("상대 출전 펫", profiles: entry.opponentPets)
            if let reason = entry.reason {
                Text(reason).font(.caption).foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 8))
    }

    private func participants(_ label: String, profiles: [BattleProfile]) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            ForEach(profiles) { profile in
                HStack(alignment: .firstTextBaseline) {
                    Text(profile.petName).font(.caption.bold())
                    if let level = profile.petLevel ?? profile.battleLevel {
                        Text("Lv.\(level)").font(.caption2).foregroundStyle(.secondary)
                            .lineLimit(1).fixedSize()
                    }
                }
            }
        }
    }

    private func outcomeColor(_ outcome: BattleOutcome) -> Color {
        switch outcome {
        case .victory: return .green
        case .defeat: return .red
        case .draw: return .orange
        case .interrupted: return .secondary
        }
    }
}
