import SwiftUI

struct ContentView: View {
    @State private var sesion = Sesion()
    var body: some View {
        Group {
            if let persona = sesion.actual {
                NavigationStack {
                    VStack(spacing: 12) {
                        LogoCompras()
                        Text("Hola, \(persona.nombre)").font(.title2)
                        Text(persona.rol).foregroundStyle(.secondary)
                    }.navigationTitle("Compras").toolbar { MenuCuenta() }
                }
            } else { LoginView() }
        }.environment(sesion).tint(.teal)
    }
}
