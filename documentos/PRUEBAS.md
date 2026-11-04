# Verificación del caso Compras

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
