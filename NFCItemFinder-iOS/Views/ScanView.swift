import SwiftUI

struct ScanView: View {
    @EnvironmentObject var store: ItemStore
    @EnvironmentObject var nfcManager: NFCManager
    @State private var foundItem: Item?
    @State private var showDetail = false
    @State private var showNotFound = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "wave.3.right.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.blue)
                    .opacity(nfcManager.isScanning ? 0.5 : 1.0)
                    .scaleEffect(nfcManager.isScanning ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: nfcManager.isScanning)

                Text(nfcManager.isScanning ? "正在扫描 NFC 标签..." : "碰一下就知道在哪")
                    .font(.title2)
                    .bold()

                Text(nfcManager.statusMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                if case .error(let msg) = nfcManager.lastResult {
                    Text(msg)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }

                Spacer()

                Button(action: startScan) {
                    Text(nfcManager.isScanning ? "扫描中..." : "开始扫描")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(nfcManager.isScanning ? Color.gray : Color.blue)
                        .cornerRadius(12)
                }
                .disabled(nfcManager.isScanning)
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("扫码查找")
            .onChange(of: nfcManager.lastResult) { newValue in
                handleResult(newValue)
            }
            .sheet(isPresented: $showDetail) {
                if let item = foundItem {
                    NavigationView {
                        ItemDetailView(item: item)
                    }
                }
            }
            .alert("未找到物品", isPresented: $showNotFound) {
                Button("确定") { }
            } message: {
                Text("扫描到的标签尚未在 App 中登记。请先添加物品并写入标签。")
            }
        }
    }

    private func startScan() {
        nfcManager.reset()
        nfcManager.startReading()
    }

    private func handleResult(_ result: NFCResult?) {
        guard let result = result else { return }
        switch result {
        case .payload(let payload):
            if let uuid = UUID(uuidString: payload.itemID),
               let item = store.item(byID: uuid) {
                foundItem = item
                showDetail = true
            } else if let item = store.item(byTagID: payload.itemID) {
                foundItem = item
                showDetail = true
            } else {
                showNotFound = true
            }
        case .raw:
            showNotFound = true
        case .error, .cancelled:
            break
        }
    }
}
