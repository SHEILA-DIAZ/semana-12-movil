# Compras Tecsup

Grupo B · Caso Compras. Aplicación iOS con SwiftUI y SwiftData.

## Índice

- [Ejecutar](#ejecutar)
- [Funcionalidades](#funcionalidades)
- [Pruebas y pendientes](#pruebas-y-pendientes)
- [Entrega](#entrega)

## Ejecutar

Abrir `ComprasTecsup.xcodeproj` en Xcode y elegir el esquema **ComprasTecsup** y un simulador con iOS 17 o posterior. No usa paquetes externos.

1. Crear una cuenta Supervisor y registrar productos y proveedores.
2. Cerrar sesión desde el avatar y crear una cuenta Comprador.
3. Registrar compras. Volver al Supervisor para aprobar, rechazar o pagar.

Los datos se conservan en SwiftData/SQLite. La sesión vuelve al login al cerrar completamente la app.

## Funcionalidades

- B1–B2: login, registro, sesión y roles Comprador/Supervisor.
- B3–B4: productos y proveedores; mantenimiento solo Supervisor.
- B5–B6: compras al contado o crédito a 30 días; cada comprador consulta las suyas.
- B7–B8: aprobación, rechazo con motivo, vencimientos, filtros, búsqueda y pagos.
- B9: inventario, crédito fiscal, por pagar, por aprobar y barras por proveedor.

IGV del 18 %. Desde S/ 5,000 se requiere aprobación; el inventario se actualiza al aprobar mediante costo promedio ponderado. No se permite borrar usuarios, productos o proveedores con compras. Ícono y nombre de la aplicación: **Compras**.

## Pruebas y pendientes

[Tests/ComprasTests.swift](Tests/ComprasTests.swift) contiene 14 pruebas, incluidos los nueve casos de la guía. [UITests/ComprasUITests.swift](UITests/ComprasUITests.swift) contiene el recorrido de interfaz. Los resultados esperados están en el [expediente](documentos/EXPEDIENTE.md#casos-de-prueba-con-resultado-esperado).

En Windows se verificó la sintaxis de los 24 archivos Swift y la configuración del ícono. Queda pendiente compilar y ejecutar las pruebas en macOS: **Product > Test** en Xcode. También faltan las capturas B1–B9 y de Inicio con el ícono Compras.

## Entrega

- [Expediente: modelos, permisos, reglas, pantallas y casos](documentos/EXPEDIENTE.md).
- [PROMPTS: registro de asistencia de IA](PROMPTS.md).
- [Guía del Grupo B](documentos/Grupo%20B%20%C2%B7%20Caso%20Compras%20%28SwiftUI%20%2B%20SwiftData%29.pdf).
- [Guía completa del laboratorio](documentos/GLAB-S11-JLEONS-2026-02.pdf).

Rama de trabajo: `ia-asistida`. `main` se conserva sin cambios. El expediente requiere completar integrantes y visto bueno docente. Las conclusiones personales y la defensa oral corresponden a la estudiante.
