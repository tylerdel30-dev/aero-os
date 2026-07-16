import Foundation
import Glibc

typealias GtkWidget = OpaquePointer
typealias GtkApplication = OpaquePointer
typealias GtkWindow = OpaquePointer
typealias GtkBox = OpaquePointer
typealias GtkButton = OpaquePointer
typealias GtkLabel = OpaquePointer
typealias GtkStack = OpaquePointer
typealias GtkPicture = OpaquePointer
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
let GTK_ALIGN_END = GtkAlign(rawValue: 2)
let GTK_ALIGN_CENTER = GtkAlign(rawValue: 3)
let GTK_STYLE_PROVIDER_PRIORITY_APPLICATION: UInt32 = 600
let G_SPAWN_SEARCH_PATH = GSpawnFlags(rawValue: 1 << 1)
let GTK_STACK_TRANSITION_TYPE_CROSSFADE: Int32 = 1

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

@_silgen_name("gtk_widget_set_valign")
func gtk_widget_set_valign(_ widget: GtkWidget?, _ align: GtkAlign)

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

@_silgen_name("gtk_stack_new")
func gtk_stack_new() -> GtkStack?

@_silgen_name("gtk_stack_add_named")
func gtk_stack_add_named(_ stack: GtkStack?, _ child: GtkWidget?, _ name: UnsafePointer<CChar>)

@_silgen_name("gtk_stack_set_visible_child_name")
func gtk_stack_set_visible_child_name(_ stack: GtkStack?, _ name: UnsafePointer<CChar>)

@_silgen_name("gtk_stack_set_transition_type")
func gtk_stack_set_transition_type(_ stack: GtkStack?, _ transition: Int32)

@_silgen_name("gtk_stack_set_transition_duration")
func gtk_stack_set_transition_duration(_ stack: GtkStack?, _ duration: UInt32)

@_silgen_name("gtk_picture_new_for_filename")
func gtk_picture_new_for_filename(_ filename: UnsafePointer<CChar>) -> GtkPicture?

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

// MARK: - Shared state between GTK main loop and background threads

final class SettingsState {
    static let shared = SettingsState()

    private let lock = NSLock()
    private var _accountStatus = "Not signed in"
    private var _updateStatus = "Local version unknown"
    private var _updateAvailable = false

    var accountStatus: String {
        get { lock.lock(); defer { lock.unlock() }; return _accountStatus }
        set { lock.lock(); _accountStatus = newValue; lock.unlock() }
    }

    var updateStatus: String {
        get { lock.lock(); defer { lock.unlock() }; return _updateStatus }
        set { lock.lock(); _updateStatus = newValue; lock.unlock() }
    }

    var updateAvailable: Bool {
        get { lock.lock(); defer { lock.unlock() }; return _updateAvailable }
        set { lock.lock(); _updateAvailable = newValue; lock.unlock() }
    }
}

var globalStack: GtkStack?
var accountStatusLabel: GtkLabel?
var updateStatusLabel: GtkLabel?
var aeroUsernameEntry: GtkWidget?
var aeroPasswordEntry: GtkWidget?

let aeroConfigDirectory = NSString(string: "~/.config/aero").expandingTildeInPath
let aeroVersionFile = "/etc/aero-version"
let aeroUpdateRepository = "tylerdel30-dev/aero-os"

func loadUpdateRepository() -> String {
    let path = "/etc/aero/repos.conf"
    guard let contents = try? String(contentsOfFile: path, encoding: .utf8) else {
        return aeroUpdateRepository
    }
    for line in contents.components(separatedBy: "\n") {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if trimmed.hasPrefix("os_repo=") {
            let value = String(trimmed.dropFirst("os_repo=".count))
            if !value.isEmpty && !value.contains("YOUR_GITHUB_USERNAME") {
                return value
            }
        }
    }
    return aeroUpdateRepository
}
let oauthLoopbackPort: UInt16 = 53682

// MARK: - Process helpers

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

// MARK: - Layer 1: OAuth 2.0 cloud identity pipeline

struct OAuthProvider {
    let name: String
    let authorizeURL: String
    let tokenURL: String
    let clientID: String
    let scope: String

    var redirectURI: String {
        "http://127.0.0.1:\(oauthLoopbackPort)/callback"
    }

    var fullAuthorizeURL: String {
        var components = URLComponents(string: authorizeURL)!
        var items = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "scope", value: scope),
        ]
        // Apple Sign In requires response_mode for web/loopback clients
        if name == "apple" {
            items.append(URLQueryItem(name: "response_mode", value: "query"))
            items.append(URLQueryItem(name: "state", value: "aero-apple"))
        }
        components.queryItems = items
        return components.url!.absoluteString
    }
}

func oauthClientID(for provider: String, fallback: String = "") -> String {
    let path = "\(aeroConfigDirectory)/oauth.conf"
    if let text = try? String(contentsOfFile: path, encoding: .utf8) {
        for line in text.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("\(provider)_client_id=") {
                return String(trimmed.dropFirst("\(provider)_client_id=".count))
            }
        }
    }
    let envName = "AERO_\(provider.uppercased())_CLIENT_ID"
    if let env = getenv(envName) {
        return String(cString: env)
    }
    return fallback
}

