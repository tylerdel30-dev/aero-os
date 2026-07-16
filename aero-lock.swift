import Foundation
import Glibc

typealias GtkWidget = OpaquePointer
typealias GtkApplication = OpaquePointer
typealias GtkWindow = OpaquePointer
typealias GtkBox = OpaquePointer
typealias GtkLabel = OpaquePointer
typealias GtkCssProvider = OpaquePointer
typealias GdkDisplay = OpaquePointer
typealias GApplication = OpaquePointer
typealias gboolean = Int32

struct GApplicationFlags: OptionSet {
    let rawValue: UInt32
}

struct GtkOrientation: RawRepresentable {
    let rawValue: Int32
}

struct GtkAlign: RawRepresentable {
    let rawValue: Int32
}

let GTK_APPLICATION_FLAGS_NONE = GApplicationFlags(rawValue: 0)
let GTK_ORIENTATION_VERTICAL = GtkOrientation(rawValue: 1)
let GTK_ALIGN_CENTER = GtkAlign(rawValue: 3)
let GTK_STYLE_PROVIDER_PRIORITY_APPLICATION: UInt32 = 600

enum GtkLayerShellLayer: Int32 {
    case background = 0
    case bottom = 1
    case top = 2
    case overlay = 3
}

enum GtkLayerShellEdge: Int32 {
    case left = 0
    case right = 1
    case top = 2
    case bottom = 3
}

enum GtkLayerShellKeyboardMode: Int32 {
    case none = 0
    case exclusive = 1
    case onDemand = 2
}

@_silgen_name("gtk_application_new")
func gtk_application_new(_ applicationID: UnsafePointer<CChar>, _ flags: GApplicationFlags) -> GtkApplication?

@_silgen_name("g_signal_connect_data")
func g_signal_connect_data(
    _ instance: OpaquePointer?,
    _ detailedSignal: UnsafePointer<CChar>,
    _ handler: @convention(c) (OpaquePointer?, OpaquePointer?) -> Void,
    _ data: UnsafeMutableRawPointer?,
    _ destroyData: OpaquePointer?,
    _ connectFlags: Int32
) -> UInt64

