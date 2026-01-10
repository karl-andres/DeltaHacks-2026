//
//  ReadinessStatus.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-10.
//

import Foundation

enum ReadinessStatus: String, Codable {
    case calculating = "Calculating"
    case scanning = "Scanning"
    case fit = "Fit to Drive"
    case restAdvised = "Rest Advised"

    var isSafeToOperate: Bool {
        return self == .fit
    }

    var displayText: String {
        switch self {
        case .calculating:
            return "Calculating readiness..."
        case .scanning:
            return "Scanning in progress"
        case .fit:
            return "FIT TO DRIVE"
        case .restAdvised:
            return "REST ADVISED"
        }
    }
}

enum AlertnessLevel: String, Codable {
    case peak = "Peak Focus"
    case normal = "Ready"
    case moderate = "Caution"
    case low = "Warning"
    case critical = "Critical Level"

    static func from(score: Double) -> AlertnessLevel {
        switch score {
        case 90...:
            return .peak
        case 75..<90:
            return .normal
        case 60..<75:
            return .moderate
        case 50..<60:
            return .low
        default:
            return .critical
        }
    }
}
