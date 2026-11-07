# Verificación del caso Compras

## Revisión actual · Windows · 2026-11-06

Fuente principal: `Grupo B · Caso Compras (SwiftUI + SwiftData).pdf`, **siete páginas** leídas mediante extracción de texto y renderizado visual completo. B1–B3 están en página 1; B4–B6 en página 2; B7–B9 y reglas en página 3; nueve casos e ícono en página 4; instrucciones de entrega y rúbrica en páginas 5–6; captura de Inicio y enlace en página 7.

Resultado real en esta continuación:

- Swift 6.4 de Windows: análisis sintáctico de **24 archivos de Sources, Tests y UITests**, sin errores. No resuelve tipos del SDK, expande macros SwiftData ni valida la compilación iOS.
- `git diff --check`: sin errores.
- Proyecto Xcode: los 24 archivos figuran referenciados; esquema XML válido con targets unitario y UI. Catálogo AppIcon: PNG RGB 1024 × 1024 sin canal alfa; Display Name configurado en Compras.
- **14 métodos XCTest definidos**, con los nueve casos originales y la nueva regresión de edición/borrado entre contextos. No ejecutados en Windows.
- `scripts/verificar_windows.ps1`: analiza sintaxis y revisa `git diff --check`. Se eliminó el verificador numérico auxiliar que duplicaba escenarios de XCTest y no pudo compilar por falta de cabeceras C de Windows. Las pruebas de negocio se mantienen en `Tests/ComprasTests.swift`.
- No hay Xcode ni simulador iOS disponible en Windows. No se generaron capturas ni `.xcresult` nuevos.

### Trazabilidad actual de los nueve casos

| Caso | Implementación y prueba existente en ComprasTests | Estado de esta revisión |
| --- | --- | --- |
| 1 | Autenticacion/RegistroView; testCaso01UsuarioUnicoSinMayusculasYRegistroDirecto | Código revisado; ejecución macOS pendiente |
| 2 | Autenticacion/LoginView; testCaso02LoginIncorrectoYValidacionDeClaves | Código revisado; ejecución macOS pendiente |
| 3 | ReglasCompra/registrar; testCaso03CreditoPequenoActualizaStockCostoIGVYVencimiento | 1,200 + 216 = 1,416; promedio 112 contrastado con PDF; ejecución pendiente |
| 4 | aplicar/ConsultasCompras; testCaso04ContadoQuedaPagadaYNoGeneraDeuda | Código revisado; ejecución macOS pendiente |
| 5 | registrar/ResumenCompras; testCaso05CompraGrandeEsPendienteSinEfectos | 7,080 pendiente sin efectos; ejecución pendiente |
| 6 | aprobar/prevision; testCaso06AprobarActualizaUnaSolaVezYResumen | Stock 90, promedio 115.555…; ejecución pendiente |
| 7 | rechazar/RechazoForm/CompraFila; testCaso07RechazoExigeMotivoYSinEfectos | Motivo obligatorio y visible; ejecución pendiente |
| 8 | pagos/PorPagarView/pagar; testCaso08CreditoVencidoPasaAPagadoSinAlterarInventario | Filtros, VENCIDA y pago revisados; ejecución pendiente |
| 9 | propias/ContentView/servicios; testCaso09CompradorSoloVePropiasYNoPuedeAprobarRechazarNiPagar | Visibilidad y permisos revisados; ejecución pendiente |

### Verificación pendiente en macOS

1. Ejecutar los comandos del README con un simulador disponible y conservar el `.xcresult`. Confirmar las 14 pruebas unitarias, el recorrido UI y la reapertura SQLite. Los resultados previos no sustituyen esta ejecución.
2. En B8, con dos proveedores y créditos aprobados, buscar uno: deben combinarse búsqueda y filtros Pendientes/Vencidas/Pagadas. Buscar un nombre inexistente debe mostrar la lista vacía. Borrar el texto restaura resultados. El total inferior conserva toda la deuda y baja al pagar.
3. Revisar B1–B9 contra las maquetas con teclado, texto grande y pantalla pequeña; confirmar pestañas por rol y ausencia de Pagar para Comprador. El recorrido UI automatizado existente no incluye todavía la nueva búsqueda B8.
4. Capturar B1–B9, rechazo con motivo, crédito vencido/pagado e Inicio con ícono y nombre Compras. Adjuntar evidencia real sin sustituirla por maquetas o imágenes del PDF.
5. Completar integrantes y visto bueno del expediente, conclusiones personales y defensa oral. Estos elementos académicos no se acreditan desde el entorno técnico.

