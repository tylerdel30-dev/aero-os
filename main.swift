import Foundation
import Glibc

typealias GtkWidget = OpaquePointer
typealias GtkApplication = OpaquePointer
typealias GtkWindow = OpaquePointer
typealias GtkBox = OpaquePointer
typealias GtkButton = OpaquePointer
typealias GtkLabel = OpaquePointer
typealias GtkCssProvider = OpaquePointer
typealias GdkDisplay = OpaquePointer
typealias GApplication = OpaquePointer

let GTK_APPLICATION_FLAGS_NONE: GApplicationFlags = GApplicationFlags(rawValue: 0)
let GTK_ORIENTATION_HORIZONTAL: GtkOrientation = GtkOrientation(rawValue: 0)
let GTK_ORIENTATION_VERTICAL: GtkOrientation = GtkOrientation(rawValue: 1)
let GTK_ALIGN_FILL: GtkAlign = GtkAlign(rawValue: 0)
let GTK_ALIGN_START: GtkAlign = GtkAlign(rawValue: 1)
let GTK_ALIGN_END: GtkAlign = GtkAlign(rawValue: 2)
let GTK_ALIGN_CENTER: GtkAlign = GtkAlign(rawValue: 3)
let GTK_STYLE_PROVIDER_PRIORITY_APPLICATION: Int32 = 600
let G_SOURCE_REMOVE: Int32 = 0
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
    _ handler: @convention(c) (OpaquePointer?, OpaquePointer?) -> Void,
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

@_silgen_name("gtk_button_new")
func gtk_button_new() -> GtkButton?

@_silgen_name("gtk_button_set_child")
func gtk_button_set_child(_ button: GtkButton?, _ child: GtkWidget?)

@_silgen_name("gtk_picture_new_for_filename")
func gtk_picture_new_for_filename(_ filename: UnsafePointer<CChar>) -> GtkWidget?

@_silgen_name("gtk_widget_set_size_request")
func gtk_widget_set_size_request(_ widget: GtkWidget?, _ width: Int32, _ height: Int32)

@_silgen_name("gtk_popover_new")
func gtk_popover_new() -> GtkWidget?

@_silgen_name("gtk_popover_set_child")
func gtk_popover_set_child(_ popover: GtkWidget?, _ child: GtkWidget?)

@_silgen_name("gtk_popover_popup")
func gtk_popover_popup(_ popover: GtkWidget?)

@_silgen_name("gtk_popover_popdown")
func gtk_popover_popdown(_ popover: GtkWidget?)

@_silgen_name("gtk_popover_set_has_arrow")
func gtk_popover_set_has_arrow(_ popover: GtkWidget?, _ hasArrow: gboolean)

@_silgen_name("gtk_popover_set_position")
func gtk_popover_set_position(_ popover: GtkWidget?, _ position: Int32)

@_silgen_name("gtk_widget_set_parent")
func gtk_widget_set_parent(_ widget: GtkWidget?, _ parent: GtkWidget?)

@_silgen_name("gtk_box_remove")
func gtk_box_remove(_ box: GtkBox?, _ child: GtkWidget?)

@_silgen_name("gtk_window_new")
func gtk_window_new() -> GtkWindow?

@_silgen_name("gtk_window_destroy")
func gtk_window_destroy(_ window: GtkWindow?)

@_silgen_name("gtk_layer_set_margin")
func gtk_layer_set_margin(_ window: GtkWindow?, _ edge: GtkLayerShellEdge, _ margin: Int32)

@_silgen_name("gtk_widget_set_visible")
func gtk_widget_set_visible(_ widget: GtkWidget?, _ visible: gboolean)

@_silgen_name("gtk_entry_new")
func gtk_entry_new() -> GtkWidget?

@_silgen_name("gtk_entry_set_placeholder_text")
func gtk_entry_set_placeholder_text(_ entry: GtkWidget?, _ text: UnsafePointer<CChar>)

@_silgen_name("gtk_editable_get_text")
func gtk_editable_get_text(_ editable: GtkWidget?) -> UnsafePointer<CChar>?

let GTK_POS_BOTTOM: Int32 = 3

@_silgen_name("gtk_label_new")
func gtk_label_new(_ text: UnsafePointer<CChar>) -> GtkLabel?

@_silgen_name("gtk_label_set_text")
func gtk_label_set_text(_ label: GtkLabel?, _ text: UnsafePointer<CChar>)

@_silgen_name("gtk_label_set_wrap")
func gtk_label_set_wrap(_ label: GtkLabel?, _ wrap: gboolean)

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
    _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>,
    _ envp: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?,
    _ flags: GSpawnFlags,
    _ childSetup: OpaquePointer?,
    _ userData: UnsafeMutableRawPointer?,
    _ childPid: UnsafeMutablePointer<Gpid>?,
    _ error: UnsafeMutablePointer<OpaquePointer?>?
) -> gboolean

final class ClockContext {
    let label: GtkLabel
    let formatter: DateFormatter

    init(label: GtkLabel) {
        self.label = label
        self.formatter = DateFormatter()
        self.formatter.locale = Locale(identifier: "en_US_POSIX")
        self.formatter.dateFormat = "EEE  MMM d   h:mm:ss a"
    }
}

