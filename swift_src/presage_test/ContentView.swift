import SwiftUI
import SmartSpectraSwiftSDK

struct ContentView: View {
    @ObservedObject var sdk = SmartSpectraSwiftSDK.shared
    @ObservedObject var vitalsProcessor = SmartSpectraVitalsProcessor.shared
    @State private var isVitalMonitoringEnabled: Bool = false
    // EVERYTHING UNDER ESSENTIAL FOR ACTUALLY RETURNING ARRAYS OF PULSE AND BREATHE (DO NOT MODIFY)
    @State private var localPulseHistory: [MetricPoint] = []
    @State private var localBreathingHistory: [MetricPoint] = []
    @State private var samplingTimer: Timer? = nil
    @State private var sessionStartTime: Date? = nil

    // NEW: Add a property to show mock status in preview
    var mockStatus: String? = nil
    
    init(mockStatus: String? = nil) {
        if !ProcessInfo.isPreview {
            let apiKey = "XDTroSWEaP4ISp3zEfFRCaf1JhXFwfS817R0si6y"
            sdk.setApiKey(apiKey)
            sdk.setRecordingDelay(0)
        }
    }

    var body: some View {
        VStack {
            GroupBox(label: Text("Vitals")) {
                ContinuousVitalsPlotView()
                Grid {
                    GridRow {
                        Text("Status: \(mockStatus ?? vitalsProcessor.statusHint)")
                    }
                    GridRow {
                        HStack {
                            Text("Vitals Monitoring")
                            Spacer()
                            Button(isVitalMonitoringEnabled ? "Stop": "Start") {
                                isVitalMonitoringEnabled.toggle()
                                if(isVitalMonitoringEnabled) {
                                    startVitalsMonitoring()
                                } else {
                                    stopVitalsMonitoring(shouldUpload: true)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 10)
            }
        }
    }

// main functions for starting and stopping vital monitoring (DO NOT MODIFY)
    func startVitalsMonitoring() {
        // Reset local buffers for a new session
        localPulseHistory = []
        localBreathingHistory = []
        sessionStartTime = Date()
        
        vitalsProcessor.startProcessing()
        vitalsProcessor.startRecording()
        
        // Start the Sampling Timer (Every 0.25 seconds)
        samplingTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { _ in
            guard let metrics = sdk.metricsBuffer, let start = sessionStartTime else { return }
            let currentTime = Date().timeIntervalSince(start)
            
            // Pulse Update
            if let latestPulse = metrics.pulse.rate.last {
                // Only append if it's a "fresh" reading or if the history is empty
                if localPulseHistory.last?.value != Double(latestPulse.value) {
                    let point = MetricPoint(time: currentTime, value: Double(latestPulse.value))
                    localPulseHistory.append(point)
                }
            }
            
            // Breathing Update
            if let latestBreathing = metrics.breathing.rate.last {
                if localBreathingHistory.last?.value != Double(latestBreathing.value) {
                    let point = MetricPoint(time: currentTime, value: Double(latestBreathing.value))
                    localBreathingHistory.append(point)
                }
            }
        }
    }

    @State private var safetyResult: Bool? = nil // null = no result yet, true = safe, false = danger

    func stopVitalsMonitoring(shouldUpload: Bool) {
        // 1. KILL THE TIMER FIRST
        // If you don't do this, the timer keeps trying to append data
        // even after you hit stop.
        samplingTimer?.invalidate()
        samplingTimer = nil
        
        if shouldUpload {
            print("Uploading \(localPulseHistory.count) pulse points...")
            
            sendVitalsToBackend(
                driverID: "karl_001",
                fullName: "Karl Andres",
                pulseData: localPulseHistory,
                breathingData: localBreathingHistory
            ) { isSafe in
                DispatchQueue.main.async {
                    self.safetyResult = isSafe
                }
            }
        }

        vitalsProcessor.stopRecording()
        vitalsProcessor.stopProcessing()
        isVitalMonitoringEnabled = false
    }
}

// so i can see on xcode
#Preview {
    // Pass in a string so you can see how the text fits in the UI
    ContentView(mockStatus: "Looking for face...")
}

// make sure to not load sdk if in preview mode
extension ProcessInfo {
    static var isPreview: Bool {
        processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
