import Foundation
import SwiftData

@MainActor
final class ServicioCompras {
    let context: ModelContext
    init(context: ModelContext) { self.context = context }

    func exigirSupervisor(_ actor: Usuario) throws {
        guard actor.esSupervisor else { throw ErrorCompras.validacion("Esta operación requiere el rol Supervisor.") }
    }
    func transaccion(_ cambios: () -> Void) throws {
        cambios()
        do { try context.save() }
        catch { context.rollback(); throw error }
    }

    func guardarProducto(_ producto: Producto? = nil, nombre: String, categoria: String,
                         stock: Int, costo: Double, actor: Usuario) throws {
        try exigirSupervisor(actor)
        guard !nombre.limpio.isEmpty, !categoria.limpio.isEmpty else {
            throw ErrorCompras.validacion("Completa nombre y categoría.")
        }
        guard stock >= 0, costo.isFinite, costo >= 0, (Double(stock) * costo).isFinite else {
            throw ErrorCompras.validacion("El stock y el costo deben ser números válidos no negativos.")
        }
        try transaccion {
            let dato = producto ?? Producto(nombre: nombre.limpio, categoria: categoria.limpio, stock: stock, costoPromedio: costo)
            if producto == nil { context.insert(dato) }
            dato.nombre = nombre.limpio; dato.categoria = categoria.limpio
            dato.stock = stock; dato.costoPromedio = costo
        }
    }
    func eliminarProducto(_ producto: Producto, actor: Usuario) throws {
        try exigirSupervisor(actor)
        guard producto.compras.isEmpty else { throw ErrorCompras.validacion("No se puede borrar un producto que tiene compras.") }
        try transaccion { context.delete(producto) }
    }
    func guardarProveedor(_ proveedor: Proveedor? = nil, nombre: String, ruc: String, actor: Usuario) throws {
        try exigirSupervisor(actor)
        guard !nombre.limpio.isEmpty, !ruc.limpio.isEmpty else { throw ErrorCompras.validacion("Completa nombre y RUC.") }
        try transaccion {
            let dato = proveedor ?? Proveedor(nombre: nombre.limpio, ruc: ruc.limpio)
            if proveedor == nil { context.insert(dato) }
            dato.nombre = nombre.limpio; dato.ruc = ruc.limpio
        }
    }
    func eliminarProveedor(_ proveedor: Proveedor, actor: Usuario) throws {
        try exigirSupervisor(actor)
        guard proveedor.compras.isEmpty else { throw ErrorCompras.validacion("No se puede borrar un proveedor que tiene compras.") }
        try transaccion { context.delete(proveedor) }
    }
    func eliminarUsuario(_ usuario: Usuario, actor: Usuario) throws {
        try exigirSupervisor(actor)
        guard usuario.compras.isEmpty else { throw ErrorCompras.validacion("No se puede borrar un usuario que tiene compras.") }
        guard usuario != actor else { throw ErrorCompras.validacion("No puedes borrar la cuenta de tu sesión activa.") }
        try transaccion { context.delete(usuario) }
    }
}
