import SwiftUI
import SwiftData

struct AprobacionesView: View {
    let usuario: Usuario
    @State private var todas = false
    @State private var busqueda = ""
    var body: some View {
        VStack(spacing: 0) {
            Picker("Compras", selection: $todas) {
                Text("Pendientes").tag(false)
                Text("Todas").tag(true)
            }.pickerStyle(.segmented).padding(.horizontal).padding(.bottom, 8)
            AprobacionesLista(usuario: usuario, todas: todas, busqueda: busqueda)
        }
        .navigationTitle("Aprobar").searchable(text: $busqueda, prompt: "Buscar proveedor")
        .toolbar { ToolbarItem(placement: .topBarTrailing) { MenuCuenta() } }
    }
}

private struct AprobacionesLista: View {
    let usuario: Usuario
    let busqueda: String
    @Environment(\.modelContext) private var context
    @Query private var compras: [Compra]
    @State private var rechazo: Compra?
    @State private var error: String?
    init(usuario: Usuario, todas: Bool, busqueda: String) {
        self.usuario = usuario; self.busqueda = busqueda
        let pendiente = EstadoCompra.pendiente.rawValue
        _compras = Query(filter: #Predicate<Compra> { todas || $0.estado == pendiente }, sort: \Compra.fecha, order: .reverse)
    }
    private var filtradas: [Compra] {
        compras.filter { busqueda.isEmpty || ($0.proveedor?.nombre.localizedCaseInsensitiveContains(busqueda) ?? false) }
    }
    var body: some View {
        List {
            if filtradas.isEmpty { ContentUnavailableView("Sin compras por mostrar", systemImage: "checkmark.seal") }
            ForEach(filtradas) { compra in
                Section {
                    CompraFila(compra: compra, mostrarComprador: true)
                    if compra.estado == EstadoCompra.pendiente.rawValue {
                        if let producto = compra.producto,
                           let prevision = try? ReglasCompra.prevision(producto: producto, cantidad: compra.cantidad, costo: compra.costoUnitario) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Si apruebas").font(.caption.bold())
                                Text("Stock: \(producto.stock) → \(prevision.stock)")
                                Text("Costo promedio: \(producto.costoPromedio.soles) → \(prevision.costoPromedio.soles)")
                            }.font(.callout).accessibilityIdentifier("previsionInventario")
                        }
                        HStack {
                            Button("Rechazar", role: .destructive) { rechazo = compra }
                                .buttonStyle(.bordered).accessibilityIdentifier("rechazarCompra")
                            Spacer()
                            Button("Aprobar") {
                                do { try ServicioCompras(context: context).aprobar(compra, actor: usuario) }
                                catch { self.error = error.localizedDescription }
                            }.buttonStyle(.borderedProminent).accessibilityIdentifier("aprobarCompra")
                        }
                    }
                }
            }
        }
        .sheet(item: $rechazo) { RechazoForm(usuario: usuario, compra: $0) }
        .mensajeError($error)
    }
}

private struct RechazoForm: View {
    let usuario: Usuario
    let compra: Compra
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var motivo = ""
    @State private var error: String?
    var body: some View {
        NavigationStack {
            Form {
                Section("Compra pendiente") { CompraFila(compra: compra, mostrarComprador: true) }
                Section("Motivo obligatorio") {
                    TextField("Motivo de rechazo", text: $motivo, axis: .vertical)
                        .lineLimit(3...6).accessibilityIdentifier("motivoRechazo")
                }
                Section {
                    Button("Rechazar compra", role: .destructive) {
                        do {
                            try ServicioCompras(context: context).rechazar(compra, motivo: motivo, actor: usuario)
                            dismiss()
                        } catch { self.error = error.localizedDescription }
                    }.disabled(motivo.limpio.isEmpty).accessibilityIdentifier("confirmarRechazo")
                } footer: { Text("El motivo será visible para quien registró la compra. El inventario no cambiará.") }
            }
            .navigationTitle("Rechazar compra").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } } }
            .mensajeError($error)
        }
    }
}
