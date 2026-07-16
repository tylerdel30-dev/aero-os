import Foundation
import Glibc

typealias GtkWidget = OpaquePointer
typealias GtkApplication = OpaquePointer
typealias GtkWindow = OpaquePointer
typealias GtkBox = OpaquePointer
typealias GtkCssProvider = OpaquePointer
typealias GdkDisplay = OpaquePointer
typealias GApplication = OpaquePointer
typealias gboolean = Int32
typealias Gpid = Int32

struct GApplicationFlags: OptionSet {
    let rawValue: UInt32
}

struct GtkOrientation: RawRepresentable {
    let rawValue: Int32
}

struct GtkAlign: RawRepresentable {
    let rawValue: Int32
}

struct GSpawnFlags: OptionSet {
    let rawValue: UInt32
}

let GTK_APPLICATION_FLAGS_NONE = GApplicationFlags(rawValue: 0)
let GTK_ORIENTATION_VERTICAL = GtkOrientation(rawValue: 1)
let GTK_ALIGN_CENTER = GtkAlign(rawValue: 3)
let GTK_STYLE_PROVIDER_PRIORITY_APPLICATION: UInt32 = 600
let G_SPAWN_SEARCH_PATH = GSpawnFlags(rawValue: 1 << 1)

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

@_silgen_name("gtk_window_close")
func gtk_window_close(_ window: GtkWindow?)

@_silgen_name("gtk_widget_set_name")
func gtk_widget_set_name(_ widget: GtkWidget?, _ name: UnsafePointer<CChar>)

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

@_silgen_name("gtk_widget_set_opacity")
func gtk_widget_set_opacity(_ widget: GtkWidget?, _ opacity: Double)

@_silgen_name("gtk_box_new")
func gtk_box_new(_ orientation: GtkOrientation, _ spacing: Int32) -> GtkBox?

@_silgen_name("gtk_box_append")
func gtk_box_append(_ box: GtkBox?, _ child: GtkWidget?)

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

@_silgen_name("gtk_layer_set_namespace")
func gtk_layer_set_namespace(_ window: GtkWindow?, _ nameSpace: UnsafePointer<CChar>)

@_silgen_name("g_timeout_add")
func g_timeout_add(
    _ interval: UInt32,
    _ function: @convention(c) (UnsafeMutableRawPointer?) -> gboolean,
    _ data: UnsafeMutableRawPointer?
) -> UInt32

@_silgen_name("g_spawn_async")
func g_spawn_async(
    _ workingDirectory: UnsafePointer<CChar>?,
    _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>,
    _ envp: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?,
    _ flags: GSpawnFlags,
    _ childSetup: OpaquePointer?,
    _ userData: UnsafeMutableRawPointer?,
    _ childPid: UnsafeMutablePointer<Gpid>?,
    _ error: UnsafeMutablePointer<OpaquePointer?>?
) -> gboolean

let firstBootMarkerPath = "/var/db/aero-firstboot-done"
let firstBootLogoPath = "/usr/local/share/aero/firstboot-logo.png"
let setupExecutablePath = "/usr/local/sbin/aero-install"

let logoStartSize: Double = 420
let logoEndSize: Double = 48
let holdFrames = 55        // ~0.9s at 16ms per frame
let shrinkFrames = 80      // ~1.3s at 16ms per frame

private var overlayWindow: GtkWindow?
private var logoPicture: GtkWidget?
private var frameCounter = 0

func easeInOutCubic(_ t: Double) -> Double {
    if t < 0.5 {
        return 4 * t * t * t
    }
    let f = -2 * t + 2
    return 1 - (f * f * f) / 2
}

func launchSetup() {
    var argv: [UnsafeMutablePointer<CChar>?] = [strdup(setupExecutablePath), nil]
    argv.withUnsafeMutableBufferPointer { buffer in
        var pid = Gpid(0)
        _ = g_spawn_async(nil, buffer.baseAddress!, nil, G_SPAWN_SEARCH_PATH, nil, nil, &pid, nil)
    }
    if let pointer = argv[0] {
        free(pointer)
    }
}