let microsoftProvider = OAuthProvider(
    name: "microsoft",
    authorizeURL: "https://login.microsoftonline.com/common/oauth2/v2.0/authorize",
    tokenURL: "https://login.microsoftonline.com/common/oauth2/v2.0/token",
    clientID: "",
    scope: "openid profile email offline_access"
)

let appleProvider = OAuthProvider(
    name: "apple",
    authorizeURL: "https://appleid.apple.com/auth/authorize",
    tokenURL: "https://appleid.apple.com/auth/token",
    clientID: "",
    scope: "name email"
)

let githubProvider = OAuthProvider(
    name: "github",
    authorizeURL: "https://github.com/login/oauth/authorize",
    tokenURL: "https://github.com/login/oauth/access_token",
    clientID: "",
    scope: "read:user"
)

func beginDeviceCodeSignIn(provider: OAuthProvider) {
    var provider = provider
    let resolved = oauthClientID(for: provider.name)
    provider = OAuthProvider(
        name: provider.name,
        authorizeURL: provider.authorizeURL,
        tokenURL: provider.tokenURL,
        clientID: resolved,
        scope: provider.scope
    )
    SettingsState.shared.accountStatus = "Starting \(provider.name) device sign-in…"
    Thread.detachNewThread {
        if provider.name == "github" {
            guard !provider.clientID.isEmpty else {
                SettingsState.shared.accountStatus = "Set github_client_id in ~/.config/aero/oauth.conf"
                return
            }
            guard let codeJSON = runAndCapture([
                "/usr/local/bin/curl", "-s", "-X", "POST",
                "-H", "Accept: application/json",
                "https://github.com/login/device/code",
                "-d", "client_id=\(provider.clientID)&scope=\(provider.scope)"
            ]), let data = codeJSON.data(using: .utf8),
               let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let deviceCode = obj["device_code"] as? String,
               let userCode = obj["user_code"] as? String,
               let verify = obj["verification_uri"] as? String else {
                SettingsState.shared.accountStatus = "GitHub device code failed"
                return
            }
            let interval = (obj["interval"] as? Int) ?? 5
            SettingsState.shared.accountStatus = "GitHub: open \(verify) and enter \(userCode)"
            spawnDetached(["xdg-open", verify])
            for _ in 0..<60 {
                Thread.sleep(forTimeInterval: Double(interval))
                guard let tokenJSON = runAndCapture([
                    "/usr/local/bin/curl", "-s", "-X", "POST",
                    "-H", "Accept: application/json",
                    "https://github.com/login/oauth/access_token",
                    "-d", "client_id=\(provider.clientID)&device_code=\(deviceCode)&grant_type=urn:ietf:params:oauth:grant-type:device_code"
                ]), let tdata = tokenJSON.data(using: .utf8),
                   let tobj = try? JSONSerialization.jsonObject(with: tdata) as? [String: Any] else { continue }
                if let err = tobj["error"] as? String {
                    if err == "authorization_pending" { continue }
                    if err == "slow_down" { Thread.sleep(forTimeInterval: 5); continue }
                    SettingsState.shared.accountStatus = "GitHub sign-in error: \(err)"
                    return
                }
                if tobj["access_token"] != nil {
                    saveSession(provider: provider, tokenJSON: tokenJSON)
                    SettingsState.shared.accountStatus = "Signed in with GitHub"
                    return
                }
            }
            SettingsState.shared.accountStatus = "GitHub sign-in timed out"
            return
        }

        if provider.name == "microsoft" {
            guard !provider.clientID.isEmpty else {
                SettingsState.shared.accountStatus = "Set microsoft_client_id in ~/.config/aero/oauth.conf"
                return
            }
            guard let codeJSON = runAndCapture([
                "/usr/local/bin/curl", "-s", "-X", "POST",
                "https://login.microsoftonline.com/common/oauth2/v2.0/devicecode",
                "-d", "client_id=\(provider.clientID)&scope=\(provider.scope)"
            ]), let data = codeJSON.data(using: .utf8),
               let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let deviceCode = obj["device_code"] as? String,
               let userCode = obj["user_code"] as? String,
               let verify = (obj["verification_uri"] as? String) ?? (obj["verification_url"] as? String) else {
                SettingsState.shared.accountStatus = "Microsoft device code failed"
                return
            }
            let interval = (obj["interval"] as? Int) ?? 5
            SettingsState.shared.accountStatus = "Microsoft: open \(verify) and enter \(userCode)"
            spawnDetached(["xdg-open", verify])
            for _ in 0..<60 {
                Thread.sleep(forTimeInterval: Double(interval))
                guard let tokenJSON = runAndCapture([
                    "/usr/local/bin/curl", "-s", "-X", "POST",
                    provider.tokenURL,
                    "-d", "grant_type=urn:ietf:params:oauth:grant-type:device_code&client_id=\(provider.clientID)&device_code=\(deviceCode)"
                ]), let tdata = tokenJSON.data(using: .utf8),
                   let tobj = try? JSONSerialization.jsonObject(with: tdata) as? [String: Any] else { continue }
                if let err = tobj["error"] as? String {
                    if err == "authorization_pending" { continue }
                    if err == "slow_down" { Thread.sleep(forTimeInterval: 5); continue }
                    SettingsState.shared.accountStatus = "Microsoft sign-in error: \(err)"
                    return
                }
                if tobj["access_token"] != nil {
                    saveSession(provider: provider, tokenJSON: tokenJSON)
                    SettingsState.shared.accountStatus = "Signed in with Microsoft"
                    return
                }
            }
            SettingsState.shared.accountStatus = "Microsoft sign-in timed out"
            return
        }

        // Apple / fallback: classic loopback OAuth
        beginSignIn(provider: provider)
    }
}

