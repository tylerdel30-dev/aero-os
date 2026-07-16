import Foundation
import Glibc

typealias WebKitWebView = OpaquePointer

@_silgen_name("webkit_web_view_new")
func webkit_web_view_new() -> WebKitWebView?

@_silgen_name("webkit_web_view_load_uri")
func webkit_web_view_load_uri(_ webView: WebKitWebView?, _ uri: UnsafePointer<CChar>)

@_silgen_name("webkit_web_view_get_uri")
func webkit_web_view_get_uri(_ webView: WebKitWebView?) -> UnsafePointer<CChar>?

@_silgen_name("g_idle_add")
func g_idle_add(
    _ function: @convention(c) (UnsafeMutableRawPointer?) -> gboolean,
    _ data: UnsafeMutableRawPointer?
) -> guint

final class OAuthWebContext {
    let window: GtkWindow
    let webView: WebKitWebView
    let redirectPrefix: String
    let callbackPath: String

    init(window: GtkWindow, webView: WebKitWebView, redirectPrefix: String, callbackPath: String) {
        self.window = window
        self.webView = webView
        self.redirectPrefix = redirectPrefix
        self.callbackPath = callbackPath
    }
}

private var oauthContext: Unmanaged<OAuthWebContext>?

@_cdecl("aero_oauth_load_changed")
func aeroOAuthLoadChanged(_ webView: OpaquePointer?, _ loadEvent: Int32, _ userData: OpaquePointer?) {
    guard let webView = webView, let userData = userData else { return }
    let context = Unmanaged<OAuthWebContext>.fromOpaque(userData).takeUnretainedValue()
    guard let uriPointer = webkit_web_view_get_uri(webView) else { return }
    let uri = String(cString: uriPointer)
    if uri.hasPrefix(context.redirectPrefix) {
        if let query = URL(string: uri)?.query {
            for part in query.split(separator: "&") {
                let pieces = part.split(separator: "=", maxSplits: 1)
                if pieces.count == 2, pieces[0] == "code" {
                    let code = String(pieces[1])
                    try? code.write(toFile: context.callbackPath, atomically: true, encoding: .utf8)
                    chmod(context.callbackPath, 0o600)
                    exit(0)
                }
            }
        }
    }
}

@_cdecl("aero_oauth_activate")
func aeroOAuthActivate(_ app: OpaquePointer?, _ userData: OpaquePointer?) {
    guard let application = app else { return }
    let args = CommandLine.arguments
    guard args.count >= 2 else {
        fputs("Usage: aero-oauth-webview <auth-url>\n", stderr)
        exit(1)
    }

    let authURL = args[1]
    let callbackPath = ProcessInfo.processInfo.environment["AERO_OAUTH_CALLBACK"] ?? "/tmp/aero-oauth.callback"
    let redirectScheme = ProcessInfo.processInfo.environment["AERO_OAUTH_REDIRECT"] ?? "aero://auth"

    guard let window = gtk_application_window_new(application) else { return }
    "Sign In".withCString { gtk_window_set_title(window, $0) }
    gtk_window_set_default_size(window, 520, 680)

    guard let webView = webkit_web_view_new() else { return }
    authURL.withCString { webkit_web_view_load_uri(webView, $0) }

    let context = OAuthWebContext(
        window: window,
        webView: webView,
        redirectPrefix: redirectScheme,
        callbackPath: callbackPath
    )
    let retained = Unmanaged.passRetained(context)
    oauthContext = retained

    _ = g_signal_connect_data(webView, "load-changed", aeroOAuthLoadChanged, retained.toOpaque(), nil, 0)
    gtk_window_set_child(window, webView)
    gtk_window_present(window)
}

gtk_init()

guard let application = gtk_application_new("org.aero.OAuthWebView", GTK_APPLICATION_FLAGS_NONE) else {
    exit(1)
}

_ = g_signal_connect_data(application, "activate", aeroOAuthActivate, nil, nil, 0)
let status = g_application_run(application, 0, nil)
exit(Int32(status))
