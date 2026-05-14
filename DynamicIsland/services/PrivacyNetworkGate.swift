/*
 * Atoll (DynamicIsland)
 * Privacy hardening for local-only builds.
 */

import Defaults
import Foundation

enum PrivacyNetworkFeature: String {
    case externalAI
    case localAI
    case weather
    case lyrics
    case musicMetadata
    case remoteArtwork
    case remoteIdleAnimation
    case localSend
    case youtubeMusic

    var displayName: String {
        switch self {
        case .externalAI: return "external AI providers"
        case .localAI: return "local AI provider"
        case .weather: return "weather"
        case .lyrics: return "lyrics"
        case .musicMetadata: return "music metadata"
        case .remoteArtwork: return "remote artwork"
        case .remoteIdleAnimation: return "remote idle animations"
        case .localSend: return "LocalSend sharing"
        case .youtubeMusic: return "YouTube Music local bridge"
        }
    }
}

enum PrivacyNetworkError: LocalizedError {
    case blocked(feature: PrivacyNetworkFeature, url: URL, reason: String)

    var errorDescription: String? {
        switch self {
        case let .blocked(feature, url, reason):
            return "Blocked \(feature.displayName) network request to \(url.absoluteString): \(reason)"
        }
    }
}

struct PrivacyNetworkGate {
    private init() {}

    @discardableResult
    static func validate(_ request: URLRequest, feature: PrivacyNetworkFeature) throws -> URLRequest {
        guard let url = request.url else {
            throw PrivacyNetworkError.blocked(feature: feature, url: URL(fileURLWithPath: "/"), reason: "request has no URL")
        }
        try validate(url, feature: feature)
        return request
    }

    static func validate(_ url: URL, feature: PrivacyNetworkFeature) throws {
        guard let scheme = url.scheme?.lowercased(), ["http", "https", "ws", "wss"].contains(scheme) else {
            throw PrivacyNetworkError.blocked(feature: feature, url: url, reason: "unsupported URL scheme")
        }

        guard let host = url.host?.lowercased(), !host.isEmpty else {
            throw PrivacyNetworkError.blocked(feature: feature, url: url, reason: "missing host")
        }

        switch feature {
        case .externalAI:
            guard Defaults[.enableScreenAssistant] else {
                throw PrivacyNetworkError.blocked(feature: feature, url: url, reason: "Screen Assistant is disabled")
            }
            guard Defaults[.enableExternalAIProviders] else {
                throw PrivacyNetworkError.blocked(feature: feature, url: url, reason: "external AI providers are disabled")
            }
            guard isHTTPS(scheme),
                  matches(host, "generativelanguage.googleapis.com") ||
                  matches(host, "api.openai.com") ||
                  matches(host, "api.groq.com") ||
                  matches(host, "api.anthropic.com") else {
                throw PrivacyNetworkError.blocked(feature: feature, url: url, reason: "host is not an approved AI endpoint")
            }
            // generativelanguage.googleapis.com: Gemini; sends prompts and user-attached files when enabled.
            // api.openai.com: OpenAI chat completions; sends prompts and text context when enabled.
            // api.groq.com: Groq OpenAI-compatible chat completions; sends prompts and text context when enabled.
            // api.anthropic.com: Anthropic Claude messages; sends prompts and text context when enabled.

        case .localAI:
            guard Defaults[.enableScreenAssistant] else {
                throw PrivacyNetworkError.blocked(feature: feature, url: url, reason: "Screen Assistant is disabled")
            }
            guard isLoopbackHost(host) else {
                throw PrivacyNetworkError.blocked(feature: feature, url: url, reason: "local AI is restricted to localhost")
            }
            // localhost / 127.0.0.1 / ::1: local Ollama-compatible chat service only.

        case .weather:
            guard Defaults[.enableLockScreenWeatherWidget] else {
                throw PrivacyNetworkError.blocked(feature: feature, url: url, reason: "weather is disabled")
            }
            guard isHTTPS(scheme), matches(host, "wttr.in") || matches(host, "open-meteo.com") else {
                throw PrivacyNetworkError.blocked(feature: feature, url: url, reason: "host is not an approved weather endpoint")
            }
            // wttr.in: optional weather fallback; may receive coarse location or IP-derived request.
            // api.open-meteo.com / air-quality-api.open-meteo.com: optional forecast and AQI using coordinates.

        case .lyrics:
            guard Defaults[.enableLyrics] else {
                throw PrivacyNetworkError.blocked(feature: feature, url: url, reason: "lyrics lookups are disabled")
            }
            guard isHTTPS(scheme), matches(host, "lrclib.net") else {
                throw PrivacyNetworkError.blocked(feature: feature, url: url, reason: "host is not an approved lyrics endpoint")
            }
            // lrclib.net: optional lyrics lookup; receives track title and artist.

        case .musicMetadata:
            guard Defaults[.enableMusicMetadataLookups] else {
                throw PrivacyNetworkError.blocked(feature: feature, url: url, reason: "music metadata lookups are disabled")
            }
            guard isHTTPS(scheme),
                  matches(host, "itunes.apple.com") ||
                  matches(host, "open.spotify.com") else {
                throw PrivacyNetworkError.blocked(feature: feature, url: url, reason: "host is not an approved music metadata endpoint")
            }
            // itunes.apple.com: optional explicitness/artwork fallback; receives title/artist/album search terms.
            // open.spotify.com: optional explicitness lookup; receives Spotify track ID.

        case .remoteArtwork:
            guard Defaults[.enableRemoteArtworkLoading] else {
                throw PrivacyNetworkError.blocked(feature: feature, url: url, reason: "remote artwork loading is disabled")
            }
            guard isHTTPS(scheme) else {
                throw PrivacyNetworkError.blocked(feature: feature, url: url, reason: "remote artwork must use HTTPS")
            }
            // Artwork URLs come from the active media app/provider. Enable only if remote cover art is acceptable.

        case .remoteIdleAnimation:
            guard Defaults[.enableRemoteIdleAnimationURLs] else {
                throw PrivacyNetworkError.blocked(feature: feature, url: url, reason: "remote idle animation URLs are disabled")
            }
            guard isHTTPS(scheme) else {
                throw PrivacyNetworkError.blocked(feature: feature, url: url, reason: "remote idle animation URLs must use HTTPS")
            }
            // User-supplied remote Lottie URLs. Disabled by default because the renderer fetches third-party content.

        case .localSend:
            guard Defaults[.quickShareProvider] == "LocalSend" else {
                throw PrivacyNetworkError.blocked(feature: feature, url: url, reason: "LocalSend is not the selected sharing provider")
            }
            guard isPrivateOrLocalHost(host) else {
                throw PrivacyNetworkError.blocked(feature: feature, url: url, reason: "LocalSend is restricted to loopback, private LAN, or .local hosts")
            }
            // LocalSend: user-initiated LAN discovery and file transfer to private/local hosts only.

        case .youtubeMusic:
            guard Defaults[.mediaController] == .youtubeMusic else {
                throw PrivacyNetworkError.blocked(feature: feature, url: url, reason: "YouTube Music controller is disabled")
            }
            guard isLoopbackHost(host) else {
                throw PrivacyNetworkError.blocked(feature: feature, url: url, reason: "YouTube Music bridge is restricted to localhost")
            }
            // localhost / 127.0.0.1 / ::1: companion bridge on the same Mac.
        }
    }