private var globalClockContext: Unmanaged<ClockContext>?
private var globalCanvas: GtkWidget?
private var currentAppearance = ""

let appearanceModes = ["light", "dark", "night"]

func readAppearancePreference() -> String {
    let configPath = NSString(string: "~/.config/aero/display.conf").expandingTildeInPath
    guard let contents = try? String(contentsOfFile: configPath, encoding: .utf8) else {
        return "dark"
    }
    for line in contents.components(separatedBy: "\n") {
        if line.hasPrefix("appearance=") {
            let value = String(line.dropFirst("appearance=".count))
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if appearanceModes.contains(value) {
                return value
            }
        }
    }
    return "dark"
}

func applyAppearance(_ mode: String) {
    guard mode != currentAppearance, let canvas = globalCanvas else { return }
    for known in appearanceModes {
        "wallpaper-\(known)".withCString { gtk_widget_remove_css_class(canvas, $0) }
    }
    "wallpaper-\(mode)".withCString { gtk_widget_add_css_class(canvas, $0) }
    currentAppearance = mode
}

@_cdecl("aero_appearance_tick")
func aeroAppearanceTick(_ userData: UnsafeMutableRawPointer?) -> Int32 {
    applyAppearance(readAppearancePreference())
    return 1
}

@_cdecl("aero_clock_tick")
func aeroClockTick(_ userData: UnsafeMutableRawPointer?) -> Int32 {
    guard let userData = userData else { return 1 }
    let context = Unmanaged<ClockContext>.fromOpaque(userData).takeUnretainedValue()
    let now = Date()
    let formatted = context.formatter.string(from: now)
    formatted.withCString { cString in
        gtk_label_set_text(context.label, cString)
    }
    return 1
}

func loadAeroStylesheet(for widget: GtkWidget?) {
    let cssPath = "/usr/local/share/aero/style.css"
    guard FileManager.default.fileExists(atPath: cssPath) else { return }
    guard let provider = gtk_css_provider_new() else { return }
    cssPath.withCString { path in
        _ = gtk_css_provider_load_from_path(provider, path)
    }
    if let display = gtk_widget_get_display(widget) {
        gtk_style_context_add_provider_for_display(
            display,
            provider,
            UInt32(GTK_STYLE_PROVIDER_PRIORITY_APPLICATION)
        )
    }
}

struct RunningApp {
    let pid: Gpid
    let name: String
    let title: String
    let focusToken: String
}

func playAeroSound(_ event: String) {
    launchExecutable("/usr/local/bin/aero-sound", arguments: [event])
}

var runningApps: [RunningApp] = []

func focusWaylandToplevel(_ token: String) {
    guard !token.isEmpty else { return }
    if FileManager.default.isExecutableFile(atPath: "/usr/local/bin/wlrctl") {
        launchExecutable("/usr/local/bin/wlrctl", arguments: ["toplevel", "focus", "address:\(token)"])
    }
}

func refreshRunningAppsFromCompositor() {
    // Merge PID-tracked launches with live foreign-toplevel list from aero-windows
    var live: [RunningApp] = []
    if let output = runAndCapture(["/usr/local/bin/aero-windows"]), !output.isEmpty {
        for line in output.split(separator: "\n") {
            let parts = line.split(separator: "|", omittingEmptySubsequences: false).map(String.init)
            guard parts.count >= 2 else { continue }
            let appId = parts[0]
            let title = parts[1]
            let token = parts.count > 2 ? parts[2] : ""
            let short = (appId as NSString).lastPathComponent
            live.append(RunningApp(pid: 0, name: short.isEmpty ? appId : short, title: title, focusToken: token))
        }
    }
    // Keep PID-tracked apps that are still alive and not already listed
    let stillAlive = runningApps.filter { $0.pid > 0 && kill($0.pid, 0) == 0 }
    var merged = live
    for app in stillAlive {
        if !merged.contains(where: { $0.name == app.name }) {
            merged.append(app)
        }
    }
    runningApps = merged
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
        let launched = g_spawn_async(
            nil,
            buffer.baseAddress!,
            nil,
            G_SPAWN_SEARCH_PATH,
            nil,
            nil,
            &pid,
            nil
        )
        if launched != 0 && pid > 0 {
            let appName = (path as NSString).lastPathComponent
            runningApps.append(RunningApp(pid: pid, name: appName, title: appName, focusToken: ""))
        }
    }

    for index in 0..<(argv.count - 1) {
        if let pointer = argv[index] {
            free(pointer)
        }
    }
}

@_cdecl("aero_on_setup_clicked")
func aeroOnSetupClicked(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    launchExecutable("/usr/local/sbin/aero-install")
}

@_cdecl("aero_on_terminal_clicked")
func aeroOnTerminalClicked(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    launchExecutable("/usr/local/bin/foot")
}

@_cdecl("aero_on_files_clicked")
func aeroOnFilesClicked(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    launchExecutable("/usr/local/bin/thunar")
}

@_cdecl("aero_on_settings_clicked")
func aeroOnSettingsClicked(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    launchExecutable("/usr/local/bin/aero-settings")
}

@_cdecl("aero_on_store_clicked")
func aeroOnStoreClicked(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    launchExecutable("/usr/local/bin/aero-store")
}

