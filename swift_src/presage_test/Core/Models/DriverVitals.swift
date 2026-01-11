//
//  DriverVitals.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-11.
//

import Foundation

// MARK: - Driver Vitals Model
struct DriverVitals: Codable, Identifiable {
    let id = UUID()
    let driverId: String
    let fullname: String
    let timestamp: Date
    let pulseRespirationQuotient: Double?
    let breathingRate: Double?
    let pulseRate: Double?
    let integratedVitalScore: Double?
    let cardioRespiratoryCoupler: Double?
    let nonlinearAlertnessIndex: Double?
    let status: String?
    let riskScore: Double?
    let failReason: String?

    enum CodingKeys: String, CodingKey {
        case driverId = "driver_id"
        case fullname
        case timestamp
        case pulseRespirationQuotient = "pulse_respiration_quotient"
        case breathingRate = "breathing_rate"
        case pulseRate = "pulse_rate"
        case integratedVitalScore = "integrated_vital_score"
        case cardioRespiratoryCoupler = "cardio_respiratory_coupler"
        case nonlinearAlertnessIndex = "nonlinear_alertness_index"
        case status
        case riskScore = "risk_score"
        case failReason = "fail_reason"
    }

    // Custom decoder to handle date parsing
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        driverId = try container.decode(String.self, forKey: .driverId)
        fullname = try container.decode(String.self, forKey: .fullname)

        // Parse timestamp - handle both string and date formats
        if let timestampString = try? container.decode(String.self, forKey: .timestamp) {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            timestamp = formatter.date(from: timestampString) ?? Date()
        } else {
            timestamp = try container.decode(Date.self, forKey: .timestamp)
        }

        pulseRespirationQuotient = try? container.decode(Double.self, forKey: .pulseRespirationQuotient)
        breathingRate = try? container.decode(Double.self, forKey: .breathingRate)
        pulseRate = try? container.decode(Double.self, forKey: .pulseRate)
        integratedVitalScore = try? container.decode(Double.self, forKey: .integratedVitalScore)
        cardioRespiratoryCoupler = try? container.decode(Double.self, forKey: .cardioRespiratoryCoupler)
        nonlinearAlertnessIndex = try? container.decode(Double.self, forKey: .nonlinearAlertnessIndex)
        status = try? container.decode(String.self, forKey: .status)
        riskScore = try? container.decode(Double.self, forKey: .riskScore)
        failReason = try? container.decode(String.self, forKey: .failReason)
    }

    // Standard encoder
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(driverId, forKey: .driverId)
        try container.encode(fullname, forKey: .fullname)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encodeIfPresent(pulseRespirationQuotient, forKey: .pulseRespirationQuotient)
        try container.encodeIfPresent(breathingRate, forKey: .breathingRate)
        try container.encodeIfPresent(pulseRate, forKey: .pulseRate)
        try container.encodeIfPresent(integratedVitalScore, forKey: .integratedVitalScore)
        try container.encodeIfPresent(cardioRespiratoryCoupler, forKey: .cardioRespiratoryCoupler)
        try container.encodeIfPresent(nonlinearAlertnessIndex, forKey: .nonlinearAlertnessIndex)
        try container.encodeIfPresent(status, forKey: .status)
        try container.encodeIfPresent(riskScore, forKey: .riskScore)
        try container.encodeIfPresent(failReason, forKey: .failReason)
    }

    // Manual initializer
    init(
        driverId: String,
        fullname: String,
        timestamp: Date,
        pulseRespirationQuotient: Double? = nil,
        breathingRate: Double? = nil,
        pulseRate: Double? = nil,
        integratedVitalScore: Double? = nil,
        cardioRespiratoryCoupler: Double? = nil,
        nonlinearAlertnessIndex: Double? = nil,
        status: String? = nil,
        riskScore: Double? = nil,
        failReason: String? = nil
    ) {
        self.driverId = driverId
        self.fullname = fullname
        self.timestamp = timestamp
        self.pulseRespirationQuotient = pulseRespirationQuotient
        self.breathingRate = breathingRate
        self.pulseRate = pulseRate
        self.integratedVitalScore = integratedVitalScore
        self.cardioRespiratoryCoupler = cardioRespiratoryCoupler
        self.nonlinearAlertnessIndex = nonlinearAlertnessIndex
        self.status = status
        self.riskScore = riskScore
        self.failReason = failReason
    }
}

// MARK: - API Response Wrapper
struct DriverVitalsResponse: Codable {
    let data: [DriverVitals]?
    let error: String?
}
