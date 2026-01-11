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
    @Published var isLoading: Bool = false

    var isAuthenticated: Bool {
        authState.isAuthenticated
    }

    var currentDriver: Driver? {
        authState.driver
    }

    // MARK: - Authentication Actions

    func login(fullName: String, driverID: String) async {
        await MainActor.run {
            isLoading = true
            authState = .authenticating
            errorMessage = nil
        }

        // Validate inputs
        guard !fullName.isEmpty, !driverID.isEmpty else {
            await MainActor.run {
                errorMessage = "Please enter both full name and driver ID"
                isLoading = false
                authState = .unauthenticated
            }
            return
        }

        do {
            // Fetch driver history from backend
            let historyResponse = try await NetworkService.shared.fetchDriverHistory(fullName: fullName)

            // Verify driverID matches
            guard historyResponse.driver_id == driverID else {
                await MainActor.run {
                    errorMessage = "Invalid driver credentials"
                    isLoading = false
                    authState = .unauthenticated
                }
                return
            }

            // Create driver object from response
            let driver = Driver(
                id: UUID().uuidString,
                name: fullName,
                email: "",  // Not used anymore
                phone: "",
                company: "Swift Transport",
                driverId: driverID,
                shiftType: .day,
                licenseNumber: "",
                dateJoined: Date(),
                totalShifts: historyResponse.scan_history.count,
                hoursDrivern: 0,
                averageAlertness: 0
            )

            // Load scan history into service
            await loadHistoryIntoService(historyResponse.scan_history)

            await MainActor.run {
                authState = .authenticated(driver)
                saveSession(driver: driver)
                isLoading = false
            }

        } catch {
            await MainActor.run {
                errorMessage = "Login failed: \(error.localizedDescription)"
                isLoading = false
                authState = .unauthenticated
            }
        }
    }

    // MARK: - Load History from Backend

    private func loadHistoryIntoService(_ backendScans: [BackendScanResult]) async {
        let scanRecords = backendScans.map { backendResult in
            ScanRecord(
                timestamp: Date(timeIntervalSince1970: backendResult.timestamp),
                heartRate: Int(backendResult.pulse_rate),
                respirationRate: Int(backendResult.breathing_rate),
                alertnessScore: Double(backendResult.integrated_vital_score),
                status: backendResult.status,
                riskScore: backendResult.risk_score,
                backendResult: backendResult
            )
        }

        await MainActor.run {
            ScanHistoryService.shared.setHistory(scanRecords)
        }
    }

    func logout() {
        authState = .unauthenticated
        errorMessage = nil
        clearSession()
    }

    func checkExistingSession() {
        // Check UserDefaults for saved session
        if let driverData = UserDefaults.standard.data(forKey: "savedDriver"),
           let driver = try? JSONDecoder().decode(Driver.self, from: driverData) {
            authState = .authenticated(driver)
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