// MARK: - Start menu

private var globalStartMenu: GtkWidget?

func startMenuLaunch(_ path: String, arguments: [String] = []) {
    gtk_popover_popdown(globalStartMenu)
    playAeroSound("click")
    launchExecutable(path, arguments: arguments)
}

@_cdecl("aero_on_start_clicked")
func aeroOnStartClicked(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    playAeroSound("click")
    gtk_popover_popup(globalStartMenu)
}

@_cdecl("aero_menu_terminal")
func aeroMenuTerminal(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    startMenuLaunch("/usr/local/bin/foot")
}

@_cdecl("aero_menu_files")
func aeroMenuFiles(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    startMenuLaunch("/usr/local/bin/thunar")
}

@_cdecl("aero_menu_browser")
func aeroMenuBrowser(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    startMenuLaunch("/usr/local/bin/firefox")
}

@_cdecl("aero_menu_settings")
func aeroMenuSettings(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    startMenuLaunch("/usr/local/bin/aero-settings")
}

@_cdecl("aero_menu_store")
func aeroMenuStore(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    startMenuLaunch("/usr/local/bin/aero-store")
}

@_cdecl("aero_menu_setup")
func aeroMenuSetup(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    startMenuLaunch("/usr/local/sbin/aero-install")
}

@_cdecl("aero_menu_restart")
func aeroMenuRestart(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    gtk_popover_popdown(globalStartMenu)
    playAeroSound("shutdown")
    usleep(900_000)
    launchExecutable("/sbin/shutdown", arguments: ["-r", "now"])
}

@_cdecl("aero_menu_shutdown")
func aeroMenuShutdown(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    gtk_popover_popdown(globalStartMenu)
    playAeroSound("shutdown")
    usleep(900_000)
    launchExecutable("/sbin/shutdown", arguments: ["-p", "now"])
}

func makeStartMenuItem(_ title: String, handler: @convention(c) (OpaquePointer?, OpaquePointer?) -> Void) -> GtkButton? {
    guard let button = title.withCString({ gtk_button_new_with_label($0) }) else { return nil }
    "start-menu-item".withCString { gtk_widget_add_css_class(button, $0) }
    gtk_widget_set_halign(button, GTK_ALIGN_FILL)
    _ = g_signal_connect_data(button, "clicked", handler, nil, nil, 0)
    return button
}

// MARK: - Start menu search

private var searchableMenuItems: [(widget: GtkWidget, title: String)] = []
private var startMenuSearchEntry: GtkWidget?

@_cdecl("aero_start_search_changed")
func aeroStartSearchChanged(_ editable: OpaquePointer?, _ userData: OpaquePointer?) {
    var query = ""
    if let pointer = gtk_editable_get_text(startMenuSearchEntry) {
        query = String(cString: pointer).lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    for item in searchableMenuItems {
        let visible: gboolean = query.isEmpty || item.title.lowercased().contains(query) ? 1 : 0
        gtk_widget_set_visible(item.widget, visible)
    }
}

func appendSearchableItem(_ box: GtkBox?, _ title: String, handler: @convention(c) (OpaquePointer?, OpaquePointer?) -> Void) {
    guard let item = makeStartMenuItem(title, handler: handler) else { return }
    gtk_box_append(box, item)
    searchableMenuItems.append((widget: item, title: title))
}

func buildStartMenu(attachedTo anchor: GtkWidget?) {
    guard let popover = gtk_popover_new() else { return }
    "aero-start-menu".withCString { gtk_widget_set_name(popover, $0) }
    gtk_popover_set_has_arrow(popover, 0)
    gtk_popover_set_position(popover, GTK_POS_BOTTOM)
    gtk_widget_set_parent(popover, anchor)

    guard let menuBox = gtk_box_new(GTK_ORIENTATION_VERTICAL, 4) else { return }
    "start-menu-box".withCString { gtk_widget_add_css_class(menuBox, $0) }
    gtk_widget_set_size_request(menuBox, 260, -1)

    if let heading = "Aero OS".withCString({ gtk_label_new($0) }) {
        "start-menu-heading".withCString { gtk_widget_add_css_class(heading, $0) }
        gtk_box_append(menuBox, heading)
    }

    if let searchEntry = gtk_entry_new() {
        "start-menu-search".withCString { gtk_widget_add_css_class(searchEntry, $0) }
        "🔍 Search apps…".withCString { gtk_entry_set_placeholder_text(searchEntry, $0) }
        startMenuSearchEntry = searchEntry
        _ = g_signal_connect_data(searchEntry, "changed", aeroStartSearchChanged, nil, nil, 0)
        gtk_box_append(menuBox, searchEntry)
    }

    appendSearchableItem(menuBox, "💻  Terminal", handler: aeroMenuTerminal)
    appendSearchableItem(menuBox, "📂  Files", handler: aeroMenuFiles)
    appendSearchableItem(menuBox, "🌐  Web Browser", handler: aeroMenuBrowser)
    appendSearchableItem(menuBox, "🛒  App Store", handler: aeroMenuStore)
    appendSearchableItem(menuBox, "⚙️  Settings", handler: aeroMenuSettings)
    appendSearchableItem(menuBox, "💾  Setup Aero OS", handler: aeroMenuSetup)

    if let divider = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 0) {
        "start-menu-divider".withCString { gtk_widget_add_css_class(divider, $0) }
        gtk_widget_set_size_request(divider, -1, 1)
        gtk_box_append(menuBox, divider)
    }

    gtk_box_append(menuBox, makeStartMenuItem("🔒  Lock", handler: aeroLockScreen))
    gtk_box_append(menuBox, makeStartMenuItem("🔄  Restart", handler: aeroMenuRestart))
    gtk_box_append(menuBox, makeStartMenuItem("⏻  Shut Down", handler: aeroMenuShutdown))

    gtk_popover_set_child(popover, menuBox)
    globalStartMenu = popover
}

