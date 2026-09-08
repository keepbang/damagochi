import AppKit
import Foundation
import Combine
import CryptoKit
import DamagochiCore
import DamagochiMonitor
import DamagochiStorage
import DamagochiRenderer

enum AppTab: String, CaseIterable {
    case pet, inventory, achievements, graveyard, notifications, battle, settings

    var icon: String {
        switch self {
        case .pet:           return "pawprint.fill"
        case .inventory:     return "bag.fill"
        case .achievements:  return "trophy.fill"
        case .graveyard:     return "book.closed.fill"
        case .notifications: return "bell.fill"
        case .battle:        return "bolt.shield.fill"
        case .settings:      return "gearshape.fill"
        }
    }
}

struct PetNotification: Identifiable {
    let id = UUID()
    let message: String
    let icon: String
}

struct WalkNotification: Identifiable {
    let id = UUID()
    let message: String
    let timestamp: Date
    var isRead: Bool = false
}

@MainActor
final class PetViewModel: ObservableObject {
    @Published var state: PetState
    @Published private(set) var roster: PetRoster
    @Published var selectedTab: AppTab = .pet
    @Published var notification: PetNotification?
    @Published var claudeHookInstalled: Bool = false
    @Published var codexHookInstalled: Bool = false
    @Published var notificationsEnabled: Bool {
        didSet { UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled") }
    }

    private let store = PetStore()
    private let processor = FeedProcessor()
    private let deathChecker = DeathChecker()
    private let inventoryManager = InventoryManager()
    private let equipmentFusion = EquipmentFusion()
    private let claudeHookInstaller = HookInstaller()
    private let codexHookInstaller = CodexHookInstaller()
    private let notificationManager = NotificationManager.shared
    private var eventObserver: NSObjectProtocol?
    private var monitor: ClaudeSessionMonitor?
    private var deathCheckTimer: AnyCancellable?
    private var decayTimer: AnyCancellable?
    private var notificationTimer: AnyCancellable?
    private var bugSpawnTimer: AnyCancellable?
    private var bugCleanupTimer: AnyCancellable?
    @Published var latestVersion: String?
    @Published var isCheckingUpdate: Bool = false
    @Published var isUpdating: Bool = false
    @Published var updateError: String?
    @Published var isWalking: Bool = false
    @Published var walkSpeechBubble: String?
    @Published var walkNotifications: [WalkNotification] = []
    @Published var petSpeechBubble: String?
    @Published var bugXPPopup: String?
    private var walkingDecayTimer: AnyCancellable?
    private var speechBubbleTimer: AnyCancellable?
    private var petSpeechBubbleTimer: AnyCancellable?
    private var bugPopupTimer: AnyCancellable?

    var pets: [PetState] { roster.pets }
    var selectedPetIndex: Int { roster.selectedIndex }
    var canAddPet: Bool { roster.canAddPet }
    var accountActivityStats: ActivityStats { roster.activityStats }

    var baseFrames: [PixelSprite] { baseFrames(direction: .front) }

    func baseFrames(direction: SpriteDirection) -> [PixelSprite] {
        SpriteSheet.frames(
            species: state.species,
            stage: state.stage,
            phase: state.phase,
            direction: direction
        )
    }

    var equippedOverlays: [SpriteSheet.EquippedOverlay] {
        guard state.phase == .alive else { return [] }
        return SpriteSheet.equippedOverlays(
            equipped: state.equippedItems,
            inventory: state.inventory
        ).filter { $0.slot == .effect }
    }

    func setPetName(_ name: String) {
        guard state.phase == .alive else { return }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedName = trimmedName.isEmpty ? nil : String(trimmedName.prefix(12))
        guard state.name != normalizedName else { return }

        state.name = normalizedName
        save()
    }

    var statusMessage: String {
        switch state.phase {
        case .egg:
            return state.totalXp > 50 ? "곧 부화할 것 같아요..." : "따뜻하게 해주세요..."
        case .dead:
            return "..."
        case .alive:
            if state.hunger < 20 { return "배고파요..." }
            if state.hp < 30 { return "힘이 없어요..." }
            if state.mood < 30 { return "외로워요..." }
            if state.mood > 80 { return "기분이 좋아요!" }
            return "코딩 중..."
        }
    }

    var displayXp: Int {
        state.phase == .egg ? state.totalXp : state.xp
    }

    var xpProgress: Double {
        if state.phase == .egg {
            return min(1.0, Double(state.totalXp) / 100.0)
        }
        let needed = XPEngine().xpNeededForLevel(state.level + 1)
        guard needed > 0 else { return 1 }
        return min(1.0, Double(state.xp) / Double(needed))
    }

    var xpNeededForNextLevel: Int {
        if state.phase == .egg { return 100 }
        return XPEngine().xpNeededForLevel(state.level + 1)
    }

    init() {
        self.notificationsEnabled = UserDefaults.standard.object(forKey: "notificationsEnabled") as? Bool ?? true
        let hostHash = ProcessInfo.processInfo.hostName
            .data(using: .utf8)
            .map { CryptoKit.SHA256.hash(data: $0) }
            .map { $0.prefix(8).map { String(format: "%02x", $0) }.joined() }
            ?? "unknown"
        var loadedRoster = store.loadRoster() ?? PetRoster(pets: [PetState(machineId: hostHash)])
        loadedRoster.migrateAccountActivityStatsIfNeeded()
        self.roster = loadedRoster
        self.state = loadedRoster.selectedPet ?? PetState(machineId: hostHash)
        // Auto-upgrade older damagochi hook installs so newly added Stop/Notification hooks land
        // without forcing the user to manually re-install.
        if !claudeHookInstaller.isInstalled() && claudeHookInstaller.hasAnyDamagochiHook() {
            try? claudeHookInstaller.install()
        }
        self.claudeHookInstalled = claudeHookInstaller.isInstalled()
        self.codexHookInstalled = codexHookInstaller.isInstalled()
    }

    func start() {
        if notificationsEnabled {
            notificationManager.requestPermission()
        }

        checkDeath()

        synchronizeSelectedPet()
        for index in roster.pets.indices where roster.pets[index].phase == .alive {
            let engine = XPEngine()
            let result = engine.checkLevelUp(currentLevel: roster.pets[index].level, currentXp: roster.pets[index].xp)
            if result.newLevel != roster.pets[index].level {
                roster.pets[index].level = result.newLevel
                roster.pets[index].xp = result.remainingXp
            }
        }
        refreshSelectedPet()

        // Pending 파일은 라이브 옵저버와 별개로 모든 이벤트가 append 된다.
        // 이미 라이브로 처리된 이벤트가 재시작 시 다시 replay 되면 streakDays/통계가 망가지므로,
        // lastActiveAt 이후에 발생한 이벤트(즉 앱이 꺼져 있을 때의 catch-up)만 처리한다.
        let cursor = roster.pets.map(\.lastActiveAt).max() ?? state.lastActiveAt
        let pending = EventBridge.drainFileEvents()
        let fresh = pending.filter { $0.timestamp > cursor }
        for event in fresh { _ = processEventAcrossRoster(event) }
        if !fresh.isEmpty { save() }

        eventObserver = EventBridge.observe { [weak self] event in
            Task { @MainActor in self?.handleEvent(event) }
        }

        monitor = ClaudeSessionMonitor(
            onDelta: { [weak self] delta in
                Task { @MainActor in self?.handleDelta(delta) }
            },
            onSessionStart: { [weak self] in
                let event = BehaviorEvent(kind: .sessionStart, metadata: ["source": ActivitySource.claude.rawValue])
                Task { @MainActor in self?.handleEvent(event) }
            }
        )
        monitor?.startMonitoring()

        applyDecay()

        deathCheckTimer = Timer.publish(every: 3600, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.checkDeath() }

        decayTimer = Timer.publish(every: 3600, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.applyDecay() }

        scheduleBugSpawn()
        bugCleanupTimer = Timer.publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.cleanupExpiredBugs() }
    }

