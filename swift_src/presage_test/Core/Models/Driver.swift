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
    let driverId: String
    let fullname: String

    // Mock data for preview/testing
    static let mock = Driver(
        id: UUID().uuidString,
        driverId: "DRV-2024-1247",
        fullname: "John Driver"
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
