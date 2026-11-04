import SwiftUI
import SwiftData

enum FiltroPagos: String, CaseIterable, Identifiable {
    case pendientes = "Pendientes"
    case vencidas = "Vencidas"
    case pagadas = "Pagadas"
    var id: String { rawValue }
}

struct PorPagarView: View {
    let usuario: Usuario
    @Query(filter: #Predicate<Compra> { $0.estado == "Aprobada" && $0.alCredito && !$0.pagada })
    private var pendientes: [Compra]
    @State private var filtro: FiltroPagos = .pendientes
    @State private var ahora = Date()
    @Environment(\.scenePhase) private var scenePhase
    var body: some View {
        VStack(spacing: 0) {
            Picker("Pagos", selection: $filtro) { ForEach(FiltroPagos.allCases) { Text($0.rawValue).tag($0) } }
                .pickerStyle(.segmented).padding(.horizontal).padding(.bottom, 8)
            PagosLista(usuario: usuario, filtro: filtro, ahora: ahora)
            ImporteFila(titulo: "Total por pagar", valor: pendientes.reduce(0) { $0 + $1.total })
                .font(.headline).padding().background(.regularMaterial).accessibilityIdentifier("totalPorPagar")
        }
        .navigationTitle("Por pagar")
        .toolbar { ToolbarItem(placement: .topBarTrailing) { MenuCuenta() } }
        .onChange(of: scenePhase) { _, phase in if phase == .active { ahora = Date() } }
        .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { ahora = $0 }
    }
}

private struct PagosLista: View {
    let usuario: Usuario
    let ahora: Date
    @Environment(\.modelContext) private var context
    @Query private var compras: [Compra]
    @State private var error: String?
    init(usuario: Usuario, filtro: FiltroPagos, ahora: Date) {
        self.usuario = usuario; self.ahora = ahora
        let pagadas = filtro == .pagadas
        let soloVencidas = filtro == .vencidas
        let aprobada = EstadoCompra.aprobada.rawValue
        _compras = Query(filter: #Predicate<Compra> {
            $0.estado == aprobada && $0.alCredito && $0.pagada == pagadas && (!soloVencidas || $0.vence < ahora)
        }, sort: \Compra.vence)
    }
    var body: some View {
        List {
            if compras.isEmpty { ContentUnavailableView("Sin compras en este filtro", systemImage: "creditcard") }
            ForEach(compras) { compra in
                VStack(alignment: .leading, spacing: 7) {
                    CompraFila(compra: compra, mostrarComprador: true)
                    HStack {
                        Text("Vence: \(compra.vence.formatted(date: .abbreviated, time: .omitted))")
                        Spacer()
                        if compra.estaVencida(en: ahora) { Text("VENCIDA").fontWeight(.bold).foregroundStyle(.red) }
                        if compra.pagada { Label("Pagada", systemImage: "checkmark.circle.fill").foregroundStyle(.green) }
                    }.font(.caption)
                }
                .accessibilityIdentifier("pago-\(compra.producto?.nombre ?? "compra")")
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    if compra.estaPorPagar {
                        Button("Pagar") {
                            do { try ServicioCompras(context: context).pagar(compra, actor: usuario) }
                            catch { self.error = error.localizedDescription }
                        }.tint(.green).accessibilityIdentifier("pagarCompra")
                    }
                }
            }
        }.mensajeError($error)
    }
}
