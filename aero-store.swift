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
let GTK_ORIENTATION_HORIZONTAL = GtkOrientation(rawValue: 0)
let GTK_ORIENTATION_VERTICAL = GtkOrientation(rawValue: 1)
let GTK_ALIGN_FILL = GtkAlign(rawValue: 0)
let GTK_ALIGN_START = GtkAlign(rawValue: 1)
let GTK_ALIGN_CENTER = GtkAlign(rawValue: 3)
let GTK_STYLE_PROVIDER_PRIORITY_APPLICATION: UInt32 = 600
let G_SPAWN_SEARCH_PATH = GSpawnFlags(rawValue: 1 << 1)
let GTK_POLICY_AUTOMATIC: Int32 = 1

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

@_silgen_name("gtk_window_set_child")
func gtk_window_set_child(_ window: GtkWindow?, _ child: GtkWidget?)

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

@_silgen_name("gtk_widget_set_size_request")
func gtk_widget_set_size_request(_ widget: GtkWidget?, _ width: Int32, _ height: Int32)

@_silgen_name("gtk_widget_set_margin_top")
func gtk_widget_set_margin_top(_ widget: GtkWidget?, _ margin: Int32)

@_silgen_name("gtk_widget_set_margin_bottom")
func gtk_widget_set_margin_bottom(_ widget: GtkWidget?, _ margin: Int32)

@_silgen_name("gtk_widget_set_margin_start")
func gtk_widget_set_margin_start(_ widget: GtkWidget?, _ margin: Int32)

@_silgen_name("gtk_widget_set_margin_end")
func gtk_widget_set_margin_end(_ widget: GtkWidget?, _ margin: Int32)

@_silgen_name("gtk_widget_set_visible")
func gtk_widget_set_visible(_ widget: GtkWidget?, _ visible: gboolean)

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

@_silgen_name("gtk_label_set_wrap")
func gtk_label_set_wrap(_ label: GtkLabel?, _ wrap: gboolean)

@_silgen_name("gtk_label_set_xalign")
func gtk_label_set_xalign(_ label: GtkLabel?, _ xalign: Float)

@_silgen_name("gtk_entry_new")
func gtk_entry_new() -> GtkWidget?

@_silgen_name("gtk_entry_set_placeholder_text")
func gtk_entry_set_placeholder_text(_ entry: GtkWidget?, _ text: UnsafePointer<CChar>)

@_silgen_name("gtk_editable_get_text")
func gtk_editable_get_text(_ editable: GtkWidget?) -> UnsafePointer<CChar>?

@_silgen_name("gtk_editable_set_text")
func gtk_editable_set_text(_ editable: GtkWidget?, _ text: UnsafePointer<CChar>)

@_silgen_name("gtk_picture_new_for_filename")
func gtk_picture_new_for_filename(_ filename: UnsafePointer<CChar>) -> GtkWidget?

@_silgen_name("gtk_scrolled_window_new")
func gtk_scrolled_window_new() -> GtkWidget?

@_silgen_name("gtk_scrolled_window_set_child")
func gtk_scrolled_window_set_child(_ scrolled: GtkWidget?, _ child: GtkWidget?)

@_silgen_name("gtk_scrolled_window_set_policy")
func gtk_scrolled_window_set_policy(_ scrolled: GtkWidget?, _ h: Int32, _ v: Int32)

@_silgen_name("gtk_css_provider_new")
func gtk_css_provider_new() -> GtkCssProvider?

@_silgen_name("gtk_css_provider_load_from_path")
func gtk_css_provider_load_from_path(_ provider: GtkCssProvider?, _ path: UnsafePointer<CChar>) -> gboolean

@_silgen_name("gtk_widget_get_display")
func gtk_widget_get_display(_ widget: GtkWidget?) -> GdkDisplay?

@_silgen_name("gtk_style_context_add_provider_for_display")
func gtk_style_context_add_provider_for_display(_ display: GdkDisplay?, _ provider: GtkCssProvider?, _ priority: UInt32)

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

// MARK: - Models

struct StoreApp {
    let id: String
    let name: String
    let description: String
    let category: String
    let iconDomain: String
    let installName: String
}

final class StoreAppRef {
    let app: StoreApp
    var row: GtkWidget?
    var statusLabel: GtkLabel?
    var iconWidget: GtkWidget?
    var iconBox: GtkBox?

