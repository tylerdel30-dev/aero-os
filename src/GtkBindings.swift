import Foundation
import Glibc

typealias GtkWidget = OpaquePointer
typealias GtkApplication = OpaquePointer
typealias GtkWindow = OpaquePointer
typealias GtkBox = OpaquePointer
typealias GtkButton = OpaquePointer
typealias GtkLabel = OpaquePointer
typealias GtkCssProvider = OpaquePointer
typealias GtkStack = OpaquePointer
typealias GtkProgressBar = OpaquePointer
typealias GtkScrolledWindow = OpaquePointer
typealias GdkDisplay = OpaquePointer
typealias GApplication = OpaquePointer

let GTK_APPLICATION_FLAGS_NONE: GApplicationFlags = GApplicationFlags(rawValue: 0)
let GTK_ORIENTATION_HORIZONTAL: GtkOrientation = GtkOrientation(rawValue: 0)
let GTK_ORIENTATION_VERTICAL: GtkOrientation = GtkOrientation(rawValue: 1)
let GTK_ALIGN_CENTER: GtkAlign = GtkAlign(rawValue: 3)
let GTK_ALIGN_END: GtkAlign = GtkAlign(rawValue: 2)
let GTK_ALIGN_START: GtkAlign = GtkAlign(rawValue: 1)
let GTK_ALIGN_FILL: GtkAlign = GtkAlign(rawValue: 4)
let GTK_STYLE_PROVIDER_PRIORITY_APPLICATION: Int32 = 600
let G_SPAWN_SEARCH_PATH: GSpawnFlags = GSpawnFlags(rawValue: 1 << 1)

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

typealias Gpid = Int32
typealias gboolean = Int32
typealias guint = UInt32

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

@_silgen_name("gtk_init")
func gtk_init()

@_silgen_name("gtk_application_new")
func gtk_application_new(_ applicationID: UnsafePointer<CChar>, _ flags: GApplicationFlags) -> GtkApplication?

@_silgen_name("g_signal_connect_data")
func g_signal_connect_data(
    _ instance: OpaquePointer?,
    _ detailedSignal: UnsafePointer<CChar>,
    _ handler: @convention(c) (OpaquePointer?, OpaquePointer?, OpaquePointer?) -> Void,
    _ data: UnsafeMutableRawPointer?,
    _ destroyData: OpaquePointer?,
    _ connectFlags: Int32
) -> UInt64

@_silgen_name("g_application_run")
func g_application_run(_ application: GApplication?, _ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32

@_silgen_name("gtk_application_window_new")
func gtk_application_window_new(_ application: GtkApplication?) -> GtkWindow?

@_silgen_name("gtk_window_set_title")
func gtk_window_set_title(_ window: GtkWindow?, _ title: UnsafePointer<CChar>)

@_silgen_name("gtk_window_set_default_size")
func gtk_window_set_default_size(_ window: GtkWindow?, _ width: Int32, _ height: Int32)

@_silgen_name("gtk_window_present")
func gtk_window_present(_ window: GtkWindow?)

@_silgen_name("gtk_widget_set_name")
func gtk_widget_set_name(_ widget: GtkWidget?, _ name: UnsafePointer<CChar>)

@_silgen_name("gtk_widget_add_css_class")
func gtk_widget_add_css_class(_ widget: GtkWidget?, _ cssClass: UnsafePointer<CChar>)

@_silgen_name("gtk_widget_remove_css_class")
func gtk_widget_remove_css_class(_ widget: GtkWidget?, _ cssClass: UnsafePointer<CChar>)

@_silgen_name("gtk_widget_set_hexpand")
func gtk_widget_set_hexpand(_ widget: GtkWidget?, _ expand: gboolean)

@_silgen_name("gtk_widget_set_vexpand")
func gtk_widget_set_vexpand(_ widget: GtkWidget?, _ expand: gboolean)

@_silgen_name("gtk_widget_set_halign")
func gtk_widget_set_halign(_ widget: GtkWidget?, _ align: GtkAlign)

@_silgen_name("gtk_widget_set_valign")
func gtk_widget_set_valign(_ widget: GtkWidget?, _ align: GtkAlign)

@_silgen_name("gtk_widget_set_margin_top")
func gtk_widget_set_margin_top(_ widget: GtkWidget?, _ margin: Int32)

@_silgen_name("gtk_widget_set_margin_bottom")
func gtk_widget_set_margin_bottom(_ widget: GtkWidget?, _ margin: Int32)

@_silgen_name("gtk_widget_set_margin_start")
func gtk_widget_set_margin_start(_ widget: GtkWidget?, _ margin: Int32)

@_silgen_name("gtk_widget_set_margin_end")
func gtk_widget_set_margin_end(_ widget: GtkWidget?, _ margin: Int32)

@_silgen_name("gtk_box_new")
func gtk_box_new(_ orientation: GtkOrientation, _ spacing: Int32) -> GtkBox?

@_silgen_name("gtk_box_append")
func gtk_box_append(_ box: GtkBox?, _ child: GtkWidget?)

@_silgen_name("gtk_button_new_with_label")
func gtk_button_new_with_label(_ label: UnsafePointer<CChar>) -> GtkButton?

@_silgen_name("gtk_label_new")
func gtk_label_new(_ text: UnsafePointer<CChar>) -> GtkLabel?

@_silgen_name("gtk_label_set_text")
func gtk_label_set_text(_ label: GtkLabel?, _ text: UnsafePointer<CChar>)

@_silgen_name("gtk_label_set_xalign")
func gtk_label_set_xalign(_ label: GtkLabel?, _ xalign: Float)

@_silgen_name("gtk_window_set_child")
func gtk_window_set_child(_ window: GtkWindow?, _ child: GtkWidget?)

@_silgen_name("gtk_css_provider_new")
func gtk_css_provider_new() -> GtkCssProvider?

@_silgen_name("gtk_css_provider_load_from_path")
func gtk_css_provider_load_from_path(_ provider: GtkCssProvider?, _ path: UnsafePointer<CChar>) -> gboolean

@_silgen_name("gtk_widget_get_display")
func gtk_widget_get_display(_ widget: GtkWidget?) -> GdkDisplay?

@_silgen_name("gtk_style_context_add_provider_for_display")
func gtk_style_context_add_provider_for_display(
    _ display: GdkDisplay?,
    _ provider: GtkCssProvider?,
    _ priority: UInt32
)

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
) -> guint

