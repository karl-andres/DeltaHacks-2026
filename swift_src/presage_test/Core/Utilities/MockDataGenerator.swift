//
//  MockDataGenerator.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-10.
//

import Foundation

class MockDataGenerator {
    static let shared = MockDataGenerator()

    private init() {}

    // MARK: - Biometric Data
    func generateMockHeartRate() -> Int {
        Int.random(in: 65...85)
    }

    func generateMockRespiration() -> Int {
        Int.random(in: 12...18)
    }

    func generateMockHRV() -> Int {
        Int.random(in: 30...100)
    }

    func generateMockAlertness() -> Double {
        Double.random(in: 40...95)
    }

    func generateBiometricData() -> BiometricData {
        BiometricData(
            heartRate: generateMockHeartRate(),
            respirationRate: generateMockRespiration(),
            hrv: generateMockHRV(),
            heartRateConfidence: Double.random(in: 0.7...0.95),
            respirationConfidence: Double.random(in: 0.7...0.95),
            timestamp: Date()
        )
    }

    // MARK: - Historical Data for Graphs
    func generateHeartRateHistory(points: Int = 60) -> [Double] {
        (0..<points).map { _ in Double.random(in: 65...85) }
    }

    func generateRespirationHistory(points: Int = 60) -> [Double] {
        (0..<points).map { _ in Double.random(in: 12...18) }
    }

    func generateHRVHistory(points: Int = 60) -> [Double] {
        (0..<points).map { _ in Double.random(in: 35...95) }
    }

    func generateAlertnessHistory(points: Int = 60) -> [Double] {
        let baseValue = Double.random(in: 70...90)
        return (0..<points).map { i in
            let variation = sin(Double(i) * 0.1) * 10
            return max(40, min(100, baseValue + variation + Double.random(in: -5...5)))
        }
    }

    // MARK: - Wellness Metrics
    func generateWellnessMetrics(alertnessScore: Double? = nil) -> WellnessMetrics {
        let alertness = alertnessScore ?? generateMockAlertness()
        let sleepHours = Double.random(in: 5...9)

        return WellnessMetrics(
            alertnessScore: alertness,
            sleepHours: sleepHours,
            sleepMinutes: Int.random(in: 0...59),
            shiftDuration: Double.random(in: 0...(12 * 3600)),
            reactionTime: ReactionTimeStatus.from(alertness: alertness),
            sleepDebt: SleepDebtLevel.from(sleepHours: sleepHours)
        )
    }

    // MARK: - Rest Stops
    func generateRestStops() -> [RestStop] {
        [
            RestStop(
                name: "Love's Travel Stop",
                distance: 2.0,
                amenities: ["Showers", "Food"],
                location: "I-40, Exit 234 • Large Lot",
                type: .truckStop
            ),
            RestStop(
                name: "Rest Area 5B",
                distance: 12.0,
                amenities: ["Restrooms", "Vending"],
                location: "Hwy 101 North • Quiet Zone",
                type: .restArea
            ),
            RestStop(
                name: "Joe's 24/7 Diner",
                distance: 18.0,
                amenities: ["Hot Food", "Wifi"],
                location: "Exit 29 • Truck Friendly",
                type: .diner
            )
        ]
    }

    // MARK: - Mock Data for Preview
    static func createMockBiometricsViewModel() -> (
        heartRate: Int,
        respiration: Int,
        hrv: Int,
        alertness: Double,
        heartRateHistory: [Double],
        respirationHistory: [Double],
        hrvHistory: [Double],
        alertnessHistory: [Double]
    ) {
        let generator = MockDataGenerator.shared
        return (
            heartRate: 72,
            respiration: 14,
            hrv: 98,
            alertness: 85.0,
            heartRateHistory: generator.generateHeartRateHistory(),
            respirationHistory: generator.generateRespirationHistory(),
            hrvHistory: generator.generateHRVHistory(),
            alertnessHistory: generator.generateAlertnessHistory()
        )
    }
}
