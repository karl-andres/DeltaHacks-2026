//
//  BiometricsViewModel.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-10.
//

import SwiftUI
import Combine
import SmartSpectraSwiftSDK

class BiometricsViewModel: ObservableObject {
    // MARK: - SDK Integration
    @Published var sdk = SmartSpectraSwiftSDK.shared
    @ObservedObject var vitalsManager = VitalsManager()

    // MARK: - Driver Info
    var currentDriverID: String = ""
    var currentFullName: String = ""

    func setDriverInfo(driverID: String, fullName: String) {
        self.currentDriverID = driverID
        self.currentFullName = fullName
    }

    // MARK: - Real-time Metrics
    @Published var currentHeartRate: Int = 0
    @Published var currentRespirationRate: Int = 0
    @Published var heartRateConfidence: Double = 0.0
    @Published var respirationConfidence: Double = 0.0
    @Published var faceDetected: Bool = false

    // MARK: - Calculated Metrics
    @Published var hrvScore: Int = 0
    @Published var alertnessLevel: Double = 0.0
    @Published var readinessStatus: ReadinessStatus = .calculating

    // MARK: - Historical Data for Graphs
    @Published var heartRateHistory: [Double] = []
    @Published var respirationHistory: [Double] = []
    @Published var hrvHistory: [Double] = []
    @Published var alertnessHistory: [Double] = []

    // MARK: - Scan State
    @Published var isScanning: Bool = false
    @Published var scanProgress: Double = 0.0

    // MARK: - Mock Data Mode
    var useMockData: Bool = false  // Changed to false for real SDK usage

    private var cancellables = Set<AnyCancellable>()
    private var scanTimer: Timer?
    private var mockDataTimer: Timer?
    private var realTimeTimer: Timer?

    // MARK: - Initialization
    init() {
        setupSDKObservers()
        setupBackendResultObserver()

        // Initialize with mock data for development
        if useMockData {
            initializeMockData()
        }
    }

