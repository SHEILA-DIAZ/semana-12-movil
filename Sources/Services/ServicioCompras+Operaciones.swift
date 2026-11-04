import Foundation
import SwiftData

extension ServicioCompras {
    @discardableResult
    func registrar(proveedor: Proveedor, producto: Producto, cantidad: Int, costo: Double,
                   alCredito: Bool, actor: Usuario, fecha: Date = Date()) throws -> Compra {
        guard actor.rol == Rol.comprador.rawValue else { throw ErrorCompras.validacion("Solo el Comprador puede registrar compras.") }
        guard actor.modelContext === context, proveedor.modelContext === context, producto.modelContext === context else {
            throw ErrorCompras.validacion("Selecciona un producto y proveedor vigentes de esta sesión.")
        }
        let importes = try ReglasCompra.importes(cantidad: cantidad, costo: costo)
        let prevision = try ReglasCompra.prevision(producto: producto, cantidad: cantidad, costo: costo)
        guard let vence = Calendar.current.date(byAdding: .day, value: 30, to: fecha) else {
            throw ErrorCompras.validacion("No se pudo calcular el vencimiento.")
        }
        let compra = Compra(fecha: fecha, cantidad: cantidad, costoUnitario: costo, igv: importes.igv, total: importes.total,
                            alCredito: alCredito, vence: vence, comprador: actor, proveedor: proveedor, producto: producto)
        try transaccion {
            context.insert(compra)
            if !importes.requiereAprobacion { aplicar(compra, producto: producto, prevision: prevision) }
        }
        return compra
    }
    func aprobar(_ compra: Compra, actor: Usuario) throws {
        try exigirSupervisor(actor)
        try exigirCompraVigente(compra)
        guard compra.estado == EstadoCompra.pendiente.rawValue else {
            throw ErrorCompras.validacion("Solo se puede aprobar una compra pendiente.")
        }
        guard let producto = compra.producto else { throw ErrorCompras.validacion("La compra no tiene producto.") }
        let prevision = try ReglasCompra.prevision(producto: producto, cantidad: compra.cantidad, costo: compra.costoUnitario)
        try transaccion { aplicar(compra, producto: producto, prevision: prevision) }
    }
    func rechazar(_ compra: Compra, motivo: String, actor: Usuario) throws {
        try exigirSupervisor(actor)
        try exigirCompraVigente(compra)
        guard compra.estado == EstadoCompra.pendiente.rawValue else { throw ErrorCompras.validacion("Solo se puede rechazar una compra pendiente.") }
        guard !motivo.limpio.isEmpty else { throw ErrorCompras.validacion("Escribe un motivo de rechazo.") }
        try transaccion {
            compra.estado = EstadoCompra.rechazada.rawValue
            compra.motivoRechazo = motivo.limpio
        }
    }
    func pagar(_ compra: Compra, actor: Usuario) throws {
        try exigirSupervisor(actor)
        try exigirCompraVigente(compra)
        guard compra.estaPorPagar else { throw ErrorCompras.validacion("La compra no tiene un pago pendiente.") }
        try transaccion { compra.pagada = true }
    }
    private func aplicar(_ compra: Compra, producto: Producto, prevision: PrevisionInventario) {
        producto.stock = prevision.stock
        producto.costoPromedio = prevision.costoPromedio
        compra.estado = EstadoCompra.aprobada.rawValue
        compra.pagada = !compra.alCredito
        compra.motivoRechazo = nil
    }
}
