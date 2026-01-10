//
//  ReadinessStatusView.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-10.
//

import SwiftUI

struct ReadinessStatusView: View {
    let status: ReadinessStatus
    @EnvironmentObject var biometricsVM: BiometricsViewModel
    @EnvironmentObject var wellnessData: WellnessDataService
    @EnvironmentObject var appState: AppStateManager

    var body: some View {
        ZStack {
            // Background
            AppTheme.Colors.backgroundDark
                .ignoresSafeArea()

            // Ambient background effects
            ambientEffects

            VStack(spacing: 0) {
                // Top navigation
                topBar

                Spacer()

                // Central status orb
                StatusOrbView(status: status)
                    .padding(.vertical, AppTheme.Spacing.xl)

                // Status text
                statusText

                // Sync progress bar
                syncProgressBar
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.vertical, AppTheme.Spacing.xl)

                // Metrics display
                metricsDisplay
                    .padding(.horizontal, AppTheme.Spacing.lg)

                Spacer()

                // Bottom slide button
                if status == .fit {
                    SlideToStartButton {
                        appState.approveForDuty()
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.bottom, AppTheme.Spacing.xl)
                }
            }
            .padding(.top, AppTheme.Spacing.xl)
        }
    }

    // MARK: - Ambient Effects
    private var ambientEffects: some View {
        ZStack {
            Circle()
                .fill(AppTheme.Colors.primaryBlue.opacity(0.2))
                .blur(radius: 120)
                .frame(width: 400, height: 400)
                .offset(x: -100, y: -150)

            Circle()
                .fill((status == .fit ? AppTheme.Colors.successGreen : AppTheme.Colors.dangerRed).opacity(0.1))
                .blur(radius: 100)
                .frame(width: 300, height: 300)
                .offset(x: 100, y: 300)
        }
        .ignoresSafeArea()
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Button(action: {
                appState.showResultsFullScreen = false
                appState.currentState = .dashboard
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial)
                    .background(AppTheme.Colors.glassFill)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(AppTheme.Colors.glassBorder, lineWidth: 1)
                    )
            }

            Spacer()

            Text("Readiness Check")
                .font(AppTheme.Typography.caption)
                .fontWeight(.medium)
                .foregroundStyle(AppTheme.Colors.textTertiary)
                .textCase(.uppercase)
                .tracking(1.5)

            Spacer()

            Button(action: {}) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial)
                    .background(AppTheme.Colors.glassFill)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(AppTheme.Colors.glassBorder, lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
    }

    // MARK: - Status Text
    private var statusText: some View {
        VStack(spacing: 8) {
            Text(status.displayText)
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .shadow(color: .white.opacity(0.3), radius: 15)

            Text("Last sync: Just now")
                .font(AppTheme.Typography.callout)
                .foregroundStyle(AppTheme.Colors.textTertiary)
        }
    }

    // MARK: - Sync Progress Bar
    private var syncProgressBar: some View {
        GlassMorphismCard(cornerRadius: AppTheme.CornerRadius.full, padding: 8) {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(AppTheme.Colors.primaryBlue)
                        .frame(width: 40, height: 40)
                        .shadow(color: AppTheme.Colors.primaryBlue.opacity(0.4), radius: 10)

                    Image(systemName: "checkmark.icloud.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.white)
                }

                // Progress info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Sync Complete")
                            .font(AppTheme.Typography.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                            .textCase(.uppercase)

                        Spacer()

                        Text("100%")
                            .font(AppTheme.Typography.caption2)
                            .foregroundStyle(AppTheme.Colors.textTertiary)
                    }

                    // Progress track
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 6)

                            Capsule()
                                .fill(AppTheme.Colors.primaryBlue)
                                .frame(width: geometry.size.width, height: 6)
                                .shadow(color: AppTheme.Colors.primaryBlue.opacity(0.8), radius: 5)
                        }
                    }
                    .frame(height: 6)
                }

                Image(systemName: "checkmark")
                    .font(.system(size: 20))
                    .foregroundStyle(AppTheme.Colors.primaryBlue)
            }
        }
    }

    // MARK: - Metrics Display
    private var metricsDisplay: some View {
        HStack(spacing: 16) {
            // Sleep hours
            GlassMorphismCard(cornerRadius: 16, padding: 16) {
                VStack(spacing: 8) {
                    Text("Hours Slept")
                        .font(AppTheme.Typography.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                        .textCase(.uppercase)

                    HStack(spacing: 6) {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(AppTheme.Colors.indigoAccent)

                        Text(wellnessData.wellnessMetrics.formattedSleepDuration)
                            .font(AppTheme.Typography.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                    }
                }
            }

            // HRV score
            GlassMorphismCard(cornerRadius: 16, padding: 16) {
                VStack(spacing: 8) {
                    Text("HRV Score")
                        .font(AppTheme.Typography.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                        .textCase(.uppercase)

                    HStack(spacing: 6) {
                        Image(systemName: "waveform.path.ecg")
                            .font(.system(size: 16))
                            .foregroundStyle(AppTheme.Colors.roseAccent)

                        Text("\(biometricsVM.hrvScore)ms")
                            .font(AppTheme.Typography.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview("Fit to Drive") {
    ReadinessStatusView(status: .fit)
        .environmentObject(BiometricsViewModel.preview)
        .environmentObject(WellnessDataService.preview)
        .environmentObject(AppStateManager.preview)
}

#Preview("Rest Advised") {
    ReadinessStatusView(status: .restAdvised)
        .environmentObject(BiometricsViewModel.preview)
        .environmentObject(WellnessDataService.preview)
        .environmentObject(AppStateManager.preview)
}
