//
//  WellnessMetrics.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-10.
//

import Foundation

struct WellnessMetrics: Codable {
    var alertnessScore: Double
    var sleepHours: Double
    var sleepMinutes: Int
    var shiftDuration: TimeInterval
    var reactionTime: ReactionTimeStatus
    var sleepDebt: SleepDebtLevel

    var alertnessLevel: AlertnessLevel {
        AlertnessLevel.from(score: alertnessScore)
    }

    var formattedSleepDuration: String {
        let hours = Int(sleepHours)
        let minutes = sleepMinutes
        return "\(hours)h \(minutes)m"
    }

    var formattedShiftDuration: String {
        let hours = Int(shiftDuration) / 3600
        let minutes = (Int(shiftDuration) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }

    init(
        alertnessScore: Double = 0.0,
        sleepHours: Double = 7.0,
        sleepMinutes: Int = 0,
        shiftDuration: TimeInterval = 0,
        reactionTime: ReactionTimeStatus = .normal,
        sleepDebt: SleepDebtLevel = .none
    ) {
        self.alertnessScore = alertnessScore
        self.sleepHours = sleepHours
        self.sleepMinutes = sleepMinutes
        self.shiftDuration = shiftDuration
        self.reactionTime = reactionTime
        self.sleepDebt = sleepDebt
    }
}

enum ReactionTimeStatus: String, Codable {
    case quick = "Quick"
    case normal = "Normal"
    case slowed = "Slowed"

    static func from(alertness: Double) -> ReactionTimeStatus {
        switch alertness {
        case 80...:
            return .quick
        case 50..<80:
            return .normal
        default:
            return .slowed
        }
    }
}

enum SleepDebtLevel: String, Codable {
    case none = "None"
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"

    var percentageImpact: String {
        switch self {
        case .none:
            return "+5%"
        case .low:
            return "-5%"
        case .moderate:
            return "-10%"
        case .high:
            return "-15%"
        }
    }

    static func from(sleepHours: Double) -> SleepDebtLevel {
        switch sleepHours {
        case 8...:
            return .none
        case 7..<8:
            return .low
        case 6..<7:
            return .moderate
        default:
            return .high
        }
    }
}

struct RestStop: Identifiable, Codable {
    let id: UUID
    let name: String
    let distance: Double
    let amenities: [String]
    let location: String
    let type: RestStopType

    var formattedDistance: String {
        if distance < 1 {
            return "< 1 mi away"
        } else {
            return "\(Int(distance)) mi away"
        }
    }

    init(
        id: UUID = UUID(),
        name: String,
        distance: Double,
        amenities: [String],
        location: String,
        type: RestStopType
    ) {
        self.id = id
        self.name = name
        self.distance = distance
        self.amenities = amenities
        self.location = location
        self.type = type
    }
}

enum RestStopType: String, Codable {
    case truckStop = "local_gas_station"
    case restArea = "local_parking"
    case diner = "coffee"
}
