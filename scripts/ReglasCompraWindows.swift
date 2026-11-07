import Foundation

// Dobles mínimos del modelo y del error para ejecutar ReglasCompra.swift sin el SDK iOS.
// No prueban SwiftData, permisos, sesión ni vistas. No se incluyen en el target de la app.
enum ErrorCompras: Error { case validacion(String) }
struct Producto {
    let stock: Int
    let costoPromedio: Double
}

@main
struct VerificarReglasWindows {
    static func main() throws {
        var verificaciones = 0
        func comprobar(_ condicion: Bool, _ descripcion: String) {
            guard condicion else { fatalError("FALLO: \(descripcion)") }
            verificaciones += 1
        }
        func rechaza(_ descripcion: String, _ operacion: () throws -> Void) {
            do { try operacion(); fatalError("Debió rechazar: \(descripcion)") }
            catch { verificaciones += 1 }
        }
        let inicial = Producto(stock: 40, costoPromedio: 110)
        let pequena = try ReglasCompra.importes(cantidad: 10, costo: 120)
        comprobar(pequena.subtotal == 1200, "caso 3: subtotal")
        comprobar(pequena.igv == 216, "caso 3: IGV")
        comprobar(pequena.total == 1416, "caso 3: total")
        comprobar(!pequena.requiereAprobacion, "casos 3/4: umbral")
        let prevision = try ReglasCompra.prevision(producto: inicial, cantidad: 10, costo: 120)
        comprobar(prevision.stock == 50, "caso 3: stock previsto")
        comprobar(abs(prevision.costoPromedio - 112) < 0.000001, "caso 3: promedio")
        let grande = try ReglasCompra.importes(cantidad: 50, costo: 120)
        comprobar(grande.total == 7080 && grande.igv == 1080, "caso 5: importes")
        comprobar(grande.requiereAprobacion, "caso 5: umbral")
        let aprobacion = try ReglasCompra.prevision(producto: inicial, cantidad: 50, costo: 120)
        comprobar(aprobacion.stock == 90, "caso 6: stock previsto")
        comprobar(abs(aprobacion.costoPromedio - 115.5555555556) < 0.000001, "caso 6: promedio sin redondeo prematuro")
        let limite = try ReglasCompra.importes(cantidad: 1, costo: 4237.29)
        comprobar(limite.igv == 762.71 && limite.total == 5000 && limite.requiereAprobacion, "umbral exacto 5000")
        let menor = try ReglasCompra.importes(cantidad: 1, costo: 4237.28)
        comprobar(menor.total == 4999.99 && !menor.requiereAprobacion, "centavo inferior al umbral")
        let vacio = try ReglasCompra.prevision(producto: Producto(stock: 0, costoPromedio: 0), cantidad: 3, costo: 120)
        comprobar(vacio.stock == 3 && vacio.costoPromedio == 120, "primer ingreso")
        let consecutiva = try ReglasCompra.prevision(producto: Producto(stock: prevision.stock, costoPromedio: prevision.costoPromedio), cantidad: 50, costo: 120)
        comprobar(consecutiva.stock == 100 && abs(consecutiva.costoPromedio - 116) < 0.000001, "promedio de compras consecutivas")
        for cantidad in [0, -1] {
            rechaza("cantidad inválida") { _ = try ReglasCompra.importes(cantidad: cantidad, costo: 120) }
        }
        for costo in [0, -1, Double.nan, Double.infinity, -Double.infinity] {
            rechaza("costo inválido") { _ = try ReglasCompra.importes(cantidad: 1, costo: costo) }
        }
        rechaza("overflow de stock") { _ = try ReglasCompra.prevision(producto: inicial, cantidad: Int.max, costo: 1) }
        rechaza("stock negativo") { _ = try ReglasCompra.prevision(producto: Producto(stock: -1, costoPromedio: 110), cantidad: 10, costo: 120) }
        rechaza("promedio inválido") { _ = try ReglasCompra.prevision(producto: Producto(stock: 40, costoPromedio: .nan), cantidad: 10, costo: 120) }
        print("OK: \(verificaciones) comprobaciones del archivo real ReglasCompra.swift. No incluye SwiftData/UI.")
    }
}