func extractQueryValue(named name: String, fromRequestLine line: String) -> String? {
    guard let pathStart = line.range(of: "GET ")?.upperBound,
          let pathEnd = line.range(of: " HTTP/")?.lowerBound else { return nil }
    let path = String(line[pathStart..<pathEnd])
    guard let components = URLComponents(string: path) else { return nil }
    return components.queryItems?.first(where: { $0.name == name })?.value
}

func listenForAuthorizationCode() -> String? {
    let serverSocket = socket(AF_INET, Int32(SOCK_STREAM.rawValue), 0)
    guard serverSocket >= 0 else { return nil }
    defer { close(serverSocket) }

    var reuse: Int32 = 1
    setsockopt(serverSocket, SOL_SOCKET, SO_REUSEADDR, &reuse, socklen_t(MemoryLayout<Int32>.size))

    var address = sockaddr_in()
    address.sin_family = sa_family_t(AF_INET)
    address.sin_port = oauthLoopbackPort.bigEndian
    address.sin_addr = in_addr(s_addr: inet_addr("127.0.0.1"))

    let bindResult = withUnsafePointer(to: &address) { pointer in
        pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockaddrPointer in
            bind(serverSocket, sockaddrPointer, socklen_t(MemoryLayout<sockaddr_in>.size))
        }
    }
    guard bindResult == 0, listen(serverSocket, 1) == 0 else { return nil }

    let clientSocket = accept(serverSocket, nil, nil)
    guard clientSocket >= 0 else { return nil }
    defer { close(clientSocket) }

    var buffer = [UInt8](repeating: 0, count: 4096)
    let bytesRead = read(clientSocket, &buffer, buffer.count)
    guard bytesRead > 0 else { return nil }

    let request = String(decoding: buffer[0..<bytesRead], as: UTF8.self)
    let firstLine = request.components(separatedBy: "\r\n").first ?? ""
    let code = extractQueryValue(named: "code", fromRequestLine: firstLine)

    let responseBody = """
    <html><head><title>Aero OS</title></head>
    <body style="background:#0d1117;color:#e8ecf4;font-family:sans-serif;text-align:center;padding-top:12%">
    <h1>Sign-in complete</h1>
    <p>You can close this window and return to Aero Settings.</p>
    </body></html>
    """
    let response = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nContent-Length: \(responseBody.utf8.count)\r\nConnection: close\r\n\r\n\(responseBody)"
    _ = response.withCString { pointer in
        write(clientSocket, pointer, strlen(pointer))
    }

    return code
}

func exchangeCodeForTokens(provider: OAuthProvider, code: String) -> String? {
    let form = [
        "grant_type=authorization_code",
        "code=\(code)",
        "client_id=\(provider.clientID)",
        "redirect_uri=\(provider.redirectURI)",
    ].joined(separator: "&")

    return runAndCapture([
        "/usr/local/bin/curl",
        "-s",
        "-X", "POST",
        "-H", "Content-Type: application/x-www-form-urlencoded",
        "-d", form,
        provider.tokenURL,
    ])
}

func saveSession(provider: OAuthProvider, tokenJSON: String) {
    let fileManager = FileManager.default
    try? fileManager.createDirectory(
        atPath: aeroConfigDirectory,
        withIntermediateDirectories: true,
        attributes: [.posixPermissions: 0o700]
    )
    let sessionPath = "\(aeroConfigDirectory)/\(provider.name)-session.json"
    try? tokenJSON.write(toFile: sessionPath, atomically: true, encoding: .utf8)
    try? fileManager.setAttributes([.posixPermissions: 0o600], ofItemAtPath: sessionPath)
}

func beginSignIn(provider: OAuthProvider) {
    let resolved = oauthClientID(for: provider.name)
    let provider = OAuthProvider(
        name: provider.name,
        authorizeURL: provider.authorizeURL,
        tokenURL: provider.tokenURL,
        clientID: resolved,
        scope: provider.scope
    )
    guard !provider.clientID.isEmpty else {
        SettingsState.shared.accountStatus = "Set \(provider.name)_client_id in ~/.config/aero/oauth.conf"
        return
    }
    SettingsState.shared.accountStatus = "Waiting for \(provider.name.capitalized) sign-in in browser…"
    spawnDetached(["xdg-open", provider.fullAuthorizeURL])

    Thread.detachNewThread {
        guard let code = listenForAuthorizationCode() else {
            SettingsState.shared.accountStatus = "Sign-in cancelled or timed out"
            return
        }
        SettingsState.shared.accountStatus = "Exchanging authorization code…"
        guard let tokenJSON = exchangeCodeForTokens(provider: provider, code: code),
              tokenJSON.contains("access_token") else {
            SettingsState.shared.accountStatus = "Token exchange failed for \(provider.name.capitalized)"
            return
        }
        saveSession(provider: provider, tokenJSON: tokenJSON)
        SettingsState.shared.accountStatus = "Signed in with \(provider.name.capitalized) account"
    }
}

