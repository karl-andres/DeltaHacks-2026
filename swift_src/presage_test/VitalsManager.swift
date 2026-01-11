//
//  VitalsManager.swift
//  presage_test
//
//  Created by Karl Andres on 2026-01-10.
//

import SwiftUI
import SmartSpectraSwiftSDK

class VitalsManager: ObservableObject {
    // 1. SDK Instances
    @ObservedObject var sdk = SmartSpectraSwiftSDK.shared
    @ObservedObject var vitalsProcessor = SmartSpectraVitalsProcessor.shared
    
    // 2. Local Buffers (Your "Local Memory")
    @Published var localPulseHistory: [MetricPoint] = []
    @Published var localBreathingHistory: [MetricPoint] = []
    @Published var isRecording: Bool = false
    @Published var safetyResult: Bool? = nil
    
    private var samplingTimer: Timer? = nil
    private var sessionStartTime: Date? = nil
    
    init() {
        if !ProcessInfo.isPreview {
            // Your Hackathon API Key
            let apiKey = "XDTroSWEaP4ISp3zEfFRCaf1JhXFwfS817R0si6y"
            sdk.setApiKey(apiKey)
            sdk.setRecordingDelay(0)
            sdk.setSmartSpectraMode(.continuous)
        }
    }
    
    func startMonitoring() {
        // Reset everything
        localPulseHistory = []
        localBreathingHistory = []
        sessionStartTime = Date()
        safetyResult = nil
        isRecording = true
        
        vitalsProcessor.startProcessing()
        vitalsProcessor.startRecording()
        
        // Start the Sampling Timer
        samplingTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            guard let self = self,
                  let metrics = self.sdk.metricsBuffer,
                  let start = self.sessionStartTime else { return }
            
            let currentTime = Date().timeIntervalSince(start)
            
            // Pulse Sampling
            if let latestPulse = metrics.pulse.rate.last {
                if self.localPulseHistory.last?.value != Double(latestPulse.value) {
                    let point = MetricPoint(time: currentTime, value: Double(latestPulse.value))
                    DispatchQueue.main.async { self.localPulseHistory.append(point) }
                }
            }
            
            // Breathing Sampling
            if let latestBreathing = metrics.breathing.rate.last {
                if self.localBreathingHistory.last?.value != Double(latestBreathing.value) {
                    let point = MetricPoint(time: currentTime, value: Double(latestBreathing.value))
                    DispatchQueue.main.async { self.localBreathingHistory.append(point) }
                }
            }
        }
    }
    
    func stopMonitoring(shouldUpload: Bool, driverID: String, fullName: String) {
        samplingTimer?.invalidate()
        samplingTimer = nil
        isRecording = false
        
        if shouldUpload {
            sendVitalsToBackend(
                driverID: driverID,
                fullName: fullName,
                pulseData: localPulseHistory,
                breathingData: localBreathingHistory
            ) { result in
                DispatchQueue.main.async {
                    self.safetyResult = result
                }
            }
        }
        
        vitalsProcessor.stopRecording()
        vitalsProcessor.stopProcessing()
    }
}
