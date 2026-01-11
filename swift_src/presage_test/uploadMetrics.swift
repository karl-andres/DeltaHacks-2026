import Foundation
import SmartSpectraSwiftSDK

// 1. This is your "Bridge" struct. It is Codable.
struct MetricPoint: Codable {
    let time: Double
    let value: Double
}

struct BackendResponse: Codable {
    let status: Bool
}

struct VitalsReport: Codable {
    let driver_id: String
    let fullname: String
    let timestamp: Double
    let breathing_rate: [MetricPoint]
    let pulse_rate: [MetricPoint]
    let landmarks_stable: Bool
}

func sendVitalsToBackend(driverID: String, fullName: String, pulseData: [MetricPoint], breathingData: [MetricPoint], completion: @escaping (Bool) -> Void) {
    let sdk = SmartSpectraSwiftSDK.shared
    
    guard let metricsBuffer = sdk.metricsBuffer else {
        print("Error: No vital metrics found.")
        completion(false)
        return
    }
    
    guard let edgeMetrics = sdk.edgeMetrics else {
        print("Error: No edge metrics found.")
        completion(false)
        return
    }

    let faceDetected = sdk.edgeMetrics?.hasFace ?? false
    
    // --- THE FIX: MAPPING ---
    // This converts the non-Codable SDK array into your Codable MetricPoint array
//    let mappedPulse: [MetricPoint] = metricsBuffer.pulse.rate.map { measurement in
//        MetricPoint(time: Double(measurement.time), value: Double(measurement.value))
//    }
//    
//    let mappedBreathing: [MetricPoint] = metricsBuffer.breathing.rate.map { measurement in
//        MetricPoint(time: Double(measurement.time), value: Double(measurement.value))
//    }
    
    let report = VitalsReport(
        driver_id: driverID,
        fullname: fullName,
        timestamp: Date().timeIntervalSince1970,
        // Use the mapped arrays here
        breathing_rate: breathingData, // returns array
        pulse_rate: pulseData, // returns array
        landmarks_stable: faceDetected
    )

    // Using your ngrok URL
    guard let url = URL(string: "https://carolee-nonerosive-prewillingly.ngrok-free.dev/detect") else { return }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    do {
        let jsonData = try JSONEncoder().encode(report)
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, error == nil {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Server Response: \(responseString)")
                }
                
                do {
                    let backendResult = try JSONDecoder().decode(BackendResponse.self, from: data)
                    DispatchQueue.main.async { completion(backendResult.status) }
                } catch {
                    print("Decoding error: \(error)")
                    DispatchQueue.main.async { completion(false) }
                }
            } else {
                print("Network error: \(error?.localizedDescription ?? "Unknown")")
                DispatchQueue.main.async { completion(false) }
            }
        }.resume()
        
    } catch {
        print("Encoding error: \(error)")
        completion(false)
    }
}