    func stop() {
        if let observer = eventObserver {
            EventBridge.removeObserver(observer)
        }
        monitor?.stopMonitoring()
        deathCheckTimer?.cancel()
        decayTimer?.cancel()
        walkingDecayTimer?.cancel()
        bugSpawnTimer?.cancel()
        bugCleanupTimer?.cancel()
        save()
    }

    // MARK: - Walk

    var canWalk: Bool { state.phase == .alive && state.stage != .stage1 }

    var walkablePets: [PetState] {
        roster.walkableIndices.map { roster.pets[$0] }
    }

    func selectPet(at index: Int) {
        guard roster.pets.indices.contains(index) else { return }
        synchronizeSelectedPet()
        roster.selectedIndex = index
        refreshSelectedPet()
        save()
    }

    func addPetSlot() {
        synchronizeSelectedPet()
        guard roster.addPet(machineId: state.machineId) else {
            showNotification("펫은 최대 4마리까지 키울 수 있어요.", icon: "exclamationmark.circle")
            return
        }
        refreshSelectedPet()
        save()
        showNotification("새 알이 슬롯에 추가됐어요!", icon: "plus.circle.fill")
    }

    func startWalk() {
        guard canWalk else { return }
        isWalking = true
        walkingDecayTimer = Timer.publish(every: 108, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.applyWalkingDecay() }
    }

