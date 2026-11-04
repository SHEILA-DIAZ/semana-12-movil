import Foundation
import SwiftData

// Predicados compartidos entre las pantallas y las pruebas sobre SQLite.
enum ConsultasCompras {
    static func propias(usuario: String, estado: String = "") -> Predicate<Compra> {
        let todas = estado.isEmpty
        return #Predicate<Compra> { $0.comprador?.usuario == usuario && (todas || $0.estado == estado) }
    }
    static func pagos(pagadas: Bool, vencidas: Bool, ahora: Date) -> Predicate<Compra> {
        let aprobada = EstadoCompra.aprobada.rawValue
        return #Predicate<Compra> {
            $0.estado == aprobada && $0.alCredito && $0.pagada == pagadas && (!vencidas || $0.vence < ahora)
        }
    }
}
