import SwiftUI

struct AlertsView: View {
    @EnvironmentObject var store: ItemStore

    var expiringItems: [Item] {
        store.expiringItems()
    }

    var lentItems: [Item] {
        store.items.filter { $0.isLent }
    }

    var body: some View {
        NavigationView {
            List {
                if !expiringItems.isEmpty {
                    Section("有效期提醒") {
                        ForEach(expiringItems) { item in
                            NavigationLink(destination: ItemDetailView(item: item)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name)
                                        .font(.headline)
                                    if let expiry = item.expiryDate {
                                        Text("有效期至 \(formattedDate(expiry))")
                                            .font(.caption)
                                            .foregroundColor(item.isExpired ? .red : .orange)
                                    }
                                    Text(item.location)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }

                if !lentItems.isEmpty {
                    Section("未归还物品") {
                        ForEach(lentItems) { item in
                            if let lend = item.currentLend {
                                NavigationLink(destination: ItemDetailView(item: item)) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.name)
                                            .font(.headline)
                                        Text("借给：\(lend.borrower)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        if let expected = lend.expectedReturnAt {
                                            Text("预计归还：\(formattedDate(expected))")
                                                .font(.caption)
                                                .foregroundColor(expected < Date() ? .red : .orange)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                if expiringItems.isEmpty && lentItems.isEmpty {
                    Section {
                        HStack {
                            Spacer()
                            VStack(spacing: 12) {
                                Image(systemName: "checkmark.circle")
                                    .font(.system(size: 50))
                                    .foregroundColor(.green)
                                Text("暂无提醒")
                                    .font(.headline)
                                Text("没有即将过期或未归还的物品")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 40)
                    }
                }
            }
            .navigationTitle("提醒")
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
