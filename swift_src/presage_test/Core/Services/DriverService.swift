//
//  DriverService.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-11.
//

import Foundation

// MARK: - Driver Service
class DriverService {
    static let shared = DriverService()

    private let baseURL = "https://carolee-nonerosive-prewillingly.ngrok-free.dev"

    private init() {}

    // MARK: - Fetch Driver Vitals
    func fetchDriverVitals(fullName: String) async throws -> [DriverVitals] {
        // URL encode the full name
        guard let encodedName = fullName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            throw DriverServiceError.invalidURL
        }

        let urlString = "\(baseURL)/drivers/\(encodedName)"

        guard let url = URL(string: urlString) else {
            throw DriverServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw DriverServiceError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw DriverServiceError.httpError(statusCode: httpResponse.statusCode)
        }

        // Try to decode the response
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        // The API might return an array directly or wrapped in an object
        do {
            // Try decoding as array first
            let vitals = try decoder.decode([DriverVitals].self, from: data)
            return vitals
        } catch {
            // Try decoding as wrapped response
            do {
                let response = try decoder.decode(DriverVitalsResponse.self, from: data)
                if let errorMessage = response.error {
                    throw DriverServiceError.apiError(message: errorMessage)
                }
                return response.data ?? []
            } catch {
                throw DriverServiceError.decodingError(error)
            }
        }
    }

    // MARK: - Fetch Latest Driver Vitals
    func fetchLatestDriverVitals(fullName: String) async throws -> DriverVitals? {
        let allVitals = try await fetchDriverVitals(fullName: fullName)
        // Return the most recent vitals
        return allVitals.sorted { $0.timestamp > $1.timestamp }.first
    }
}

// MARK: - Service Errors
enum DriverServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case apiError(message: String)
    case decodingError(Error)
    case noData

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .apiError(let message):
            return "API error: \(message)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .noData:
            return "No data available"
        }
    }
}
