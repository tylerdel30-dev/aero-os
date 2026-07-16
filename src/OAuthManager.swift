import Foundation

struct OAuthProvider: Codable {
    let id: String
    let name: String
    let authURL: String
    let redirectScheme: String
    let tokenEndpoint: String
}

struct OAuthProviderList: Codable {
    let providers: [OAuthProvider]
}

struct StoredSession: Codable {
    let providerID: String
    let accountLabel: String
    let encryptedToken: String
    let savedAt: String
}

struct SessionStore: Codable {
    var sessions: [StoredSession]
}

enum OAuthManager {
    static func loadProviders() -> [OAuthProvider] {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: AeroPaths.oauthProviders)),
              let list = try? JSONDecoder().decode(OAuthProviderList.self, from: data) else {
            return []
        }
        return list.providers
    }

    static func loadSessions() -> SessionStore {
        let path = AeroPaths.sessionStore()
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let store = try? JSONDecoder().decode(SessionStore.self, from: data) else {
            return SessionStore(sessions: [])
        }
        return store
    }

    static func saveSession(provider: OAuthProvider, authorizationCode: String, accountLabel: String) {
        let token = sealToken(authorizationCode, for: provider.id)
        let session = StoredSession(
            providerID: provider.id,
            accountLabel: accountLabel,
            encryptedToken: token,
            savedAt: ISO8601DateFormatter().string(from: Date())
        )
        var store = loadSessions()
        store.sessions.removeAll { $0.providerID == provider.id }
        store.sessions.append(session)
        persist(store)
    }

    static func sessionLabel(for providerID: String) -> String? {
        loadSessions().sessions.first { $0.providerID == providerID }?.accountLabel
    }

    static func beginLogin(provider: OAuthProvider, completion: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let callbackPath = "/tmp/aero-oauth-\(provider.id).callback"
            try? FileManager.default.removeItem(atPath: callbackPath)
            let authURL = provider.authURL
            let webViewScript = """
            #!/bin/sh
            export AERO_OAUTH_CALLBACK="\(callbackPath)"
            export AERO_OAUTH_REDIRECT="\(provider.redirectScheme)"
            exec /usr/local/bin/aero-oauth-webview "\(authURL)"
            """
            let scriptPath = "/tmp/aero-oauth-launch-\(provider.id).sh"
            try? webViewScript.write(toFile: scriptPath, atomically: true, encoding: .utf8)
            chmod(scriptPath, 0o755)
            launchExecutable("/bin/sh", arguments: [scriptPath])

            let deadline = Date().addingTimeInterval(300)
            while Date() < deadline {
                if let code = try? String(contentsOfFile: callbackPath, encoding: .utf8),
                   !code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    DispatchQueue.main.async {
                        completion(.success(code.trimmingCharacters(in: .whitespacesAndNewlines)))
                    }
                    return
                }
                Thread.sleep(forTimeInterval: 0.5)
            }
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "AeroOS", code: 10, userInfo: [
                    NSLocalizedDescriptionKey: "Authentication timed out"
                ])))
            }
        }
    }

    private static func persist(_ store: SessionStore) {
        let path = AeroPaths.sessionStore()
        let directory = (path as NSString).deletingLastPathComponent
        try? FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true)
        if let data = try? JSONEncoder().encode(store) {
            try? data.write(to: URL(fileURLWithPath: path))
            chmod(path, 0o600)
        }
    }

    private static func sealToken(_ token: String, for providerID: String) -> String {
        let payload = "\(providerID):\(token):\(UUID().uuidString)"
        return Data(payload.utf8).base64EncodedString()
    }

    private static func chmod(_ path: String, _ mode: Int32) {
        path.withCString { cPath in
            _ = Glibc.chmod(cPath, mode_t(mode))
        }
    }
}
