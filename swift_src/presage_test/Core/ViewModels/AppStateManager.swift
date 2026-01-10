//
//  AppStateManager.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-10.
//

import SwiftUI

enum AppState {
    case dashboard
    case scanning
    case showingResults(ReadinessStatus)
    case activeMonitoring
    case restPeriod
}

class AppStateManager: ObservableObject {
    // MARK: - Published State
    @Published var currentState: AppState = .dashboard
    @Published var showScanSheet: Bool = false
    @Published var showResultsFullScreen: Bool = false
    @Published var dutyStartTime: Date?
    @Published var restStartTime: Date?

    // MARK: - Computed Properties
    var isOnDuty: Bool {
        return currentState == .activeMonitoring && dutyStartTime != nil
    }

    var shiftDuration: TimeInterval {
        guard let startTime = dutyStartTime else { return 0 }
        return Date().timeIntervalSince(startTime)
    }

    var restDuration: TimeInterval {
        guard let startTime = restStartTime else { return 0 }
        return Date().timeIntervalSince(startTime)
    }

    // MARK: - Navigation Actions
    func startDuty() {
        showScanSheet = true
        currentState = .scanning
    }

    func completeScan(result: ReadinessStatus) {
        showScanSheet = false
        currentState = .showingResults(result)
        showResultsFullScreen = true
    }

    func approveForDuty() {
        showResultsFullScreen = false
        currentState = .activeMonitoring
        dutyStartTime = Date()
    }

    func requireRest() {
        currentState = .restPeriod
        // Keep on RestAdvisedView until action taken
    }

    func logRestStart() {
        restStartTime = Date()
        showResultsFullScreen = false
        currentState = .dashboard
    }

    func cancelScan() {
        showScanSheet = false
        currentState = .dashboard
    }

    func endDuty() {
        dutyStartTime = nil
        restStartTime = nil
        currentState = .dashboard
    }

    // MARK: - Preview Helper
    static var preview: AppStateManager {
        let manager = AppStateManager()
        manager.currentState = .dashboard
        return manager
    }
}
