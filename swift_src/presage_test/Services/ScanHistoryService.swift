//
//  ScanHistoryService.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-11.
//

import Foundation
import SwiftUI

class ScanHistoryService: ObservableObject {
    static let shared = ScanHistoryService()

    @Published var scanHistory: [ScanRecord] = []

    private let storageKey = "scan_history"
    private let maxStoredScans = 100

    init() {
        loadHistory()
    }

    // MARK: - Save Scan

    func saveScan(_ record: ScanRecord) {
        scanHistory.insert(record, at: 0) // Most recent first

        // Keep only the most recent maxStoredScans
        if scanHistory.count > maxStoredScans {
            scanHistory = Array(scanHistory.prefix(maxStoredScans))
        }

        persistToStorage()
    }

    // MARK: - Load History

    func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            scanHistory = []
            return
        }

        do {
            let decoder = JSONDecoder()
            scanHistory = try decoder.decode([ScanRecord].self, from: data)
        } catch {
            print("Failed to load scan history: \(error)")
            scanHistory = []
        }
    }

    // MARK: - Set History

    func setHistory(_ records: [ScanRecord]) {
        scanHistory = records
        persistToStorage()
    }

    // MARK: - Clear History

    func clearHistory() {
        scanHistory = []
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    // MARK: - Persist to Storage

    private func persistToStorage() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(scanHistory)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Failed to save scan history: \(error)")
        }
    }

    // MARK: - Helper Methods for UI

    func getLatestScan() -> ScanRecord? {
        return scanHistory.first
    }

    func getScans(limit: Int) -> [ScanRecord] {
        return Array(scanHistory.prefix(limit))
    }

    func averageHeartRate() -> Int {
        guard !scanHistory.isEmpty else { return 0 }
        let sum = scanHistory.reduce(0) { $0 + $1.heartRate }
        return sum / scanHistory.count
    }

    func averageRespirationRate() -> Int {
        guard !scanHistory.isEmpty else { return 0 }
        let sum = scanHistory.reduce(0) { $0 + $1.respirationRate }
        return sum / scanHistory.count
    }
}
