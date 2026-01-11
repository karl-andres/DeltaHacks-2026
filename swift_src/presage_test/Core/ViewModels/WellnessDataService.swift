//
//  WellnessDataService.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-10.
//

import SwiftUI

class WellnessDataService: ObservableObject {
    // MARK: - Published Data
    @Published var wellnessMetrics: WellnessMetrics
    @Published var restStops: [RestStop] = []

    // MARK: - Initialization
    init() {
        // Initialize with default/mock data
        self.wellnessMetrics = WellnessMetrics(
            alertnessScore: 85.0,
            sleepHours: 7.0,
            sleepMinutes: 12,
            shiftDuration: 0,
            reactionTime: .normal,
            sleepDebt: .low
        )

        // Load mock rest stops
        self.restStops = MockDataGenerator.shared.generateRestStops()
    }

    // MARK: - Update Metrics
    func updateAlertness(_ score: Double) {
        wellnessMetrics.alertnessScore = score
        wellnessMetrics.reactionTime = ReactionTimeStatus.from(alertness: score)
    }

    func updateSleepData(hours: Double, minutes: Int) {
        wellnessMetrics.sleepHours = hours
        wellnessMetrics.sleepMinutes = minutes
        wellnessMetrics.sleepDebt = SleepDebtLevel.from(sleepHours: hours)
    }

    func updateShiftDuration(_ duration: TimeInterval) {
        wellnessMetrics.shiftDuration = duration
    }

    // MARK: - Rest Stops
    func fetchNearbyRestStops() {
        // In a real app, this would use location services
        // For now, use mock data
        restStops = MockDataGenerator.shared.generateRestStops()
    }

    // MARK: - Preview Helper
    static var preview: WellnessDataService {
        let service = WellnessDataService()
        service.wellnessMetrics = MockDataGenerator.shared.generateWellnessMetrics(alertnessScore: 42.0)
        return service
    }
}
