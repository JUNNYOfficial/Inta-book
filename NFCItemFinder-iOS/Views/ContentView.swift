import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: ItemStore
    @StateObject private var nfcManager = NFCManager()

    var body: some View {
        TabView {
            ItemListView()
                .tabItem {
                    Label("物品", systemImage: "archivebox")
                }

            ScanView()
                .tabItem {
                    Label("扫码", systemImage: "wave.3.right")
                }

            AlertsView()
                .tabItem {
                    Label("提醒", systemImage: "bell")
                }

            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gear")
                }
        }
        .environmentObject(nfcManager)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ItemStore())
    }
}
