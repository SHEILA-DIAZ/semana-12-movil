import Foundation
import SwiftData

enum EstadoCompra: String, CaseIterable {
    case pendiente = "Pendiente"
    case aprobada = "Aprobada"
    case rechazada = "Rechazada"
}

@Model
final class Compra {
    var fecha: Date
    var cantidad: Int
    var costoUnitario: Double
    var igv: Double
    var total: Double
    var alCredito: Bool
    var vence: Date
    var estado: String
    var pagada: Bool
    var motivoRechazo: String?
    var comprador: Usuario?
    var proveedor: Proveedor?
    var producto: Producto?

    init(fecha: Date, cantidad: Int, costoUnitario: Double, igv: Double, total: Double,
         alCredito: Bool, vence: Date, comprador: Usuario, proveedor: Proveedor, producto: Producto) {
        self.fecha = fecha
        self.cantidad = cantidad
        self.costoUnitario = costoUnitario
        self.igv = igv
        self.total = total
        self.alCredito = alCredito
        self.vence = vence
        self.estado = EstadoCompra.pendiente.rawValue
        self.pagada = false
        self.comprador = comprador
        self.proveedor = proveedor
        self.producto = producto
    }
    var estaAprobada: Bool { estado == EstadoCompra.aprobada.rawValue }
    var estaPorPagar: Bool { estaAprobada && alCredito && !pagada }
    func estaVencida(en fecha: Date = Date()) -> Bool { estaPorPagar && vence < fecha }
}
