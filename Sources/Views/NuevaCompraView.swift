import SwiftUI
import SwiftData

struct NuevaCompraView: View {
    let usuario: Usuario
    @Environment(\.modelContext) private var context
    @Query(sort: \Producto.nombre) private var productos: [Producto]
    @Query(sort: \Proveedor.nombre) private var proveedores: [Proveedor]
    @State private var producto: Producto?
    @State private var proveedor: Proveedor?
    @State private var cantidad = "1"
    @State private var costo = ""
    @State private var credito = false
    @State private var error: String?
    @State private var confirmacion: String?
    @FocusState private var escribiendo: Bool
    private var importes: ImportesCompra? {
        guard let unidades = Int(cantidad.limpio), let precio = costo.numeroDecimal else { return nil }
        return try? ReglasCompra.importes(cantidad: unidades, costo: precio)
    }
    var body: some View {
        Form {
            if productos.isEmpty || proveedores.isEmpty {
                Section { Label("Un supervisor debe registrar productos y proveedores antes de comprar.", systemImage: "info.circle") }
            }
            Section("Datos de la compra") {
                Picker("Proveedor", selection: $proveedor) {
                    Text("Seleccionar").tag(nil as Proveedor?)
                    ForEach(proveedores) { Text($0.nombre).tag(Optional($0)) }
                }.accessibilityIdentifier("compraProveedor")
                Picker("Producto", selection: $producto) {
                    Text("Seleccionar").tag(nil as Producto?)
                    ForEach(productos) { Text($0.nombre).tag(Optional($0)) }
                }.accessibilityIdentifier("compraProducto")
                .onChange(of: producto) { _, nuevo in costo = nuevo.map { String($0.costoPromedio) } ?? "" }
                TextField("Cantidad", text: $cantidad).keyboardType(.numberPad).focused($escribiendo)
                    .accessibilityIdentifier("compraCantidad")
                TextField("Costo unitario", text: $costo).keyboardType(.decimalPad).focused($escribiendo)
                    .accessibilityIdentifier("compraCosto")
                Picker("Forma de pago", selection: $credito) {
                    Text("Contado").tag(false)
                    Text("Crédito 30 días").tag(true)
                }.pickerStyle(.segmented).accessibilityIdentifier("compraCredito")
            }
            if let importes {
                Section("Resumen") {
                    ImporteFila(titulo: "Subtotal", valor: importes.subtotal)
                    ImporteFila(titulo: "IGV 18 %", valor: importes.igv)
                    ImporteFila(titulo: "Total", valor: importes.total).fontWeight(.bold)
                    if importes.requiereAprobacion {
                        Label("Desde S/ 5,000 requiere aprobación. El stock y el costo promedio todavía no cambiarán.", systemImage: "exclamationmark.triangle.fill")
                            .font(.callout).foregroundStyle(.orange).accessibilityIdentifier("requiereAprobacion")
                    }
                }
            }
            Section {
                Button(importes?.requiereAprobacion == true ? "Enviar a aprobación" : "Registrar compra") { registrar() }
                    .disabled(producto == nil || proveedor == nil || importes == nil)
                    .accessibilityIdentifier("registrarCompra")
            } footer: { Text("Comprador: \(usuario.nombre). El crédito vence 30 días después del registro.") }
        }
        .navigationTitle("Nueva compra")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) { MenuCuenta() }
            ToolbarItemGroup(placement: .keyboard) { Spacer(); Button("Listo") { escribiendo = false } }
        }
        .scrollDismissesKeyboard(.interactively).mensajeError($error)
        .alert("Compra registrada", isPresented: Binding(get: { confirmacion != nil }, set: { if !$0 { confirmacion = nil } })) {
            Button("Aceptar", role: .cancel) { confirmacion = nil }
        } message: { Text(confirmacion ?? "") }
    }
    private func registrar() {
        guard let proveedor, let producto, let unidades = Int(cantidad.limpio), let precio = costo.numeroDecimal else { return }
        do {
            let compra = try ServicioCompras(context: context).registrar(proveedor: proveedor, producto: producto,
                                                                       cantidad: unidades, costo: precio, alCredito: credito, actor: usuario)
            escribiendo = false
            confirmacion = "\(compra.estado) · \(compra.total.soles)" + (compra.pagada ? " · Pagada al contado" : "")
            cantidad = "1"
        } catch { self.error = error.localizedDescription }
    }
}
