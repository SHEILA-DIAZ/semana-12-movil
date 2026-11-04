import Foundation
import SwiftData

enum Rol: String, CaseIterable, Identifiable {
    case comprador = "Comprador"
    case supervisor = "Supervisor"
    var id: String { rawValue }
}

@Model
final class Usuario {
    var nombre: String
    @Attribute(.unique) var usuario: String
    // Texto según el ejercicio académico; no se usa como credencial de ningún servicio externo.
    var clave: String
    var rol: String
    @Relationship(deleteRule: .deny, inverse: \Compra.comprador)
    var compras: [Compra] = []

    init(nombre: String, usuario: String, clave: String, rol: Rol) {
        self.nombre = nombre
        self.usuario = usuario.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        self.clave = clave
        self.rol = rol.rawValue
    }
    var esSupervisor: Bool { rol == Rol.supervisor.rawValue }
}
