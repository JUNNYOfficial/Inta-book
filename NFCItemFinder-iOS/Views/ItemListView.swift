import SwiftUI

struct ItemListView: View {
    @EnvironmentObject var store: ItemStore
    @State private var searchText = ""
    @State private var showingAddSheet = false

    var filteredItems: [Item] {
        searchText.isEmpty ? store.items : store.search(query: searchText)
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(filteredItems) { item in
                    NavigationLink(destination: ItemDetailView(item: item)) {
                        ItemRow(item: item)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .listStyle(.plain)
            .navigationTitle("我的物品")
            .searchable(text: $searchText, prompt: "搜索物品、位置、分类")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddItemView()
            }
            .overlay {
                if store.items.isEmpty {
                    EmptyStateView()
                }
            }
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            store.delete(filteredItems[index])
        }
    }
}

struct ItemRow: View {
    let item: Item

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(item.name)
                    .font(.headline)
                Spacer()
                if item.isLent {
                    Text("已借出")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.orange)
                        .cornerRadius(4)
                }
                if item.isExpired {
                    Text("已过期")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red.opacity(0.2))
                        .foregroundColor(.red)
                        .cornerRadius(4)
                } else if item.isExpiringSoon {
                    Text("即将过期")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.yellow.opacity(0.2))
                        .foregroundColor(.yellow)
                        .cornerRadius(4)
                }
            }

            Text("\(item.category) · \(item.location)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            if let tagID = item.tagID {
                Text("标签: \(tagID)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "archivebox.circle")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("还没有物品")
                .font(.headline)
            Text("点击右上角 + 添加第一件物品")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}
