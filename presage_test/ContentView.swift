import SwiftUI
import SmartSpectraSwiftSDK

struct ContentView: View {
    @ObservedObject var sdk = SmartSpectraSwiftSDK.shared

    init() {
        // Replace with your API key from https://physiology.presagetech.com
        sdk.setApiKey("")
    }

    var body: some View {
        SmartSpectraView()
    }
}

//import SwiftUI
//
//struct ContentView: View {
//    var body: some View {
//        Text("Hello, world!")
//            .padding()
//    }
//}
//
//#Preview {
//    ContentView()
//}