    init(app: StoreApp) {
        self.app = app
    }
}

private var catalog: [StoreAppRef] = []
private var searchEntry: GtkWidget?
private var anyAppEntry: GtkWidget?
private var statusBanner: GtkLabel?
private var listBox: GtkBox?
private var pendingIconLoads: [StoreAppRef] = []
private let pendingLock = NSLock()

final class InstallStatus {
    var text: String = ""
    var ref: StoreAppRef?
}
private var pendingStatus = InstallStatus()
private let statusLock = NSLock()

let storeIndexPath = "/usr/local/share/aero/store/index.json"
let iconCacheDir = NSString(string: "~/.cache/aero/icons").expandingTildeInPath

func spawnDetached(_ arguments: [String]) {
    var argv: [UnsafeMutablePointer<CChar>?] = arguments.map { strdup($0) }
    argv.append(nil)
    argv.withUnsafeMutableBufferPointer { buffer in
        var pid = Gpid(0)
        _ = g_spawn_async(nil, buffer.baseAddress!, nil, G_SPAWN_SEARCH_PATH, nil, nil, &pid, nil)
    }
    for pointer in argv where pointer != nil {
        free(pointer)
    }
}

func playAeroSound(_ event: String) {
    spawnDetached(["/usr/local/bin/aero-sound", event])
}

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

func jsonStringField(_ key: String, in block: String) -> String {
    let pattern = "\"\(key)\"\\s*:\\s*\"([^\"]*)\""
    guard let regex = try? NSRegularExpression(pattern: pattern) else { return "" }
    let range = NSRange(block.startIndex..<block.endIndex, in: block)
    guard let match = regex.firstMatch(in: block, range: range),
          let valueRange = Range(match.range(at: 1), in: block) else {
        return ""
    }
    return String(block[valueRange])
}

func loadCatalog() -> [StoreApp] {
    guard let raw = try? String(contentsOfFile: storeIndexPath, encoding: .utf8) else {
        return []
    }
    var apps: [StoreApp] = []
    let blocks = raw.replacingOccurrences(of: "\n", with: " ")
        .components(separatedBy: "},")
    for block in blocks {
        let id = jsonStringField("id", in: block)
        let name = jsonStringField("name", in: block)
        guard !id.isEmpty, !name.isEmpty else { continue }
        let description = jsonStringField("description", in: block)
        let category = jsonStringField("category", in: block)
        let iconDomain = jsonStringField("icon_domain", in: block)
        let installName = String(id.split(separator: ".").last ?? Substring(name.lowercased()))
        apps.append(StoreApp(
            id: id,
            name: name,
            description: description.isEmpty ? "Available on Aero OS" : description,
            category: category.isEmpty ? "Apps" : category,
            iconDomain: iconDomain.isEmpty ? "example.com" : iconDomain,
            installName: installName
        ))
    }
    return apps
}

func iconPath(for appId: String) -> String {
    "\(iconCacheDir)/\(appId).png"
}

func ensureIcon(for ref: StoreAppRef) {
    let path = iconPath(for: ref.app.id)
    if FileManager.default.fileExists(atPath: path) {
        applyIcon(path, to: ref)
        return
    }
    Thread.detachNewThread {
        _ = runAndCapture([
            "/usr/local/bin/aero-fetch-icon",
            ref.app.id,
            ref.app.iconDomain,
        ])
        if FileManager.default.fileExists(atPath: path) {
            pendingLock.lock()
            pendingIconLoads.append(ref)
            pendingLock.unlock()
        }
    }
}

func applyIcon(_ path: String, to ref: StoreAppRef) {
    guard let box = ref.iconBox else { return }
    if let picture = path.withCString({ gtk_picture_new_for_filename($0) }) {
        gtk_widget_set_size_request(picture, 48, 48)
        "store-app-icon".withCString { gtk_widget_add_css_class(picture, $0) }
        gtk_box_append(box, picture)
        ref.iconWidget = picture
    }
}

@_cdecl("aero_store_icon_poll")
func aeroStoreIconPoll(_ userData: UnsafeMutableRawPointer?) -> gboolean {
    pendingLock.lock()
    let batch = pendingIconLoads
    pendingIconLoads.removeAll()
    pendingLock.unlock()
    for ref in batch {
        let path = iconPath(for: ref.app.id)
        if FileManager.default.fileExists(atPath: path) {
            applyIcon(path, to: ref)
        }
    }
    return 1
}