// MARK: - Taskbar (running app chips)

private var taskbarBox: GtkBox?
private var taskbarChips: [GtkWidget] = []

func appDisplayName(_ app: RunningApp) -> String {
    let base: String
    switch app.name {
    case "foot": base = "Terminal"
    case "thunar": base = "Files"
    case "firefox": base = "Browser"
    case "aero-settings": base = "Settings"
    case "aero-store": base = "Store"
    case "aero-install": base = "Setup"
    default: base = app.name
    }
    if !app.title.isEmpty && app.title != app.name {
        let shortTitle = app.title.count > 24 ? String(app.title.prefix(21)) + "…" : app.title
        return "\(base) — \(shortTitle)"
    }
    return base
}

private var taskbarFocusTokens: [UnsafeMutablePointer<CChar>?] = []

@_cdecl("aero_taskbar_focus")
func aeroTaskbarFocus(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    guard let userData = userData else { return }
    let token = String(cString: UnsafePointer<CChar>(userData))
    focusWaylandToplevel(token)
    playAeroSound("click")
}

@_cdecl("aero_taskbar_tick")
func aeroTaskbarTick(_ userData: UnsafeMutableRawPointer?) -> Int32 {
    refreshRunningAppsFromCompositor()

    guard let bar = taskbarBox else { return 1 }
    for chip in taskbarChips {
        gtk_box_remove(bar, chip)
    }
    taskbarChips.removeAll()
    for pointer in taskbarFocusTokens where pointer != nil {
        free(pointer)
    }
    taskbarFocusTokens.removeAll()

    for app in runningApps {
        let label = appDisplayName(app)
        guard let chip = label.withCString({ gtk_button_new_with_label($0) }) else { continue }
        "taskbar-chip".withCString { gtk_widget_add_css_class(chip, $0) }
        let tokenCopy = strdup(app.focusToken)
        taskbarFocusTokens.append(tokenCopy)
        _ = g_signal_connect_data(chip, "clicked", aeroTaskbarFocus, UnsafeMutableRawPointer(tokenCopy), nil, 0)
        gtk_box_append(bar, chip)
        taskbarChips.append(chip)
    }
    return 1
}

// MARK: - Status area (Wi-Fi, volume, battery) and quick settings

private var batteryLabel: GtkLabel?
private var wifiLabel: GtkLabel?
private var quickSettingsPopover: GtkWidget?

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

func batteryStatusText() -> String {
    // FreeBSD: apm -l prints remaining battery percent, 255 when no battery
    guard let output = runAndCapture(["/usr/sbin/apm", "-l"]),
          let percent = Int(output.trimmingCharacters(in: .whitespacesAndNewlines)),
          percent >= 0, percent <= 100 else {
        return "🔌"
    }
    let icon = percent > 60 ? "🔋" : (percent > 25 ? "🪫" : "🪫⚠")
    return "\(icon) \(percent)%"
}

func wifiStatusText() -> String {
    guard let output = runAndCapture(["/sbin/ifconfig", "wlan0"]) else {
        return "📶 —"
    }
    for line in output.components(separatedBy: "\n") {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if trimmed.hasPrefix("ssid ") {
            let parts = trimmed.components(separatedBy: " ")
            if parts.count >= 2, parts[1] != "\"\"" {
                return "📶 \(parts[1])"
            }
        }
    }
    return "📶 off"
}

@_cdecl("aero_status_tick")
func aeroStatusTick(_ userData: UnsafeMutableRawPointer?) -> Int32 {
    batteryStatusText().withCString { gtk_label_set_text(batteryLabel, $0) }
    wifiStatusText().withCString { gtk_label_set_text(wifiLabel, $0) }
    if systemStatsLabel != nil {
        systemStatsText().withCString { gtk_label_set_text(systemStatsLabel, $0) }
    }
    return 1
}

@_cdecl("aero_quick_settings_open")
func aeroQuickSettingsOpen(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    playAeroSound("click")
    gtk_popover_popup(quickSettingsPopover)
}

@_cdecl("aero_volume_up")
func aeroVolumeUp(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    launchExecutable("/usr/local/bin/wpctl", arguments: ["set-volume", "@DEFAULT_AUDIO_SINK@", "5%+"])
    playAeroSound("volume")
}

@_cdecl("aero_volume_down")
func aeroVolumeDown(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    launchExecutable("/usr/local/bin/wpctl", arguments: ["set-volume", "@DEFAULT_AUDIO_SINK@", "5%-"])
    playAeroSound("volume")
}

