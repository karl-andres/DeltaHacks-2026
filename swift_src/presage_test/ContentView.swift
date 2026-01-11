import SwiftUI
import SmartSpectraSwiftSDK

struct ContentView: View {
    // State management
    @StateObject private var biometricsVM = BiometricsViewModel()
    @StateObject private var appState = AppStateManager()
    @StateObject private var wellnessData = WellnessDataService()
    @StateObject private var authManager = AuthenticationManager()

    // Tab selection
    @State private var selectedTab: Tab = .home

    enum Tab {
        case home
        case history
        case profile
        case settings
    }

    init() {
        // Initialize SDK with API key
        let sdk = SmartSpectraSwiftSDK.shared
        // Replace with your API key from https://physiology.presagetech.com
        sdk.setApiKey("")
    }

    var body: some View {
        Group {
            if authManager.isAuthenticated {
                authenticatedView
            } else {
                LoginView()
                    .environmentObject(authManager)
            }
        }
        .onAppear {
            authManager.checkExistingSession()
        }
    }

    // MARK: - Authenticated View
    private var authenticatedView: some View {
        ZStack {
            // Main navigation
            mainContent

            // Tab bar overlay (visible on all tabs except when scanning/showing results)
            if !appState.showScanSheet, !appState.showResultsFullScreen {
                VStack {
                    Spacer()
                    bottomTabBar
                }
            }
        }
        .sheet(isPresented: $appState.showScanSheet) {
            BiometricScanView()
                .environmentObject(biometricsVM)
                .environmentObject(appState)
                .onDisappear {
                    // Handle scan completion
                    if biometricsVM.scanProgress >= 1.0 {
                        let status = biometricsVM.readinessStatus
                        appState.completeScan(result: status)
                    }
                }
        }
        .fullScreenCover(isPresented: $appState.showResultsFullScreen) {
            resultView
        }
    }

    // MARK: - Main Content
    @ViewBuilder
    private var mainContent: some View {
        switch selectedTab {
        case .home:
            WellnessDashboardView()
                .environmentObject(biometricsVM)
                .environmentObject(appState)
                .environmentObject(wellnessData)
        case .history:
            HistoryView()
                .environmentObject(wellnessData)
        case .profile:
            ProfileView()
                .environmentObject(biometricsVM)
                .environmentObject(authManager)
        case .settings:
            SettingsView()
                .environmentObject(authManager)
        }
    }

    // MARK: - Result View
    @ViewBuilder
    private var resultView: some View {
        if case .showingResults(let status) = appState.currentState {
            if status == .fit {
                ReadinessStatusView(status: status)
                    .environmentObject(biometricsVM)
                    .environmentObject(wellnessData)
                    .environmentObject(appState)
            } else {
                RestAdvisedView()
                    .environmentObject(biometricsVM)
                    .environmentObject(wellnessData)
                    .environmentObject(appState)
            }
        }
    }

    // MARK: - Bottom Tab Bar
    private var bottomTabBar: some View {
        HStack(spacing: 0) {
            TabBarItem(icon: "house.fill", isActive: selectedTab == .home) {
                selectedTab = .home
            }
            TabBarItem(icon: "clock.arrow.circlepath", isActive: selectedTab == .history) {
                selectedTab = .history
            }
            TabBarItem(icon: "person.fill", isActive: selectedTab == .profile) {
                selectedTab = .profile
            }
            TabBarItem(icon: "gearshape.fill", isActive: selectedTab == .settings) {
                selectedTab = .settings
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.vertical, AppTheme.Spacing.md)
        .background(.ultraThinMaterial)
        .background(AppTheme.Colors.cardBackground.opacity(0.85))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(AppTheme.Colors.glassBorder, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.4), radius: 30, y: -4)
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.bottom, AppTheme.Spacing.lg)
    }
}

// MARK: - Tab Bar Item
struct TabBarItem: View {
    let icon: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(isActive ? AppTheme.Colors.primaryBlue : AppTheme.Colors.textTertiary)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}

extension ProcessInfo {
    static var isPreview: Bool {
        processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
