import XCTest
import SwiftData
@testable import ComprasTecsup

@MainActor
final class ComprasTests: XCTestCase {
    private struct Escenario {
        let container: ModelContainer
        let context: ModelContext
        let servicio: ServicioCompras
        let comprador: Usuario
        let supervisor: Usuario
        let proveedor: Proveedor
        let producto: Producto
    }
    private func escenario() throws -> Escenario {
        let schema = ModelContainerProvider.schema
        let container = try ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)])
        let context = ModelContext(container)
        context.autosaveEnabled = false
        let comprador = Usuario(nombre: "Marco Torres", usuario: "mtorres", clave: "clave123", rol: .comprador)
        let supervisor = Usuario(nombre: "Sheila Díaz", usuario: "supervisor", clave: "clave123", rol: .supervisor)
        let proveedor = Proveedor(nombre: "Distribuidora Lima", ruc: "20123456789")
        let producto = Producto(nombre: "Laptop Pro 14", categoria: "Laptops", stock: 40, costoPromedio: 110)
        context.insert(comprador); context.insert(supervisor); context.insert(proveedor); context.insert(producto)
        try context.save()
        return Escenario(container: container, context: context, servicio: ServicioCompras(context: context),
                         comprador: comprador, supervisor: supervisor, proveedor: proveedor, producto: producto)
    }
    private func compra(_ e: Escenario, cantidad: Int = 10, credito: Bool = true, fecha: Date = Date()) throws -> Compra {
        try e.servicio.registrar(proveedor: e.proveedor, producto: e.producto, cantidad: cantidad, costo: 120,
                                alCredito: credito, actor: e.comprador, fecha: fecha)
    }

    func testCaso01UsuarioUnicoSinMayusculasYRegistroDirecto() throws {
        let e = try escenario(); let auth = Autenticacion(context: e.context)
        XCTAssertThrowsError(try auth.registrar(nombre: "Repetido", usuario: " MTORRES ", clave: "clave123", confirmacion: "clave123", rol: .supervisor))
        XCTAssertEqual(try e.context.fetchCount(FetchDescriptor<Usuario>()), 2)
        let nuevo = try auth.registrar(nombre: "Nueva", usuario: " NUEVA ", clave: "abcdef", confirmacion: "abcdef", rol: .comprador)
        let sesion = Sesion(); sesion.actual = nuevo
        XCTAssertEqual(sesion.actual?.usuario, "nueva")
        XCTAssertEqual(sesion.actual?.rol, "Comprador")
        sesion.cerrar(); XCTAssertNil(sesion.actual)
    }
    func testCaso02LoginIncorrectoYValidacionDeClaves() throws {
        let e = try escenario(); let auth = Autenticacion(context: e.context)
        for usuario in ["mtorres", "inexistente"] {
            XCTAssertThrowsError(try auth.ingresar(usuario: usuario, clave: "incorrecta")) { error in
                XCTAssertEqual(error.localizedDescription, "Usuario o clave incorrectos")
            }
        }
        XCTAssertEqual(try auth.ingresar(usuario: " MTORRES ", clave: "clave123"), e.comprador)
        XCTAssertThrowsError(try auth.registrar(nombre: "Otro", usuario: "otro", clave: "1234", confirmacion: "1234", rol: .comprador))
        XCTAssertThrowsError(try auth.registrar(nombre: "Otro", usuario: "otro", clave: "123456", confirmacion: "diferente", rol: .comprador))
        XCTAssertEqual(try e.context.fetchCount(FetchDescriptor<Usuario>()), 2)
    }
    func testCaso03CreditoPequenoActualizaStockCostoIGVYVencimiento() throws {
        let e = try escenario(); let fecha = Date(timeIntervalSince1970: 1_790_000_000)
        let c = try compra(e, fecha: fecha)
        XCTAssertEqual(c.total, 1416, accuracy: 0.001); XCTAssertEqual(c.igv, 216, accuracy: 0.001)
        XCTAssertEqual(c.estado, "Aprobada"); XCTAssertFalse(c.pagada)
        XCTAssertEqual(e.producto.stock, 50); XCTAssertEqual(e.producto.costoPromedio, 112, accuracy: 0.0001)
        XCTAssertEqual(c.vence, Calendar.current.date(byAdding: .day, value: 30, to: fecha))
        XCTAssertEqual(e.comprador.compras.count, 1); XCTAssertEqual(e.proveedor.compras.count, 1); XCTAssertEqual(e.producto.compras.count, 1)
        XCTAssertEqual(e.proveedor.totalComprado, 1416, accuracy: 0.001)
        XCTAssertEqual(e.proveedor.porPagar.count, 1)
    }
    func testCaso04ContadoQuedaPagadaYNoGeneraDeuda() throws {
        let e = try escenario(); let c = try compra(e, credito: false)
        XCTAssertTrue(c.estaAprobada); XCTAssertTrue(c.pagada); XCTAssertFalse(c.estaPorPagar)
        XCTAssertTrue(e.proveedor.porPagar.isEmpty)
        let pagos = FetchDescriptor<Compra>(predicate: ConsultasCompras.pagos(pagadas: false, vencidas: false, ahora: Date()))
        XCTAssertEqual(try e.context.fetchCount(pagos), 0)
    }
    func testCaso05CompraGrandeEsPendienteSinEfectos() throws {
        let e = try escenario(); let c = try compra(e, cantidad: 50)
        XCTAssertEqual(c.total, 7080, accuracy: 0.001); XCTAssertEqual(c.estado, "Pendiente")
        XCTAssertEqual(e.producto.stock, 40); XCTAssertEqual(e.producto.costoPromedio, 110)
        let resumen = ResumenCompras(productos: [e.producto], compras: [c])
        XCTAssertEqual(resumen.inventario, 4400); XCTAssertEqual(resumen.creditoFiscal, 0); XCTAssertEqual(resumen.porPagar, 0)
        XCTAssertEqual(resumen.pendientes, 1); XCTAssertEqual(resumen.totalPendiente, 7080)
        XCTAssertEqual(e.proveedor.totalComprado, 0); XCTAssertTrue(e.proveedor.porPagar.isEmpty)
    }
    func testCaso06AprobarActualizaUnaSolaVezYResumen() throws {
        let e = try escenario(); let c = try compra(e, cantidad: 50)
        try e.servicio.aprobar(c, actor: e.supervisor)
        XCTAssertEqual(e.producto.stock, 90); XCTAssertEqual(e.producto.costoPromedio, 115.55555555, accuracy: 0.0001)
        XCTAssertTrue(c.estaPorPagar)
        XCTAssertThrowsError(try e.servicio.aprobar(c, actor: e.supervisor))
        XCTAssertEqual(e.producto.stock, 90)
        let resumen = ResumenCompras(productos: [e.producto], compras: [c])
        XCTAssertEqual(resumen.inventario, 10400, accuracy: 0.001)
        XCTAssertEqual(resumen.creditoFiscal, 1080); XCTAssertEqual(resumen.porPagar, 7080); XCTAssertEqual(resumen.pendientes, 0)
    }
    func testCaso07RechazoExigeMotivoYSinEfectos() throws {
        let e = try escenario(); let c = try compra(e, cantidad: 50)
        XCTAssertThrowsError(try e.servicio.rechazar(c, motivo: "  ", actor: e.supervisor))
        XCTAssertEqual(c.estado, "Pendiente")
        try e.servicio.rechazar(c, motivo: " Precio alto ", actor: e.supervisor)
        XCTAssertEqual(c.estado, "Rechazada"); XCTAssertEqual(c.motivoRechazo, "Precio alto")
        XCTAssertEqual(e.producto.stock, 40); XCTAssertEqual(e.producto.costoPromedio, 110)
        XCTAssertFalse(c.estaPorPagar); XCTAssertEqual(e.proveedor.totalComprado, 0)
        XCTAssertThrowsError(try e.servicio.aprobar(c, actor: e.supervisor))
    }
    func testCaso08CreditoVencidoPasaAPagadoSinAlterarInventario() throws {
        let e = try escenario(); let ahora = Date()
        let fecha = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -31, to: ahora))
        let c = try compra(e, fecha: fecha)
        XCTAssertTrue(c.estaVencida(en: ahora))
        XCTAssertEqual(try e.context.fetchCount(FetchDescriptor<Compra>(predicate: ConsultasCompras.pagos(pagadas: false, vencidas: true, ahora: ahora))), 1)
        try e.servicio.pagar(c, actor: e.supervisor)
        XCTAssertTrue(c.pagada); XCTAssertFalse(c.estaVencida(en: ahora)); XCTAssertEqual(e.producto.stock, 50)
        XCTAssertEqual(try e.context.fetchCount(FetchDescriptor<Compra>(predicate: ConsultasCompras.pagos(pagadas: true, vencidas: false, ahora: ahora))), 1)
        XCTAssertEqual(ResumenCompras(productos: [e.producto], compras: [c]).porPagar, 0)
        XCTAssertThrowsError(try e.servicio.pagar(c, actor: e.supervisor))
    }
    func testCaso09CompradorSoloVePropiasYNoPuedeAprobarRechazarNiPagar() throws {
        let e = try escenario(); let propia = try compra(e)
        let ajeno = try Autenticacion(context: e.context).registrar(nombre: "Otro", usuario: "otro", clave: "clave123", confirmacion: "clave123", rol: .comprador)
        let otra = try e.servicio.registrar(proveedor: e.proveedor, producto: e.producto, cantidad: 50, costo: 120, alCredito: true, actor: ajeno)
        let visibles = try e.context.fetch(FetchDescriptor<Compra>(predicate: ConsultasCompras.propias(usuario: e.comprador.usuario)))
        XCTAssertEqual(visibles, [propia]); XCTAssertFalse(visibles.contains(otra))
        XCTAssertThrowsError(try e.servicio.aprobar(otra, actor: e.comprador))
        XCTAssertThrowsError(try e.servicio.rechazar(otra, motivo: "No", actor: e.comprador))
        XCTAssertThrowsError(try e.servicio.pagar(propia, actor: e.comprador))
        XCTAssertEqual(otra.estado, "Pendiente"); XCTAssertFalse(propia.pagada)
    }
    func testLimiteExacto5000YValidacionesNumericas() throws {
        let e = try escenario()
        let importe = try ReglasCompra.importes(cantidad: 1, costo: 4237.29)
        XCTAssertEqual(importe.total, 5000, accuracy: 0.001); XCTAssertTrue(importe.requiereAprobacion)
        let c = try e.servicio.registrar(proveedor: e.proveedor, producto: e.producto, cantidad: 1, costo: 4237.29, alCredito: false, actor: e.comprador)
        XCTAssertEqual(c.estado, "Pendiente"); XCTAssertEqual(e.producto.stock, 40)
        for cantidad in [0,-1] { XCTAssertThrowsError(try ReglasCompra.importes(cantidad: cantidad, costo: 120)) }
        for costo in [0,-1,Double.nan,Double.infinity] { XCTAssertThrowsError(try ReglasCompra.importes(cantidad: 1, costo: costo)) }
        XCTAssertThrowsError(try ReglasCompra.prevision(producto: e.producto, cantidad: Int.max, costo: 1))
    }
    func testDenyBloqueaBorradoDeLosTresPadresYPermisosDeCatalogos() throws {
        let e = try escenario(); _ = try compra(e, cantidad: 50)
        XCTAssertThrowsError(try e.servicio.eliminarProducto(e.producto, actor: e.supervisor))
        XCTAssertThrowsError(try e.servicio.eliminarProveedor(e.proveedor, actor: e.supervisor))
        XCTAssertThrowsError(try e.servicio.eliminarUsuario(e.comprador, actor: e.supervisor))
        XCTAssertThrowsError(try e.servicio.guardarProducto(nombre: "Otro", categoria: "Accesorios", stock: 0, costo: 0, actor: e.comprador))
        XCTAssertThrowsError(try e.servicio.guardarProveedor(nombre: "Otro", ruc: "123", actor: e.comprador))
        XCTAssertEqual(try e.context.fetchCount(FetchDescriptor<Producto>()), 1)
        XCTAssertEqual(try e.context.fetchCount(FetchDescriptor<Proveedor>()), 1)
        XCTAssertEqual(try e.context.fetchCount(FetchDescriptor<Usuario>()), 2)
    }
    func testCRUDCatalogosSinComprasYEstadosDeContadoAprobado() throws {
        let e = try escenario()
        try e.servicio.guardarProducto(e.producto, nombre: "Laptop editada", categoria: "Portátiles", stock: 40, costo: 110, actor: e.supervisor)
        try e.servicio.guardarProveedor(e.proveedor, nombre: "Proveedor editado", ruc: "20999999999", actor: e.supervisor)
        XCTAssertEqual(e.producto.nombre, "Laptop editada"); XCTAssertEqual(e.proveedor.ruc, "20999999999")
        let c = try compra(e, cantidad: 50, credito: false)
        XCTAssertFalse(c.pagada)
        try e.servicio.aprobar(c, actor: e.supervisor)
        XCTAssertTrue(c.pagada); XCTAssertFalse(c.estaPorPagar)
        try e.servicio.guardarProducto(nombre: "Sin compras", categoria: "Otros", stock: 1, costo: 10, actor: e.supervisor)
        let todos = try e.context.fetch(FetchDescriptor<Producto>())
        let nuevo = try XCTUnwrap(todos.first { $0.nombre == "Sin compras" })
        try e.servicio.eliminarProducto(nuevo, actor: e.supervisor)
        XCTAssertEqual(try e.context.fetchCount(FetchDescriptor<Producto>()), 1)
    }

    func testSQLiteReabreUsuariosComprasRelacionesYEstadoPagado() throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }
        let schema = ModelContainerProvider.schema
        let config = ModelConfiguration("TestPersistencia", schema: schema, url: folder.appendingPathComponent("Compras.sqlite"))
        try autoreleasepool {
            let container = try ModelContainer(for: schema, configurations: [config]); let context = ModelContext(container)
            context.autosaveEnabled = false
            let auth = Autenticacion(context: context)
            let comprador = try auth.registrar(nombre: "Marco", usuario: "mtorres", clave: "clave123", confirmacion: "clave123", rol: .comprador)
            let supervisor = try auth.registrar(nombre: "Sheila", usuario: "sup", clave: "clave123", confirmacion: "clave123", rol: .supervisor)
            let producto = Producto(nombre: "Laptop", categoria: "Laptops", stock: 40, costoPromedio: 110)
            let proveedor = Proveedor(nombre: "Lima", ruc: "20123456789")
            context.insert(producto); context.insert(proveedor); try context.save()
            let service = ServicioCompras(context: context)
            let c = try service.registrar(proveedor: proveedor, producto: producto, cantidad: 50, costo: 120, alCredito: true, actor: comprador)
            try service.aprobar(c, actor: supervisor); try service.pagar(c, actor: supervisor)
        }
        try autoreleasepool {
            let reopened = try ModelContainer(for: schema, configurations: [config]); let context = ModelContext(reopened)
            let usuario = try Autenticacion(context: context).ingresar(usuario: "MTORRES", clave: "clave123")
            let c = try XCTUnwrap(context.fetch(FetchDescriptor<Compra>()).first)
            XCTAssertEqual(c.comprador, usuario); XCTAssertEqual(c.producto?.stock, 90)
            XCTAssertEqual(c.producto?.costoPromedio ?? 0, 115.5555555, accuracy: 0.0001)
            XCTAssertEqual(c.proveedor?.nombre, "Lima"); XCTAssertEqual(c.proveedor?.compras.count, 1)
            XCTAssertTrue(c.pagada); XCTAssertEqual(c.estado, "Aprobada")
            XCTAssertEqual(try context.fetchCount(FetchDescriptor<Usuario>()), 2)
            XCTAssertNil(Sesion().actual)
        }
    }
}