@_cdecl("aero_volume_mute")
func aeroVolumeMute(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    launchExecutable("/usr/local/bin/wpctl", arguments: ["set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"])
    playAeroSound("volume")
}

@_cdecl("aero_wifi_toggle")
func aeroWifiToggle(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    launchExecutable("/usr/sbin/service", arguments: ["netif", "restart", "wlan0"])
}

@_cdecl("aero_lock_screen")
func aeroLockScreen(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    gtk_popover_popdown(quickSettingsPopover)
    playAeroSound("lock")
    launchExecutable("/usr/local/bin/aero-lock")
}

@_cdecl("aero_screenshot")
func aeroScreenshot(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    gtk_popover_popdown(quickSettingsPopover)
    launchExecutable("/usr/local/bin/aero", arguments: ["screenshot"])
}

// MARK: - Calendar popover

private var calendarPopover: GtkWidget?
private var calendarLabel: GtkLabel?
private var systemStatsLabel: GtkLabel?

func buildCalendar(attachedTo anchor: GtkWidget?) {
    guard let popover = gtk_popover_new() else { return }
    "aero-calendar".withCString { gtk_widget_set_name(popover, $0) }
    gtk_popover_set_has_arrow(popover, 0)
    gtk_popover_set_position(popover, GTK_POS_BOTTOM)
    gtk_widget_set_parent(popover, anchor)

    guard let panel = gtk_box_new(GTK_ORIENTATION_VERTICAL, 8) else { return }
    "quick-settings-box".withCString { gtk_widget_add_css_class(panel, $0) }

    if let month = "".withCString({ gtk_label_new($0) }) {
        "calendar-grid".withCString { gtk_widget_add_css_class(month, $0) }
        calendarLabel = month
        gtk_box_append(panel, month)
    }

    gtk_popover_set_child(popover, panel)
    calendarPopover = popover
}

@_cdecl("aero_calendar_open")
func aeroCalendarOpen(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    if let output = runAndCapture(["/usr/bin/cal"]) {
        output.withCString { gtk_label_set_text(calendarLabel, $0) }
    }
    gtk_popover_popup(calendarPopover)
}

func systemStatsText() -> String {
    var parts: [String] = []
    if let load = runAndCapture(["/sbin/sysctl", "-n", "vm.loadavg"]) {
        let cleaned = load.trimmingCharacters(in: CharacterSet(charactersIn: "{} \n"))
        if let first = cleaned.components(separatedBy: " ").first {
            parts.append("⚡ load \(first)")
        }
    }
    if let mem = runAndCapture(["/sbin/sysctl", "-n", "hw.physmem"]),
       let bytes = Double(mem.trimmingCharacters(in: .whitespacesAndNewlines)) {
        parts.append(String(format: "%.1f GB RAM", bytes / 1_073_741_824))
    }
    return parts.isEmpty ? "stats unavailable" : parts.joined(separator: "  ·  ")
}

func buildQuickSettings(attachedTo anchor: GtkWidget?) {
    guard let popover = gtk_popover_new() else { return }
    "aero-quick-settings".withCString { gtk_widget_set_name(popover, $0) }
    gtk_popover_set_has_arrow(popover, 0)
    gtk_popover_set_position(popover, GTK_POS_BOTTOM)
    gtk_widget_set_parent(popover, anchor)

    guard let panel = gtk_box_new(GTK_ORIENTATION_VERTICAL, 6) else { return }
    "quick-settings-box".withCString { gtk_widget_add_css_class(panel, $0) }
    gtk_widget_set_size_request(panel, 240, -1)

    if let heading = "Quick Settings".withCString({ gtk_label_new($0) }) {
        "start-menu-heading".withCString { gtk_widget_add_css_class(heading, $0) }
        gtk_box_append(panel, heading)
    }

    if let stats = systemStatsText().withCString({ gtk_label_new($0) }) {
        "notification-body".withCString { gtk_widget_add_css_class(stats, $0) }
        systemStatsLabel = stats
        gtk_box_append(panel, stats)
    }

    guard let volumeRow = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 6) else { return }
    gtk_box_append(volumeRow, makeStartMenuItem("🔉", handler: aeroVolumeDown))
    gtk_box_append(volumeRow, makeStartMenuItem("🔇", handler: aeroVolumeMute))
    gtk_box_append(volumeRow, makeStartMenuItem("🔊", handler: aeroVolumeUp))
    gtk_box_append(panel, volumeRow)

    gtk_box_append(panel, makeStartMenuItem("📶  Reconnect Wi-Fi", handler: aeroWifiToggle))
    gtk_box_append(panel, makeStartMenuItem("📸  Screenshot", handler: aeroScreenshot))
    gtk_box_append(panel, makeStartMenuItem("🔒  Lock Screen", handler: aeroLockScreen))

    gtk_popover_set_child(popover, panel)
    quickSettingsPopover = popover
}

// MARK: - Notifications

private let notificationSpool = "/tmp/aero-notifications"
private var seenNotifications = Set<String>()

struct NotificationRecord {
    let app: String
    let title: String
    let body: String
}

private var notificationHistory: [NotificationRecord] = []
private var notificationCenterPopover: GtkWidget?
private var notificationCenterBox: GtkBox?
private var notificationCenterRows: [GtkWidget] = []

