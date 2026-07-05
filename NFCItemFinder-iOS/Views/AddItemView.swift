import SwiftUI

struct AddItemView: View {
    @EnvironmentObject var store: ItemStore
    @EnvironmentObject var nfcManager: NFCManager
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var category = ""
    @State private var location = ""
    @State private var owner = ""
    @State private var notes = ""
    @State private var hasExpiry = false
    @State private var expiryDate = Date()
    @State private var showWriteNFC = false
    @State private var createdItem: Item?

    let categories = ["书籍", "工具", "药品", "证件", "食品", "电子产品", "衣物", "其他"]

    var body: some View {
        NavigationView {
            Form {
                Section("基本信息") {
                    TextField("物品名称", text: $name)
                    Picker("分类", selection: $category) {
                        Text("请选择").tag("")
                        ForEach(categories, id: \.self) { Text($0).tag($0) }
                    }
                    TextField("位置", text: $location, prompt: Text("如：客厅书架第3层"))
                    TextField("所有者", text: $owner)
                }

                Section("备注") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }

                Section("有效期") {
                    Toggle("设置有效期/过期提醒", isOn: $hasExpiry)
                    if hasExpiry {
                        DatePicker("过期日期", selection: $expiryDate, displayedComponents: .date)
                    }
                }

                Section {
                    Button(action: saveAndWrite) {
                        HStack {
                            Spacer()
                            Text("保存并写入 NFC 标签")
                            Spacer()
                        }
                    }
                    .disabled(name.isEmpty || location.isEmpty)
                }
            }
            .navigationTitle("添加物品")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
            .sheet(isPresented: $showWriteNFC) {
                WriteTagView()
            }
            .onChange(of: nfcManager.lastTagID) { tagID in
                guard let tagID = tagID, var item = createdItem else { return }
                item.tagID = tagID
                item.updatedAt = Date()
                store.update(item)
            }
        }
    }

    private func saveAndWrite() {
        let item = Item(
            name: name,
            category: category,
            location: location,
            owner: owner,
            notes: notes,
            expiryDate: hasExpiry ? expiryDate : nil
        )
        createdItem = item
        store.add(item)
        showWriteNFC = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            nfcManager.startWriting(item: item)
        }
    }
}
