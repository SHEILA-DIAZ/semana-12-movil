import SwiftUI

struct ContentView: View {
    @State private var sesion = Sesion()
    var body: some View {
        Group {
            if let persona = sesion.actual {
                TabView {
                    NavigationStack { ProductosView(usuario: persona) }
                        .tabItem { Label("Productos", systemImage: "shippingbox") }
                }.id(persona.persistentModelID)
            } else { LoginView() }
        }.environment(sesion).tint(.teal)
    }
}