@_cdecl("aero_notification_center_open")
func aeroNotificationCenterOpen(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    guard let box = notificationCenterBox else { return }
    for row in notificationCenterRows {
        gtk_box_remove(box, row)
    }
    notificationCenterRows.removeAll()

    if notificationHistory.isEmpty {
        if let empty = "No notifications".withCString({ gtk_label_new($0) }) {
            "notification-body".withCString { gtk_widget_add_css_class(empty, $0) }
            gtk_box_append(box, empty)
            notificationCenterRows.append(empty)
        }
    } else {
        for record in notificationHistory.suffix(8).reversed() {
            guard let row = gtk_box_new(GTK_ORIENTATION_VERTICAL, 2) else { continue }
            "notification-history-row".withCString { gtk_widget_add_css_class(row, $0) }
            if let title = "\(record.app): \(record.title)".withCString({ gtk_label_new($0) }) {
                "notification-title".withCString { gtk_widget_add_css_class(title, $0) }
                gtk_label_set_xalign(title, 0)
                gtk_box_append(row, title)
            }
            if let body = record.body.withCString({ gtk_label_new($0) }) {
                "notification-body".withCString { gtk_widget_add_css_class(body, $0) }
                gtk_label_set_wrap(body, 1)
                gtk_label_set_xalign(body, 0)
                gtk_box_append(row, body)
            }
            gtk_box_append(box, row)
            notificationCenterRows.append(row)
        }
    }
    gtk_popover_popup(notificationCenterPopover)
}

func buildNotificationCenter(attachedTo anchor: GtkWidget?) {
    guard let popover = gtk_popover_new() else { return }
    "aero-notification-center".withCString { gtk_widget_set_name(popover, $0) }
    gtk_popover_set_has_arrow(popover, 0)
    gtk_popover_set_position(popover, GTK_POS_BOTTOM)
    gtk_widget_set_parent(popover, anchor)

    guard let panel = gtk_box_new(GTK_ORIENTATION_VERTICAL, 8) else { return }
    "quick-settings-box".withCString { gtk_widget_add_css_class(panel, $0) }
    gtk_widget_set_size_request(panel, 300, -1)

    if let heading = "Notifications".withCString({ gtk_label_new($0) }) {
        "start-menu-heading".withCString { gtk_widget_add_css_class(heading, $0) }
        gtk_box_append(panel, heading)
    }

    notificationCenterBox = panel
    gtk_popover_set_child(popover, panel)
    notificationCenterPopover = popover
}

func showNotificationBanner(title: String, body: String, app: String) {
    playAeroSound("notification")
    notificationHistory.append(NotificationRecord(app: app, title: title, body: body))
    if notificationHistory.count > 50 {
        notificationHistory.removeFirst(notificationHistory.count - 50)
    }
    guard let banner = gtk_window_new() else { return }
    gtk_layer_init_for_window(banner)
    gtk_layer_set_layer(banner, .overlay)
    "aero-banner".withCString { gtk_layer_set_namespace(banner, $0) }
    gtk_layer_set_anchor(banner, .top, 1)
    gtk_layer_set_anchor(banner, .right, 1)
    gtk_layer_set_margin(banner, .top, 52)
    gtk_layer_set_margin(banner, .right, 16)

    guard let card = gtk_box_new(GTK_ORIENTATION_VERTICAL, 4) else { return }
    "notification-card".withCString { gtk_widget_add_css_class(card, $0) }
    gtk_widget_set_size_request(card, 300, -1)

    if let appLabel = app.withCString({ gtk_label_new($0) }) {
        "notification-app".withCString { gtk_widget_add_css_class(appLabel, $0) }
        gtk_label_set_xalign(appLabel, 0)
        gtk_box_append(card, appLabel)
    }
    if let titleLabel = title.withCString({ gtk_label_new($0) }) {
        "notification-title".withCString { gtk_widget_add_css_class(titleLabel, $0) }
        gtk_label_set_xalign(titleLabel, 0)
        gtk_box_append(card, titleLabel)
    }
    if let bodyLabel = body.withCString({ gtk_label_new($0) }) {
        "notification-body".withCString { gtk_widget_add_css_class(bodyLabel, $0) }
        gtk_label_set_wrap(bodyLabel, 1)
        gtk_label_set_xalign(bodyLabel, 0)
        gtk_box_append(card, bodyLabel)
    }

    gtk_window_set_child(banner, card)
    gtk_window_present(banner)

    let retained = Unmanaged.passRetained(BannerBox(window: banner))
    _ = g_timeout_add(5000, aeroBannerClose, retained.toOpaque())
}

final class BannerBox {
    let window: GtkWindow
    init(window: GtkWindow) { self.window = window }
}

@_cdecl("aero_banner_close")
func aeroBannerClose(_ userData: UnsafeMutableRawPointer?) -> Int32 {
    guard let userData = userData else { return 0 }
    let box = Unmanaged<BannerBox>.fromOpaque(userData).takeRetainedValue()
    gtk_window_destroy(box.window)
    return 0
}

