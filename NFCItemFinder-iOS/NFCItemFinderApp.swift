import SwiftUI

@main
struct NFCItemFinderApp: App {
    @StateObject private var store = ItemStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
