# Compras Tecsup

Aplicación iOS del **Grupo B · Caso Compras** del Laboratorio 11, implementada con **SwiftUI y SwiftData**. Repositorio independiente: [SHEILA-DIAZ/semana-12-movil](https://github.com/SHEILA-DIAZ/semana-12-movil).

## Índice

- [Estado de la continuación en Windows](#estado-de-la-continuación-en-windows)
- [Abrir y ejecutar](#abrir-y-ejecutar)
- [Pantallas de la guía](#pantallas-de-la-guía)
- [Reglas de negocio](#reglas-de-negocio)
- [Ejemplos de la guía](#ejemplos-de-la-guía)
- [Estructura](#estructura)
- [Compilar y probar](#compilar-y-probar)
- [Documentación y ramas](#documentación-y-ramas)

## Estado de la continuación en Windows

Revisión del **2026-11-06** sobre `ia-asistida`, a partir de `da1a004`. Se leyeron las siete páginas del [PDF específico del Grupo B](documentos/Grupo%20B%20%C2%B7%20Caso%20Compras%20%28SwiftUI%20%2B%20SwiftData%29.pdf), incluidas las maquetas B1–B9 y la rúbrica, y se contrastaron con el código y los commits existentes. Las nueve pantallas y las reglas principales ya estaban implementadas.

Se completó la búsqueda por proveedor en B8 y la validación del contexto de los registros al mantener catálogos. Hay **14 métodos XCTest**, incluidos los nueve casos del PDF y una nueva prueba de aislamiento entre almacenes, más el recorrido UI existente. Esta continuación verificó sintaxis de los 24 archivos Swift, referencias del proyecto/esquema e ícono PNG RGB de 1024 × 1024. **No se compiló la aplicación ni se ejecutaron XCTest o simulador iOS en Windows.**

La ejecución del verificador de cálculos Foundation quedó bloqueada porque la instalación local no encuentra `stdlib.h` del entorno C de Windows. La matriz de evidencia y los pasos restantes están en [PRUEBAS.md](documentos/PRUEBAS.md). Se conserva la evidencia histórica documentada sin presentarla como una ejecución actual.

## Abrir y ejecutar

Abrir `ComprasTecsup.xcodeproj`, elegir el esquema **ComprasTecsup** y un simulador con iOS 17 o posterior. El proyecto está incluido y no utiliza paquetes externos. `project.yml` permite regenerarlo opcionalmente con XcodeGen.

La app inicia sin usuarios ni catálogos de ejemplo. Para usarla:

1. En **Crear cuenta**, registrar un **Supervisor**. El registro inicia sesión directamente.
2. Crear un producto y un proveedor desde sus pestañas y el botón +.
3. Abrir el menú del avatar y **Cerrar sesión**.
4. Crear una cuenta **Comprador**. Se mostrarán Productos, Proveedores, Compra y Mis compras.
5. En **Compra**, seleccionar proveedor y producto, cantidad, costo y forma de pago. El resumen muestra subtotal, IGV y total antes de confirmar.
6. Para gestionar compras grandes o pagar créditos, cerrar sesión e ingresar con el Supervisor.

No se restablece el almacén automáticamente, no se inserta contenido de prueba al iniciar y no se borran datos al cerrar sesión. La sesión vive en memoria: al cerrar completamente la aplicación vuelve a mostrarse el login. Los registros permanecen en `Application Support/ComprasData.sqlite`; su ruta se imprime en la consola de Xcode.

## Pantallas de la guía

| Pantalla | Funcionalidad |
| --- | --- |
| B1 · Login | Marca Compras Tecsup, usuario, clave oculta y mensaje genérico al fallar; acceso a Crear cuenta |
| B2 · Registro | Nombre, usuario único sin distinguir mayúsculas, clave de al menos seis caracteres, confirmación y rol; acceso directo al registrarse |
| B3 · Productos | Búsqueda por nombre/categoría, costo promedio, stock en color e inventario; mantenimiento y borrado solo Supervisor |
| B4 · Proveedores | Búsqueda por nombre/RUC, total comprado aprobado e insignia Al día/por pagar; mantenimiento solo Supervisor |
| B5 · Nueva compra | Comprador de sesión, proveedor, producto, cantidad, costo, contado/crédito a 30 días, IGV y aviso desde S/ 5,000 |
| B6 · Mis compras | Consulta de las compras propias con #Predicate; filtros Todas/Pendientes/Rechazadas y búsqueda por proveedor; motivo visible |
| B7 · Aprobar | Pendientes y consulta de todas; nombre del solicitante, vista previa de inventario, aprobación y rechazo con motivo obligatorio |
| B8 · Por pagar | Solo créditos aprobados; filtros con #Predicate de pendientes/vencidas/pagadas y búsqueda por proveedor, etiqueta VENCIDA y swipe Pagar; total de toda la deuda |
| B9 · Resumen | Inventario, crédito fiscal, deuda, pendientes de aprobación y gráfico de compras aprobadas por proveedor |

**Comprador:** Productos, Proveedores, Compra, Mis compras. **Supervisor:** Resumen, Aprobar, Por pagar, Productos, Proveedores. El avatar muestra nombre, usuario y rol y permite cerrar sesión. Los permisos se validan también en los servicios, además de ocultar los controles que no corresponden.

## Reglas de negocio

- Subtotal = cantidad × costo unitario; IGV = 18 %; total = subtotal + IGV. El cálculo usa Decimal y redondeo a céntimos; las propiedades persistidas son Double, como exige la guía.
- Un total menor que S/ 5,000 se aprueba inmediatamente. Desde S/ 5,000 queda pendiente y no afecta inventario, crédito fiscal ni cuentas por pagar.
- Al aprobar, stock nuevo = stock anterior + cantidad. Promedio nuevo = (stock anterior × promedio anterior + cantidad × costo unitario) / stock nuevo. Se conserva precisión y se muestra con dos decimales.
- Las transiciones solo permiten aprobar/rechazar pendientes y pagar créditos aprobados no pagados. Una aprobación repetida se bloquea para no duplicar el stock.
- Contado aprobado: pagada. Crédito aprobado: por pagar y vence 30 días después de la fecha de registro. Rechazar requiere motivo y no cambia inventario.
- Los totales por proveedor y el crédito fiscal cuentan solo compras aprobadas. La deuda cuenta solo créditos aprobados sin pagar. Pagar no modifica stock ni vuelve a generar IGV.
- Usuario, Producto y Proveedor declaran relaciones .deny e inversas. Los servicios impiden borrarlos si tienen compras, incluso pendientes o rechazadas. El mantenimiento de usuarios no es una pantalla exigida; su restricción se comprueba en el servicio y las pruebas.

## Ejemplos de la guía

Cada ejemplo parte de un **producto independiente** con stock 40 y promedio S/ 110:

- 10 unidades a S/ 120: subtotal 1,200; IGV 216; total 1,416; stock 50 y promedio 112. Si es a crédito, genera una obligación de 1,416.
- 50 unidades a S/ 120: total 7,080 y estado Pendiente. Al aprobar: stock 90 y promedio mostrado 115.56. Antes de aprobar sigue en stock 40/promedio 110.

Si se registran consecutivamente ambas compras sobre el mismo producto, el segundo cálculo usa el stock y promedio ya actualizados; no deben confundirse con los casos independientes del PDF.

## Estructura

```text
ComprasTecsup.xcodeproj/
project.yml
Sources/
  ComprasTecsupApp.swift
  Models/          Usuario, Proveedor, Producto, Compra
  Data/            ModelContainerProvider
  Services/        Autenticacion, Sesion, ServicioCompras, ReglasCompra, ConsultasCompras, ResumenCompras
  Views/           Login/Registro, Productos, Proveedores, NuevaCompra, MisCompras, Aprobar, PorPagar, Resumen
  Assets.xcassets/ AppIcon y MarcaCompras
Tests/             Casos de negocio y persistencia SQLite
UITests/           Recorrido de interfaz B1–B9
 documentacion:    documentos/EXPEDIENTE.md, documentos/PRUEBAS.md, PROMPTS.md
```

El ícono existente corresponde a la referencia **Ícono de Compras (Grupo B)**: página 4 del PDF específico y página 28 de la guía completa, caja blanca, flecha amarilla descendente y fondo verde/turquesa. Es un PNG RGB de 1024 × 1024, sin transparencia ni esquinas recortadas. También se utiliza como marca del login. Display Name: **Compras**.

## Compilar y probar

En Windows con Swift instalado, comprobar sintaxis:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\verificar_windows.ps1 -SoloSintaxis
```

Sin `-SoloSintaxis`, el script intenta compilar y ejecutar **el archivo real** `ReglasCompra.swift` con 24 comprobaciones numéricas y dobles mínimos de Producto/ErrorCompras, sin SwiftData ni interfaz. Requiere MSVC y Windows SDK correctamente configurados. Los dobles están fuera del target iOS. Ese modo no pudo ejecutarse en este equipo por falta de cabeceras C.

En macOS con Xcode e iOS 17 o posterior, listar primero los destinos disponibles y elegir un simulador instalado. El entorno Xcode 26.3 descrito en los registros anteriores es histórico y no se verificó en esta continuación.

```sh
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
xcodebuild -project ComprasTecsup.xcodeproj -scheme ComprasTecsup -showdestinations
xcodebuild -project ComprasTecsup.xcodeproj -scheme ComprasTecsup -sdk iphonesimulator -derivedDataPath .build/App build
# Sustituir UUID_DEL_SIMULADOR por un destino de -showdestinations:
xcodebuild -project ComprasTecsup.xcodeproj -scheme ComprasTecsup -destination 'platform=iOS Simulator,id=UUID_DEL_SIMULADOR' -parallel-testing-enabled NO -derivedDataPath .build/App -resultBundlePath .build/Compras-Verificacion.xcresult test
```

La firma está desactivada para el simulador; para instalar en un dispositivo físico se debe configurar el equipo de desarrollo y la firma en Xcode. No se requiere conexión a Internet para usar la app.

## Documentación y ramas

- [Expediente y decisiones técnicas](documentos/EXPEDIENTE.md).
- [Resultados reales de pruebas y capturas](documentos/PRUEBAS.md).
- [Registro de asistencia](PROMPTS.md).
- [PDF específico del Grupo B, siete páginas](documentos/Grupo%20B%20%C2%B7%20Caso%20Compras%20%28SwiftUI%20%2B%20SwiftData%29.pdf).
- [Guía principal](documentos/GLAB-S11-JLEONS-2026-02.pdf).

Los commits se realizan en `ia-asistida`, con nombre SHEILA-DIAZ y correo sheila.diaz@tecsup.edu.pe. `manual` conserva solo el punto inicial del expediente; no se atribuye a trabajo manual el código generado con IA. El visto bueno docente debe aportarlo la estudiante: no se registra como concedido. Por instrucción expresa de la propietaria se avanzó con la construcción asistida.

La continuación publica commits progresivos únicamente en `ia-asistida`, sin cambios a `main`, squash ni force push. En macOS queda por compilar, ejecutar las 14 pruebas y el recorrido UI, revisar B1–B9 y guardar capturas de la app y de Inicio con el nombre Compras. La página 7 del PDF ya contiene una captura, que no acredita esta revisión del código. El visto bueno, las conclusiones personales y la defensa oral corresponden a la estudiante.

Por tratarse de la práctica, la clave se guarda como texto y el rol se elige al registrarse, tal como establece el PDF. No se presenta este mecanismo como autenticación de producción.