@_cdecl("aero_notifications_tick")
func aeroNotificationsTick(_ userData: UnsafeMutableRawPointer?) -> Int32 {
    let fileManager = FileManager.default
    guard let entries = try? fileManager.contentsOfDirectory(atPath: notificationSpool) else { return 1 }

    for entry in entries.sorted() where entry.hasSuffix(".json") && !seenNotifications.contains(entry) {
        seenNotifications.insert(entry)
        let path = "\(notificationSpool)/\(entry)"
        guard let data = fileManager.contents(atPath: path),
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: String] else {
            try? fileManager.removeItem(atPath: path)
            continue
        }
        showNotificationBanner(
            title: object["title"] ?? "Notification",
            body: object["body"] ?? "",
            app: object["app"] ?? "Aero OS"
        )
        try? fileManager.removeItem(atPath: path)
    }
    return 1
}

func makeStartButton() -> GtkButton? {
    guard let button = gtk_button_new() else { return nil }
    "aero-start-button".withCString { gtk_widget_set_name(button, $0) }

    let iconPath = "/usr/local/share/aero/start-button.png"
    if FileManager.default.fileExists(atPath: iconPath),
       let picture = iconPath.withCString({ gtk_picture_new_for_filename($0) }) {
        gtk_widget_set_size_request(picture, 26, 26)
        gtk_button_set_child(button, picture)
    } else if let fallback = "A".withCString({ gtk_label_new($0) }) {
        "start-button-fallback".withCString { gtk_widget_add_css_class(fallback, $0) }
        gtk_button_set_child(button, fallback)
    }

    _ = g_signal_connect_data(button, "clicked", aeroOnStartClicked, nil, nil, 0)
    return button
}

func makeDockButton(label: String, cssClass: String, handler: @convention(c) (OpaquePointer?, OpaquePointer?) -> Void) -> GtkButton? {
    guard let button = label.withCString({ gtk_button_new_with_label($0) }) else { return nil }
    "dock-btn".withCString { gtk_widget_add_css_class(button, $0) }
    cssClass.withCString { gtk_widget_add_css_class(button, $0) }
    _ = g_signal_connect_data(
        button,
        "clicked",
        handler,
        nil,
        nil,
        0
    )
    return button
}

