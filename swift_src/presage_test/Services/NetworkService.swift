//
//  NetworkService.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-11.
//

import Foundation

class NetworkService {
    static let shared = NetworkService()
    private let baseURL = "https://carolee-nonerosive-prewillingly.ngrok-free.dev"

    private init() {}

    // MARK: - Fetch Driver History

    func fetchDriverHistory(fullName: String) async throws -> DriverHistoryResponse {
        let urlString = "\(baseURL)/drivers/\(fullName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? fullName)"
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw NetworkError.httpError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(DriverHistoryResponse.self, from: data)
    }

    // MARK: - Network Errors

    enum NetworkError: Error, LocalizedError {
        case invalidURL
        case invalidResponse
        case httpError(Int)
        case decodingError

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL"
            case .invalidResponse:
                return "Invalid server response"
            case .httpError(let code):
                return "Server error: \(code)"
            case .decodingError:
                return "Failed to decode response"
            }
        }
    }
}
