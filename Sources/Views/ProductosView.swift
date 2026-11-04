import SwiftUI
import SwiftData

struct ProductosView: View {
    let usuario: Usuario
    @Environment(\.modelContext) private var context
    @Query(sort: \Producto.nombre) private var productos: [Producto]
    @State private var busqueda = ""
    @State private var nuevo = false
    @State private var seleccionado: Producto?
    @State private var error: String?
    @State private var versionLista = 0
    private var filtrados: [Producto] {
        productos.filter { busqueda.isEmpty || $0.nombre.localizedCaseInsensitiveContains(busqueda) || $0.categoria.localizedCaseInsensitiveContains(busqueda) }
    }
    var body: some View {
        List {
            if productos.isEmpty {
                ContentUnavailableView("Sin productos", systemImage: "shippingbox",
                                       description: Text(usuario.esSupervisor ? "Pulsa + para registrar el primero." : "El supervisor debe registrar productos."))
            }
            ForEach(filtrados) { producto in
                Group {
                    if usuario.esSupervisor {
                        Button { seleccionado = producto } label: { ProductoFila(producto: producto) }.buttonStyle(.plain)
                    } else { ProductoFila(producto: producto) }
                }.accessibilityIdentifier("producto-\(producto.nombre)")
            }
            .onDelete { offsets in
                let seleccion = offsets.map { filtrados[$0] }
                do { for p in seleccion { try ServicioCompras(context: context).eliminarProducto(p, actor: usuario) } }
                catch {
                    // onDelete anima la fila de forma optimista; restaurar su identidad si el servicio bloquea el borrado.
                    versionLista += 1
                    self.error = error.localizedDescription
                }
            }
            .deleteDisabled(!usuario.esSupervisor)
            Section("Valor del inventario") {
                ImporteFila(titulo: "Stock × costo promedio", valor: productos.reduce(0) { $0 + $1.valorInventario })
                    .accessibilityIdentifier("valorInventario")
            }
        }
        .id(versionLista)
        .navigationTitle("Productos").searchable(text: $busqueda, prompt: "Buscar producto o categoría")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) { MenuCuenta() }
            if usuario.esSupervisor {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Nuevo producto", systemImage: "plus") { nuevo = true }.accessibilityIdentifier("nuevoProducto")
                }
            }
        }
        .sheet(isPresented: $nuevo) { ProductoForm(usuario: usuario) }
        .sheet(item: $seleccionado) { ProductoForm(usuario: usuario, producto: $0) }
        .mensajeError($error)
    }
}

private struct ProductoFila: View {
    let producto: Producto
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "shippingbox.fill").foregroundStyle(.teal)
            VStack(alignment: .leading, spacing: 4) {
                Text(producto.nombre).font(.headline)
                Text(producto.categoria).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 5) {
                Text(producto.costoPromedio.soles).font(.subheadline.bold())
                Text("costo prom.").font(.caption2).foregroundStyle(.secondary)
                Text("\(producto.stock) u.").font(.caption.bold()).foregroundStyle(.white)
                    .padding(.horizontal, 8).padding(.vertical, 3).background(colorStock, in: Capsule())
            }
        }.padding(.vertical, 4)
    }
    private var colorStock: Color { producto.stock <= 5 ? .red : producto.stock <= 10 ? .orange : .green }
}

struct ProductoForm: View {
    let usuario: Usuario
    var producto: Producto?
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var nombre: String
    @State private var categoria: String
    @State private var stock: String
    @State private var costo: String
    @State private var error: String?

    init(usuario: Usuario, producto: Producto? = nil) {
        self.usuario = usuario; self.producto = producto
        _nombre = State(initialValue: producto?.nombre ?? "")
        _categoria = State(initialValue: producto?.categoria ?? "")
        _stock = State(initialValue: producto.map { String($0.stock) } ?? "0")
        _costo = State(initialValue: producto.map { String($0.costoPromedio) } ?? "0")
    }
    var body: some View {
        NavigationStack {
            Form {
                Section("Datos del producto") {
                    TextField("Nombre", text: $nombre).accessibilityIdentifier("productoNombre")
                    TextField("Categoría", text: $categoria).accessibilityIdentifier("productoCategoria")
                    TextField("Stock", text: $stock).keyboardType(.numberPad).accessibilityIdentifier("productoStock")
                    TextField("Costo promedio", text: $costo).keyboardType(.decimalPad).accessibilityIdentifier("productoCosto")
                }
                if producto != nil { Text("El costo de las compras ya registradas se conserva.").font(.footnote).foregroundStyle(.secondary) }
            }
            .navigationTitle(producto == nil ? "Nuevo producto" : "Editar producto").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        guard let cantidad = Int(stock.limpio), let precio = costo.numeroDecimal else {
                            error = "Ingresa un stock entero y un costo válido."; return
                        }
                        do {
                            try ServicioCompras(context: context).guardarProducto(producto, nombre: nombre, categoria: categoria,
                                                                                 stock: cantidad, costo: precio, actor: usuario)
                            dismiss()
                        } catch { self.error = error.localizedDescription }
                    }.disabled(nombre.limpio.isEmpty || categoria.limpio.isEmpty).accessibilityIdentifier("guardarProducto")
                }
            }.mensajeError($error)
        }
    }
}
