import Foundation

struct ResumenCompras {
    let inventario: Double
    let creditoFiscal: Double
    let porPagar: Double
    let pendientes: Int
    let totalPendiente: Double

    init(productos: [Producto], compras: [Compra]) {
        inventario = productos.reduce(0) { $0 + $1.valorInventario }
        creditoFiscal = compras.filter(\.estaAprobada).reduce(0) { $0 + $1.igv }
        porPagar = compras.filter(\.estaPorPagar).reduce(0) { $0 + $1.total }
        let sinAprobar = compras.filter { $0.estado == EstadoCompra.pendiente.rawValue }
        pendientes = sinAprobar.count
        totalPendiente = sinAprobar.reduce(0) { $0 + $1.total }
    }
}
