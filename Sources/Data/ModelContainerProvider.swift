import Foundation
import SwiftData

@MainActor
final class ModelContainerProvider {
    static let shared = ModelContainerProvider()
    static let schema = Schema([Usuario.self, Proveedor.self, Producto.self, Compra.self])
    let container: ModelContainer

    private init() {
        do {
            let folder = try FileManager.default.url(for: .applicationSupportDirectory,
                                                     in: .userDomainMask, appropriateFor: nil, create: true)
            let config = ModelConfiguration("ComprasData", schema: Self.schema,
                                            url: folder.appendingPathComponent("ComprasData.sqlite"))
            container = try ModelContainer(for: Self.schema, configurations: [config])
            print("Base de datos SQLite en: \(config.url.path)")
        } catch { fatalError("No se pudo abrir el almacén de Compras: \(error)") }
    }
}