@_silgen_name("g_spawn_async")
func g_spawn_async(
    _ workingDirectory: UnsafePointer<CChar>?,
    _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?,
    _ envp: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?,
    _ flags: GSpawnFlags,
    _ childSetup: OpaquePointer?,
    _ userData: UnsafeMutableRawPointer?,
    _ childPid: UnsafeMutablePointer<Gpid>?,
    _ error: UnsafeMutablePointer<OpaquePointer?>?
) -> gboolean

@_silgen_name("gtk_stack_new")
func gtk_stack_new() -> GtkStack?

@_silgen_name("gtk_stack_add_named")
func gtk_stack_add_named(_ stack: GtkStack?, _ child: GtkWidget?, _ name: UnsafePointer<CChar>)

@_silgen_name("gtk_stack_set_visible_child_name")
func gtk_stack_set_visible_child_name(_ stack: GtkStack?, _ name: UnsafePointer<CChar>)

@_silgen_name("gtk_progress_bar_new")
func gtk_progress_bar_new() -> GtkProgressBar?

@_silgen_name("gtk_progress_bar_set_fraction")
func gtk_progress_bar_set_fraction(_ progress: GtkProgressBar?, _ fraction: Double)

@_silgen_name("gtk_progress_bar_set_text")
func gtk_progress_bar_set_text(_ progress: GtkProgressBar?, _ text: UnsafePointer<CChar>)

@_silgen_name("gtk_progress_bar_set_show_text")
func gtk_progress_bar_set_show_text(_ progress: GtkProgressBar?, _ showText: gboolean)

@_silgen_name("gtk_scrolled_window_new")
func gtk_scrolled_window_new() -> GtkScrolledWindow?

@_silgen_name("gtk_scrolled_window_set_child")
func gtk_scrolled_window_set_child(_ scrolled: GtkScrolledWindow?, _ child: GtkWidget?)

@_silgen_name("gtk_separator_new")
func gtk_separator_new(_ orientation: GtkOrientation) -> GtkWidget?

func connectClicked(_ widget: OpaquePointer?, handler: @convention(c) (OpaquePointer?, OpaquePointer?) -> Void) {
    _ = g_signal_connect_data(widget, "clicked", handler, nil, nil, 0)
}

func loadStylesheet(path: String, for widget: GtkWidget?) {
    guard FileManager.default.fileExists(atPath: path) else { return }
    guard let provider = gtk_css_provider_new() else { return }
    path.withCString { cPath in
        _ = gtk_css_provider_load_from_path(provider, cPath)
    }
    if let display = gtk_widget_get_display(widget) {
        gtk_style_context_add_provider_for_display(
            display,
            provider,
            UInt32(GTK_STYLE_PROVIDER_PRIORITY_APPLICATION)
        )
    }
}

func launchExecutable(_ path: String, arguments: [String] = []) {
    var argv: [UnsafeMutablePointer<CChar>?] = []
    path.withCString { cPath in
        argv.append(strdup(cPath))
    }
    for argument in arguments {
        argument.withCString { cArg in
            argv.append(strdup(cArg))
        }
    }
    argv.append(nil)

    argv.withUnsafeMutableBufferPointer { buffer in
        var pid = Gpid(0)
        _ = g_spawn_async(nil, buffer.baseAddress!, nil, G_SPAWN_SEARCH_PATH, nil, nil, &pid, nil)
    }

    for index in 0..<(argv.count - 1) {
        if let pointer = argv[index] {
            free(pointer)
        }
    }
}

func setLabelText(_ label: GtkLabel?, _ text: String) {
    text.withCString { gtk_label_set_text(label, $0) }
}

func makeButton(_ label: String, cssClasses: [String], handler: @convention(c) (OpaquePointer?, OpaquePointer?) -> Void) -> GtkButton? {
    guard let button = label.withCString({ gtk_button_new_with_label($0) }) else { return nil }
    for cssClass in cssClasses {
        cssClass.withCString { gtk_widget_add_css_class(button, $0) }
    }
    connectClicked(button, handler: handler)
    return button
}
