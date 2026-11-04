import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView("Compras Tecsup", systemImage: "shippingbox", description: Text("Grupo B · SwiftUI y SwiftData"))
                .navigationTitle("Compras")
        }
    }
}
