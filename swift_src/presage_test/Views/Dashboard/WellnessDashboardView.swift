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
            // Heart Rate Card
            MetricCardView(
                icon: "heart.fill",
                iconColor: AppTheme.Colors.roseAccent,
                title: "Heart Rate",
                value: "\(biometricsVM.currentHeartRate)",
                unit: "BPM",
                status: "Resting",
                statusColor: AppTheme.Colors.successGreen,
                graphData: biometricsVM.heartRateHistory,
                graphColor: AppTheme.Colors.roseAccent,
                graphType: .line
            )

            // HRV Card
            MetricCardView(
                icon: "waveform.path.ecg",
                iconColor: AppTheme.Colors.purpleAccent,
                title: "HRV",
                value: "\(biometricsVM.hrvScore)",
                unit: "ms",
                status: "Ready",
                statusColor: AppTheme.Colors.purpleAccent,
                graphData: biometricsVM.hrvHistory,
                graphColor: AppTheme.Colors.purpleAccent,
                graphType: .wave
            )

            // Respiration Card
            MetricCardView(
                icon: "wind",
                iconColor: AppTheme.Colors.skyAccent,
                title: "Resp Rate",
                value: "\(biometricsVM.currentRespirationRate)",
                unit: "brpm",
                status: "Normal",
                statusColor: AppTheme.Colors.skyAccent,
                graphData: biometricsVM.respirationHistory,
                graphColor: AppTheme.Colors.skyAccent,
                graphType: .curve
            )

            // Alertness Card
            MetricCardView(
                icon: "bolt.fill",
                iconColor: AppTheme.Colors.primaryBlue,
                title: "Alertness",
                value: String(format: "%.0f", biometricsVM.alertnessLevel),
                unit: "%",
                status: AlertnessLevel.from(score: biometricsVM.alertnessLevel).rawValue,
                statusColor: biometricsVM.alertnessLevel >= 75 ? AppTheme.Colors.primaryBlue : AppTheme.Colors.warningYellow,
                graphData: biometricsVM.alertnessHistory,
                graphColor: AppTheme.Colors.primaryBlue,
                graphType: .line
            )
        }
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    // MARK: - Sync Wearable Button
    private var syncWearableButton: some View {
        Button(action: {
            // Trigger sync action
        }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 40, height: 40)

                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 20))
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Sync Wearable")
                        .font(AppTheme.Typography.callout)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.Colors.textPrimary)

                    Text("Last sync: 2 min ago")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.Colors.textTertiary)
            }
            .padding(AppTheme.Spacing.md)
            .background(.ultraThinMaterial)
            .background(AppTheme.Colors.glassFill)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                    .stroke(AppTheme.Colors.glassBorder, lineWidth: 1)
            )
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.top, AppTheme.Spacing.lg)
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