## Registro histórico previo a esta continuación

Los apartados siguientes se conservan del repositorio recibido. Sus resultados de Xcode son antecedentes declarados, **no ejecuciones realizadas o reproducidas en Windows**. No se encontraron `.xcresult` ni capturas independientes versionadas que permitan ratificar todos esos resultados.

La implementación se contrasta con las reglas comunes de páginas 19–20 y con el Grupo B de páginas 24–29. Las nueve maquetas B1–B9 se revisaron visualmente en las páginas 25–27. El ícono corresponde a la referencia del Grupo B de página 28.

## Entorno

Xcode 26.3 (17C529), SDK Simulator 26.2 y runtime iOS 26.3. Simulador exclusivo **Compras Tecsup Pruebas**, iPhone 17 Pro, UUID CE7FDB00-8D70-4892-98EE-1EBC82AC5695. Se creó sin modificar los simuladores ni los datos de Contacto/Alumno.

## Casos unitarios ejecutados

La ejecución inicial de `ComprasTests` terminó con **13 pruebas y 0 fallos**. No se afirma éxito del recorrido UI en esta ejecución: la primera automatización se detuvo al buscar el rol tras intentar abrir el registro y se corrigió la navegación/localización antes de repetirlo.

| Caso de la guía | Prueba y comprobación |
| --- | --- |
| 1 | Usuario mtorres/MTORRES: no duplica; registro válido inicia sesión con el rol seleccionado |
| 2 | Login incorrecto: mensaje genérico; se validan además clave corta y confirmación distinta |
| 3 | Crédito de 10 × 120: total 1,416, IGV 216, stock 50, promedio 112 y vence a 30 días |
| 4 | Contado pequeño: aprobada y pagada; ausente de deuda |
| 5 | Compra grande 50 × 120: pendiente 7,080; sin efectos sobre inventario, fiscal o deuda |
| 6 | Aprobar: stock 90, promedio 115.555… mostrado 115.56, deuda 7,080 y fiscal 1,080; repetir se bloquea |
| 7 | Rechazo sin motivo se bloquea; motivo válido se guarda; no modifica inventario ni permite aprobar después |
| 8 | Fecha de compra 31 días atrás: crédito vencido; al pagar pasa al filtro Pagadas y sale de deuda, sin cambiar stock |
| 9 | Predicado real de compras propias: excluye compras de otro usuario; Comprador no puede aprobar, rechazar ni pagar |
| Adicional | Total redondeado exactamente 5,000 queda pendiente; cantidades/costos inválidos y overflow se rechazan |
| Adicional | Borrado de Usuario/Producto/Proveedor con compras se bloquea; Comprador no puede mantener catálogos |
| Adicional | Edición y borrado de catálogo sin compras; contado grande pasa a pagada al aprobar |
| Persistencia | Cierra los contenedores y reabre SQLite: conserva usuarios, relaciones, inventario actualizado y pago; sesión nueva vuelve a nil |

Los predicados `ConsultasCompras.propias` y `ConsultasCompras.pagos` son los mismos utilizados por las vistas @Query y por las pruebas sobre el almacén. Se evita demostrar la visibilidad con un filtro de prueba que la interfaz no utilice.

## Interpretaciones técnicas

- Los casos de stock 40/promedio 110 son independientes; no se encadenan con el producto modificado por el caso anterior.
- El crédito vence a los 30 días desde el registro, pues la guía no define un reinicio de ese plazo al aprobar.
- La pestaña Aprobar incluye Todas para cumplir que el Supervisor puede consultar todas las compras, manteniendo las acciones solo en pendientes.
- Total comprado por proveedor y crédito fiscal cuentan solo aprobadas. La deuda excluye pendientes/rechazadas y contado.
- Las relaciones declaran .deny y los servicios comprueban la existencia de compras antes del borrado; no se ofrece borrado de compras que altere la trazabilidad.
- El stock se muestra verde sobre 10, ámbar de 6 a 10 y rojo con 5 o menos, acorde a los colores de las maquetas.

Los resultados del recorrido visual y sus capturas se incorporan al finalizar la ejecución. No se ha probado en un dispositivo físico ni se simula aprobación docente o trabajo manual no realizado.
