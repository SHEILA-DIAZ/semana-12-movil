# Registro de asistencia de IA

## Limpieza del proyecto

**Solicitud:** quitar elementos sin uso y duplicados.

**Cambio:** se eliminó `scripts/ReglasCompraWindows.swift`, que repetía escenarios de XCTest con copias de Producto y ErrorCompras y no pudo ejecutarse en este entorno. El script de Windows queda limitado al análisis sintáctico que sí funciona. Se redujo el contenido repetido del README y se actualizaron las instrucciones. Se limpiaron las dependencias temporales de lectura del PDF, sus renders y la carpeta de compilación vacía. Se conservan las 14 pruebas XCTest, las pantallas, las reglas, ambos PDFs con distinto alcance y los recursos gráficos utilizados por iOS y el login.

**Verificación:** análisis sintáctico de las 24 fuentes Swift, referencias del proyecto, ausencia de referencias activas al verificador eliminado y revisión del diff. La compilación iOS sigue pendiente en macOS. Los apartados siguientes conservan el registro histórico, incluidas herramientas retiradas durante esta limpieza.

## Continuación en Windows · 2026-11-06 · B8

**Solicitud:** continuar el proyecto existente en `ia-asistida`, leer las siete páginas de `documentos/Grupo B · Caso Compras (SwiftUI + SwiftData).pdf`, contrastar código e historial, completar pendientes y publicar cada etapa sin modificar main.

**Revisión:** se extrajo el texto y se inspeccionaron visualmente las siete páginas, incluidas maquetas B1–B9, modelos, reglas, nueve casos y rúbrica. El historial inicial termina en `da1a004`; las nueve pantallas y reglas base ya estaban implementadas. Se preservan esos avances.

**Faltante corregido:** B8 no ofrecía búsqueda por proveedor del Nivel +. Se agregó búsqueda combinada con los filtros existentes con #Predicate; el total por pagar sigue representando toda la deuda. La acción Pagar exige también rol Supervisor en la vista, además del servicio.

**Verificación:** revisión del cambio y análisis sintáctico con Swift de Windows. No se dispone de SwiftUI, SwiftData, Xcode ni simulador iOS en este sistema; la prueba visual queda para macOS. Los resultados históricos de Xcode no corresponden a esta continuación.

## Continuación en Windows · 2026-11-06 · Aislamiento de catálogos

**Hallazgo:** la edición y el borrado de catálogos validaban al Supervisor, pero no el contexto del registro recibido. A diferencia de las operaciones de compra, podían intentar modificar objetos de otro almacén.

**Cambio:** se exige el contexto de la sesión para editar y borrar Producto/Proveedor y borrar Usuario, antes de cualquier mutación. Se añadió una prueba XCTest con dos almacenes independientes y un producto sin insertar; comprueba rechazo sin cambios en ambos contextos.

**Verificación real:** Swift de Windows analizó la sintaxis del servicio y la prueba sin errores; `git diff --check` pasó. La ejecución de XCTest/SwiftData requiere macOS y queda pendiente.

## Continuación en Windows · 2026-11-06 · Verificación y entrega

**Trabajo:** revisión completa de modelos, servicios, B1–B9, proyecto, tests, historial e ícono. Se preservaron los avances existentes; solo se completaron búsqueda B8 y aislamiento de catálogos. Se incorporó al repositorio el PDF específico recibido, que inicialmente estaba sin seguimiento.

**Herramientas:** PyMuPDF local en `.tools` para texto y renderizado de las siete páginas; Swift 6.4 para sintaxis; Python estándar para inspeccionar PNG, referencias del proyecto, esquema XML y presencia de casos. `.tools` y los renders temporales se ignoran en Git.

**Evidencia actual:** sintaxis de 24 archivos Swift correcta, más la del nuevo verificador; AppIcon RGB 1024 × 1024 sin alfa; nombre Compras y referencias Xcode comprobados; 14 métodos XCTest definidos, incluyendo casos 01–09; `git diff --check` correcto. Se añadió `scripts/verificar_windows.ps1` con modo `-SoloSintaxis`, ejecutado correctamente, y un verificador que compila el archivo real de reglas con dobles mínimos y 24 comprobaciones.