func detectExistingSession() {
    if let account = loadLocalAeroAccount(),
       FileManager.default.fileExists(atPath: aeroLocalSessionPath) {
        SettingsState.shared.accountStatus = "Signed in as \(account.username) (Aero account on this computer)"
        return
    }
    for provider in [microsoftProvider, appleProvider, githubProvider] {
        let sessionPath = "\(aeroConfigDirectory)/\(provider.name)-session.json"
        if FileManager.default.fileExists(atPath: sessionPath) {
            SettingsState.shared.accountStatus = "Signed in with \(provider.name.capitalized) account"
            return
        }
    }
}

// MARK: - Local Aero Account (stored on this computer, no server required)

struct LocalAeroAccount {
    let username: String
    let salt: String
    let passwordHash: String
    let created: String
}

var aeroLocalAccountPath: String { "\(aeroConfigDirectory)/aero-account.json" }
var aeroLocalSessionPath: String { "\(aeroConfigDirectory)/aero-session.token" }

func sha256Hex(of input: String) -> String? {
    for tool in ["/sbin/sha256", "/usr/bin/sha256", "/usr/local/bin/sha256"] {
        if FileManager.default.isExecutableFile(atPath: tool),
           let output = runAndCapture([tool, "-q", "-s", input]) {
            return output.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    return nil
}

func randomSaltHex() -> String {
    let first = String(format: "%016lx", UInt64.random(in: UInt64.min...UInt64.max))
    let second = String(format: "%016lx", UInt64.random(in: UInt64.min...UInt64.max))
    return first + second
}

func loadLocalAeroAccount() -> LocalAeroAccount? {
    guard let data = FileManager.default.contents(atPath: aeroLocalAccountPath),
          let object = try? JSONSerialization.jsonObject(with: data) as? [String: String],
          let username = object["username"],
          let salt = object["salt"],
          let passwordHash = object["password_hash"],
          let created = object["created"] else { return nil }
    return LocalAeroAccount(username: username, salt: salt, passwordHash: passwordHash, created: created)
}

func saveLocalAeroAccount(_ account: LocalAeroAccount) -> Bool {
    let fileManager = FileManager.default
    try? fileManager.createDirectory(
        atPath: aeroConfigDirectory,
        withIntermediateDirectories: true,
        attributes: [.posixPermissions: 0o700]
    )
    let object: [String: String] = [
        "username": account.username,
        "salt": account.salt,
        "password_hash": account.passwordHash,
        "created": account.created,
    ]
    guard let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]) else {
        return false
    }
    guard fileManager.createFile(
        atPath: aeroLocalAccountPath,
        contents: data,
        attributes: [.posixPermissions: 0o600]
    ) else { return false }
    return true
}

func readEntryText(_ entry: GtkWidget?) -> String {
    guard let pointer = gtk_editable_get_text(entry) else { return "" }
    return String(cString: pointer).trimmingCharacters(in: .whitespacesAndNewlines)
}

func createLocalAeroAccount() {
    let username = readEntryText(aeroUsernameEntry)
    let password = readEntryText(aeroPasswordEntry)

    guard username.count >= 2 else {
        SettingsState.shared.accountStatus = "Choose a username with at least 2 characters"
        return
    }
    guard password.count >= 4 else {
        SettingsState.shared.accountStatus = "Choose a password with at least 4 characters"
        return
    }
    if loadLocalAeroAccount() != nil {
        SettingsState.shared.accountStatus = "An Aero account already exists on this computer — sign in instead"
        return
    }

    let salt = randomSaltHex()
    guard let hash = sha256Hex(of: salt + password) else {
        SettingsState.shared.accountStatus = "Could not hash password (sha256 tool missing)"
        return
    }

    let formatter = ISO8601DateFormatter()
    let account = LocalAeroAccount(
        username: username,
        salt: salt,
        passwordHash: hash,
        created: formatter.string(from: Date())
    )

    if saveLocalAeroAccount(account) {
        try? "aero-local".write(toFile: aeroLocalSessionPath, atomically: true, encoding: .utf8)
        try? FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: aeroLocalSessionPath)
        "".withCString { gtk_editable_set_text(aeroPasswordEntry, $0) }
        SettingsState.shared.accountStatus = "Aero account '\(username)' created and saved on this computer"
    } else {
        SettingsState.shared.accountStatus = "Failed to save the account file"
    }
}

func signInLocalAeroAccount() {
    let username = readEntryText(aeroUsernameEntry)
    let password = readEntryText(aeroPasswordEntry)

    guard let account = loadLocalAeroAccount() else {
        SettingsState.shared.accountStatus = "No Aero account on this computer yet — create one first"
        return
    }
    guard username == account.username else {
        SettingsState.shared.accountStatus = "Unknown username '\(username)'"
        return
    }
    guard let hash = sha256Hex(of: account.salt + password), hash == account.passwordHash else {
        SettingsState.shared.accountStatus = "Wrong password for '\(username)'"
        return
    }

    try? "aero-local".write(toFile: aeroLocalSessionPath, atomically: true, encoding: .utf8)
    try? FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: aeroLocalSessionPath)
    "".withCString { gtk_editable_set_text(aeroPasswordEntry, $0) }
    SettingsState.shared.accountStatus = "Signed in as \(username) (Aero account on this computer)"
}

