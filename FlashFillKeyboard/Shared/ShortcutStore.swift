import Foundation

/// 主 App 与键盘扩展通过 App Group 共享快捷项数据
final class ShortcutStore {
    static let shared = ShortcutStore()

    /// 请在 Xcode 中把主 App 和键盘扩展都加入同一个 App Group，并改成你的 Team ID
    static let appGroupID = "group.com.example.flashfill"
    static let storageKey = "shortcut_items_v1"

    private let defaults: UserDefaults

    private init() {
        if let shared = UserDefaults(suiteName: Self.appGroupID) {
            defaults = shared
        } else {
            // 模拟器/未配置 App Group 时回退，便于本地调试
            defaults = .standard
        }
        seedIfNeeded()
    }

    func load() -> [ShortcutItem] {
        guard let data = defaults.data(forKey: Self.storageKey) else {
            return ShortcutItem.defaults
        }
        do {
            let items = try JSONDecoder().decode([ShortcutItem].self, from: data)
            return items.sorted { $0.sortOrder < $1.sortOrder }
        } catch {
            return ShortcutItem.defaults
        }
    }

    func save(_ items: [ShortcutItem]) {
        var normalized = items
        for index in normalized.indices {
            normalized[index].sortOrder = index
        }
        guard let data = try? JSONEncoder().encode(normalized) else { return }
        defaults.set(data, forKey: Self.storageKey)
        defaults.synchronize()
    }

    func enabledItems() -> [ShortcutItem] {
        load().filter(\.isEnabled).filter { !$0.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !$0.label.isEmpty }
    }

    func upsert(_ item: ShortcutItem) {
        var items = load()
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        } else {
            items.append(item)
        }
        save(items)
    }

    func delete(id: UUID) {
        var items = load()
        items.removeAll { $0.id == id }
        save(items)
    }

    func move(from source: IndexSet, to destination: Int) {
        var items = load()
        items.move(fromOffsets: source, toOffset: destination)
        save(items)
    }

    private func seedIfNeeded() {
        guard defaults.data(forKey: Self.storageKey) == nil else { return }
        save(ShortcutItem.defaults)
    }
}
