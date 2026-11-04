import SwiftUI
import SwiftData

enum FiltroCompras: String, CaseIterable, Identifiable {
    case todas = "Todas"
    case pendientes = "Pendientes"
    case rechazadas = "Rechazadas"
    var id: String { rawValue }
    var estado: String {
        switch self {
        case .todas: ""
        case .pendientes: EstadoCompra.pendiente.rawValue
        case .rechazadas: EstadoCompra.rechazada.rawValue
        }
    }
}

struct MisComprasView: View {
    let usuario: Usuario
    @State private var filtro: FiltroCompras = .todas
    @State private var busqueda = ""
    var body: some View {
        VStack(spacing: 0) {
            Picker("Estado", selection: $filtro) { ForEach(FiltroCompras.allCases) { Text($0.rawValue).tag($0) } }
                .pickerStyle(.segmented).padding(.horizontal).padding(.bottom, 8)
            ComprasPropias(usuario: usuario, estado: filtro.estado, busqueda: busqueda)
        }
        .navigationTitle("Mis compras").searchable(text: $busqueda, prompt: "Buscar proveedor")
        .toolbar { ToolbarItem(placement: .topBarTrailing) { MenuCuenta() } }
    }
}

private struct ComprasPropias: View {
    @Query private var compras: [Compra]
    let busqueda: String
    init(usuario: Usuario, estado: String, busqueda: String) {
        let nombreUsuario = usuario.usuario
        let todas = estado.isEmpty
        _compras = Query(filter: #Predicate<Compra> {
            $0.comprador?.usuario == nombreUsuario && (todas || $0.estado == estado)
        }, sort: \Compra.fecha, order: .reverse)
        self.busqueda = busqueda
    }
    private var filtradas: [Compra] {
        compras.filter { busqueda.isEmpty || ($0.proveedor?.nombre.localizedCaseInsensitiveContains(busqueda) ?? false) }
    }
    var body: some View {
        List {
            if filtradas.isEmpty {
                ContentUnavailableView("Sin compras", systemImage: "cart", description: Text("Aquí aparecerán tus compras que coincidan con el filtro."))
            }
            ForEach(filtradas) { compra in CompraFila(compra: compra) }
        }.accessibilityIdentifier("listaMisCompras")
    }
}

struct CompraFila: View {
    let compra: Compra
    var mostrarComprador = false
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(compra.proveedor?.nombre ?? "Sin proveedor").font(.headline)
                    Text("\(compra.producto?.nombre ?? "Sin producto") · \(compra.cantidad) u.")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 5) {
                    Text(compra.total.soles).font(.subheadline.bold()).monospacedDigit()
                    InsigniaEstado(compra: compra)
                }
            }
            HStack {
                Text(compra.fecha, format: .dateTime.day().month().year())
                Spacer()
                Text(compra.alCredito ? "Crédito 30 días" : "Contado")
            }.font(.caption).foregroundStyle(.secondary)
            if mostrarComprador { Text("Solicitó: \(compra.comprador?.nombre ?? "Sin comprador")").font(.caption) }
            if let motivo = compra.motivoRechazo { Text("Motivo: \(motivo)").font(.caption).foregroundStyle(.red) }
        }.padding(.vertical, 5)
    }
}
