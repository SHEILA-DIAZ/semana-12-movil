import SwiftUI
import SwiftData

@main
struct ComprasTecsupApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
            .modelContainer(ModelContainerProvider.shared.container)
    }
}
