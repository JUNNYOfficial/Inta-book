import Foundation
import Combine

final class ItemStore: ObservableObject {
    @Published var items: [Item] = []

    private let filename = "nfc_items.json"

    var fileURL: URL {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
    }

    init() {
        load()
    }

    func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            items = try JSONDecoder().decode([Item].self, from: data)
        } catch {
            items = []
        }
    }

    func save() {
        do {
            let data = try JSONEncoder().encode(items)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("保存失败: \(error.localizedDescription)")
        }
    }

    func add(_ item: Item) {
        items.append(item)
        save()
    }

    func update(_ item: Item) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
            save()
        }
    }

    func delete(_ item: Item) {
        items.removeAll { $0.id == item.id }
        save()
    }

    func item(byID id: UUID) -> Item? {
        items.first { $0.id == id }
    }

    func item(byTagID tagID: String) -> Item? {
        items.first { $0.tagID == tagID }
    }

    func search(query: String) -> [Item] {
        let lower = query.lowercased()
        return items.filter {
            $0.name.lowercased().contains(lower) ||
            $0.location.lowercased().contains(lower) ||
            $0.category.lowercased().contains(lower) ||
            $0.notes.lowercased().contains(lower)
        }
    }

    func lend(item: Item, to borrower: String, expectedReturn: Date?) {
        var mutable = item
        var records = mutable.lendRecords
        records.append(LendRecord(borrower: borrower, expectedReturnAt: expectedReturn))
        mutable.lendRecords = records
        mutable.updatedAt = Date()
        update(mutable)
    }

    func returnItem(_ item: Item) {
        guard var mutable = self.item(byID: item.id) else { return }
        guard let index = mutable.lendRecords.firstIndex(where: { $0.returnedAt == nil }) else { return }
        mutable.lendRecords[index].returnedAt = Date()
        mutable.updatedAt = Date()
        update(mutable)
    }

    func expiringItems() -> [Item] {
        items.filter { $0.isExpiringSoon || $0.isExpired }
    }
}