func isInstalled(_ app: StoreApp) -> Bool {
    let home = NSString(string: "~/.local/share/aero/apps").expandingTildeInPath
    let candidates = [app.id, "app.\(app.installName)", app.installName]
    for candidate in candidates {
        if FileManager.default.fileExists(atPath: "\(home)/\(candidate)/manifest.json") {
            return true
        }
    }
    return false
}

@_cdecl("aero_store_install_v2")
func aeroStoreInstallV2(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    guard let userData = userData else { return }
    let ref = Unmanaged<StoreAppRef>.fromOpaque(UnsafeRawPointer(userData)).takeUnretainedValue()
    playAeroSound("click")
    "Installing…".withCString { gtk_label_set_text(ref.statusLabel, $0) }
    "Installing \(ref.app.name)…".withCString { gtk_label_set_text(statusBanner, $0) }

    let installName = ref.app.installName
    let appName = ref.app.name
    Thread.detachNewThread {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/local/bin/aero")
        process.arguments = ["install", installName]
        var result = "Failed"
        var banner = "Could not install \(appName)"
        do {
            try process.run()
            process.waitUntilExit()
            if process.terminationStatus == 0 {
                result = "Installed"
                banner = "\(appName) is ready — run: aero run \(installName)"
            }
        } catch {
            result = "Failed"
        }
        statusLock.lock()
        pendingStatus.text = result
        pendingStatus.ref = ref
        statusLock.unlock()
        try? banner.write(toFile: "/tmp/aero-store-status", atomically: true, encoding: .utf8)
        try? (result == "Installed" ? "success" : "error")
            .write(toFile: "/tmp/aero-store-sound", atomically: true, encoding: .utf8)
    }
}

@_cdecl("aero_store_status_poll")
func aeroStoreStatusPoll(_ userData: UnsafeMutableRawPointer?) -> gboolean {
    statusLock.lock()
    let ref = pendingStatus.ref
    let text = pendingStatus.text
    if !text.isEmpty, let ref = ref {
        text.withCString { gtk_label_set_text(ref.statusLabel, $0) }
        pendingStatus.text = ""
        pendingStatus.ref = nil
    }
    statusLock.unlock()

    if let banner = try? String(contentsOfFile: "/tmp/aero-store-status", encoding: .utf8), !banner.isEmpty {
        banner.withCString { gtk_label_set_text(statusBanner, $0) }
        try? FileManager.default.removeItem(atPath: "/tmp/aero-store-status")
    }
    if let sound = try? String(contentsOfFile: "/tmp/aero-store-sound", encoding: .utf8), !sound.isEmpty {
        playAeroSound(sound.trimmingCharacters(in: .whitespacesAndNewlines))
        try? FileManager.default.removeItem(atPath: "/tmp/aero-store-sound")
    }

    _ = aeroStoreIconPoll(nil)
    return 1
}

