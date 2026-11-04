import SwiftUI

struct ContentView: View {
    @State private var sesion = Sesion()
    var body: some View {
        Group {
            if let persona = sesion.actual {
                TabView {
                    NavigationStack { ProductosView(usuario: persona) }
                        .tabItem { Label("Productos", systemImage: "shippingbox") }
                    NavigationStack { ProveedoresView(usuario: persona) }
                        .tabItem { Label("Proveedores", systemImage: "building.2") }
                    if !persona.esSupervisor {
                        NavigationStack { NuevaCompraView(usuario: persona) }
                            .tabItem { Label("Compra", systemImage: "cart.badge.plus") }
                        NavigationStack { MisComprasView(usuario: persona) }
                            .tabItem { Label("Mis compras", systemImage: "list.bullet.rectangle") }
                    }
                }.id(persona.persistentModelID)
            } else { LoginView() }
        }.environment(sesion).tint(.teal)
    }
}
