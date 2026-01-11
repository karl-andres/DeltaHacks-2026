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

    // Simulated driver database
    private let driverDatabase: [String: (password: String, driver: Driver)] = [
        "john.driver@trucking.com": (
            password: "password123",
            driver: Driver(
                id: UUID().uuidString,
                name: "John Driver",
                email: "john.driver@trucking.com",
                phone: "+1 (555) 123-4567",
                company: "Swift Transport",
                driverId: "DRV-2024-1247",
                shiftType: .day,
                licenseNumber: "CDL-ABC-123456",
                dateJoined: Date().addingTimeInterval(-365 * 24 * 60 * 60),
                totalShifts: 247,
                hoursDrivern: 1842,
                averageAlertness: 87
            )
        ),
        "jane.night@trucking.com": (
            password: "night456",
            driver: Driver(
                id: UUID().uuidString,
                name: "Jane Wilson",
                email: "jane.night@trucking.com",
                phone: "+1 (555) 987-6543",
                company: "Swift Transport",
                driverId: "DRV-2024-0892",
                shiftType: .night,
                licenseNumber: "CDL-XYZ-789012",
                dateJoined: Date().addingTimeInterval(-180 * 24 * 60 * 60),
                totalShifts: 156,
                hoursDrivern: 1124,
                averageAlertness: 82
            )
        ),
        "demo@driver.com": (
            password: "demo",
            driver: Driver(
                id: UUID().uuidString,
                name: "Demo Driver",
                email: "demo@driver.com",
                phone: "+1 (555) 000-0000",
                company: "Demo Transport Co.",
                driverId: "DRV-DEMO-0001",
                shiftType: .day,
                licenseNumber: "CDL-DEMO-000",
                dateJoined: Date(),
                totalShifts: 50,
                hoursDrivern: 400,
                averageAlertness: 90
            )
        )
    ]

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

        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        await MainActor.run {
            // Validate credentials
            if let credentials = driverDatabase[email.lowercased()],
               credentials.password == password {
                authState = .authenticated(credentials.driver)
                saveSession(driver: credentials.driver)

                // Fetch driver vitals from API
                Task {
                    await DriverVitalsManager.shared.fetchAndStoreVitals(for: credentials.driver)
                }
            } else {
                authState = .unauthenticated
                errorMessage = "Invalid email or password"
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