@_cdecl("aero_store_search")
func aeroStoreSearch(_ editable: OpaquePointer?, _ userData: OpaquePointer?) {
    var query = ""
    if let pointer = gtk_editable_get_text(searchEntry) {
        query = String(cString: pointer).lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    for ref in catalog {
        guard let row = ref.row else { continue }
        let haystack = "\(ref.app.name) \(ref.app.description) \(ref.app.category) \(ref.app.installName)".lowercased()
        let visible: gboolean = query.isEmpty || haystack.contains(query) ? 1 : 0
        gtk_widget_set_visible(row, visible)
    }
}

@_cdecl("aero_store_install_any")
func aeroStoreInstallAny(_ entry: OpaquePointer?, _ userData: OpaquePointer?) {
    guard let pointer = gtk_editable_get_text(anyAppEntry) else { return }
    let query = String(cString: pointer).trimmingCharacters(in: .whitespacesAndNewlines)
    guard !query.isEmpty else { return }

    playAeroSound("click")
    "Looking up \(query) on the internet…".withCString { gtk_label_set_text(statusBanner, $0) }
    "".withCString { gtk_editable_set_text(anyAppEntry, $0) }

    Thread.detachNewThread {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/local/bin/aero")
        // Split multi-word names into separate args
        let parts = query.split(separator: " ").map(String.init)
        process.arguments = ["install"] + parts
        var banner = "Could not install \(query)"
        var sound = "error"
        do {
            try process.run()
            process.waitUntilExit()
            if process.terminationStatus == 0 {
                banner = "\(query) installed — run: aero run \(query.lowercased())"
                sound = "success"
            }
        } catch {
            banner = "Install failed for \(query)"
        }
        try? banner.write(toFile: "/tmp/aero-store-status", atomically: true, encoding: .utf8)
        try? sound.write(toFile: "/tmp/aero-store-sound", atomically: true, encoding: .utf8)
    }
}

@_cdecl("aero_store_open_app")
func aeroStoreOpenApp(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    guard let userData = userData else { return }
    let ref = Unmanaged<StoreAppRef>.fromOpaque(UnsafeRawPointer(userData)).takeUnretainedValue()
    spawnDetached(["/usr/local/bin/aero", "run", ref.app.installName])
}

func makeAppRow(_ ref: StoreAppRef) -> GtkWidget? {
    guard let row = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 14) else { return nil }
    "store-app-row".withCString { gtk_widget_add_css_class(row, $0) }
    gtk_widget_set_margin_top(row, 6)
    gtk_widget_set_margin_bottom(row, 6)
    gtk_widget_set_margin_start(row, 8)
    gtk_widget_set_margin_end(row, 8)

    guard let iconBox = gtk_box_new(GTK_ORIENTATION_VERTICAL, 0) else { return row }
    "store-icon-box".withCString { gtk_widget_add_css_class(iconBox, $0) }
    gtk_widget_set_size_request(iconBox, 52, 52)
    if let placeholder = "📦".withCString({ gtk_label_new($0) }) {
        gtk_box_append(iconBox, placeholder)
    }
    ref.iconBox = iconBox
    gtk_box_append(row, iconBox)

    guard let textCol = gtk_box_new(GTK_ORIENTATION_VERTICAL, 2) else { return row }
    gtk_widget_set_hexpand(textCol, 1)

    if let name = ref.app.name.withCString({ gtk_label_new($0) }) {
        "store-app-name".withCString { gtk_widget_add_css_class(name, $0) }
        gtk_label_set_xalign(name, 0)
        gtk_box_append(textCol, name)
    }
    if let category = ref.app.category.withCString({ gtk_label_new($0) }) {
        "store-app-category".withCString { gtk_widget_add_css_class(category, $0) }
        gtk_label_set_xalign(category, 0)
        gtk_box_append(textCol, category)
    }
    if let desc = ref.app.description.withCString({ gtk_label_new($0) }) {
        "store-app-desc".withCString { gtk_widget_add_css_class(desc, $0) }
        gtk_label_set_wrap(desc, 1)
        gtk_label_set_xalign(desc, 0)
        gtk_box_append(textCol, desc)
    }
    gtk_box_append(row, textCol)

    guard let actions = gtk_box_new(GTK_ORIENTATION_VERTICAL, 4) else { return row }
    gtk_widget_set_halign(actions, GTK_ALIGN_CENTER)

    let installed = isInstalled(ref.app)
    let buttonTitle = installed ? "Open" : "Get"
    if let button = buttonTitle.withCString({ gtk_button_new_with_label($0) }) {
        "store-get-btn".withCString { gtk_widget_add_css_class(button, $0) }
        let retained = Unmanaged.passRetained(ref).toOpaque()
        if installed {
            _ = g_signal_connect_data(button, "clicked", aeroStoreOpenApp, OpaquePointer(retained), nil, 0)
        } else {
            _ = g_signal_connect_data(button, "clicked", aeroStoreInstallV2, OpaquePointer(retained), nil, 0)
        }
        gtk_box_append(actions, button)
    }

    if let status = (installed ? "Installed" : "Free").withCString({ gtk_label_new($0) }) {
        "store-app-status".withCString { gtk_widget_add_css_class(status, $0) }
        ref.statusLabel = status
        gtk_box_append(actions, status)
    }

    gtk_box_append(row, actions)
    ref.row = row
    ensureIcon(for: ref)
    return row
}

