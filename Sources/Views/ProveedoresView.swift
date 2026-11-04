import SwiftUI
import SwiftData

struct ProveedoresView: View {
    let usuario: Usuario
    @Environment(\.modelContext) private var context
    @Query(sort: \Proveedor.nombre) private var proveedores: [Proveedor]
    @State private var busqueda = ""
    @State private var nuevo = false
    @State private var seleccionado: Proveedor?
    @State private var error: String?
    private var filtrados: [Proveedor] {
        proveedores.filter { busqueda.isEmpty || $0.nombre.localizedCaseInsensitiveContains(busqueda) || $0.ruc.contains(busqueda) }
    }
    var body: some View {
        List {
            if proveedores.isEmpty {
                ContentUnavailableView("Sin proveedores", systemImage: "building.2",
                                       description: Text(usuario.esSupervisor ? "Pulsa + para registrar el primero." : "El supervisor debe registrar proveedores."))
            }
            ForEach(filtrados) { proveedor in
                Group {
                    if usuario.esSupervisor {
                        Button { seleccionado = proveedor } label: { fila(proveedor) }.buttonStyle(.plain)
                    } else { fila(proveedor) }
                }.accessibilityIdentifier("proveedor-\(proveedor.nombre)")
            }
            .onDelete { offsets in
                let seleccion = offsets.map { filtrados[$0] }
                do { for p in seleccion { try ServicioCompras(context: context).eliminarProveedor(p, actor: usuario) } }
                catch { self.error = error.localizedDescription }
            }
            .deleteDisabled(!usuario.esSupervisor)
        }
        .navigationTitle("Proveedores").searchable(text: $busqueda, prompt: "Buscar nombre o RUC")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) { MenuCuenta() }
            if usuario.esSupervisor {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Nuevo proveedor", systemImage: "plus") { nuevo = true }.accessibilityIdentifier("nuevoProveedor")
                }
            }
        }
        .sheet(isPresented: $nuevo) { ProveedorForm(usuario: usuario) }
        .sheet(item: $seleccionado) { ProveedorForm(usuario: usuario, proveedor: $0) }
        .mensajeError($error)
    }
    private func fila(_ proveedor: Proveedor) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "building.2.fill").foregroundStyle(.teal)
            VStack(alignment: .leading, spacing: 5) {
                Text(proveedor.nombre).font(.headline)
                Text("RUC: \(proveedor.ruc)").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 5) {
                Text(proveedor.totalComprado.soles).font(.subheadline.bold())
                Text(proveedor.porPagar.isEmpty ? "Al día" : "\(proveedor.porPagar.count) por pagar")
                    .font(.caption.bold()).foregroundStyle(proveedor.porPagar.isEmpty ? .green : .red)
            }
        }.padding(.vertical, 5)
    }
}

struct ProveedorForm: View {
    let usuario: Usuario
    var proveedor: Proveedor?
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var nombre: String
    @State private var ruc: String
    @State private var error: String?

    init(usuario: Usuario, proveedor: Proveedor? = nil) {
        self.usuario = usuario; self.proveedor = proveedor
        _nombre = State(initialValue: proveedor?.nombre ?? "")
        _ruc = State(initialValue: proveedor?.ruc ?? "")
    }
    var body: some View {
        NavigationStack {
            Form {
                TextField("Nombre del proveedor", text: $nombre).accessibilityIdentifier("proveedorNombre")
                TextField("RUC", text: $ruc).keyboardType(.numberPad).accessibilityIdentifier("proveedorRUC")
            }
            .navigationTitle(proveedor == nil ? "Nuevo proveedor" : "Editar proveedor").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        do {
                            try ServicioCompras(context: context).guardarProveedor(proveedor, nombre: nombre, ruc: ruc, actor: usuario)
                            dismiss()
                        } catch { self.error = error.localizedDescription }
                    }.disabled(nombre.limpio.isEmpty || ruc.limpio.isEmpty).accessibilityIdentifier("guardarProveedor")
                }
            }.mensajeError($error)
        }
    }
}
