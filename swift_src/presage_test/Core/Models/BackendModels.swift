//
//  BackendModels.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-11.
//

import Foundation

// MARK: - Backend Scan Result

struct BackendScanResult: Codable, Identifiable {
    var id = UUID()
    let driver_id: String
    let fullname: String
    let timestamp: Double
    let pulse_respiration_quotient: Float
    let breathing_rate: Float
    let pulse_rate: Float
    let integrated_vital_score: Float
    let cardio_respiratory_coupler: Float
    let nonlinear_alertness_index: Float
    let status: String
    let risk_score: Float
    let fail_reason: String?

    enum CodingKeys: String, CodingKey {
        case driver_id, fullname, timestamp
        case pulse_respiration_quotient, breathing_rate, pulse_rate
        case integrated_vital_score, cardio_respiratory_coupler
        case nonlinear_alertness_index, status, risk_score, fail_reason
    }
}

// MARK: - Driver History Response

struct DriverHistoryResponse: Codable {
    let driver_id: String
    let fullname: String
    let scan_history: [BackendScanResult]
}

// MARK: - Local Scan Record

struct ScanRecord: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let heartRate: Int
    let respirationRate: Int
    let alertnessScore: Double
    let status: String
    let riskScore: Float
    let backendResult: BackendScanResult

    init(id: UUID = UUID(), timestamp: Date, heartRate: Int, respirationRate: Int,
         alertnessScore: Double, status: String, riskScore: Float, backendResult: BackendScanResult) {
        self.id = id
        self.timestamp = timestamp
        self.heartRate = heartRate
        self.respirationRate = respirationRate
        self.alertnessScore = alertnessScore
        self.status = status
        self.riskScore = riskScore
        self.backendResult = backendResult
    }
}
