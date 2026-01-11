import SwiftUI
import SmartSpectraSwiftSDK

struct ContentView: View {
    // 1. Use the Manager we just created
    @StateObject var manager = VitalsManager()
    var mockStatus: String? = nil

    var body: some View {
        VStack {
            GroupBox(label: Text("Vitals")) {
                ContinuousVitalsPlotView()
                Grid {
                    GridRow {
                        Text("Status: \(mockStatus ?? manager.vitalsProcessor.statusHint)")
                    }
                    GridRow {
                        HStack {
                            Text("Vitals Monitoring")
                            Spacer()
                            Button(manager.isRecording ? "Stop" : "Start") {
                                if manager.isRecording {
                                    manager.stopMonitoring(shouldUpload: true, driverID: "karl_001", fullName: "Karl Andres")
                                } else {
                                    manager.startMonitoring()
                                }
                            }
                        }
                    }
                    // Debug view to see points growing
                    if manager.isRecording {
                        Text("Collected: \(manager.localPulseHistory.count) points")
                            .font(.caption2).foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 10)
            }
            
            // Show result overlay
            if let safe = manager.safetyResult {
                Text(safe ? "✅ SAFE TO DRIVE" : "🛑 DO NOT DRIVE")
                    .bold().padding().background(safe ? Color.green : Color.red).foregroundColor(.white).cornerRadius(8)
            }
        }
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
