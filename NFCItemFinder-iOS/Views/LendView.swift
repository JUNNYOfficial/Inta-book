import SwiftUI

struct LendView: View {
    @EnvironmentObject var store: ItemStore
    @Environment(\.dismiss) var dismiss

    let item: Item
    @State private var borrower = ""
    @State private var expectedReturn = Date()
    @State private var hasExpectedReturn = false

    var body: some View {
        NavigationView {
            Form {
                Section("借出信息") {
                    TextField("借用人", text: $borrower)
                    Toggle("设置预计归还日期", isOn: $hasExpectedReturn)
                    if hasExpectedReturn {
                        DatePicker("预计归还", selection: $expectedReturn, displayedComponents: .date)
                    }
                }

                Section {
                    Button(action: confirmLend) {
                        HStack {
                            Spacer()
                            Text("确认借出")
                            Spacer()
                        }
                    }
                    .disabled(borrower.isEmpty)
                }
            }
            .navigationTitle("登记借出")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
        }
    }

    private func confirmLend() {
        store.lend(item: item, to: borrower, expectedReturn: hasExpectedReturn ? expectedReturn : nil)
        dismiss()
    }
}
