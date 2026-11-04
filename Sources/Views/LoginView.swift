import SwiftUI
import SwiftData

struct LoginView: View {
    @Environment(\.modelContext) private var context
    @Environment(Sesion.self) private var sesion
    @State private var usuario = ""
    @State private var clave = ""
    @State private var error: String?
    @State private var mostrarRegistro = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    LogoCompras().padding(.top, 50)
                    VStack(spacing: 7) {
                        Text("Compras Tecsup").font(.largeTitle.bold())
                        Text("Inicia sesión para continuar").foregroundStyle(.secondary)
                    }
                    VStack(spacing: 16) {
                        TextField("Usuario", text: $usuario)
                            .textInputAutocapitalization(.never).autocorrectionDisabled()
                            .textContentType(.username).accessibilityIdentifier("loginUsuario")
                        SecureField("Clave", text: $clave)
                            .textContentType(.password).accessibilityIdentifier("loginClave")
                    }
                    .textFieldStyle(.roundedBorder)
                    if let error { Text(error).font(.callout).foregroundStyle(.red).accessibilityIdentifier("loginError") }
                    Button("Ingresar") {
                        do { sesion.actual = try Autenticacion(context: context).ingresar(usuario: usuario, clave: clave) }
                        catch { self.error = error.localizedDescription }
                    }
                    .buttonStyle(.borderedProminent).controlSize(.large).frame(maxWidth: .infinity)
                    .disabled(usuario.limpio.isEmpty || clave.isEmpty).accessibilityIdentifier("ingresar")
                    Button("¿Primera vez? Crear cuenta") { mostrarRegistro = true }
                        .accessibilityIdentifier("crearCuenta")
                }.padding(24).frame(maxWidth: 520).frame(maxWidth: .infinity)
            }
            .background(Color(.systemGroupedBackground)).scrollDismissesKeyboard(.interactively)
            .navigationDestination(isPresented: $mostrarRegistro) { RegistroView() }
        }
    }
}

struct RegistroView: View {
    @Environment(\.modelContext) private var context
    @Environment(Sesion.self) private var sesion
    @State private var nombre = ""
    @State private var usuario = ""
    @State private var clave = ""
    @State private var confirmacion = ""
    @State private var rol: Rol = .comprador
    @State private var disponible: Bool?
    @State private var error: String?

    var body: some View {
        Form {
            Section("Datos de la cuenta") {
                TextField("Nombre completo", text: $nombre).accessibilityIdentifier("registroNombre")
                TextField("Usuario", text: $usuario)
                    .textInputAutocapitalization(.never).autocorrectionDisabled()
                    .accessibilityIdentifier("registroUsuario")
                    .onChange(of: usuario) { _, nuevo in
                        do { disponible = nuevo.limpio.isEmpty ? nil : try Autenticacion(context: context).disponible(nuevo) }
                        catch { self.error = error.localizedDescription }
                    }
                if let disponible {
                    Label(disponible ? "Usuario disponible" : "Ese usuario ya existe", systemImage: disponible ? "checkmark.circle" : "exclamationmark.circle")
                        .foregroundStyle(disponible ? .green : .red).font(.caption)
                }
                SecureField("Clave (mínimo 6 caracteres)", text: $clave).accessibilityIdentifier("registroClave")
                SecureField("Confirmar clave", text: $confirmacion).accessibilityIdentifier("registroConfirmacion")
            }
            Section("Tu rol") {
                Picker("Rol", selection: $rol) {
                    ForEach(Rol.allCases) { Text($0.rawValue).tag($0) }
                }.pickerStyle(.segmented).accessibilityIdentifier("registroRol")
            }
            Section {
                Button("Registrarme") {
                    do {
                        sesion.actual = try Autenticacion(context: context).registrar(nombre: nombre, usuario: usuario,
                                                                                     clave: clave, confirmacion: confirmacion, rol: rol)
                    } catch { self.error = error.localizedDescription }
                }
                .disabled(nombre.limpio.isEmpty || usuario.limpio.isEmpty || clave.isEmpty || confirmacion.isEmpty)
                .accessibilityIdentifier("registrarme")
            } footer: { Text("Al registrarte entrarás directamente con las pestañas de tu rol.") }
        }
        .navigationTitle("Crear cuenta").navigationBarTitleDisplayMode(.inline).mensajeError($error)
    }
}
