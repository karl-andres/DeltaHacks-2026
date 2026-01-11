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
    @ObservedObject var vitalsManager = DriverVitalsManager.shared

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
            // Heart Rate Card (pulse_rate)
            MetricCardView(
                icon: "heart.fill",
                iconColor: AppTheme.Colors.roseAccent,
                title: "Heart Rate",
                value: vitalsManager.hasVitals ? String(format: "%.0f", vitalsManager.latestPulseRate) : "\(biometricsVM.currentHeartRate)",
                unit: "BPM",
                status: vitalsManager.hasVitals ? vitalsManager.vitalsStatus : "Resting",
                statusColor: AppTheme.Colors.successGreen,
                graphData: biometricsVM.heartRateHistory,
                graphColor: AppTheme.Colors.roseAccent,
                graphType: .line
            )

            // Respiration Card (breathing_rate)
            MetricCardView(
                icon: "wind",
                iconColor: AppTheme.Colors.skyAccent,
                title: "Resp Rate",
                value: vitalsManager.hasVitals ? String(format: "%.1f", vitalsManager.latestBreathingRate) : "\(biometricsVM.currentRespirationRate)",
                unit: "brpm",
                status: vitalsManager.hasVitals ? vitalsManager.vitalsStatus : "Normal",
                statusColor: AppTheme.Colors.skyAccent,
                graphData: biometricsVM.respirationHistory,
                graphColor: AppTheme.Colors.skyAccent,
                graphType: .curve
            )

            // Risk Score Card (risk_score)
            MetricCardView(
                icon: "exclamationmark.triangle.fill",
                iconColor: AppTheme.Colors.warningYellow,
                title: "Risk Score",
                value: vitalsManager.hasVitals ? String(format: "%.2f", vitalsManager.latestRiskScore) : "0.00",
                unit: "",
                status: vitalsManager.hasVitals ? (vitalsManager.latestRiskScore < 0.3 ? "Low" : vitalsManager.latestRiskScore < 0.7 ? "Medium" : "High") : "Unknown",
                statusColor: vitalsManager.hasVitals ? (vitalsManager.latestRiskScore < 0.3 ? AppTheme.Colors.successGreen : vitalsManager.latestRiskScore < 0.7 ? AppTheme.Colors.warningYellow : AppTheme.Colors.errorRed) : AppTheme.Colors.textTertiary,
                graphData: biometricsVM.heartRateHistory,
                graphColor: AppTheme.Colors.warningYellow,
                graphType: .line
            )

            // Pulse Respiration Quotient Card (pulse_respiration_quotient)
            MetricCardView(
                icon: "waveform.path.ecg",
                iconColor: AppTheme.Colors.purpleAccent,
                title: "PRQ",
                value: vitalsManager.hasVitals ? String(format: "%.1f", vitalsManager.latestPulseRespirationQuotient) : "0.0",
                unit: "ratio",
                status: vitalsManager.hasVitals ? vitalsManager.vitalsStatus : "Unknown",
                statusColor: AppTheme.Colors.purpleAccent,
                graphData: biometricsVM.hrvHistory,
                graphColor: AppTheme.Colors.purpleAccent,
                graphType: .wave
            )
        }
        .padding(.horizontal, AppTheme.Spacing.md)
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
