import XCTest

@MainActor
final class ComprasUITests: XCTestCase {
    func testRecorridoCompletoB1AB9RolesPersistenciaAprobacionRechazoYPago() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "es_PE"]
        app.launch()
        let token = String(UUID().uuidString.prefix(5)).lowercased()
        let supervisor = "sup\(token)"
        let comprador = "mt\(token)"
        let producto = "Laptop\(token)"
        let proveedor = "Lima\(token)"
        func capturar(_ nombre: String) {
            let foto = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
            foto.name = nombre; foto.lifetime = .keepAlways; add(foto)
        }
        func escribir(_ campo: XCUIElement, _ texto: String) {
            XCTAssertTrue(campo.waitForExistence(timeout: 5))
            campo.tap()
            let actual = campo.value as? String ?? ""
            let cantidad = actual == campo.placeholderValue ? 0 : actual.count
            campo.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: cantidad) + texto)
        }
        func pulsar(_ boton: XCUIElement) {
            XCTAssertTrue(boton.waitForExistence(timeout: 5))
            if !boton.isHittable { app.swipeUp() }
            boton.tap()
        }
        func registrar(_ usuario: String, rol: String, captura: Bool = false) {
            pulsar(app.buttons["crearCuenta"])
            let seleccion = app.buttons[rol]
            // En el primer arranque iOS puede descartar el toque durante la transición inicial.
            if !seleccion.waitForExistence(timeout: 3), app.buttons["crearCuenta"].exists {
                app.buttons["crearCuenta"].tap()
            }
            pulsar(seleccion)
            escribir(app.textFields["registroNombre"], "Persona \(usuario)")
            escribir(app.textFields["registroUsuario"], usuario)
            escribir(app.secureTextFields["registroClave"], "clave123")
            escribir(app.secureTextFields["registroConfirmacion"], "clave123")
            if captura { capturar("B2-registro-y-roles") }
            pulsar(app.buttons["registrarme"])
            XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 8))
        }
        func salir() {
            pulsar(app.buttons["cuenta"])
            pulsar(app.buttons["cerrarSesion"])
            XCTAssertTrue(app.buttons["ingresar"].waitForExistence(timeout: 5))
        }
        func ingresar(_ usuario: String) {
            escribir(app.textFields["loginUsuario"], usuario)
            escribir(app.secureTextFields["loginClave"], "clave123")
            pulsar(app.buttons["ingresar"])
            XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 8))
        }
        func pestaña(_ nombre: String) { pulsar(app.tabBars.buttons[nombre]) }
        func nuevaCompra() {
            pestaña("Compra")
            pulsar(app.buttons["compraProveedor"])
            pulsar(app.buttons[proveedor])
            pulsar(app.buttons["compraProducto"])
            pulsar(app.buttons[producto])
            escribir(app.textFields["compraCantidad"], "50")
            escribir(app.textFields["compraCosto"], "120")
            if app.buttons["Listo"].exists { app.buttons["Listo"].tap() }
            pulsar(app.buttons["Crédito 30 días"])
            let boton = app.buttons["registrarCompra"]
            if !boton.isHittable { app.swipeUp() }
            XCTAssertTrue(app.staticTexts["requiereAprobacion"].exists || app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Desde S/ 5,000")).firstMatch.exists)
            capturar("B5-compra-pendiente-igv-credito")
            pulsar(boton)
            XCTAssertTrue(app.alerts["Compra registrada"].waitForExistence(timeout: 5))
            XCTAssertTrue(app.alerts.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Pendiente")).firstMatch.exists)
            app.alerts.buttons["Aceptar"].tap()
        }

        capturar("B1-login")
        registrar(supervisor, rol: "Supervisor", captura: true)
        XCTAssertTrue(app.tabBars.buttons["Resumen"].exists)
        XCTAssertFalse(app.tabBars.buttons["Compra"].exists)
        pestaña("Productos")
        pulsar(app.buttons["nuevoProducto"])
        escribir(app.textFields["productoNombre"], producto)
        escribir(app.textFields["productoCategoria"], "Laptops")
        escribir(app.textFields["productoStock"], "40")
        escribir(app.textFields["productoCosto"], "110")
        pulsar(app.buttons["guardarProducto"])
        XCTAssertTrue(app.staticTexts[producto].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["40 u."].exists)
        capturar("B3-productos-e-inventario")
        pestaña("Proveedores")
        pulsar(app.buttons["nuevoProveedor"])
        escribir(app.textFields["proveedorNombre"], proveedor)
        escribir(app.textFields["proveedorRUC"], "20123456789")
        pulsar(app.buttons["guardarProveedor"])
        XCTAssertTrue(app.staticTexts[proveedor].waitForExistence(timeout: 5))
        capturar("B4-proveedores")
        salir()
        // Registro inicia sesión directamente como Comprador.
        registrar(comprador, rol: "Comprador")
        XCTAssertFalse(app.tabBars.buttons["Aprobar"].exists)
        XCTAssertFalse(app.buttons["nuevoProducto"].exists)
        XCTAssertFalse(app.tabBars.buttons["Por pagar"].exists)
        nuevaCompra()
        pestaña("Mis compras")
        XCTAssertTrue(app.staticTexts[proveedor].waitForExistence(timeout: 5))
        capturar("B6-mis-compras-pendientes")
        salir()
        // Mensaje genérico y posterior acceso válido, usando mayúsculas en el usuario.
        escribir(app.textFields["loginUsuario"], supervisor.uppercased())
        escribir(app.secureTextFields["loginClave"], "incorrecta")
        pulsar(app.buttons["ingresar"])
        XCTAssertTrue(app.staticTexts["Usuario o clave incorrectos"].waitForExistence(timeout: 5))
        escribir(app.secureTextFields["loginClave"], "clave123")
        pulsar(app.buttons["ingresar"])
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 8))
        pestaña("Aprobar")
        XCTAssertTrue(app.staticTexts["Stock: 40 → 90"].waitForExistence(timeout: 5))
        capturar("B7-aprobar-prevision-inventario")
        pulsar(app.buttons["aprobarCompra"])
        pestaña("Productos")
        XCTAssertTrue(app.staticTexts["90 u."].waitForExistence(timeout: 5))
        // Deny: producto con compra no se elimina.
        app.staticTexts[producto].swipeLeft()
        pulsar(app.buttons["Delete"])
        XCTAssertTrue(app.alerts.staticTexts["No se puede borrar un producto que tiene compras."].waitForExistence(timeout: 5))
        app.alerts.buttons["Aceptar"].tap()
        XCTAssertTrue(app.staticTexts[producto].waitForExistence(timeout: 5))
        pestaña("Por pagar")
        let pago = app.descendants(matching: .any).matching(identifier: "pago-\(producto)").firstMatch
        XCTAssertTrue(pago.waitForExistence(timeout: 5))
        capturar("B8-credito-por-pagar")
        pago.swipeLeft()
        pulsar(app.buttons["pagarCompra"])
        pulsar(app.buttons["Pagadas"])
        XCTAssertTrue(app.staticTexts["Pagada"].waitForExistence(timeout: 5))
        capturar("B8-credito-pagado")
        pestaña("Resumen")
        XCTAssertTrue(app.staticTexts["Total comprado por proveedor"].waitForExistence(timeout: 5))
        capturar("B9-resumen-y-grafico")
        salir(); ingresar(comprador)
        nuevaCompra()
        salir(); ingresar(supervisor)
        pestaña("Aprobar")
        pulsar(app.buttons["rechazarCompra"])
        XCTAssertFalse(app.buttons["confirmarRechazo"].isEnabled)
        let motivo = app.textFields["motivoRechazo"].exists ? app.textFields["motivoRechazo"] : app.textViews["motivoRechazo"]
        escribir(motivo, "Precio alto")
        capturar("B7-rechazo-con-motivo")
        pulsar(app.buttons["confirmarRechazo"])
        salir(); ingresar(comprador)
        pestaña("Mis compras")
        pulsar(app.buttons["Rechazadas"])
        XCTAssertTrue(app.staticTexts["Motivo: Precio alto"].waitForExistence(timeout: 5))
        capturar("B6-motivo-visible-al-comprador")
        // Relanzar conserva los registros, pero la sesión es solo en memoria.
        app.terminate(); app.launch()
        XCTAssertTrue(app.buttons["ingresar"].waitForExistence(timeout: 8))
        ingresar(supervisor)
        pestaña("Productos")
        XCTAssertTrue(app.staticTexts[producto].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["90 u."].exists)
        pestaña("Por pagar")
        pulsar(app.buttons["Pagadas"])
        XCTAssertTrue(app.staticTexts["Pagada"].waitForExistence(timeout: 5))
        salir()
        registrar("otro\(token)", rol: "Comprador")
        pestaña("Mis compras")
        XCTAssertTrue(app.staticTexts["Sin compras"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts[proveedor].exists)
        capturar("B6-aislamiento-entre-compradores")
        XCUIDevice.shared.press(.home)
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        for _ in 0..<3 {
            if springboard.icons["Compras"].firstMatch.exists { break }
            springboard.swipeLeft()
        }
        XCTAssertTrue(springboard.icons["Compras"].firstMatch.exists)
        capturar("Icono-Compras-en-inicio")
    }
}