    // MARK: - Backend Result Observer
    private func setupBackendResultObserver() {
        vitalsManager.$latestBackendResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self = self, let result = result else { return }
                self.handleBackendResponse(result)
            }
            .store(in: &cancellables)
    }

    // MARK: - SDK Observers
    private func setupSDKObservers() {
        // Observe metricsBuffer changes from SDK
        sdk.$metricsBuffer
            .receive(on: DispatchQueue.main)
            .sink { [weak self] buffer in
                guard let self = self, !self.useMockData else { return }
                self.processMetricsBuffer(buffer)
            }
            .store(in: &cancellables)

        // Observe edgeMetrics for face detection (if available)
        // Note: edgeMetrics is a Combine publisher
        // sdk.edgeMetrics?
        //     .receive(on: DispatchQueue.main)
        //     .sink { [weak self] metrics in
        //         self?.processFaceMetrics(metrics)
        //     }
        //     .store(in: &cancellables)
    }

    // MARK: - Process SDK Data
    private func processMetricsBuffer(_ buffer: Any?) {
        guard let buffer = buffer as? Any else { return }

        // Extract pulse rate
        // if let pulseRate = buffer.pulse?.rate?.last {
        //     currentHeartRate = Int(pulseRate.value)
        //     heartRateConfidence = pulseRate.confidence
        //     heartRateHistory.append(pulseRate.value)
        //     if heartRateHistory.count > 60 {
        //         heartRateHistory.removeFirst()
        //     }
        // }

        // Extract breathing rate
        // if let breathingRate = buffer.breathing?.rate?.last {
        //     currentRespirationRate = Int(breathingRate.value)
        //     respirationConfidence = breathingRate.confidence
        //     respirationHistory.append(breathingRate.value)
        //     if respirationHistory.count > 60 {
        //         respirationHistory.removeFirst()
        //     }
        // }

        // Calculate HRV and alertness
        calculateMetrics()
    }

    private func processFaceMetrics(_ metrics: Any) {
        // Extract face detection status
        // faceDetected = metrics.hasFace ?? false
    }

    // MARK: - Scan Control
    func startScan() {
        guard !isScanning else { return }

        isScanning = true
        scanProgress = 0.0
        readinessStatus = .scanning
        faceDetected = false

        // Clear history
        heartRateHistory.removeAll()
        respirationHistory.removeAll()
        hrvHistory.removeAll()
        alertnessHistory.removeAll()

        if useMockData {
            startMockScan()
        } else {
            // Start VitalsManager (real SDK)
            vitalsManager.startMonitoring()
            startRealTimePolling()
        }

        // 10-second scan duration (changed from 45s)
        scanTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
            self?.completeScan()
        }

        // Update progress for 10 seconds
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            guard let self = self, self.isScanning else {
                timer.invalidate()
                return
            }
            self.scanProgress += (0.5 / 10.0)  // Changed from 45.0
            if self.scanProgress >= 1.0 {
                timer.invalidate()
            }
        }
    }

    // MARK: - Real-time Polling
    private func startRealTimePolling() {
        realTimeTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            // Extract latest values from VitalsManager
            if let latestPulse = self.vitalsManager.localPulseHistory.last {
                self.currentHeartRate = Int(latestPulse.value)
                self.heartRateHistory.append(latestPulse.value)
            }

            if let latestBreathing = self.vitalsManager.localBreathingHistory.last {
                self.currentRespirationRate = Int(latestBreathing.value)
                self.respirationHistory.append(latestBreathing.value)
            }

            // Keep only last 60 values for graphs
            if self.heartRateHistory.count > 60 {
                self.heartRateHistory.removeFirst()
            }
            if self.respirationHistory.count > 60 {
                self.respirationHistory.removeFirst()
            }

            // Update calculated metrics
            self.calculateMetrics()
        }
    }

    func cancelScan() {
        isScanning = false
        scanTimer?.invalidate()
        mockDataTimer?.invalidate()
        scanProgress = 0.0
        readinessStatus = .calculating
    }

    func completeScan() {
        guard isScanning else { return }

        // Stop timers
        scanTimer?.invalidate()
        mockDataTimer?.invalidate()
        realTimeTimer?.invalidate()
        scanTimer = nil
        mockDataTimer = nil
        realTimeTimer = nil

        isScanning = false
        scanProgress = 1.0

        // Stop VitalsManager with upload
        if !useMockData {
            vitalsManager.stopMonitoring(
                shouldUpload: true,
                driverID: currentDriverID,
                fullName: currentFullName
            )
        }

        // Calculate final metrics
        calculateMetrics()

        // Determine readiness status
        let readiness = determineReadinessStatus()
        readinessStatus = readiness

        // Wait for backend response (will be handled via callback)
    }

    private func determineReadinessStatus() -> ReadinessStatus {
        if alertnessLevel < 50 || hrvScore < 30 {
            return .needsRest
        }
        return .approvedForDuty
    }

    // MARK: - Backend Response Handler
    func handleBackendResponse(_ backendResult: BackendScanResult) {
        // Create scan record
        let scanRecord = ScanRecord(
            timestamp: Date(),
            heartRate: currentHeartRate,
            respirationRate: currentRespirationRate,
            alertnessScore: alertnessLevel,
            status: backendResult.status,
            riskScore: backendResult.risk_score,
            backendResult: backendResult
        )

        // Save to history service
        ScanHistoryService.shared.saveScan(scanRecord)

        // Update readiness based on backend status
        if backendResult.status == "at_risk" {
            readinessStatus = .needsRest
        }
    }

    func refreshMetrics() {
        // Refresh biometric data from mock or SDK
        if useMockData {
            let mockData = MockDataGenerator.createMockBiometricsViewModel()
            currentHeartRate = mockData.heartRate
            currentRespirationRate = mockData.respiration
            hrvScore = mockData.hrv
            alertnessLevel = mockData.alertness

            // Add latest values to history
            heartRateHistory.append(Double(currentHeartRate))
            if heartRateHistory.count > 60 {
                heartRateHistory.removeFirst()
            }

            respirationHistory.append(Double(currentRespirationRate))
            if respirationHistory.count > 60 {
                respirationHistory.removeFirst()
            }

            hrvHistory.append(Double(hrvScore))
            if hrvHistory.count > 60 {
                hrvHistory.removeFirst()
            }

            alertnessHistory.append(alertnessLevel)
            if alertnessHistory.count > 60 {
                alertnessHistory.removeFirst()
            }
        } else {
            // Trigger SDK refresh
            // sdk.refreshMetrics()
        }
    }

    // MARK: - Calculations
    private func calculateMetrics() {
        // Calculate HRV (simplified RMSSD calculation)
        if heartRateHistory.count > 10 {
            let intervals = zip(heartRateHistory, heartRateHistory.dropFirst())
                .map { abs($1 - $0) }
            let rmssd = sqrt(intervals.map { $0 * $0 }.reduce(0, +) / Double(intervals.count))
            hrvScore = Int(rmssd * 10)
            hrvHistory.append(Double(hrvScore))
            if hrvHistory.count > 60 {
                hrvHistory.removeFirst()
            }
        }

        // Calculate alertness
        let hrvFactor = min(Double(hrvScore) / 100.0, 1.0)
        let breathingStability = respirationConfidence
        let heartRateStability = heartRateConfidence

        alertnessLevel = (hrvFactor + breathingStability + heartRateStability) / 3.0 * 100
        alertnessHistory.append(alertnessLevel)
        if alertnessHistory.count > 60 {
            alertnessHistory.removeFirst()
        }
    }

    private func calculateReadinessStatus() -> ReadinessStatus {
        // Decision logic based on multiple factors
        if alertnessLevel < 50 || hrvScore < 30 {
            return .restAdvised
        }
        return .fit
    }

    // MARK: - Mock Data for Development
    private func initializeMockData() {
        let mockData = MockDataGenerator.createMockBiometricsViewModel()
        currentHeartRate = mockData.heartRate
        currentRespirationRate = mockData.respiration
        hrvScore = mockData.hrv
        alertnessLevel = mockData.alertness
        heartRateHistory = mockData.heartRateHistory
        respirationHistory = mockData.respirationHistory
        hrvHistory = mockData.hrvHistory
        alertnessHistory = mockData.alertnessHistory
        heartRateConfidence = 0.85
        respirationConfidence = 0.82
        faceDetected = true
    }

    private func startMockScan() {
        // Simulate real-time updates during mock scan
        mockDataTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isScanning else { return }

            // Generate mock data
            self.currentHeartRate = MockDataGenerator.shared.generateMockHeartRate()
            self.currentRespirationRate = MockDataGenerator.shared.generateMockRespiration()
            self.heartRateConfidence = Double.random(in: 0.7...0.95)
            self.respirationConfidence = Double.random(in: 0.7...0.95)
            self.faceDetected = true

            // Add to history
            self.heartRateHistory.append(Double(self.currentHeartRate))
            self.respirationHistory.append(Double(self.currentRespirationRate))

            // Calculate metrics
            self.calculateMetrics()
        }
    }

    // MARK: - Preview Helper
    static var preview: BiometricsViewModel {
        let vm = BiometricsViewModel()
        vm.useMockData = true
        vm.initializeMockData()
        return vm
    }
}