@_cdecl("aero_store_activate")
func aeroStoreActivate(_ app: OpaquePointer?, _ userData: OpaquePointer?) {
    guard let application = app,
          let window = gtk_application_window_new(application) else { return }

    "Aero App Store".withCString { gtk_window_set_title(window, $0) }
    gtk_window_set_default_size(window, 780, 640)

    if let provider = gtk_css_provider_new() {
        "/usr/local/share/aero/style.css".withCString {
            _ = gtk_css_provider_load_from_path(provider, $0)
        }
        if let display = gtk_widget_get_display(window) {
            gtk_style_context_add_provider_for_display(display, provider, GTK_STYLE_PROVIDER_PRIORITY_APPLICATION)
        }
    }

    try? FileManager.default.createDirectory(
        atPath: iconCacheDir,
        withIntermediateDirectories: true,
        attributes: nil
    )

    guard let root = gtk_box_new(GTK_ORIENTATION_VERTICAL, 0) else { return }
    "aero-store-root".withCString { gtk_widget_set_name(root, $0) }

    guard let header = gtk_box_new(GTK_ORIENTATION_VERTICAL, 8) else { return }
    "aero-store-header".withCString { gtk_widget_set_name(header, $0) }
    gtk_widget_set_margin_top(header, 18)
    gtk_widget_set_margin_bottom(header, 10)
    gtk_widget_set_margin_start(header, 20)
    gtk_widget_set_margin_end(header, 20)

    if let title = "App Store".withCString({ gtk_label_new($0) }) {
        "store-title".withCString { gtk_widget_add_css_class(title, $0) }
        gtk_label_set_xalign(title, 0)
        gtk_box_append(header, title)
    }
    if let subtitle = "Install apps with one click — icons download automatically".withCString({ gtk_label_new($0) }) {
        "store-subtitle".withCString { gtk_widget_add_css_class(subtitle, $0) }
        gtk_label_set_xalign(subtitle, 0)
        gtk_box_append(header, subtitle)
    }

    if let search = gtk_entry_new() {
        "store-search".withCString { gtk_widget_add_css_class(search, $0) }
        "🔍 Search apps (Spotify, Discord, Firefox…)".withCString {
            gtk_entry_set_placeholder_text(search, $0)
        }
        searchEntry = search
        _ = g_signal_connect_data(search, "changed", aeroStoreSearch, nil, nil, 0)
        gtk_box_append(header, search)
    }

    if let banner = "Browse featured apps below — or type any app name and press Enter to install from the internet".withCString({ gtk_label_new($0) }) {
        "store-banner".withCString { gtk_widget_add_css_class(banner, $0) }
        gtk_label_set_xalign(banner, 0)
        statusBanner = banner
        gtk_box_append(header, banner)
    }

    if let anyInstall = gtk_entry_new() {
        "store-search".withCString { gtk_widget_add_css_class(anyInstall, $0) }
        "⬇ Install any app from the internet (e.g. Notion, CapCut, Pinterest)…".withCString {
            gtk_entry_set_placeholder_text(anyInstall, $0)
        }
        anyAppEntry = anyInstall
        _ = g_signal_connect_data(anyInstall, "activate", aeroStoreInstallAny, nil, nil, 0)
        gtk_box_append(header, anyInstall)
    }

    gtk_box_append(root, header)

    guard let scrolled = gtk_scrolled_window_new() else { return }
    gtk_widget_set_vexpand(scrolled, 1)
    gtk_widget_set_hexpand(scrolled, 1)
    gtk_scrolled_window_set_policy(scrolled, GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC)

    guard let list = gtk_box_new(GTK_ORIENTATION_VERTICAL, 4) else { return }
    "aero-store-list".withCString { gtk_widget_set_name(list, $0) }
    gtk_widget_set_margin_start(list, 12)
    gtk_widget_set_margin_end(list, 12)
    gtk_widget_set_margin_bottom(list, 16)
    listBox = list

    let apps = loadCatalog()
    for appInfo in apps {
        let ref = StoreAppRef(app: appInfo)
        catalog.append(ref)
        if let row = makeAppRow(ref) {
            gtk_box_append(list, row)
        }
    }

    gtk_scrolled_window_set_child(scrolled, list)
    gtk_box_append(root, scrolled)
    gtk_window_set_child(window, root)

    _ = g_timeout_add(400, aeroStoreStatusPoll, nil)
    gtk_window_present(window)
}

guard let application = gtk_application_new("org.aero.AppStore", GTK_APPLICATION_FLAGS_NONE) else {
    fputs("Aero App Store: failed to create GTK application.\n", stderr)
    exit(1)
}

_ = g_signal_connect_data(application, "activate", aeroStoreActivate, nil, nil, 0)
let status = g_application_run(application, 0, nil)
exit(status)