**Límite encontrado:** el modo de ejecución numérica no pudo compilar por falta de `stdlib.h`/SwiftShims del entorno C de Windows. No se ejecutaron esas comprobaciones ni XCTest, SwiftData, Xcode o simulador. Los resultados macOS ya documentados son históricos, sin ratificación en esta continuación.

**Documentación:** README con índice, estado verificable y comandos macOS; PRUEBAS con trazabilidad de nueve casos y pasos pendientes; expediente con la instrucción vigente de conservar main. No se inventan capturas, conclusiones personales, visto bueno ni defensa oral.

**Publicación:** commits separados para B8, aislamiento de catálogos y verificación/documentación; push normal a `ia-asistida` después de cada etapa. Sin squash ni force push; main permanece en `30a709e`.

## Consulta inicial

**Contexto:** Laboratorio 11 de Tecsup; las actividades Contacto y Alumno ya están completas en otro repositorio.

**Tarea:** «puedes hacer esta parte . Grupo B · Caso Compras (SwiftUI + SwiftData) pero en otro repo es, fijate de la guia ve avanzando mientras uyo creo el repo vale para esta actividad».

**Restricciones:** caso Compras en un repositorio independiente, respetando la guía y sin modificar los proyectos anteriores. No atribuir a trabajo manual los archivos producidos con IA. La guía exige expediente y aprobación docente antes de la construcción asistida.

**Formato esperado:** proyecto iOS SwiftUI y SwiftData, con nueve pantallas, modelos y reglas documentadas, pruebas y commits progresivos.

**Uso de la respuesta:** se revisaron las reglas comunes y el caso Grupo B, incluidas las maquetas. Se preparó un borrador del expediente y se consultó si existe visto bueno. Este borrador contiene asistencia de IA y requiere revisión de la estudiante. La implementación y el remoto se registrarán al quedar confirmados.

## Construcción autorizada

**Contexto:** el expediente técnico inicial y la guía estaban preparados en una carpeta separada del laboratorio anterior.

**Tarea:** «tu solo haz todo esto en una nueva caepeta Grupo B · Caso Compras (SwiftUI + SwiftData) guiate de la guia».

**Restricciones:** implementar solo el caso Compras, mantener independientes los proyectos anteriores y no inventar visto bueno académico.

**Formato esperado:** aplicación compilable con las nueve pantallas y reglas, pruebas y commits progresivos.

**Uso:** se avanzó por instrucción expresa de la propietaria, con el visto bueno marcado como pendiente. Se crearon los modelos y contenedor, autenticación/sesión, catálogos, compras, aprobación/rechazo, pagos, filtros y resumen. Cada etapa de pantalla se compiló antes de su commit. Los casos numéricos del PDF se interpretan como fixtures independientes. Las validaciones se ubican también en los servicios.

## Repositorio nuevo

**Contexto:** el proyecto independiente se estaba desarrollando localmente.

**Tarea:** conectar a https://github.com/SHEILA-DIAZ/semana-12-movil y confirmar que el alcance era todo el caso Grupo B.

**Restricciones:** no mezclar con Contacto/Alumno ni sobrescribir trabajo remoto.

**Formato esperado:** remoto conectado y commits progresivos en ia-asistida.

**Uso:** se comprobó que el remoto estaba vacío. Se publicaron main con el expediente, manual con el mismo punto inicial sin atribuir código asistido a trabajo manual, e ia-asistida con el desarrollo.

## Referencia de ícono

**Contexto:** existía un ícono geométrico provisional de caja.

**Tarea:** «el icono es este revisalo: Ícono de Compras (Grupo B)».

**Restricciones:** usar la referencia correspondiente al Grupo B del PDF.

**Formato esperado:** ícono correcto en Assets, pantalla de inicio y marca de login.

**Uso:** se revisó visualmente la página 28, se identificó la caja blanca con flecha amarilla descendente y fondo verde/turquesa y se rasterizó exactamente su región vectorial a 1024 × 1024, RGB. El ícono provisional se reemplazó; no se generó una interpretación distinta de la referencia.