func playAeroSound(_ event: String) {
    var argv: [UnsafeMutablePointer<CChar>?] = [
        strdup("/usr/local/bin/aero-sound"),
        strdup(event),
        nil
    ]
    argv.withUnsafeMutableBufferPointer { buffer in
        var pid = Gpid(0)
        _ = g_spawn_async(nil, buffer.baseAddress!, nil, G_SPAWN_SEARCH_PATH, nil, nil, &pid, nil)
    }
    for pointer in argv where pointer != nil {
        free(pointer)
    }
}

func writeFirstBootMarker() {
    let contents = "Aero OS first boot completed \(ISO8601DateFormatter().string(from: Date()))\n"
    try? contents.write(toFile: firstBootMarkerPath, atomically: true, encoding: .utf8)
}

@_cdecl("aero_firstboot_frame")
func aeroFirstBootFrame(_ userData: UnsafeMutableRawPointer?) -> gboolean {
    frameCounter += 1

    if frameCounter <= holdFrames {
        return 1
    }

    let shrinkProgress = Double(frameCounter - holdFrames) / Double(shrinkFrames)
    if shrinkProgress >= 1.0 {
        writeFirstBootMarker()
        launchSetup()
        gtk_window_close(overlayWindow)
        exit(0)
    }

    let eased = easeInOutCubic(shrinkProgress)
    let size = logoStartSize + (logoEndSize - logoStartSize) * eased
    gtk_widget_set_size_request(logoPicture, Int32(size), Int32(size))
    gtk_widget_set_opacity(overlayWindow, 1.0 - eased)
    return 1
}

@_cdecl("aero_firstboot_activate")
func aeroFirstBootActivate(_ app: OpaquePointer?, _ userData: OpaquePointer?) {
    guard let application = app,
          let window = gtk_application_window_new(application) else {
        exit(1)
    }
    overlayWindow = window

    gtk_layer_init_for_window(window)
    gtk_layer_set_layer(window, .overlay)
    "aero-firstboot".withCString { gtk_layer_set_namespace(window, $0) }
    gtk_layer_set_anchor(window, .top, 1)
    gtk_layer_set_anchor(window, .bottom, 1)
    gtk_layer_set_anchor(window, .left, 1)
    gtk_layer_set_anchor(window, .right, 1)
    gtk_layer_set_exclusive_zone(window, -1)

    if let provider = gtk_css_provider_new() {
        "/usr/local/share/aero/style.css".withCString {
            _ = gtk_css_provider_load_from_path(provider, $0)
        }
        if let display = gtk_widget_get_display(window) {
            gtk_style_context_add_provider_for_display(display, provider, GTK_STYLE_PROVIDER_PRIORITY_APPLICATION)
        }
    }

    guard let container = gtk_box_new(GTK_ORIENTATION_VERTICAL, 0) else {
        exit(1)
    }
    "aero-firstboot-overlay".withCString { gtk_widget_set_name(container, $0) }
    gtk_widget_set_hexpand(container, 1)
    gtk_widget_set_vexpand(container, 1)

    guard let picture = firstBootLogoPath.withCString({ gtk_picture_new_for_filename($0) }) else {
        writeFirstBootMarker()
        launchSetup()
        exit(0)
    }
    logoPicture = picture
    gtk_widget_set_size_request(picture, Int32(logoStartSize), Int32(logoStartSize))
    gtk_widget_set_halign(picture, GTK_ALIGN_CENTER)
    gtk_widget_set_valign(picture, GTK_ALIGN_CENTER)
    gtk_widget_set_hexpand(picture, 1)
    gtk_widget_set_vexpand(picture, 1)
    gtk_box_append(container, picture)

    gtk_window_set_child(window, container)
    gtk_window_present(window)
    playAeroSound("startup")

    _ = g_timeout_add(16, aeroFirstBootFrame, nil)
}

if FileManager.default.fileExists(atPath: firstBootMarkerPath) {
    exit(0)
}

guard let application = gtk_application_new("org.aero.FirstBoot", GTK_APPLICATION_FLAGS_NONE) else {
    fputs("Aero FirstBoot: failed to create GTK application.\n", stderr)
    exit(1)
}

_ = g_signal_connect_data(application, "activate", aeroFirstBootActivate, nil, nil, 0)
let status = g_application_run(application, 0, nil)
exit(status)
