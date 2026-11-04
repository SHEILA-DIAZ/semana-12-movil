import Foundation

struct ImportesCompra {
    let subtotal: Double
    let igv: Double
    let total: Double
    var requiereAprobacion: Bool { total >= 5_000 }
}
struct PrevisionInventario {
    let stock: Int
    let costoPromedio: Double
}

enum ReglasCompra {
    private static func redondear(_ valor: Decimal) -> Decimal {
        var origen = valor
        var resultado = Decimal()
        NSDecimalRound(&resultado, &origen, 2, .plain)
        return resultado
    }
    static func importes(cantidad: Int, costo: Double) throws -> ImportesCompra {
        guard cantidad > 0, costo.isFinite, costo > 0,
              let decimal = Decimal(string: String(costo)), !decimal.isNaN else {
            throw ErrorCompras.validacion("La cantidad debe ser un entero positivo y el costo debe ser mayor que cero.")
        }
        let subtotal = redondear(Decimal(cantidad) * decimal)
        let igv = redondear(subtotal * Decimal(string: "0.18")!)
        let total = subtotal + igv
        guard !subtotal.isNaN, !igv.isNaN, !total.isNaN else { throw ErrorCompras.validacion("El importe excede el límite permitido.") }
        let s = NSDecimalNumber(decimal: subtotal).doubleValue
        let i = NSDecimalNumber(decimal: igv).doubleValue
        let t = NSDecimalNumber(decimal: total).doubleValue
        guard s.isFinite, i.isFinite, t.isFinite, t > 0 else { throw ErrorCompras.validacion("El importe no es válido.") }
        return ImportesCompra(subtotal: s, igv: i, total: t)
    }
    static func prevision(producto: Producto, cantidad: Int, costo: Double) throws -> PrevisionInventario {
        _ = try importes(cantidad: cantidad, costo: costo)
        let (nuevoStock, overflow) = producto.stock.addingReportingOverflow(cantidad)
        guard !overflow, producto.stock >= 0, nuevoStock > 0,
              producto.costoPromedio.isFinite, producto.costoPromedio >= 0,
              let anterior = Decimal(string: String(producto.costoPromedio)), let unitario = Decimal(string: String(costo)) else {
            throw ErrorCompras.validacion("El inventario no permite registrar esta cantidad.")
        }
        let promedio = (Decimal(producto.stock) * anterior + Decimal(cantidad) * unitario) / Decimal(nuevoStock)
        guard !promedio.isNaN else { throw ErrorCompras.validacion("El costo promedio excede el límite permitido.") }
        let valor = NSDecimalNumber(decimal: promedio).doubleValue
        guard valor.isFinite, (Double(nuevoStock) * valor).isFinite else { throw ErrorCompras.validacion("El inventario excede el límite permitido.") }
        return PrevisionInventario(stock: nuevoStock, costoPromedio: valor)
    }
}
