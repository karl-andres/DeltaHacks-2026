//
//  DriverVitalsManager.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-11.
//

import Foundation
import SwiftUI

// MARK: - Driver Vitals Manager
class DriverVitalsManager: ObservableObject {
    static let shared = DriverVitalsManager()

    // MARK: - Published Properties
    @Published var currentVitals: DriverVitals?
    @Published var vitalsHistory: [DriverVitals] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let vitalsKey = "storedDriverVitals"
    private let vitalsHistoryKey = "storedDriverVitalsHistory"

    private init() {
        loadStoredVitals()
    }

    // MARK: - Fetch and Store Vitals
    func fetchAndStoreVitals(for driver: Driver) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        do {
            // Fetch vitals from API using driver's fullname
            let allVitals = try await DriverService.shared.fetchDriverVitals(fullName: driver.fullname)

            await MainActor.run {
                // Store all vitals in history
                self.vitalsHistory = allVitals.sorted { $0.timestamp > $1.timestamp }

                // Set the most recent vitals as current
                self.currentVitals = self.vitalsHistory.first

                // Persist to local storage
                self.saveVitalsToStorage()

                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    // MARK: - Local Storage Management
    private func saveVitalsToStorage() {
        // Save current vitals
        if let currentVitals = currentVitals,
           let encoded = try? JSONEncoder().encode(currentVitals) {
            UserDefaults.standard.set(encoded, forKey: vitalsKey)
        }

        // Save vitals history
        if let encoded = try? JSONEncoder().encode(vitalsHistory) {
            UserDefaults.standard.set(encoded, forKey: vitalsHistoryKey)
        }
    }

    private func loadStoredVitals() {
        // Load current vitals
        if let data = UserDefaults.standard.data(forKey: vitalsKey),
           let vitals = try? JSONDecoder().decode(DriverVitals.self, from: data) {
            currentVitals = vitals
        }

        // Load vitals history
        if let data = UserDefaults.standard.data(forKey: vitalsHistoryKey),
           let history = try? JSONDecoder().decode([DriverVitals].self, from: data) {
            vitalsHistory = history
        }
    }

    func clearStoredVitals() {
        currentVitals = nil
        vitalsHistory = []
        UserDefaults.standard.removeObject(forKey: vitalsKey)
        UserDefaults.standard.removeObject(forKey: vitalsHistoryKey)
    }

    // MARK: - Computed Properties
    var hasVitals: Bool {
        currentVitals != nil
    }

    var latestPulseRate: Double {
        currentVitals?.pulseRate ?? 0
    }

    var latestBreathingRate: Double {
        currentVitals?.breathingRate ?? 0
    }

    var latestAlertnessIndex: Double {
        currentVitals?.nonlinearAlertnessIndex ?? 0
    }

    var latestRiskScore: Double {
        currentVitals?.riskScore ?? 0
    }

    var vitalsStatus: String {
        currentVitals?.status ?? "Unknown"
    }

    // MARK: - Helper Methods
    func getVitalsForTimePeriod(days: Int) -> [DriverVitals] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return vitalsHistory.filter { $0.timestamp >= cutoffDate }
    }

    func getAverageMetrics(for days: Int) -> (pulseRate: Double, breathingRate: Double, alertness: Double) {
        let vitals = getVitalsForTimePeriod(days: days)

        guard !vitals.isEmpty else {
            return (0, 0, 0)
        }

        let totalPulse = vitals.compactMap { $0.pulseRate }.reduce(0, +)
        let totalBreathing = vitals.compactMap { $0.breathingRate }.reduce(0, +)
        let totalAlertness = vitals.compactMap { $0.nonlinearAlertnessIndex }.reduce(0, +)

        let count = Double(vitals.count)

        return (
            pulseRate: totalPulse / count,
            breathingRate: totalBreathing / count,
            alertness: totalAlertness / count
        )
    }

    // MARK: - Preview Helper
    static var preview: DriverVitalsManager {
        let manager = DriverVitalsManager()
        manager.currentVitals = DriverVitals(
            driverId: "100200",
            fullname: "John Doe",
            timestamp: Date(),
            pulseRespirationQuotient: 4.5,
            breathingRate: 14.5,
            pulseRate: 72.0,
            integratedVitalScore: 85.0,
            cardioRespiratoryCoupler: 1.2,
            nonlinearAlertnessIndex: 87.0,
            status: "Normal",
            riskScore: 0.15,
            failReason: nil
        )
        manager.vitalsHistory = [manager.currentVitals!]
        return manager
    }
}
