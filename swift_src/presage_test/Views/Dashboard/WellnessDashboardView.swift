//
//  WellnessDashboardView.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-10.
//

import SwiftUI

struct WellnessDashboardView: View {
    @EnvironmentObject var biometricsVM: BiometricsViewModel
    @EnvironmentObject var wellnessData: WellnessDataService
    @ObservedObject var scanHistory = ScanHistoryService.shared

    @State private var isSyncing = false
    @State private var lastSyncTime = Date()

    var body: some View {
        ZStack {
            // Background
            AppTheme.Colors.backgroundDark
                .ignoresSafeArea()

            // Ambient glow effects
            ambientGlowEffects

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Profile header
                    ProfileHeaderView()

                    // Section title
                    HStack {
                        Text("Readiness")
                            .font(AppTheme.Typography.title)
                            .fontWeight(.bold)
                            .foregroundStyle(AppTheme.Colors.textPrimary)

                        Spacer()

                        Text(currentTimeString)
                            .font(AppTheme.Typography.callout)
                            .foregroundStyle(AppTheme.Colors.textTertiary)
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.top, AppTheme.Spacing.lg)
                    .padding(.bottom, AppTheme.Spacing.md)

                    // Metrics grid
                    metricsGrid

                    // Sync wearable button
                    syncWearableButton

                    // Bottom spacing for tab bar
                    Color.clear.frame(height: 100)
                }
            }
        }
    }

    // MARK: - Ambient Glow Effects
    private var ambientGlowEffects: some View {
        ZStack {
            Circle()
                .fill(AppTheme.Colors.primaryBlue.opacity(0.15))
                .blur(radius: 120)
                .frame(width: 300, height: 300)
                .offset(x: -100, y: -200)

            Circle()
                .fill(AppTheme.Colors.successGreen.opacity(0.08))
                .blur(radius: 100)
                .frame(width: 300, height: 300)
                .offset(x: 150, y: 400)
        }
        .ignoresSafeArea()
    }

    // MARK: - Metrics Grid
    private var metricsGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: 16
        ) {
            // Heart Rate Card - show latest scan or current biometric
            MetricCardView(
                icon: "heart.fill",
                iconColor: AppTheme.Colors.roseAccent,
                title: "Pulse Rate",
                value: latestPulseRate,
                unit: "BPM",
                status: latestStatus,
                statusColor: statusColor,
                graphData: pulseRateHistory,
                graphColor: AppTheme.Colors.roseAccent,
                graphType: .line
            )

            // Integrated Vital Score Card
            MetricCardView(
                icon: "waveform.path.ecg",
                iconColor: AppTheme.Colors.purpleAccent,
                title: "Vital Score",
                value: latestIntegratedVitalScore,
                unit: "",
                status: latestStatus,
                statusColor: statusColor,
                graphData: integratedVitalScoreHistory,
                graphColor: AppTheme.Colors.purpleAccent,
                graphType: .wave
            )

            // Respiration Card
            MetricCardView(
                icon: "wind",
                iconColor: AppTheme.Colors.skyAccent,
                title: "Breathing Rate",
                value: latestBreathingRate,
                unit: "brpm",
                status: latestStatus,
                statusColor: statusColor,
                graphData: breathingRateHistory,
                graphColor: AppTheme.Colors.skyAccent,
                graphType: .curve
            )

            // Alertness Card
            MetricCardView(
                icon: "bolt.fill",
                iconColor: AppTheme.Colors.primaryBlue,
                title: "Alertness Index",
                value: latestAlertnessIndex,
                unit: "",
                status: latestStatus,
                statusColor: statusColor,
                graphData: alertnessIndexHistory,
                graphColor: AppTheme.Colors.primaryBlue,
                graphType: .line
            )
        }
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    // MARK: - Computed Properties for Latest Scan Data

    private var latestPulseRate: String {
        if let latest = scanHistory.getLatestScan() {
            return String(format: "%.0f", latest.backendResult.pulse_rate)
        }
        return "\(biometricsVM.currentHeartRate)"
    }

    private var latestBreathingRate: String {
        if let latest = scanHistory.getLatestScan() {
            return String(format: "%.1f", latest.backendResult.breathing_rate)
        }
        return "\(biometricsVM.currentRespirationRate)"
    }

    private var latestIntegratedVitalScore: String {
        if let latest = scanHistory.getLatestScan() {
            return String(format: "%.1f", latest.backendResult.integrated_vital_score)
        }
        return "\(biometricsVM.hrvScore)"
    }

    private var latestAlertnessIndex: String {
        if let latest = scanHistory.getLatestScan() {
            return String(format: "%.1f", latest.backendResult.nonlinear_alertness_index)
        }
        return String(format: "%.0f", biometricsVM.alertnessLevel)
    }

    private var latestStatus: String {
        if let latest = scanHistory.getLatestScan() {
            return latest.status.capitalized
        }
        return "Ready"
    }

    private var statusColor: Color {
        if let latest = scanHistory.getLatestScan() {
            return latest.status == "at_risk" ? AppTheme.Colors.warningYellow : AppTheme.Colors.successGreen
        }
        return AppTheme.Colors.successGreen
    }

    private var pulseRateHistory: [Double] {
        return scanHistory.scanHistory.prefix(20).reversed().map { Double($0.backendResult.pulse_rate) }
    }

    private var breathingRateHistory: [Double] {
        return scanHistory.scanHistory.prefix(20).reversed().map { Double($0.backendResult.breathing_rate) }
    }

    private var integratedVitalScoreHistory: [Double] {
        return scanHistory.scanHistory.prefix(20).reversed().map { Double($0.backendResult.integrated_vital_score) }
    }

    private var alertnessIndexHistory: [Double] {
        return scanHistory.scanHistory.prefix(20).reversed().map { Double($0.backendResult.nonlinear_alertness_index) }
    }

    // MARK: - Sync Wearable Button
    private var syncWearableButton: some View {
        Button(action: syncWearable) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 40, height: 40)

                    if isSyncing {
                        ProgressView()
                            .tint(AppTheme.Colors.textPrimary)
                    } else {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 20))
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(isSyncing ? "Syncing..." : "Sync Wearable")
                        .font(AppTheme.Typography.callout)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.Colors.textPrimary)

                    Text("Last sync: \(timeSinceLastSync)")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                }

                Spacer()

                if !isSyncing {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                }
            }
            .padding(AppTheme.Spacing.md)
            .background(.ultraThinMaterial)
            .background(AppTheme.Colors.glassFill)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                    .stroke(
                        isSyncing ? AppTheme.Colors.primaryBlue : AppTheme.Colors.glassBorder,
                        lineWidth: isSyncing ? 2 : 1
                    )
            )
        }
        .disabled(isSyncing)
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.top, AppTheme.Spacing.lg)
    }

    // MARK: - Sync Action
    private func syncWearable() {
        withAnimation {
            isSyncing = true
        }

        Task {
            // Simulate syncing with wearable device
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds

            await MainActor.run {
                // Update biometrics with fresh data
                biometricsVM.refreshMetrics()
                lastSyncTime = Date()

                withAnimation {
                    isSyncing = false
                }
            }
        }
    }

    // MARK: - Time Since Last Sync
    private var timeSinceLastSync: String {
        let interval = Date().timeIntervalSince(lastSyncTime)
        let minutes = Int(interval / 60)

        if minutes < 1 {
            return "Just now"
        } else if minutes == 1 {
            return "1 min ago"
        } else if minutes < 60 {
            return "\(minutes) min ago"
        } else {
            let hours = minutes / 60
            return "\(hours) hour\(hours > 1 ? "s" : "") ago"
        }
    }

    // MARK: - Helper
    private var currentTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "'Today,' HH:mm"
        return formatter.string(from: Date())
    }
}

// MARK: - Preview
#Preview {
    WellnessDashboardView()
        .environmentObject(BiometricsViewModel.preview)
        .environmentObject(WellnessDataService.preview)
        .environmentObject(AppStateManager.preview)
}
