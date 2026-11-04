import Foundation
import SwiftData
import Observation

enum ErrorCompras: LocalizedError {
    case validacion(String)
    var errorDescription: String? {
        switch self { case .validacion(let texto): return texto }
    }
}

@MainActor
@Observable
final class Sesion {
    var actual: Usuario?
    func cerrar() { actual = nil }
}

@MainActor
struct Autenticacion {
    let context: ModelContext

    static func normalizar(_ texto: String) -> String {
        texto.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    func disponible(_ texto: String) throws -> Bool {
        let nombre = Self.normalizar(texto)
        guard !nombre.isEmpty else { return false }
        let consulta = FetchDescriptor<Usuario>(predicate: #Predicate { $0.usuario == nombre })
        return try context.fetchCount(consulta) == 0
    }
    func registrar(nombre: String, usuario: String, clave: String, confirmacion: String, rol: Rol) throws -> Usuario {
        let nombre = nombre.trimmingCharacters(in: .whitespacesAndNewlines)
        let usuario = Self.normalizar(usuario)
        guard !nombre.isEmpty, !usuario.isEmpty else { throw ErrorCompras.validacion("Completa el nombre y el usuario.") }
        guard clave.count >= 6 else { throw ErrorCompras.validacion("La clave debe tener al menos 6 caracteres.") }
        guard clave == confirmacion else { throw ErrorCompras.validacion("Las claves no coinciden.") }
        guard try disponible(usuario) else { throw ErrorCompras.validacion("Ese usuario ya existe.") }
        let nuevo = Usuario(nombre: nombre, usuario: usuario, clave: clave, rol: rol)
        context.insert(nuevo)
        do { try context.save(); return nuevo }
        catch { context.rollback(); throw error }
    }
    func ingresar(usuario: String, clave: String) throws -> Usuario {
        let nombre = Self.normalizar(usuario)
        let consulta = FetchDescriptor<Usuario>(predicate: #Predicate { $0.usuario == nombre })
        guard let persona = try context.fetch(consulta).first, persona.clave == clave else {
            throw ErrorCompras.validacion("Usuario o clave incorrectos")
        }
        return persona
    }
}
