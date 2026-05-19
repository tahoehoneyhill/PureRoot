//
//  AnthropicClient.swift
//  PureRoot
//

import Foundation

enum AnthropicModel: String, CaseIterable {
    case haiku = "claude-haiku-4-5-20251001"
    case sonnet = "claude-sonnet-4-6"
    case opus = "claude-opus-4-7"

    var displayName: String {
        switch self {
        case .haiku: return "Haiku 4.5 (fast, cheap)"
        case .sonnet: return "Sonnet 4.6 (balanced)"
        case .opus: return "Opus 4.7 (best)"
        }
    }
}

enum AnthropicClient {
    struct Message: Codable {
        let role: String
        let content: String
    }

    private struct Tool: Codable {
        let type: String
        let name: String
    }

    private struct Body: Encodable {
        let model: String
        let max_tokens: Int
        let system: String?
        let messages: [Message]
        let tools: [Tool]?
    }

    private struct ContentBlock: Decodable {
        let type: String
        let text: String?
    }

    private struct Response: Decodable {
        let content: [ContentBlock]
    }

    enum ClientError: LocalizedError {
        case noAPIKey
        case http(Int, String)
        case decoding(String)

        var errorDescription: String? {
            switch self {
            case .noAPIKey:
                return "No Anthropic API key set. Add one in Settings."
            case .http(let code, let body):
                return "API error \(code): \(body.prefix(200))"
            case .decoding(let msg):
                return "Could not parse response: \(msg)"
            }
        }
    }

    static func send(
        system: String,
        prompt: String,
        model: AnthropicModel = .haiku,
        useWebSearch: Bool = false,
        maxTokens: Int = 2048
    ) async throws -> String {
        guard let key = KeychainStore.read(for: APIKeys.anthropic), !key.isEmpty else {
            throw ClientError.noAPIKey
        }

        var request = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(key, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let body = Body(
            model: model.rawValue,
            max_tokens: maxTokens,
            system: system,
            messages: [Message(role: "user", content: prompt)],
            tools: useWebSearch ? [Tool(type: "web_search_20250305", name: "web_search")] : nil
        )
        request.httpBody = try JSONEncoder().encode(body)
        request.timeoutInterval = 60

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw ClientError.http(0, "no response")
        }
        guard (200..<300).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw ClientError.http(http.statusCode, body)
        }

        do {
            let decoded = try JSONDecoder().decode(Response.self, from: data)
            return decoded.content.compactMap { $0.text }.joined(separator: "\n\n")
        } catch {
            throw ClientError.decoding(error.localizedDescription)
        }
    }

    static func extractJSON(from text: String) -> String? {
        guard let firstBrace = text.firstIndex(of: "{"),
              let lastBrace = text.lastIndex(of: "}"),
              firstBrace < lastBrace else { return nil }
        return String(text[firstBrace...lastBrace])
    }
}