@_silgen_name("g_application_run")
func g_application_run(_ application: GApplication?, _ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32

@_silgen_name("gtk_application_window_new")
func gtk_application_window_new(_ application: GtkApplication?) -> GtkWindow?

@_silgen_name("gtk_window_set_child")
func gtk_window_set_child(_ window: GtkWindow?, _ child: GtkWidget?)

@_silgen_name("gtk_window_present")
func gtk_window_present(_ window: GtkWindow?)

@_silgen_name("gtk_widget_set_name")
func gtk_widget_set_name(_ widget: GtkWidget?, _ name: UnsafePointer<CChar>)

@_silgen_name("gtk_widget_add_css_class")
func gtk_widget_add_css_class(_ widget: GtkWidget?, _ cssClass: UnsafePointer<CChar>)

@_silgen_name("gtk_widget_set_hexpand")
func gtk_widget_set_hexpand(_ widget: GtkWidget?, _ expand: gboolean)

@_silgen_name("gtk_widget_set_vexpand")
func gtk_widget_set_vexpand(_ widget: GtkWidget?, _ expand: gboolean)

@_silgen_name("gtk_widget_set_halign")
func gtk_widget_set_halign(_ widget: GtkWidget?, _ align: GtkAlign)

@_silgen_name("gtk_widget_set_valign")
func gtk_widget_set_valign(_ widget: GtkWidget?, _ align: GtkAlign)

@_silgen_name("gtk_widget_set_size_request")
func gtk_widget_set_size_request(_ widget: GtkWidget?, _ width: Int32, _ height: Int32)

@_silgen_name("gtk_box_new")
func gtk_box_new(_ orientation: GtkOrientation, _ spacing: Int32) -> GtkBox?

@_silgen_name("gtk_box_append")
func gtk_box_append(_ box: GtkBox?, _ child: GtkWidget?)

@_silgen_name("gtk_label_new")
func gtk_label_new(_ text: UnsafePointer<CChar>) -> GtkLabel?

@_silgen_name("gtk_label_set_text")
func gtk_label_set_text(_ label: GtkLabel?, _ text: UnsafePointer<CChar>)

@_silgen_name("gtk_entry_new")
func gtk_entry_new() -> GtkWidget?

@_silgen_name("gtk_entry_set_placeholder_text")
func gtk_entry_set_placeholder_text(_ entry: GtkWidget?, _ text: UnsafePointer<CChar>)

@_silgen_name("gtk_entry_set_visibility")
func gtk_entry_set_visibility(_ entry: GtkWidget?, _ visible: gboolean)

@_silgen_name("gtk_entry_set_invisible_char")
func gtk_entry_set_invisible_char(_ entry: GtkWidget?, _ character: UInt32)

@_silgen_name("gtk_editable_get_text")
func gtk_editable_get_text(_ editable: GtkWidget?) -> UnsafePointer<CChar>?

@_silgen_name("gtk_editable_set_text")
func gtk_editable_set_text(_ editable: GtkWidget?, _ text: UnsafePointer<CChar>)

@_silgen_name("gtk_picture_new_for_filename")
func gtk_picture_new_for_filename(_ filename: UnsafePointer<CChar>) -> GtkWidget?

@_silgen_name("gtk_css_provider_new")
func gtk_css_provider_new() -> GtkCssProvider?

@_silgen_name("gtk_css_provider_load_from_path")
func gtk_css_provider_load_from_path(_ provider: GtkCssProvider?, _ path: UnsafePointer<CChar>) -> gboolean

@_silgen_name("gtk_widget_get_display")
func gtk_widget_get_display(_ widget: GtkWidget?) -> GdkDisplay?

@_silgen_name("gtk_style_context_add_provider_for_display")
func gtk_style_context_add_provider_for_display(_ display: GdkDisplay?, _ provider: GtkCssProvider?, _ priority: UInt32)

@_silgen_name("gtk_layer_init_for_window")
func gtk_layer_init_for_window(_ window: GtkWindow?)

@_silgen_name("gtk_layer_set_layer")
func gtk_layer_set_layer(_ window: GtkWindow?, _ layer: GtkLayerShellLayer)

@_silgen_name("gtk_layer_set_anchor")
func gtk_layer_set_anchor(_ window: GtkWindow?, _ edge: GtkLayerShellEdge, _ anchorToEdge: gboolean)

@_silgen_name("gtk_layer_set_exclusive_zone")
func gtk_layer_set_exclusive_zone(_ window: GtkWindow?, _ exclusiveZone: Int32)

@_silgen_name("gtk_layer_set_keyboard_mode")
func gtk_layer_set_keyboard_mode(_ window: GtkWindow?, _ mode: GtkLayerShellKeyboardMode)

@_silgen_name("gtk_layer_set_namespace")
func gtk_layer_set_namespace(_ window: GtkWindow?, _ nameSpace: UnsafePointer<CChar>)

let aeroConfigDirectory = NSString(string: "~/.config/aero").expandingTildeInPath

private var passwordEntry: GtkWidget?
private var messageLabel: GtkLabel?

func runAndCapture(_ arguments: [String]) -> String? {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: arguments[0])
    process.arguments = Array(arguments.dropFirst())
    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = Pipe()
    do {
        try process.run()
    } catch {
        return nil
    }
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    process.waitUntilExit()
    guard process.terminationStatus == 0 else { return nil }
    return String(data: data, encoding: .utf8)
}

