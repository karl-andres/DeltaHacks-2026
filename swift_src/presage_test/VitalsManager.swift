import SwiftUI
import SmartSpectraSwiftSDK

final class VitalsManager: ObservableObject {

    // ✅ SINGLETON
    static let shared = VitalsManager()
    private init() {
        if !ProcessInfo.isPreview {
            let apiKey = "t0MDutRCF739GGrTjwT1k1XMXHNUQdNE4mCgroCE"
            sdk.setApiKey(apiKey)
            sdk.setRecordingDelay(0)
            sdk.setSmartSpectraMode(.continuous)
        }
    }

    // 1. SDK Instances
    @ObservedObject var sdk = SmartSpectraSwiftSDK.shared
    @ObservedObject var vitalsProcessor = SmartSpectraVitalsProcessor.shared
    
    // 2. Local Buffers
    @Published var localPulseHistory: [MetricPoint] = []
    @Published var localBreathingHistory: [MetricPoint] = []
    @Published var isRecording: Bool = false
    @Published var safetyResult: Bool? = nil
    
    private var samplingTimer: Timer? = nil
    private var sessionStartTime: Date? = nil

    func startMonitoring() {
        localPulseHistory = []
        localBreathingHistory = []
        sessionStartTime = Date()
        safetyResult = nil
        isRecording = true
        
        vitalsProcessor.startProcessing()
        vitalsProcessor.startRecording()
        
        samplingTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            guard let self = self,
                  let metrics = self.sdk.metricsBuffer,
                  let start = self.sessionStartTime else { return }
            
            let currentTime = Date().timeIntervalSince(start)
            
            if let latestPulse = metrics.pulse.rate.last {
                if self.localPulseHistory.last?.value != Double(latestPulse.value) {
                    let point = MetricPoint(time: currentTime, value: Double(latestPulse.value))
                    DispatchQueue.main.async { self.localPulseHistory.append(point) }
                }
            }
            
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
