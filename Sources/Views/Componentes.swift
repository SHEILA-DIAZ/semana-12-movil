import SwiftUI

extension Double {
    var soles: String { formatted(.currency(code: "PEN").locale(Locale(identifier: "es_PE"))) }
}
extension String {
    var limpio: String { trimmingCharacters(in: .whitespacesAndNewlines) }
    var numeroDecimal: Double? { Double(limpio.replacingOccurrences(of: ",", with: ".")) }
}

struct MensajeError: ViewModifier {
    @Binding var mensaje: String?
    func body(content: Content) -> some View {
        content.alert("Atención", isPresented: Binding(get: { mensaje != nil }, set: { if !$0 { mensaje = nil } })) {
            Button("Aceptar", role: .cancel) { mensaje = nil }
        } message: { Text(mensaje ?? "") }
    }
}
extension View {
    func mensajeError(_ mensaje: Binding<String?>) -> some View { modifier(MensajeError(mensaje: mensaje)) }
}

struct MenuCuenta: View {
    @Environment(Sesion.self) private var sesion
    var body: some View {
        Menu {
            if let usuario = sesion.actual {
                Text(usuario.nombre)
                Text("\(usuario.usuario) · \(usuario.rol)")
            }
            Button("Cerrar sesión", systemImage: "rectangle.portrait.and.arrow.right", role: .destructive) { sesion.cerrar() }
                .accessibilityIdentifier("cerrarSesion")
        } label: {
            Image(systemName: "person.crop.circle.fill").font(.title2).accessibilityLabel("Cuenta")
        }
        .accessibilityIdentifier("cuenta")
    }
}

struct LogoCompras: View {
    var body: some View {
        Image(systemName: "shippingbox.fill")
            .font(.system(size: 42, weight: .semibold)).foregroundStyle(.white)
            .frame(width: 90, height: 90)
            .background(LinearGradient(colors: [.teal, .blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: RoundedRectangle(cornerRadius: 23))
            .accessibilityHidden(true)
    }
}

struct ImporteFila: View {
    let titulo: String
    let valor: Double
    var body: some View {
        HStack { Text(titulo); Spacer(); Text(valor.soles).monospacedDigit() }
    }
}

struct InsigniaEstado: View {
    let compra: Compra
    var body: some View {
        Text(compra.estado).font(.caption.bold())
            .padding(.horizontal, 8).padding(.vertical, 4)
            .foregroundStyle(color).background(color.opacity(0.12), in: Capsule())
    }
    private var color: Color {
        switch compra.estado {
        case EstadoCompra.aprobada.rawValue: .green
        case EstadoCompra.rechazada.rawValue: .red
        default: .orange
        }
    }
}
