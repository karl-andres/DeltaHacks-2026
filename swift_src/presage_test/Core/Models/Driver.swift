//
//  Driver.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-10.
//

import Foundation

// MARK: - Driver Model
struct Driver: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var email: String
    var phone: String
    var company: String
    var driverId: String
    var shiftType: ShiftType
    var licenseNumber: String
    var dateJoined: Date

    // Stats
    var totalShifts: Int
    var hoursDrivern: Double
    var averageAlertness: Double

    enum ShiftType: String, Codable, Equatable {
        case day = "Day Shift"
        case night = "Night Shift"
        case swing = "Swing Shift"

        var icon: String {
            switch self {
            case .day: return "sun.max.fill"
            case .night: return "moon.stars.fill"
            case .swing: return "sunrise.fill"
            }
        }
    }

    // Mock data for preview/testing
    static let mock = Driver(
        id: UUID().uuidString,
        name: "John Driver",
        email: "john.driver@trucking.com",
        phone: "+1 (555) 123-4567",
        company: "Swift Transport",
        driverId: "DRV-2024-1247",
        shiftType: .day,
        licenseNumber: "CDL-ABC-123456",
        dateJoined: Date().addingTimeInterval(-365 * 24 * 60 * 60), // 1 year ago
        totalShifts: 247,
        hoursDrivern: 1842,
        averageAlertness: 87
    )
}

// MARK: - Authentication State
enum AuthState: Equatable {
    case unauthenticated
    case authenticating
    case authenticated(Driver)

    var isAuthenticated: Bool {
        if case .authenticated = self {
            return true
        }
        return false
    }

    var driver: Driver? {
        if case .authenticated(let driver) = self {
            return driver
        }
        return nil
    }
}