    func stopWalk() {
        isWalking = false
        walkingDecayTimer?.cancel()
        walkingDecayTimer = nil
    }

    func dismissSpeechBubble() {
        speechBubbleTimer?.cancel()
        walkSpeechBubble = nil
    }

    func dismissWalkNotification(id: UUID) {
        walkNotifications.removeAll { $0.id == id }
    }

    func markWalkNotificationAsRead(id: UUID) {
        if let idx = walkNotifications.firstIndex(where: { $0.id == id }) {
            walkNotifications[idx].isRead = true
        }
    }

    func markAllWalkNotificationsAsRead() {
        for idx in walkNotifications.indices where !walkNotifications[idx].isRead {
            walkNotifications[idx].isRead = true
        }
    }

    var unreadWalkNotificationCount: Int {
        walkNotifications.lazy.filter { !$0.isRead }.count
    }

    private func applyWalkingDecay() {
        synchronizeSelectedPet()
        var changed = false
        var selectedDied = false
        for index in roster.walkableIndices {
            let oldHp = roster.pets[index].hp
            let oldHunger = roster.pets[index].hunger
            roster.pets[index].hp = max(0, roster.pets[index].hp - 1)
            roster.pets[index].hunger = max(0, roster.pets[index].hunger - 2)
            changed = changed || oldHp != roster.pets[index].hp || oldHunger != roster.pets[index].hunger
            if roster.pets[index].hp == 0 {
                let entry = deathChecker.processDeath(state: &roster.pets[index])
                roster.pets[index].graveyardEntries.append(entry)
                roster.syncGlobalHistory(from: roster.pets[index])
                selectedDied = selectedDied || index == roster.selectedIndex
            }
        }
        refreshSelectedPet()
        if changed { save() }
        if selectedDied {
            showNotification("산책 중 과로사했습니다...", icon: "heart.slash.fill")
            sendSystemNotification { $0.sendDeath() }
        }
        if roster.walkableIndices.isEmpty { stopWalk() }
    }

    private func showWalkSpeechBubble(_ message: String) {
        walkSpeechBubble = message
        walkNotifications.insert(WalkNotification(message: message, timestamp: Date()), at: 0)
        if walkNotifications.count > 50 { walkNotifications = Array(walkNotifications.prefix(50)) }
        speechBubbleTimer?.cancel()
        speechBubbleTimer = Just(())
            .delay(for: .seconds(30), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in self?.walkSpeechBubble = nil }
    }