func signOutLocalAeroAccount() {
    try? FileManager.default.removeItem(atPath: aeroLocalSessionPath)
    SettingsState.shared.accountStatus = "Signed out of the local Aero account"
}

// MARK: - Layer 2: Over-the-air update engine (GitHub Releases + pkg)

func readLocalVersion() -> String {
    guard let contents = try? String(contentsOfFile: aeroVersionFile, encoding: .utf8) else {
        return "0.0.0"
    }
    return contents.trimmingCharacters(in: .whitespacesAndNewlines)
}

func fetchLatestReleaseTag() -> String? {
    let repo = loadUpdateRepository()
    guard let json = runAndCapture([
        "/usr/local/bin/curl",
        "-s",
        "-H", "Accept: application/vnd.github+json",
        "https://api.github.com/repos/\(repo)/releases/latest",
    ]) else { return nil }

    guard let data = json.data(using: .utf8),
          let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
          let tag = object["tag_name"] as? String else { return nil }
    return tag.hasPrefix("v") ? String(tag.dropFirst()) : tag
}

func isVersion(_ remote: String, newerThan local: String) -> Bool {
    let remoteParts = remote.split(separator: ".").compactMap { Int($0) }
    let localParts = local.split(separator: ".").compactMap { Int($0) }
    for index in 0..<max(remoteParts.count, localParts.count) {
        let remoteValue = index < remoteParts.count ? remoteParts[index] : 0
        let localValue = index < localParts.count ? localParts[index] : 0
        if remoteValue != localValue {
            return remoteValue > localValue
        }
    }
    return false
}

func checkForUpdates() {
    SettingsState.shared.updateStatus = "Checking for updates…"
    SettingsState.shared.updateAvailable = false

    Thread.detachNewThread {
        let localVersion = readLocalVersion()
        guard let remoteVersion = fetchLatestReleaseTag() else {
            SettingsState.shared.updateStatus = "Could not reach the update server (local: \(localVersion))"
            return
        }
        if isVersion(remoteVersion, newerThan: localVersion) {
            SettingsState.shared.updateAvailable = true
            SettingsState.shared.updateStatus = "Update available: \(localVersion) → \(remoteVersion)"
        } else {
            SettingsState.shared.updateStatus = "Aero OS is up to date (version \(localVersion))"
        }
    }
}

func installUpdates() {
    guard SettingsState.shared.updateAvailable else {
        SettingsState.shared.updateStatus = "No update staged. Run a check first."
        return
    }
    SettingsState.shared.updateStatus = "Opening update screen…"
    Thread.detachNewThread {
        spawnDetached(["/usr/local/bin/aero", "upgrade"])
        SettingsState.shared.updateAvailable = false
        SettingsState.shared.updateStatus = "Update finished. Restart to use the new version."
    }
}

// MARK: - Display preferences

func writeDisplayPreference(key: String, value: String) {
    try? FileManager.default.createDirectory(
        atPath: aeroConfigDirectory,
        withIntermediateDirectories: true,
        attributes: nil
    )
    let path = "\(aeroConfigDirectory)/display.conf"
    var lines: [String] = []
    if let existing = try? String(contentsOfFile: path, encoding: .utf8) {
        lines = existing.components(separatedBy: "\n").filter {
            !$0.hasPrefix("\(key)=") && !$0.isEmpty
        }
    }
    lines.append("\(key)=\(value)")
    try? lines.joined(separator: "\n").write(toFile: path, atomically: true, encoding: .utf8)
}

func writeSoundPreference(enabled: Bool) {
    try? FileManager.default.createDirectory(
        atPath: aeroConfigDirectory,
        withIntermediateDirectories: true,
        attributes: nil
    )
    let body = "enabled=\(enabled ? "1" : "0")\nvolume=0.55\n"
    try? body.write(toFile: "\(aeroConfigDirectory)/sound.conf", atomically: true, encoding: .utf8)
    spawnDetached(["/usr/local/bin/aero-sound", enabled ? "success" : "click"])
}

// MARK: - GTK signal handlers

@_cdecl("aero_page_account")
func aeroPageAccount(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    "account".withCString { gtk_stack_set_visible_child_name(globalStack, $0) }
}

@_cdecl("aero_page_display")
func aeroPageDisplay(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    "display".withCString { gtk_stack_set_visible_child_name(globalStack, $0) }
}

@_cdecl("aero_page_updates")
func aeroPageUpdates(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    "updates".withCString { gtk_stack_set_visible_child_name(globalStack, $0) }
}

@_cdecl("aero_page_about")
func aeroPageAbout(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    "about".withCString { gtk_stack_set_visible_child_name(globalStack, $0) }
}

@_cdecl("aero_signin_microsoft")
func aeroSignInMicrosoft(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    beginDeviceCodeSignIn(provider: microsoftProvider)
}

@_cdecl("aero_signin_apple")
func aeroSignInApple(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    // Apple has no public device-code API — loopback with Services ID from oauth.conf
    beginDeviceCodeSignIn(provider: appleProvider)
}

