import Foundation
import Glibc

typealias GtkWidget = OpaquePointer
typealias GtkApplication = OpaquePointer
typealias GtkWindow = OpaquePointer
typealias GtkBox = OpaquePointer
typealias GtkLabel = OpaquePointer
typealias GtkProgressBar = OpaquePointer
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
let GTK_ALIGN_FILL = GtkAlign(rawValue: 0)
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

@_silgen_name("gtk_window_close")
func gtk_window_close(_ window: GtkWindow?)

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

@_silgen_name("gtk_widget_set_margin_top")
func gtk_widget_set_margin_top(_ widget: GtkWidget?, _ margin: Int32)

@_silgen_name("gtk_box_new")
func gtk_box_new(_ orientation: GtkOrientation, _ spacing: Int32) -> GtkBox?

@_silgen_name("gtk_box_append")
func gtk_box_append(_ box: GtkBox?, _ child: GtkWidget?)

@_silgen_name("gtk_label_new")
func gtk_label_new(_ text: UnsafePointer<CChar>) -> GtkLabel?

@_silgen_name("gtk_label_set_text")
func gtk_label_set_text(_ label: GtkLabel?, _ text: UnsafePointer<CChar>)

@_silgen_name("gtk_picture_new_for_filename")
func gtk_picture_new_for_filename(_ filename: UnsafePointer<CChar>) -> GtkWidget?

@_silgen_name("gtk_progress_bar_new")
func gtk_progress_bar_new() -> GtkProgressBar?

@_silgen_name("gtk_progress_bar_set_fraction")
func gtk_progress_bar_set_fraction(_ bar: GtkProgressBar?, _ fraction: Double)

@_silgen_name("gtk_progress_bar_set_show_text")
func gtk_progress_bar_set_show_text(_ bar: GtkProgressBar?, _ showText: gboolean)

@_silgen_name("gtk_progress_bar_set_text")
func gtk_progress_bar_set_text(_ bar: GtkProgressBar?, _ text: UnsafePointer<CChar>?)

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

@_silgen_name("g_timeout_add")
func g_timeout_add(
    _ interval: UInt32,
    _ function: @convention(c) (UnsafeMutableRawPointer?) -> gboolean,
    _ data: UnsafeMutableRawPointer?
) -> UInt32

let updateProgressPath = "/tmp/aero-update-progress"
let updateDonePath = "/tmp/aero-update-done"
let updateLogoPath = "/usr/local/share/aero/firstboot-logo.png"

private var overlayWindow: GtkWindow?
private var progressBar: GtkProgressBar?
private var statusLabel: GtkLabel?
private var percentLabel: GtkLabel?
private var idlePulse: Double = 0.08

func readProgressFile() -> (fraction: Double, message: String, finished: Bool) {
    if FileManager.default.fileExists(atPath: updateDonePath) {
        return (1.0, "Update complete — restarting desktop…", true)
    }

    guard let contents = try? String(contentsOfFile: updateProgressPath, encoding: .utf8) else {
        return (idlePulse, "Preparing update…", false)
    }

    let lines = contents.components(separatedBy: "\n").map {
        $0.trimmingCharacters(in: .whitespacesAndNewlines)
    }.filter { !$0.isEmpty }

    var percent = 0
    var message = "Updating Aero OS…"
    for line in lines {
        if line.hasPrefix("percent=") {
            percent = Int(line.dropFirst("percent=".count)) ?? percent
        } else if line.hasPrefix("message=") {
            message = String(line.dropFirst("message=".count))
        } else if line == "done" {
            return (1.0, message, true)
        }
    }

    let clamped = max(0, min(100, percent))
    return (Double(clamped) / 100.0, message, clamped >= 100)
}

@_cdecl("aero_update_tick")
func aeroUpdateTick(_ userData: UnsafeMutableRawPointer?) -> gboolean {
    let state = readProgressFile()

    if state.fraction <= 0.05 {
        idlePulse = min(0.12, idlePulse + 0.002)
        gtk_progress_bar_set_fraction(progressBar, idlePulse)
    } else {
        gtk_progress_bar_set_fraction(progressBar, state.fraction)
    }

    let percentText = "\(Int(state.fraction * 100))%"
    percentText.withCString { gtk_label_set_text(percentLabel, $0) }
    state.message.withCString { gtk_label_set_text(statusLabel, $0) }
    percentText.withCString { gtk_progress_bar_set_text(progressBar, $0) }

    if state.finished {
        gtk_progress_bar_set_fraction(progressBar, 1.0)
        "100%".withCString { gtk_label_set_text(percentLabel, $0) }
        // Hold the complete screen briefly so the user sees it finish
        usleep(900_000)
        gtk_window_close(overlayWindow)
        exit(0)
    }

    return 1
}