    // MARK: - Bug Game

    func catchBug(_ bug: ActiveBug) {
        guard let idx = state.activeBugs.firstIndex(where: { $0.id == bug.id }) else { return }
        state.activeBugs.remove(at: idx)

        let xp = bug.type.xpReward
        let selectedShare = awardSharedXP(xp)
        if state.phase == .alive {
            state.mood = min(100, state.mood + 5)
        }

        state.bugsCaught += 1
        if bug.type == .golden  { state.goldenBugsCaught += 1 }
        if bug.type == .rainbow { state.rainbowBugsCaught += 1 }

        let checker = AchievementChecker()
        let newAchievements = checker.check(state: state, activityStats: roster.activityStats)
        for a in newAchievements {
            state.unlockedAchievements.append(a.id)
            showNotification("\(a.name) 달성!", icon: "trophy.fill")
        }

        bugXPPopup = "+\(selectedShare) XP \(bug.type.emoji)"
        bugPopupTimer?.cancel()
        bugPopupTimer = Just(()).delay(for: .seconds(1.5), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in self?.bugXPPopup = nil }

        save()
    }

    private func scheduleBugSpawn() {
        let interval = TimeInterval.random(in: 180...600)
        bugSpawnTimer?.cancel()
        bugSpawnTimer = Just(()).delay(for: .seconds(interval), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in self?.spawnBug() }
    }

    private func spawnBug() {
        guard state.phase == .alive, state.activeBugs.count < 3 else {
            scheduleBugSpawn()
            return
        }
        let bug = ActiveBug(type: BugType.roll())
        state.activeBugs.append(bug)
        save()
        NotificationManager.shared.sendBugSpawned(bugType: bug.type.rawValue, emoji: bug.type.emoji)
        scheduleBugSpawn()
    }

    private func cleanupExpiredBugs() {
        let before = state.activeBugs.count
        state.activeBugs.removeAll { $0.isExpired }
        if state.activeBugs.count < before { save() }
    }

    // MARK: - Equipment

    func equip(itemId: String) {
        var updated = state
        if inventoryManager.equip(itemId: itemId, state: &updated) {
            state = updated
            save()
        }
    }

    func unequip(slot: EquipmentSlot) {
        var updated = state
        inventoryManager.unequip(slot: slot, state: &updated)
        state = updated
        save()
    }

    func equippedItem(for slot: EquipmentSlot) -> Equipment? {
        inventoryManager.equippedItem(for: slot, in: state)
    }

    func fusionMaterialCount(for rarity: Rarity) -> Int {
        equipmentFusion.eligibleMaterials(for: rarity, in: state).count
    }

    func fuseItems(rarity: Rarity) {
        do {
            let reward = try equipmentFusion.fuse(rarity: rarity, state: &state)
            save()
            showNotification("합성 성공! \(reward.name)을 획득했어요.", icon: "wand.and.stars")
        } catch let error as EquipmentFusionError {
            showNotification(error.errorDescription ?? "합성할 수 없습니다.", icon: "exclamationmark.triangle")
        } catch {
            showNotification("합성에 실패했습니다.", icon: "exclamationmark.triangle")
        }
    }

    // MARK: - Hook Management

    var anyHookInstalled: Bool {
        claudeHookInstalled || codexHookInstalled
    }

    func installAllHooks() {
        installClaudeHooks()
        installCodexHooks()
    }

    func installClaudeHooks() {
        do {
            try claudeHookInstaller.install()
            claudeHookInstalled = true
        } catch {}
    }

    func uninstallClaudeHooks() {
        do {
            try claudeHookInstaller.uninstall()
            claudeHookInstalled = false
        } catch {}
    }

    func installCodexHooks() {
        do {
            try codexHookInstaller.install()
            codexHookInstalled = true
        } catch {}
    }

