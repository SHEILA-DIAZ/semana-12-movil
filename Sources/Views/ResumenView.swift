import SwiftUI
import SwiftData
import Charts

struct ResumenView: View {
    let usuario: Usuario
    @Query private var productos: [Producto]
    @Query private var compras: [Compra]
    @Query(sort: \Proveedor.nombre) private var proveedores: [Proveedor]
    private var resumen: ResumenCompras { ResumenCompras(productos: productos, compras: compras) }
    private var conCompras: [Proveedor] {
        proveedores.filter { $0.totalComprado > 0 }.sorted { $0.totalComprado > $1.totalComprado }
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Hola, \(usuario.nombre)").font(.title2.bold())
                    Text("Supervisor · Resumen de compras").foregroundStyle(.secondary)
                }
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    tarjeta("Inventario", valor: resumen.inventario.soles, simbolo: "shippingbox", color: .teal)
                    tarjeta("Crédito fiscal", valor: resumen.creditoFiscal.soles, simbolo: "percent", color: .blue)
                    tarjeta("Por pagar", valor: resumen.porPagar.soles, simbolo: "creditcard", color: .orange)
                    tarjeta("Por aprobar", valor: "\(resumen.pendientes) · \(resumen.totalPendiente.soles)", simbolo: "clock", color: .purple)
                }
                VStack(alignment: .leading, spacing: 14) {
                    Text("Total comprado por proveedor").font(.headline)
                    if conCompras.isEmpty {
                        ContentUnavailableView("Sin compras aprobadas", systemImage: "chart.bar.xaxis")
                    } else {
                        Chart(conCompras) { proveedor in
                            BarMark(x: .value("Total", proveedor.totalComprado), y: .value("Proveedor", proveedor.nombre))
                                .foregroundStyle(.teal)
                                .annotation(position: .trailing) { Text(proveedor.totalComprado.soles).font(.caption2) }
                        }
                        .frame(height: CGFloat(max(180, conCompras.count * 65)))
                        .chartXAxisLabel("Importe en soles")
                        ForEach(conCompras) { proveedor in
                            ImporteFila(titulo: proveedor.nombre, valor: proveedor.totalComprado).font(.callout)
                        }
                    }
                }.padding().background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
                Text("El crédito fiscal y los totales por proveedor incluyen solo compras aprobadas. Por pagar incluye solo créditos aprobados sin pagar.")
                    .font(.footnote).foregroundStyle(.secondary)
            }.padding()
        }
        .background(Color(.systemGroupedBackground)).navigationTitle("Resumen")
        .toolbar { ToolbarItem(placement: .topBarTrailing) { MenuCuenta() } }
    }
    private func tarjeta(_ titulo: String, valor: String, simbolo: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(titulo, systemImage: simbolo).font(.caption).foregroundStyle(color)
            Text(valor).font(.title3.bold()).minimumScaleFactor(0.7).lineLimit(2).monospacedDigit()
        }
        .frame(maxWidth: .infinity, minHeight: 90, alignment: .leading).padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine).accessibilityIdentifier("resumen-\(titulo)")
    }
}
