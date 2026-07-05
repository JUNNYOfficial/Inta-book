import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: ItemStore
    @State private var showingImportSheet = false
    @State private var importData: Data?

    var body: some View {
        NavigationView {
            Form {
                Section("数据管理") {
                    Button(action: { showingImportSheet = true }) {
                        Label("从文件导入", systemImage: "square.and.arrow.down")
                    }
                }

                Section("统计") {
                    HStack {
                        Text("物品总数")
                        Spacer()
                        Text("\(store.items.count)")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("已绑定 NFC 标签")
                        Spacer()
                        Text("\(store.items.filter { $0.tagID != nil }.count)")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("当前借出")
                        Spacer()
                        Text("\(store.items.filter { $0.isLent }.count)")
                            .foregroundColor(.secondary)
                    }
                }

                Section("关于") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    Text("NFC 家庭与小型机构物品查找方案")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("设置")
            .fileImporter(
                isPresented: $showingImportSheet,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                handleImport(result)
            }
        }
    }

    private func handleImport(_ result: Result<[URL], Error>) {
        do {
            let urls = try result.get()
            guard let url = urls.first else { return }
            let data = try Data(contentsOf: url)
            let imported = try JSONDecoder().decode([Item].self, from: data)
            store.items = imported
            store.save()
        } catch {
            print("导入失败: \(error.localizedDescription)")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(ItemStore())
    }
}