    func uninstallCodexHooks() {
        do {
            try codexHookInstaller.uninstall()
            codexHookInstalled = false
        } catch {}
    }

    // MARK: - Release

    func release() {
        guard state.phase == .alive || state.phase == .egg else { return }
        let entry = GraveyardEntry(from: state, cause: "방생")
        let previousEntries = state.graveyardEntries
        let previousDeathCount = state.deathCount
        let previousAchievements = state.unlockedAchievements
        let previousInventory = state.inventory
        let previousEquippedItems = state.equippedItems
        state = PetState(machineId: state.machineId)
        state.graveyardEntries = previousEntries + [entry]
        state.deathCount = previousDeathCount
        state.unlockedAchievements = previousAchievements
        state.inventory = previousInventory
        state.equippedItems = previousEquippedItems
        save()
        showNotification("펫을 방생했습니다. 새 알이 생겼어요!", icon: "bird.fill")
    }

    // MARK: - Migration

    func exportPet() {
        let panel = NSSavePanel()
        panel.title = "이사하기 — 캐릭터 데이터 내보내기"
        panel.nameFieldStringValue = "damagochi-pet.json"
        panel.allowedContentTypes = [.json]
        panel.canCreateDirectories = true
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            try store.export(to: url)
            showNotification("캐릭터 데이터를 내보냈습니다!", icon: "tray.and.arrow.up.fill")
        } catch {
            showNotification("내보내기 실패: \(error.localizedDescription)", icon: "exclamationmark.triangle.fill")
        }
    }

    func importPet() {
        let panel = NSOpenPanel()
        panel.title = "이사오기 — 캐릭터 데이터 가져오기"
        panel.allowedContentTypes = [.json]
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK, let url = panel.urls.first else { return }
        do {
            synchronizeSelectedPet()
            var imported = try store.importRoster(from: url)
            let previousHistory = roster.globalGraveyardEntries
            if state.phase == .alive || state.phase == .egg {
                imported.globalGraveyardEntries = previousHistory + [GraveyardEntry(from: state, cause: "이사")] + imported.globalGraveyardEntries
            } else {
                imported.globalGraveyardEntries = previousHistory + imported.globalGraveyardEntries
            }
            imported.pets = Array(imported.pets.prefix(PetRoster.maximumPets)).map { pet in
                var updated = pet
                updated.machineId = state.machineId
                return updated
            }
            guard let importedState = imported.selectedPet else { throw MigrationError.invalidFile }
            roster = imported
            state = importedState
            save()
            showNotification("이사 완료! 새 캐릭터로 시작합니다.", icon: "tray.and.arrow.down.fill")
        } catch {
            showNotification("가져오기 실패: \(error.localizedDescription)", icon: "exclamationmark.triangle.fill")
        }
    }

    // MARK: - Rebirth

    func rebirth() {
        guard state.phase == .dead else { return }
        let entry = GraveyardEntry(from: state)
        let previousEntries = state.graveyardEntries
        let previousDeathCount = state.deathCount
        let previousAchievements = state.unlockedAchievements
        state = PetState(machineId: state.machineId)
        state.graveyardEntries = previousEntries + [entry]
        state.deathCount = previousDeathCount + 1
        state.unlockedAchievements = previousAchievements
        save()
        showNotification("새로운 알이 나타났습니다!", icon: "arrow.counterclockwise.circle.fill")
    }

    // MARK: - Private

    private func handleEvent(_ event: BehaviorEvent) {
        if event.kind == .stop {
            return
        }
        if event.kind == .notification {
            if isWalking {
                let detail = event.metadata?["message"].map { ": \($0)" } ?? ""
                showWalkSpeechBubble("선택이 필요해요\(detail) 👀")
            }
            return
        }
        let oldLevel = state.level
        let oldPhase = state.phase
        let result = processEventAcrossRoster(event)
        checkNotifications(oldLevel: oldLevel, oldPhase: oldPhase, result: result)
        save()
    }

    private func handleDelta(_ delta: SessionDelta) {
        let oldLevel = state.level
        let oldPhase = state.phase
        var combinedResult = FeedResult()
        for _ in 0..<delta.newPrompts {
            let r = processEventAcrossRoster(BehaviorEvent(kind: .prompt, metadata: ["source": ActivitySource.claude.rawValue]))
            combinedResult = combinedResult.merged(with: r)
        }
        for _ in 0..<delta.newToolUses {
            let r = processEventAcrossRoster(BehaviorEvent(kind: .toolUse, metadata: ["source": ActivitySource.claude.rawValue]))
            combinedResult = combinedResult.merged(with: r)
        }
        checkNotifications(oldLevel: oldLevel, oldPhase: oldPhase, result: combinedResult)
        save()
    }

    private func checkNotifications(oldLevel: Int, oldPhase: PetPhase, result: FeedResult) {
        if result.streakUpdated && result.newStreakDays > 0 {
            let milestones = [7, 30, 100]
            if milestones.contains(result.newStreakDays) {
                showNotification("\(result.newStreakDays)일 스트릭 달성!", icon: "flame.fill")
                sendSystemNotification { $0.sendStreakMilestone(days: result.newStreakDays) }
            } else if result.newStreakDays == 1 {
                showNotification("코딩 스트릭 시작!", icon: "flame")
            } else if result.newStreakDays > 1 {
                showNotification("\(result.newStreakDays)일 연속 코딩!", icon: "flame")
            }
            sendSystemNotification { $0.scheduleStreakWarning(streakDays: result.newStreakDays) }
        }

        if oldPhase == .egg && state.phase == .alive {
            let speciesEntry = state.species.flatMap { id in
                Species.allSpecies.first(where: { $0.id == id })
            }
            let speciesName = speciesEntry?.name ?? "펫"
            let rarityLabel: String
            switch speciesEntry?.rarity {
            case .common:    rarityLabel = "커먼"
            case .rare:      rarityLabel = "레어"
            case .legendary: rarityLabel = "레전더리"
            case .mythic:    rarityLabel = "미식"
            case nil:        rarityLabel = ""
            }
            let suffix = rarityLabel.isEmpty ? "" : " [\(rarityLabel)]"
            showNotification("\(speciesName)\(suffix) 부화!", icon: "sparkles")
            sendSystemNotification { $0.sendHatched(speciesName: speciesName) }
        } else if state.level > oldLevel {
            showNotification("레벨 \(state.level) 달성!", icon: "arrow.up.circle.fill")
            sendSystemNotification { $0.sendLevelUp(level: self.state.level) }
        }

        for item in result.droppedEquipment {
            sendSystemNotification { $0.sendEquipmentDrop(name: item.name) }
        }
        for achievement in result.newAchievements {
            sendSystemNotification { $0.sendAchievement(name: achievement.name) }
        }

        if state.phase == .alive && state.hunger < 20 {
            sendSystemNotification { $0.sendHungerWarning(hunger: self.state.hunger) }
        }
    }

    private func applyDecay() {
        synchronizeSelectedPet()
        var changed = false
        for index in roster.pets.indices where roster.pets[index].phase == .alive {
            let inactiveHours = Int(Date().timeIntervalSince(roster.pets[index].lastActiveAt) / 3600)
            let oldHp = roster.pets[index].hp
            let oldHunger = roster.pets[index].hunger
            HealthSystem().applyDecay(to: &roster.pets[index], inactiveHours: inactiveHours)
            changed = changed || oldHp != roster.pets[index].hp || oldHunger != roster.pets[index].hunger
        }
        refreshSelectedPet()
        if changed { save() }
    }

    private func checkDeath() {
        synchronizeSelectedPet()
        var selectedDied = false
        for index in roster.pets.indices where roster.pets[index].phase == .alive {
            let days = deathChecker.inactiveBusinessDays(lastActive: roster.pets[index].lastActiveAt, now: Date())
            if deathChecker.shouldDie(inactiveBusinessDays: days) {
                let entry = deathChecker.processDeath(state: &roster.pets[index])
                roster.pets[index].graveyardEntries.append(entry)
                roster.syncGlobalHistory(from: roster.pets[index])
                selectedDied = selectedDied || index == roster.selectedIndex
            }
        }
        refreshSelectedPet()
        if selectedDied {
            save()
            showNotification("펫이 사망했습니다...", icon: "heart.slash.fill")
            sendSystemNotification { $0.sendDeath() }
            return
        }
        let days = deathChecker.inactiveBusinessDays(lastActive: state.lastActiveAt, now: Date())
        let warning = deathChecker.warningLevel(inactiveBusinessDays: days)
        switch warning {
        case .critical:
            sendSystemNotification { $0.sendDeathRisk(days: days) }
        case .warning:
            sendSystemNotification { $0.sendDeathRisk(days: days) }
        case .none:
            break
        }
    }

    private func sendSystemNotification(_ action: (NotificationManager) -> Void) {
        guard notificationsEnabled else { return }
        action(notificationManager)
    }

    private func showNotification(_ message: String, icon: String) {
        notification = PetNotification(message: message, icon: icon)
        notificationTimer?.cancel()
        notificationTimer = Just(())
            .delay(for: .seconds(3), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in self?.notification = nil }

        walkNotifications.insert(WalkNotification(message: message, timestamp: Date()), at: 0)
        if walkNotifications.count > 50 { walkNotifications = Array(walkNotifications.prefix(50)) }

        petSpeechBubble = message
        petSpeechBubbleTimer?.cancel()
        petSpeechBubbleTimer = Just(())
            .delay(for: .seconds(5), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in self?.petSpeechBubble = nil }
    }

    // MARK: - Update Check

    func checkForUpdate() {
        guard !isCheckingUpdate else { return }
        isCheckingUpdate = true
        let url = URL(string: "https://api.github.com/repos/keepbang/damagochi/releases/latest")!
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            Task { @MainActor [weak self] in
                self?.isCheckingUpdate = false
                guard let data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let tag = json["tag_name"] as? String else { return }
                let version = tag.hasPrefix("v") ? String(tag.dropFirst()) : tag
                self?.latestVersion = version
            }
        }.resume()
    }

    var hasUpdate: Bool {
        guard let latest = latestVersion else { return false }
        let current = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
        return latest.compare(current, options: .numeric) == .orderedDescending
    }

    func performBrewUpdate() {
        guard !isUpdating else { return }
        isUpdating = true
        updateError = nil

        Task.detached(priority: .userInitiated) {
            let brewPaths = ["/opt/homebrew/bin/brew", "/usr/local/bin/brew"]
            guard let brewPath = brewPaths.first(where: { FileManager.default.fileExists(atPath: $0) }) else {
                await MainActor.run {
                    self.isUpdating = false
                    self.updateError = "Homebrew를 찾을 수 없습니다."
                }
                return
            }

            // Run brew as the current user (not root) to avoid Homebrew's root check.
            // The outer shell runs with administrator privileges so sudo can switch users without a password.
            let username = NSUserName()
            let script = "do shell script \"sudo -u '\(username)' '\(brewPath)' upgrade --cask keepbang/tap/damagochi 2>&1\" with administrator privileges"
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
            process.arguments = ["-e", script]

            let outPipe = Pipe()
            let errPipe = Pipe()
            process.standardOutput = outPipe
            process.standardError = errPipe

            do {
                try process.run()
                process.waitUntilExit()

                let outData = outPipe.fileHandleForReading.readDataToEndOfFile()
                let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
                let output = [outData, errData]
                    .compactMap { String(data: $0, encoding: .utf8) }
                    .joined()
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                await MainActor.run {
                    self.isUpdating = false
                    if process.terminationStatus == 0 {
                        self.restartApp()
                    } else {
                        // User cancelled the authentication dialog (osascript exits with 1,
                        // "User cancelled" in output)
                        let cancelled = output.lowercased().contains("user cancel") ||
                                        output.lowercased().contains("cancelled") ||
                                        output.lowercased().contains("취소")
                        if cancelled {
                            self.updateError = nil
                        } else {
                            self.updateError = output.isEmpty ? "업데이트에 실패했습니다." : output
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    self.isUpdating = false
                    self.updateError = "업데이트 실행 실패: \(error.localizedDescription)"
                }
            }
        }
    }

    private func restartApp() {
        let appPath = Bundle.main.bundlePath
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/sh")
        process.arguments = ["-c", "sleep 2 && open '\(appPath)'"]
        try? process.run()
        NSApp.terminate(nil)
    }

    func recordBattle(_ entry: BattleHistoryEntry) {
        roster.recordBattle(entry)
        save()
    }

    func save() {
        synchronizeSelectedPet()
        roster.migrateAccountActivityStatsIfNeeded()
        store.save(roster)
    }

    private func synchronizeSelectedPet() {
        roster.replaceSelectedPet(with: state)
    }

    private func refreshSelectedPet() {
        if let selected = roster.selectedPet { state = selected }
    }

    @discardableResult
    private func processEventAcrossRoster(_ event: BehaviorEvent) -> FeedResult {
        synchronizeSelectedPet()
        roster.recordAccountActivity(event.kind)
        let baseXP = XPEngine().xpForEvent(event, streakDays: state.streakDays)
        let shares = roster.distributeXP(baseXP)
        let accountStats = roster.activityStats
        var selectedResult = FeedResult()
        for index in roster.pets.indices {
            let result = processor.process(
                event: event,
                state: &roster.pets[index],
                xpOverride: shares[index] ?? 0,
                recordActivity: false,
                achievementActivityStats: accountStats
            )
            if index == roster.selectedIndex { selectedResult = result }
            roster.syncGlobalHistory(from: roster.pets[index])
        }
        refreshSelectedPet()
        return selectedResult
    }

    /// Applies non-event rewards (bugs and battle rewards) using the same
    /// roster-level split as hook events without incrementing activity stats.
    @discardableResult
    func awardSharedXP(_ totalXP: Int) -> Int {
        synchronizeSelectedPet()
        let shares = roster.distributeXP(totalXP)
        for index in roster.pets.indices {
            let share = shares[index] ?? 0
            guard share > 0 else { continue }
            roster.pets[index].totalXp += share
            switch roster.pets[index].phase {
            case .egg:
                if XPEngine().shouldHatch(totalXp: roster.pets[index].totalXp) {
                    EvolutionEngine().evolve(state: &roster.pets[index])
                    roster.pets[index].xp = roster.pets[index].totalXp - 100
                }
            case .alive:
                roster.pets[index].xp += share
                let levelResult = XPEngine().checkLevelUp(
                    currentLevel: roster.pets[index].level,
                    currentXp: roster.pets[index].xp
                )
                roster.pets[index].level = levelResult.newLevel
                roster.pets[index].xp = levelResult.remainingXp
            case .dead:
                break
            }
        }
        let selectedShare = shares[roster.selectedIndex] ?? 0
        refreshSelectedPet()
        return selectedShare
    }

    /// Keeps a battle item attached to the intended roster slot without
    /// changing the user's currently selected pet.
    func appendBattleEquipment(_ item: Equipment, recipientPetID: String?) {
        let recipientIndex = recipientPetID.flatMap { id in
            roster.pets.firstIndex { ($0.petId ?? $0.machineId) == id }
        } ?? roster.selectedIndex
        if recipientIndex == roster.selectedIndex {
            state.inventory.append(item)
        } else {
            roster.pets[recipientIndex].inventory.append(item)
        }
    }

    func battleProfile(for pet: PetState) -> BattleProfile? {
        BattleProfile.from(pet, activityStats: roster.activityStats)
    }
}
