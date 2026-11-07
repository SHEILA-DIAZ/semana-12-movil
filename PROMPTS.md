# Registro de asistencia de IA

## Implementación del caso Compras

**Solicitud:** desarrollar el Grupo B de Tecsup en un repositorio independiente, siguiendo la guía, con SwiftUI, SwiftData, nueve pantallas, pruebas y commits progresivos.

**Uso:** se preparó el expediente y se implementaron modelos, login, registro, sesión, roles, catálogos, compras, aprobación/rechazo, pagos y resumen. Las validaciones se aplican también en los servicios. El expediente es un borrador asistido; el visto bueno docente está pendiente.

## Repositorio

**Solicitud:** conectar el proyecto a `https://github.com/SHEILA-DIAZ/semana-12-movil`.

**Uso:** desarrollo publicado en `ia-asistida`. La rama `manual` conserva el expediente inicial y no acredita código asistido como trabajo manual. Por instrucción vigente, no se modifica `main`, no se hace squash ni force push.

## Ícono

**Solicitud:** usar el ícono de Compras del Grupo B de la guía.

**Uso:** se incorporó la caja blanca con flecha amarilla sobre fondo verde/turquesa como AppIcon y marca del login. PNG RGB de 1024 × 1024; nombre corto Compras.

## Continuación en Windows · 2026-11-06

**Solicitud:** leer las siete páginas del PDF específico, revisar código e historial y completar solamente lo pendiente.

**Uso:** se revisaron maquetas B1–B9, reglas, modelos, rúbrica y nueve casos. Se agregó la búsqueda por proveedor en B8 y se validó el contexto de los registros en el mantenimiento de catálogos. Se añadió una prueba de aislamiento entre almacenes.

**Verificación:** sintaxis de 24 archivos Swift, referencias Xcode e ícono comprobados. Hay 14 pruebas unitarias definidas. No se ejecutaron Xcode, SwiftData ni simulador en Windows. El verificador numérico auxiliar no compiló por falta de cabeceras C y se retiró; los escenarios permanecen en XCTest.

## Limpieza solicitada

**Solicitud:** quitar duplicados y dejar solo lo que pide la guía, sin saturar el laboratorio.

**Uso:** se retiraron temporales y verificadores auxiliares. La documentación queda en README con índice, PROMPTS y expediente. Los casos esperados están en el expediente y el estado de las pruebas en el README; se eliminó PRUEBAS.md para evitar repetirlos. Se conservan la aplicación, las pruebas y las guías. Los commits anteriores guardan el detalle histórico.
