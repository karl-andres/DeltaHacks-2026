//
//  AuthenticationManager.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-10.
//

import Foundation
import SwiftUI

class AuthenticationManager: ObservableObject {
    @Published private(set) var authState: AuthState = .unauthenticated
    @Published var errorMessage: String?


    var isAuthenticated: Bool {
        authState.isAuthenticated
    }

    var currentDriver: Driver? {
        authState.driver
    }

    // MARK: - Authentication Actions

    func login(email: String, password: String) async {
        await MainActor.run {
            authState = .authenticating
            errorMessage = nil
        }

        do {
            // Check if driver exists in backend database by attempting to fetch their vitals
            guard let encodedName = email.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
                await MainActor.run {
                    authState = .unauthenticated
                    errorMessage = "Invalid email format"
                }
                return
            }

            let urlString = "https://carolee-nonerosive-prewillingly.ngrok-free.dev/drivers/\(encodedName)"
            guard let url = URL(string: urlString) else {
                await MainActor.run {
                    authState = .unauthenticated
                    errorMessage = "Invalid URL"
                }
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Accept")

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                await MainActor.run {
                    authState = .unauthenticated
                    errorMessage = "Invalid response from server"
                }
                return
            }

            // If driver exists in database (200 response), authenticate them
            if (200...299).contains(httpResponse.statusCode) {
                // Try to decode the vitals to extract driver info
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601

                if let vitals = try? decoder.decode([DriverVitals].self, from: data),
                   let latestVitals = vitals.first {
                    // Create driver object from vitals data
                    let driver = Driver(
                        id: UUID().uuidString,
                        driverId: latestVitals.driverId,
                        fullname: latestVitals.fullname
                    )

                    await MainActor.run {
                        authState = .authenticated(driver)
                        saveSession(driver: driver)
                    }

                    // Fetch and store vitals
                    await DriverVitalsManager.shared.fetchAndStoreVitals(for: driver)
                } else {
                    await MainActor.run {
                        authState = .unauthenticated
                        errorMessage = "Driver not found in database"
                    }
                }
            } else {
                await MainActor.run {
                    authState = .unauthenticated
                    errorMessage = "Driver not found in database"
                }
            }

        } catch {
            await MainActor.run {
                authState = .unauthenticated
                errorMessage = "Failed to verify credentials: \(error.localizedDescription)"
            }
        }
    }

    func logout() {
        authState = .unauthenticated
        errorMessage = nil
        clearSession()
        // Clear driver vitals on logout
        DriverVitalsManager.shared.clearStoredVitals()
    }

    func checkExistingSession() {
        // Check UserDefaults for saved session
        if let driverData = UserDefaults.standard.data(forKey: "savedDriver"),
           let driver = try? JSONDecoder().decode(Driver.self, from: driverData) {
            authState = .authenticated(driver)

            // Fetch fresh driver vitals from API
            Task {
                await DriverVitalsManager.shared.fetchAndStoreVitals(for: driver)
            }
        }
    }

    // MARK: - Session Management

    private func saveSession(driver: Driver) {
        if let encoded = try? JSONEncoder().encode(driver) {
            UserDefaults.standard.set(encoded, forKey: "savedDriver")
        }
    }

    private func clearSession() {
        UserDefaults.standard.removeObject(forKey: "savedDriver")
    }

    // MARK: - Preview Helper

    static var preview: AuthenticationManager {
        let manager = AuthenticationManager()
        manager.authState = .authenticated(.mock)
        return manager
    }
}