@_cdecl("aero_on_activate")
func aeroOnActivate(_ app: OpaquePointer?, _ userData: OpaquePointer?) {
    guard let application = app else { return }
    guard let window = gtk_application_window_new(application) else { return }

    "Aero OS".withCString { gtk_window_set_title(window, $0) }
    gtk_window_set_default_size(window, 1920, 1080)

    gtk_layer_init_for_window(window)
    gtk_layer_set_layer(window, .background)
    gtk_layer_set_namespace(window, "aero-desktop")
    gtk_layer_set_anchor(window, .top, 1)
    gtk_layer_set_anchor(window, .bottom, 1)
    gtk_layer_set_anchor(window, .left, 1)
    gtk_layer_set_anchor(window, .right, 1)
    gtk_layer_set_exclusive_zone(window, -1)
    gtk_layer_set_keyboard_mode(window, .none)

    loadAeroStylesheet(for: window)

    guard let canvas = gtk_box_new(GTK_ORIENTATION_VERTICAL, 0) else { return }
    "aero-desktop-canvas".withCString { gtk_widget_set_name(canvas, $0) }
    gtk_widget_set_hexpand(canvas, 1)
    gtk_widget_set_vexpand(canvas, 1)
    globalCanvas = canvas
    applyAppearance(readAppearancePreference())

    guard let commandBar = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 12) else { return }
    "aero-command-bar".withCString { gtk_widget_set_name(commandBar, $0) }
    gtk_widget_set_hexpand(commandBar, 1)
    gtk_widget_set_halign(commandBar, GTK_ALIGN_FILL)
    gtk_widget_set_valign(commandBar, GTK_ALIGN_START)
    gtk_widget_set_margin_top(commandBar, 8)
    gtk_widget_set_margin_start(commandBar, 16)
    gtk_widget_set_margin_end(commandBar, 16)

    if let startButton = makeStartButton() {
        gtk_box_append(commandBar, startButton)
        buildStartMenu(attachedTo: startButton)
    }

    guard let brandLabel = "Aero OS".withCString({ gtk_label_new($0) }) else { return }
    "aero-brand-label".withCString { gtk_widget_set_name(brandLabel, $0) }
    gtk_widget_set_halign(brandLabel, GTK_ALIGN_START)
    gtk_box_append(commandBar, brandLabel)

    if let taskbar = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 6) {
        "aero-taskbar".withCString { gtk_widget_set_name(taskbar, $0) }
        gtk_widget_set_margin_start(taskbar, 12)
        taskbarBox = taskbar
        gtk_box_append(commandBar, taskbar)
    }

    guard let spacer = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 0) else { return }
    gtk_widget_set_hexpand(spacer, 1)
    gtk_box_append(commandBar, spacer)

    guard let clockLabel = "Initializing…".withCString({ gtk_label_new($0) }) else { return }
    "aero-clock-label".withCString { gtk_widget_set_name(clockLabel, $0) }
    gtk_widget_set_halign(clockLabel, GTK_ALIGN_CENTER)

    if let clockButton = gtk_button_new() {
        "clock-button".withCString { gtk_widget_add_css_class(clockButton, $0) }
        gtk_button_set_child(clockButton, clockLabel)
        _ = g_signal_connect_data(clockButton, "clicked", aeroCalendarOpen, nil, nil, 0)
        gtk_box_append(commandBar, clockButton)
        buildCalendar(attachedTo: clockButton)
    }

    guard let rightSpacer = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 0) else { return }
    gtk_widget_set_hexpand(rightSpacer, 1)
    gtk_box_append(commandBar, rightSpacer)

    if let wifi = "📶".withCString({ gtk_label_new($0) }) {
        "status-indicator".withCString { gtk_widget_add_css_class(wifi, $0) }
        wifiLabel = wifi
        gtk_box_append(commandBar, wifi)
    }

    if let battery = "🔋".withCString({ gtk_label_new($0) }) {
        "status-indicator".withCString { gtk_widget_add_css_class(battery, $0) }
        batteryLabel = battery
        gtk_box_append(commandBar, battery)
    }

    if let bellButton = "🔔".withCString({ gtk_button_new_with_label($0) }) {
        "quick-settings-btn".withCString { gtk_widget_add_css_class(bellButton, $0) }
        _ = g_signal_connect_data(bellButton, "clicked", aeroNotificationCenterOpen, nil, nil, 0)
        gtk_box_append(commandBar, bellButton)
        buildNotificationCenter(attachedTo: bellButton)
    }

    if let quickButton = "☰".withCString({ gtk_button_new_with_label($0) }) {
        "quick-settings-btn".withCString { gtk_widget_add_css_class(quickButton, $0) }
        _ = g_signal_connect_data(quickButton, "clicked", aeroQuickSettingsOpen, nil, nil, 0)
        gtk_box_append(commandBar, quickButton)
        buildQuickSettings(attachedTo: quickButton)
    }

    gtk_box_append(canvas, commandBar)

    guard let dockRegion = gtk_box_new(GTK_ORIENTATION_VERTICAL, 0) else { return }
    "aero-dock-region".withCString { gtk_widget_set_name(dockRegion, $0) }
    gtk_widget_set_vexpand(dockRegion, 1)
    gtk_widget_set_valign(dockRegion, GTK_ALIGN_END)
    gtk_widget_set_margin_bottom(dockRegion, 18)

    guard let dockCapsule = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 18) else { return }
    "aero-dock-capsule".withCString { gtk_widget_set_name(dockCapsule, $0) }
    gtk_widget_set_halign(dockCapsule, GTK_ALIGN_CENTER)
    gtk_widget_set_valign(dockCapsule, GTK_ALIGN_END)
    gtk_widget_set_margin_bottom(dockCapsule, 6)

    if let setupButton = makeDockButton(
        label: "💾 Setup Aero OS",
        cssClass: "dock-btn-setup",
        handler: aeroOnSetupClicked
    ) {
        gtk_box_append(dockCapsule, setupButton)
    }

    if let terminalButton = makeDockButton(
        label: "💻 Terminal",
        cssClass: "dock-btn-terminal",
        handler: aeroOnTerminalClicked
    ) {
        gtk_box_append(dockCapsule, terminalButton)
    }

    if let filesButton = makeDockButton(
        label: "📂 Files",
        cssClass: "dock-btn-files",
        handler: aeroOnFilesClicked
    ) {
        gtk_box_append(dockCapsule, filesButton)
    }

    if let settingsButton = makeDockButton(
        label: "⚙️ Settings",
        cssClass: "dock-btn-settings",
        handler: aeroOnSettingsClicked
    ) {
        gtk_box_append(dockCapsule, settingsButton)
    }

    if let storeButton = makeDockButton(
        label: "🛒 Store",
        cssClass: "dock-btn-store",
        handler: aeroOnStoreClicked
    ) {
        gtk_box_append(dockCapsule, storeButton)
    }

    gtk_box_append(dockRegion, dockCapsule)
    gtk_box_append(canvas, dockRegion)

    gtk_window_set_child(window, canvas)

    let clockContext = ClockContext(label: clockLabel)
    let retained = Unmanaged.passRetained(clockContext)
    globalClockContext = retained
    _ = g_timeout_add(1000, aeroClockTick, retained.toOpaque())
    aeroClockTick(retained.toOpaque())
    _ = g_timeout_add(2000, aeroAppearanceTick, nil)
    _ = g_timeout_add(2000, aeroTaskbarTick, nil)
    _ = g_timeout_add(15000, aeroStatusTick, nil)
    _ = aeroStatusTick(nil)
    _ = g_timeout_add(1000, aeroNotificationsTick, nil)
    try? FileManager.default.createDirectory(atPath: notificationSpool, withIntermediateDirectories: true)

    gtk_window_present(window)
    playAeroSound("startup")
}

gtk_init()

guard let application = gtk_application_new("org.aero.DesktopShell", GTK_APPLICATION_FLAGS_NONE) else {
    fputs("Aero OS: failed to create GTK application.\n", stderr)
    exit(1)
}

_ = g_signal_connect_data(
    application,
    "activate",
    aeroOnActivate,
    nil,
    nil,
    0
)

let status = g_application_run(application, 0, nil)
exit(Int32(status))
