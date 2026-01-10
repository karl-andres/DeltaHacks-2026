//
//  BiometricData.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-10.
//

import Foundation

struct BiometricData: Codable {
    var heartRate: Int
    var respirationRate: Int
    var hrv: Int
    var heartRateConfidence: Double
    var respirationConfidence: Double
    var timestamp: Date

    init(
        heartRate: Int = 0,
        respirationRate: Int = 0,
        hrv: Int = 0,
        heartRateConfidence: Double = 0.0,
        respirationConfidence: Double = 0.0,
        timestamp: Date = Date()
    ) {
        self.heartRate = heartRate
        self.respirationRate = respirationRate
        self.hrv = hrv
        self.heartRateConfidence = heartRateConfidence
        self.respirationConfidence = respirationConfidence
        self.timestamp = timestamp
    }
}

struct MetricStatus {
    let value: String
    let unit: String
    let status: StatusLevel
    let label: String
}

enum StatusLevel: String {
    case good = "Good"
    case normal = "Normal"
    case resting = "Resting"
    case ready = "Ready"
    case warning = "Warning"
    case critical = "Critical"

    var color: String {
        switch self {
        case .good, .normal, .resting, .ready:
            return "success"
        case .warning:
            return "warning"
        case .critical:
            return "danger"
        }
    }
}
