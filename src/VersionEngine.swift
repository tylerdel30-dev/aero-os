import Foundation

struct GitHubRelease: Codable {
    let tagName: String

    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
    }
}

struct UpdateConfig {
    let githubRepo: String

    static func load() -> UpdateConfig {
        let defaultRepo = "tylerdel30-dev/aero-os"
        guard let contents = try? String(contentsOfFile: AeroPaths.updateConfig, encoding: .utf8) else {
            return UpdateConfig(githubRepo: defaultRepo)
        }
        for line in contents.split(separator: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("github_repo=") {
                let value = trimmed.replacingOccurrences(of: "github_repo=", with: "")
                if !value.isEmpty {
                    return UpdateConfig(githubRepo: value)
                }
            }
        }
        return UpdateConfig(githubRepo: defaultRepo)
    }
}

enum VersionEngine {
    static func readLocalVersion() -> String {
        (try? String(contentsOfFile: AeroPaths.versionFile, encoding: .utf8))?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? "0.0.0"
    }

    static func isNewer(remote: String, local: String) -> Bool {
        normalize(remote) > normalize(local)
    }

    static func normalize(_ version: String) -> [Int] {
        version
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "^v", with: "", options: .regularExpression)
            .split(separator: ".")
            .map { Int($0) ?? 0 }
    }

    static func fetchLatestRelease(completion: @escaping (Result<String, Error>) -> Void) {
        let config = UpdateConfig.load()
        guard let url = URL(string: "https://api.github.com/repos/\(config.githubRepo)/releases/latest") else {
            completion(.failure(NSError(domain: "AeroOS", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Invalid release URL"
            ])))
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            var request = URLRequest(url: url)
            request.setValue("AeroOS-Updater/1.0", forHTTPHeaderField: "User-Agent")
            do {
                let (data, response) = try URLSession.shared.syncData(for: request)
                guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                    throw NSError(domain: "AeroOS", code: 2, userInfo: [
                        NSLocalizedDescriptionKey: "GitHub API request failed"
                    ])
                }
                let release = try JSONDecoder().decode(GitHubRelease.self, from: data)
                completion(.success(release.tagName))
            } catch {
                completion(.failure(error))
            }
        }
    }

    static func runSystemUpgrade(completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: AeroPaths.updaterScript)
            process.arguments = ["--apply"]
            do {
                try process.run()
                process.waitUntilExit()
                completion(process.terminationStatus == 0)
            } catch {
                completion(false)
            }
        }
    }
}

private extension URLSession {
    func syncData(for request: URLRequest) throws -> (Data, URLResponse) {
        var result: Result<(Data, URLResponse), Error>?
        let semaphore = DispatchSemaphore(value: 0)
        let task = dataTask(with: request) { data, response, error in
            if let error = error {
                result = .failure(error)
            } else if let data = data, let response = response {
                result = .success((data, response))
            } else {
                result = .failure(NSError(domain: "AeroOS", code: 3))
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        switch result {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        case .none:
            throw NSError(domain: "AeroOS", code: 4)
        }
    }
}
