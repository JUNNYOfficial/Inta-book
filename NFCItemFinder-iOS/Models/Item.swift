import Foundation

struct Item: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var category: String
    var location: String
    var owner: String
    var notes: String
    var tagID: String?
    var expiryDate: Date?
    var lendRecords: [LendRecord]
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        category: String,
        location: String,
        owner: String = "",
        notes: String = "",
        tagID: String? = nil,
        expiryDate: Date? = nil,
        lendRecords: [LendRecord] = [],
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.location = location
        self.owner = owner
        self.notes = notes
        self.tagID = tagID
        self.expiryDate = expiryDate
        self.lendRecords = lendRecords
        self.updatedAt = updatedAt
    }

    var currentLend: LendRecord? {
        lendRecords.first { $0.returnedAt == nil }
    }

    var isLent: Bool {
        currentLend != nil
    }

    var isExpired: Bool {
        guard let expiry = expiryDate else { return false }
        return Calendar.current.startOfDay(for: expiry) < Calendar.current.startOfDay(for: Date())
    }

    var isExpiringSoon: Bool {
        guard let expiry = expiryDate, !isExpired else { return false }
        guard let thirtyDaysLater = Calendar.current.date(byAdding: .day, value: 30, to: Date()) else { return false }
        return expiry <= thirtyDaysLater
    }
}

struct LendRecord: Identifiable, Codable, Equatable {
    var id: UUID
    var borrower: String
    var lentAt: Date
    var expectedReturnAt: Date?
    var returnedAt: Date?

    init(
        id: UUID = UUID(),
        borrower: String,
        lentAt: Date = Date(),
        expectedReturnAt: Date? = nil,
        returnedAt: Date? = nil
    ) {
        self.id = id
        self.borrower = borrower
        self.lentAt = lentAt
        self.expectedReturnAt = expectedReturnAt
        self.returnedAt = returnedAt
    }
}

struct NFCTagPayload: Codable, Equatable {
    var itemID: String
    var name: String
    var category: String
    var location: String
    var updated: String

    init(item: Item) {
        self.itemID = item.id.uuidString
        self.name = item.name
        self.category = item.category
        self.location = item.location
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.updated = formatter.string(from: item.updatedAt)
    }

    func toJSON() -> Data? {
        try? JSONEncoder().encode(self)
    }

    static func from(jsonData: Data) -> NFCTagPayload? {
        try? JSONDecoder().decode(NFCTagPayload.self, from: jsonData)
    }
}