@_cdecl("aero_signin_github")
func aeroSignInGitHub(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    beginDeviceCodeSignIn(provider: githubProvider)
}

@_cdecl("aero_account_create")
func aeroAccountCreate(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    createLocalAeroAccount()
}

@_cdecl("aero_account_signin")
func aeroAccountSignIn(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    signInLocalAeroAccount()
}

@_cdecl("aero_account_signout")
func aeroAccountSignOut(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    signOutLocalAeroAccount()
}

@_cdecl("aero_check_updates")
func aeroCheckUpdates(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    checkForUpdates()
}

@_cdecl("aero_install_updates")
func aeroInstallUpdates(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    installUpdates()
}

@_cdecl("aero_display_light")
func aeroDisplayLight(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    writeDisplayPreference(key: "appearance", value: "light")
}

@_cdecl("aero_display_dark")
func aeroDisplayDark(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    writeDisplayPreference(key: "appearance", value: "dark")
}

@_cdecl("aero_display_night")
func aeroDisplayNight(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    writeDisplayPreference(key: "appearance", value: "night")
}

@_cdecl("aero_display_scale_100")
func aeroDisplayScale100(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    writeDisplayPreference(key: "scale", value: "1.0")
}

@_cdecl("aero_display_scale_150")
func aeroDisplayScale150(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    writeDisplayPreference(key: "scale", value: "1.5")
}

@_cdecl("aero_sound_on")
func aeroSoundOn(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    writeSoundPreference(enabled: true)
}

@_cdecl("aero_sound_off")
func aeroSoundOff(_ button: OpaquePointer?, _ userData: OpaquePointer?) {
    writeSoundPreference(enabled: false)
}

@_cdecl("aero_settings_poll")
func aeroSettingsPoll(_ userData: UnsafeMutableRawPointer?) -> gboolean {
    SettingsState.shared.accountStatus.withCString {
        gtk_label_set_text(accountStatusLabel, $0)
    }
    SettingsState.shared.updateStatus.withCString {
        gtk_label_set_text(updateStatusLabel, $0)
    }
    return 1
}

// MARK: - Widget builders

func makeSidebarButton(_ title: String, handler: @convention(c) (OpaquePointer?, OpaquePointer?) -> Void) -> GtkButton? {
    guard let button = title.withCString({ gtk_button_new_with_label($0) }) else { return nil }
    "sidebar-btn".withCString { gtk_widget_add_css_class(button, $0) }
    gtk_widget_set_halign(button, GTK_ALIGN_FILL)
    _ = g_signal_connect_data(button, "clicked", handler, nil, nil, 0)
    return button
}

func makeActionButton(_ title: String, cssClass: String, handler: @convention(c) (OpaquePointer?, OpaquePointer?) -> Void) -> GtkButton? {
    guard let button = title.withCString({ gtk_button_new_with_label($0) }) else { return nil }
    cssClass.withCString { gtk_widget_add_css_class(button, $0) }
    "settings-action-btn".withCString { gtk_widget_add_css_class(button, $0) }
    gtk_widget_set_halign(button, GTK_ALIGN_START)
    _ = g_signal_connect_data(button, "clicked", handler, nil, nil, 0)
    return button
}

func makePageTitle(_ text: String) -> GtkLabel? {
    guard let label = text.withCString({ gtk_label_new($0) }) else { return nil }
    "settings-page-title".withCString { gtk_widget_add_css_class(label, $0) }
    gtk_label_set_xalign(label, 0)
    return label
}

func makeSectionHeading(_ text: String) -> GtkLabel? {
    guard let label = text.withCString({ gtk_label_new($0) }) else { return nil }
    "settings-section-heading".withCString { gtk_widget_add_css_class(label, $0) }
    gtk_label_set_xalign(label, 0)
    gtk_widget_set_margin_top(label, 10)
    return label
}

func makeBodyLabel(_ text: String) -> GtkLabel? {
    guard let label = text.withCString({ gtk_label_new($0) }) else { return nil }
    "settings-body-label".withCString { gtk_widget_add_css_class(label, $0) }
    gtk_label_set_wrap(label, 1)
    gtk_label_set_xalign(label, 0)
    return label
}

func makePage() -> GtkBox? {
    guard let page = gtk_box_new(GTK_ORIENTATION_VERTICAL, 14) else { return nil }
    "settings-page".withCString { gtk_widget_add_css_class(page, $0) }
    gtk_widget_set_margin_top(page, 28)
    gtk_widget_set_margin_bottom(page, 28)
    gtk_widget_set_margin_start(page, 32)
    gtk_widget_set_margin_end(page, 32)
    return page
}

