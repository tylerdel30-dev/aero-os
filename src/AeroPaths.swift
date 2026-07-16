enum AeroPaths {
    static let shareRoot = "/usr/local/share/aero"
    static let desktopCSS = "\(shareRoot)/style.css"
    static let settingsCSS = "\(shareRoot)/settings.css"
    static let versionFile = "/etc/aero-version"
    static let updateConfig = "\(shareRoot)/update.conf"
    static let oauthProviders = "\(shareRoot)/oauth-providers.json"
    static let shellBinary = "/usr/local/bin/aero-shell"
    static let settingsBinary = "/usr/local/bin/aero-settings"
    static let installerBinary = "/usr/local/sbin/aero-install"
    static let updaterScript = "/usr/local/sbin/aero-updater"
    static let terminalBinary = "/usr/local/bin/foot"
    static let filesBinary = "/usr/local/bin/thunar"

    static func userConfigDir(for username: String = NSUserName()) -> String {
        "/home/\(username)/.config/aero"
    }

    static func sessionStore(for username: String = NSUserName()) -> String {
        "\(userConfigDir(for: username))/sessions.json"
    }

    static func displayPrefs(for username: String = NSUserName()) -> String {
        "\(userConfigDir(for: username))/display.json"
    }
}