@_cdecl("aero_update_activate")
func aeroUpdateActivate(_ app: OpaquePointer?, _ userData: OpaquePointer?) {
    guard let application = app,
          let window = gtk_application_window_new(application) else {
        exit(1)
    }
    overlayWindow = window

    gtk_layer_init_for_window(window)
    gtk_layer_set_layer(window, .overlay)
    "aero-update".withCString { gtk_layer_set_namespace(window, $0) }
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

    guard let container = gtk_box_new(GTK_ORIENTATION_VERTICAL, 18) else { exit(1) }
    "aero-update-overlay".withCString { gtk_widget_set_name(container, $0) }
    gtk_widget_set_hexpand(container, 1)
    gtk_widget_set_vexpand(container, 1)
    gtk_widget_set_halign(container, GTK_ALIGN_CENTER)
    gtk_widget_set_valign(container, GTK_ALIGN_CENTER)

    if FileManager.default.fileExists(atPath: updateLogoPath),
       let picture = updateLogoPath.withCString({ gtk_picture_new_for_filename($0) }) {
        gtk_widget_set_size_request(picture, 220, 220)
        gtk_widget_set_halign(picture, GTK_ALIGN_CENTER)
        gtk_box_append(container, picture)
    }

    if let title = "Updating Aero OS".withCString({ gtk_label_new($0) }) {
        "update-title".withCString { gtk_widget_add_css_class(title, $0) }
        gtk_widget_set_halign(title, GTK_ALIGN_CENTER)
        gtk_box_append(container, title)
    }

    if let percent = "0%".withCString({ gtk_label_new($0) }) {
        "update-percent".withCString { gtk_widget_add_css_class(percent, $0) }
        gtk_widget_set_halign(percent, GTK_ALIGN_CENTER)
        percentLabel = percent
        gtk_box_append(container, percent)
    }

    if let bar = gtk_progress_bar_new() {
        "aero-update-bar".withCString { gtk_widget_set_name(bar, $0) }
        gtk_widget_set_size_request(bar, 360, 18)
        gtk_widget_set_halign(bar, GTK_ALIGN_CENTER)
        gtk_progress_bar_set_show_text(bar, 1)
        gtk_progress_bar_set_fraction(bar, 0.05)
        "0%".withCString { gtk_progress_bar_set_text(bar, $0) }
        progressBar = bar
        gtk_box_append(container, bar)
    }

    if let status = "Preparing update…".withCString({ gtk_label_new($0) }) {
        "update-status".withCString { gtk_widget_add_css_class(status, $0) }
        gtk_widget_set_halign(status, GTK_ALIGN_CENTER)
        gtk_widget_set_margin_top(status, 8)
        statusLabel = status
        gtk_box_append(container, status)
    }

    if let hint = "Please keep your computer on. Your files will not be changed.".withCString({ gtk_label_new($0) }) {
        "update-hint".withCString { gtk_widget_add_css_class(hint, $0) }
        gtk_widget_set_halign(hint, GTK_ALIGN_CENTER)
        gtk_box_append(container, hint)
    }

    gtk_window_set_child(window, container)
    gtk_window_present(window)

    _ = g_timeout_add(120, aeroUpdateTick, nil)
}

try? "percent=0\nmessage=Preparing update…\n".write(
    toFile: updateProgressPath,
    atomically: true,
    encoding: .utf8
)
try? FileManager.default.removeItem(atPath: updateDonePath)

guard let application = gtk_application_new("org.aero.UpdateUI", GTK_APPLICATION_FLAGS_NONE) else {
    fputs("Aero Update UI: failed to create GTK application.\n", stderr)
    exit(1)
}

_ = g_signal_connect_data(application, "activate", aeroUpdateActivate, nil, nil, 0)
let status = g_application_run(application, 0, nil)
exit(status)