func buildAccountPage() -> GtkBox? {
    guard let page = makePage() else { return nil }
    gtk_box_append(page, makePageTitle("Account"))

    if let status = "Not signed in".withCString({ gtk_label_new($0) }) {
        "settings-status-label".withCString { gtk_widget_add_css_class(status, $0) }
        gtk_label_set_xalign(status, 0)
        accountStatusLabel = status
        gtk_box_append(page, status)
    }

    gtk_box_append(page, makeSectionHeading("Aero Account — saved on this computer"))
    gtk_box_append(page, makeBodyLabel(
        "Create a personal Aero account that lives entirely on this machine. The username and a salted password hash are stored in ~/.config/aero/aero-account.json — no internet, no server, and your password itself is never written to disk."
    ))

    if let usernameEntry = gtk_entry_new() {
        "settings-entry".withCString { gtk_widget_add_css_class(usernameEntry, $0) }
        "Username".withCString { gtk_entry_set_placeholder_text(usernameEntry, $0) }
        gtk_widget_set_size_request(usernameEntry, 320, -1)
        gtk_widget_set_halign(usernameEntry, GTK_ALIGN_START)
        aeroUsernameEntry = usernameEntry
        gtk_box_append(page, usernameEntry)
    }

    if let passwordEntry = gtk_entry_new() {
        "settings-entry".withCString { gtk_widget_add_css_class(passwordEntry, $0) }
        "Password".withCString { gtk_entry_set_placeholder_text(passwordEntry, $0) }
        gtk_entry_set_visibility(passwordEntry, 0)
        gtk_entry_set_invisible_char(passwordEntry, 0x2022)
        gtk_widget_set_size_request(passwordEntry, 320, -1)
        gtk_widget_set_halign(passwordEntry, GTK_ALIGN_START)
        aeroPasswordEntry = passwordEntry
        gtk_box_append(page, passwordEntry)
    }

    guard let aeroAccountRow = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 10) else { return page }
    gtk_box_append(aeroAccountRow, makeActionButton("Create Aero Account", cssClass: "signin-aero", handler: aeroAccountCreate))
    gtk_box_append(aeroAccountRow, makeActionButton("Sign In", cssClass: "signin-aero", handler: aeroAccountSignIn))
    gtk_box_append(aeroAccountRow, makeActionButton("Sign Out", cssClass: "signin-aero", handler: aeroAccountSignOut))
    gtk_box_append(page, aeroAccountRow)

    gtk_box_append(page, makeSectionHeading("Cloud accounts"))
    gtk_box_append(page, makeBodyLabel(
        "Cloud sign-in uses live OAuth device flows (GitHub + Microsoft). Put client IDs in ~/.config/aero/oauth.conf (github_client_id=, microsoft_client_id=, apple_client_id=). Apple uses browser loopback. Aero never sees your password."
    ))

    gtk_box_append(page, makeActionButton("Sign in with Microsoft Account", cssClass: "signin-microsoft", handler: aeroSignInMicrosoft))
    gtk_box_append(page, makeActionButton("Sign in with Apple ID", cssClass: "signin-apple", handler: aeroSignInApple))
    gtk_box_append(page, makeActionButton("Sign in with GitHub", cssClass: "signin-github", handler: aeroSignInGitHub))
    return page
}

func buildDisplayPage() -> GtkBox? {
    guard let page = makePage() else { return nil }
    gtk_box_append(page, makePageTitle("Display"))
    gtk_box_append(page, makeBodyLabel("Choose an appearance — each has its own cloud wallpaper. The desktop switches within a couple of seconds, no restart needed. Preferences are stored in ~/.config/aero/display.conf."))

    guard let appearanceRow = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 10) else { return page }
    gtk_box_append(appearanceRow, makeActionButton("Light", cssClass: "display-light", handler: aeroDisplayLight))
    gtk_box_append(appearanceRow, makeActionButton("Dark", cssClass: "display-dark", handler: aeroDisplayDark))
    gtk_box_append(appearanceRow, makeActionButton("Night", cssClass: "display-night", handler: aeroDisplayNight))
    gtk_box_append(page, appearanceRow)

    guard let scaleRow = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 10) else { return page }
    gtk_box_append(scaleRow, makeActionButton("Scale 100%", cssClass: "display-scale", handler: aeroDisplayScale100))
    gtk_box_append(scaleRow, makeActionButton("Scale 150%", cssClass: "display-scale", handler: aeroDisplayScale150))
    gtk_box_append(page, scaleRow)

    gtk_box_append(page, makeBodyLabel("System sounds use the chill glass scheme — soft pads and quiet chimes. Toggle below; preference is stored in ~/.config/aero/sound.conf."))
    guard let soundRow = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 10) else { return page }
    gtk_box_append(soundRow, makeActionButton("Sounds On", cssClass: "display-sound", handler: aeroSoundOn))
    gtk_box_append(soundRow, makeActionButton("Sounds Off", cssClass: "display-sound", handler: aeroSoundOff))
    gtk_box_append(page, soundRow)
    return page
}

func buildUpdatesPage() -> GtkBox? {
    guard let page = makePage() else { return nil }
    gtk_box_append(page, makePageTitle("Software Update"))
    gtk_box_append(page, makeBodyLabel(
        "Updates are delivered over-the-air from GitHub Releases. The engine compares the version in /etc/aero-version against the latest release tag, then swaps only changed system files through pkg. Your files in /home are never touched."
    ))

    if let status = "Local version: \(readLocalVersion())".withCString({ gtk_label_new($0) }) {
        "settings-status-label".withCString { gtk_widget_add_css_class(status, $0) }
        gtk_label_set_xalign(status, 0)
        updateStatusLabel = status
        gtk_box_append(page, status)
    }

    gtk_box_append(page, makeActionButton("Check for Updates", cssClass: "update-check", handler: aeroCheckUpdates))
    gtk_box_append(page, makeActionButton("Install Update and Prepare Restart", cssClass: "update-install", handler: aeroInstallUpdates))
    return page
}