    static func data(from url: URL, using session: URLSession = .shared, feature: PrivacyNetworkFeature) async throws -> (Data, URLResponse) {
        try validate(url, feature: feature)
        return try await session.data(from: url)
    }

    static func data(for request: URLRequest, using session: URLSession = .shared, feature: PrivacyNetworkFeature) async throws -> (Data, URLResponse) {
        try validate(request, feature: feature)
        return try await session.data(for: request)
    }

    static func dataTask(
        with request: URLRequest,
        using session: URLSession = .shared,
        feature: PrivacyNetworkFeature,
        completion: @escaping (Data?, URLResponse?, Error?) -> Void
    ) throws -> URLSessionDataTask {
        try validate(request, feature: feature)
        return session.dataTask(with: request, completionHandler: completion)
    }

    static func uploadTask(
        with request: URLRequest,
        from bodyData: Data,
        using session: URLSession = .shared,
        feature: PrivacyNetworkFeature,
        completion: @escaping (Data?, URLResponse?, Error?) -> Void
    ) throws -> URLSessionUploadTask {
        try validate(request, feature: feature)
        return session.uploadTask(with: request, from: bodyData, completionHandler: completion)
    }

    private static func isHTTPS(_ scheme: String) -> Bool {
        scheme == "https"
    }

    private static func matches(_ host: String, _ domain: String) -> Bool {
        host == domain || host.hasSuffix(".\(domain)")
    }

    private static func isLoopbackHost(_ host: String) -> Bool {
        let normalized = host.trimmingCharacters(in: CharacterSet(charactersIn: "[]")).lowercased()
        return normalized == "localhost" ||
            normalized == "::1" ||
            normalized == "0:0:0:0:0:0:0:1" ||
            normalized.hasPrefix("127.")
    }

    private static func isPrivateOrLocalHost(_ host: String) -> Bool {
        let normalized = host.trimmingCharacters(in: CharacterSet(charactersIn: "[]")).lowercased()
        if isLoopbackHost(normalized) || normalized.hasSuffix(".local") {
            return true
        }

        let octets = normalized.split(separator: ".").compactMap { Int($0) }
        guard octets.count == 4 else { return false }

        if octets[0] == 10 { return true }
        if octets[0] == 172, (16...31).contains(octets[1]) { return true }
        if octets[0] == 192, octets[1] == 168 { return true }
        if octets[0] == 169, octets[1] == 254 { return true }
        return false
    }
}
