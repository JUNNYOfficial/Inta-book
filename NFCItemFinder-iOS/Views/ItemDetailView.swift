import SwiftUI

struct ItemDetailView: View {
    @EnvironmentObject var store: ItemStore
    @EnvironmentObject var nfcManager: NFCManager
    @State private var item: Item
    @State private var isEditing = false
    @State private var showingWriteSheet = false
    @State private var showingLendSheet = false

    init(item: Item) {
        _item = State(initialValue: item)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerCard
                infoCard
                statusCard
                actionButtons
                if !item.lendRecords.isEmpty {
                    lendHistoryCard
                }
            }
            .padding()
        }
        .navigationTitle(item.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "完成" : "编辑") {
                    if isEditing {
                        store.update(item)
                    }
                    isEditing.toggle()
                }
            }
        }
        .sheet(isPresented: $showingWriteSheet) {
            WriteTagView()
        }
        .sheet(isPresented: $showingLendSheet) {
            LendView(item: item)
        }
        .onAppear {
            if let refreshed = store.item(byID: item.id) {
                item = refreshed
            }
        }
        .onChange(of: nfcManager.lastTagID) { tagID in
            guard let tagID = tagID else { return }
            item.tagID = tagID
            item.updatedAt = Date()
            store.update(item)
        }
    }

    private var headerCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.category.isEmpty ? "未分类" : item.category)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(item.location)
                    .font(.title2)
                    .bold()
            }
            Spacer()
            statusBadge
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private var statusBadge: some View {
        Group {
            if item.isLent {
                badge(text: "已借出", color: .orange)
            } else if item.isExpired {
                badge(text: "已过期", color: .red)
            } else if item.isExpiringSoon {
                badge(text: "即将过期", color: .yellow)
            } else {
                badge(text: "在库", color: .green)
            }
        }
    }

    private func badge(text: String, color: Color) -> some View {
        Text(text)
            .font(.caption)
            .bold()
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(8)
    }

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            if isEditing {
                Group {
                    TextField("名称", text: $item.name)
                    TextField("分类", text: $item.category)
                    TextField("位置", text: $item.location)
                    TextField("所有者", text: $item.owner)
                    TextEditor(text: $item.notes)
                        .frame(minHeight: 80)
                }
                .textFieldStyle(.roundedBorder)
            } else {
                InfoRow(label: "名称", value: item.name)
                InfoRow(label: "分类", value: item.category)
                InfoRow(label: "位置", value: item.location)
                InfoRow(label: "所有者", value: item.owner.isEmpty ? "未设置" : item.owner)
                InfoRow(label: "备注", value: item.notes.isEmpty ? "无" : item.notes)
                InfoRow(label: "标签 ID", value: item.tagID ?? "未绑定")
                if let expiry = item.expiryDate {
                    InfoRow(label: "有效期至", value: formattedDate(expiry))
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4)
    }

    private var statusCard: some View {
        Group {
            if item.isLent, let lend = item.currentLend {
                VStack(alignment: .leading, spacing: 8) {
                    Text("当前借出")
                        .font(.headline)
                    Text("借给人：\(lend.borrower)")
                    Text("借出时间：\(formattedDate(lend.lentAt))")
                    if let expected = lend.expectedReturnAt {
                        Text("预计归还：\(formattedDate(expected))")
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: { showingWriteSheet = true }) {
                ActionButtonLabel(title: "写入 NFC 标签", icon: "wave.3.right", color: .blue)
            }

            if item.isLent {
                Button(action: { store.returnItem(item) }) {
                    ActionButtonLabel(title: "登记归还", icon: "checkmark.circle", color: .green)
                }
            } else {
                Button(action: { showingLendSheet = true }) {
                    ActionButtonLabel(title: "登记借出", icon: "arrowshape.turn.up.right", color: .orange)
                }
            }
        }
    }

    private var lendHistoryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("借出记录")
                .font(.headline)
            ForEach(item.lendRecords.sorted(by: { $0.lentAt > $1.lentAt })) { record in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("借给：\(record.borrower)")
                        Text("借出：\(formattedDate(record.lentAt))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text(record.returnedAt == nil ? "未归还" : "已归还")
                        .font(.caption)
                        .foregroundColor(record.returnedAt == nil ? .orange : .green)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
        }
    }
}

struct ActionButtonLabel: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(title)
        }
        .font(.headline)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .background(color)
        .cornerRadius(12)
    }
}