func sha256Hex(of input: String) -> String? {
    for tool in ["/sbin/sha256", "/usr/bin/sha256", "/usr/local/bin/sha256"] {
        if FileManager.default.isExecutableFile(atPath: tool),
           let output = runAndCapture([tool, "-q", "-s", input]) {
            return output.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    return nil
}

struct StoredAccount {
    let username: String
    let salt: String
    let passwordHash: String
}

func loadAccount() -> StoredAccount? {
    let path = "\(aeroConfigDirectory)/aero-account.json"
    guard let data = FileManager.default.contents(atPath: path),
          let object = try? JSONSerialization.jsonObject(with: data) as? [String: String],
          let username = object["username"],
          let salt = object["salt"],
          let hash = object["password_hash"] else { return nil }
    return StoredAccount(username: username, salt: salt, passwordHash: hash)
}

@_cdecl("aero_lock_try_unlock")
func aeroLockTryUnlock(_ entry: OpaquePointer?, _ userData: OpaquePointer?) {
    guard let account = loadAccount() else {
        exit(0)
    }
    guard let pointer = gtk_editable_get_text(passwordEntry) else { return }
    let typed = String(cString: pointer)

    if let hash = sha256Hex(of: account.salt + typed), hash == account.passwordHash {
        _ = runAndCapture(["/usr/local/bin/aero-sound", "unlock"])
        usleep(250_000)
        exit(0)
    }

    "".withCString { gtk_editable_set_text(passwordEntry, $0) }
    "Wrong password — try again".withCString { gtk_label_set_text(messageLabel, $0) }
    let err = Process()
    err.executableURL = URL(fileURLWithPath: "/usr/local/bin/aero-sound")
    err.arguments = ["error"]
    try? err.run()
}

@_cdecl("aero_lock_activate")
func aeroLockActivate(_ app: OpaquePointer?, _ userData: OpaquePointer?) {
    guard let application = app,
          let window = gtk_application_window_new(application) else { exit(1) }

    gtk_layer_init_for_window(window)
    gtk_layer_set_layer(window, .overlay)
    "aero-lock".withCString { gtk_layer_set_namespace(window, $0) }
    gtk_layer_set_anchor(window, .top, 1)
    gtk_layer_set_anchor(window, .bottom, 1)
    gtk_layer_set_anchor(window, .left, 1)
    gtk_layer_set_anchor(window, .right, 1)
    gtk_layer_set_exclusive_zone(window, -1)
    gtk_layer_set_keyboard_mode(window, .exclusive)

    if let provider = gtk_css_provider_new() {
        "/usr/local/share/aero/style.css".withCString {
            _ = gtk_css_provider_load_from_path(provider, $0)
        }
        if let display = gtk_widget_get_display(window) {
            gtk_style_context_add_provider_for_display(display, provider, GTK_STYLE_PROVIDER_PRIORITY_APPLICATION)
        }
    }

    guard let backdrop = gtk_box_new(GTK_ORIENTATION_VERTICAL, 18) else { exit(1) }
    "aero-lock-backdrop".withCString { gtk_widget_set_name(backdrop, $0) }
    gtk_widget_set_hexpand(backdrop, 1)
    gtk_widget_set_vexpand(backdrop, 1)

    guard let card = gtk_box_new(GTK_ORIENTATION_VERTICAL, 14) else { exit(1) }
    "aero-lock-card".withCString { gtk_widget_set_name(card, $0) }
    gtk_widget_set_halign(card, GTK_ALIGN_CENTER)
    gtk_widget_set_valign(card, GTK_ALIGN_CENTER)
    gtk_widget_set_hexpand(card, 1)
    gtk_widget_set_vexpand(card, 1)

    let logoPath = "/usr/local/share/aero/firstboot-logo.png"
    if FileManager.default.fileExists(atPath: logoPath),
       let logo = logoPath.withCString({ gtk_picture_new_for_filename($0) }) {
        gtk_widget_set_size_request(logo, 140, 140)
        gtk_widget_set_halign(logo, GTK_ALIGN_CENTER)
        gtk_box_append(card, logo)
    }

    let username = loadAccount()?.username ?? "Aero user"
    if let nameLabel = username.withCString({ gtk_label_new($0) }) {
        "lock-username".withCString { gtk_widget_add_css_class(nameLabel, $0) }
        gtk_box_append(card, nameLabel)
    }

    if let entry = gtk_entry_new() {
        "lock-password-entry".withCString { gtk_widget_add_css_class(entry, $0) }
        "Password".withCString { gtk_entry_set_placeholder_text(entry, $0) }
        gtk_entry_set_visibility(entry, 0)
        gtk_entry_set_invisible_char(entry, 0x2022)
        gtk_widget_set_size_request(entry, 280, -1)
        gtk_widget_set_halign(entry, GTK_ALIGN_CENTER)
        passwordEntry = entry
        _ = g_signal_connect_data(entry, "activate", aeroLockTryUnlock, nil, nil, 0)
        gtk_box_append(card, entry)
    }

    if let message = "Press Enter to unlock".withCString({ gtk_label_new($0) }) {
        "lock-message".withCString { gtk_widget_add_css_class(message, $0) }
        messageLabel = message
        gtk_box_append(card, message)
    }

    gtk_box_append(backdrop, card)
    gtk_window_set_child(window, backdrop)
    gtk_window_present(window)

    let lockSound = Process()
    lockSound.executableURL = URL(fileURLWithPath: "/usr/local/bin/aero-sound")
    lockSound.arguments = ["lock"]
    try? lockSound.run()
}

guard let application = gtk_application_new("org.aero.Lock", GTK_APPLICATION_FLAGS_NONE) else {
    fputs("Aero Lock: failed to create GTK application.\n", stderr)
    exit(1)
}

_ = g_signal_connect_data(application, "activate", aeroLockActivate, nil, nil, 0)
let status = g_application_run(application, 0, nil)
exit(status)