func buildAboutPage() -> GtkBox? {
    guard let page = makePage() else { return nil }

    let logoPath = "/usr/local/share/aero/aero-logo.png"
    if FileManager.default.fileExists(atPath: logoPath),
       let picture = logoPath.withCString({ gtk_picture_new_for_filename($0) }) {
        gtk_widget_set_size_request(picture, 220, 140)
        gtk_widget_set_halign(picture, GTK_ALIGN_START)
        gtk_box_append(page, picture)
    }

    gtk_box_append(page, makePageTitle("About Aero OS"))
    gtk_box_append(page, makeBodyLabel("Version \(readLocalVersion())"))
    gtk_box_append(page, makeBodyLabel("Unix foundation: FreeBSD 14.2-RELEASE (amd64)"))
    gtk_box_append(page, makeBodyLabel("Desktop: Aero shell on Weston (Wayland), built with Swift 5.10 and GTK4"))
    gtk_box_append(page, makeBodyLabel("Updates: over-the-air via GitHub Releases and pkg"))
    return page
}

// MARK: - Application activation

@_cdecl("aero_settings_activate")
func aeroSettingsActivate(_ app: OpaquePointer?, _ userData: OpaquePointer?) {
    guard let application = app,
          let window = gtk_application_window_new(application) else { return }

    "Aero Settings".withCString { gtk_window_set_title(window, $0) }
    gtk_window_set_default_size(window, 920, 620)

    if let provider = gtk_css_provider_new() {
        "/usr/local/share/aero/style.css".withCString {
            _ = gtk_css_provider_load_from_path(provider, $0)
        }
        if let display = gtk_widget_get_display(window) {
            gtk_style_context_add_provider_for_display(display, provider, GTK_STYLE_PROVIDER_PRIORITY_APPLICATION)
        }
    }

    guard let rootPane = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 0) else { return }
    "aero-settings-root".withCString { gtk_widget_set_name(rootPane, $0) }

    guard let sidebar = gtk_box_new(GTK_ORIENTATION_VERTICAL, 6) else { return }
    "aero-settings-sidebar".withCString { gtk_widget_set_name(sidebar, $0) }
    gtk_widget_set_size_request(sidebar, 220, -1)
    gtk_widget_set_vexpand(sidebar, 1)
    gtk_widget_set_margin_top(sidebar, 16)
    gtk_widget_set_margin_bottom(sidebar, 16)
    gtk_widget_set_margin_start(sidebar, 12)
    gtk_widget_set_margin_end(sidebar, 12)

    if let heading = "Aero Settings".withCString({ gtk_label_new($0) }) {
        "settings-sidebar-heading".withCString { gtk_widget_add_css_class(heading, $0) }
        gtk_label_set_xalign(heading, 0)
        gtk_widget_set_margin_bottom(heading, 10)
        gtk_box_append(sidebar, heading)
    }

    gtk_box_append(sidebar, makeSidebarButton("Account", handler: aeroPageAccount))
    gtk_box_append(sidebar, makeSidebarButton("Display", handler: aeroPageDisplay))
    gtk_box_append(sidebar, makeSidebarButton("Software Update", handler: aeroPageUpdates))
    gtk_box_append(sidebar, makeSidebarButton("About", handler: aeroPageAbout))

    guard let stack = gtk_stack_new() else { return }
    globalStack = stack
    gtk_stack_set_transition_type(stack, GTK_STACK_TRANSITION_TYPE_CROSSFADE)
    gtk_stack_set_transition_duration(stack, 180)
    gtk_widget_set_hexpand(stack, 1)
    gtk_widget_set_vexpand(stack, 1)
    "aero-settings-content".withCString { gtk_widget_set_name(stack, $0) }

    if let accountPage = buildAccountPage() {
        "account".withCString { gtk_stack_add_named(stack, accountPage, $0) }
    }
    if let displayPage = buildDisplayPage() {
        "display".withCString { gtk_stack_add_named(stack, displayPage, $0) }
    }
    if let updatesPage = buildUpdatesPage() {
        "updates".withCString { gtk_stack_add_named(stack, updatesPage, $0) }
    }
    if let aboutPage = buildAboutPage() {
        "about".withCString { gtk_stack_add_named(stack, aboutPage, $0) }
    }
    "account".withCString { gtk_stack_set_visible_child_name(stack, $0) }

    gtk_box_append(rootPane, sidebar)
    gtk_box_append(rootPane, stack)
    gtk_window_set_child(window, rootPane)

    detectExistingSession()
    _ = g_timeout_add(500, aeroSettingsPoll, nil)

    gtk_window_present(window)
}

guard let application = gtk_application_new("org.aero.Settings", GTK_APPLICATION_FLAGS_NONE) else {
    fputs("Aero Settings: failed to create GTK application.\n", stderr)
    exit(1)
}

_ = g_signal_connect_data(application, "activate", aeroSettingsActivate, nil, nil, 0)
let status = g_application_run(application, 0, nil)
exit(status)
