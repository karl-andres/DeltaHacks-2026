//
//  RestAdvisedView.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-10.
//

import SwiftUI

struct RestAdvisedView: View {
    @EnvironmentObject var biometricsVM: BiometricsViewModel
    @EnvironmentObject var wellnessData: WellnessDataService
    @EnvironmentObject var appState: AppStateManager

    var body: some View {
        ZStack {
            // Background
            AppTheme.Colors.backgroundDark
                .ignoresSafeArea()

            // Ambient effects
            ambientEffects

            VStack(spacing: 0) {
                // Top header
                topHeader

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppTheme.Spacing.lg) {
                        // Warning circle
                        warningCircle
                            .padding(.vertical, AppTheme.Spacing.xl)

                        // Status text
                        statusText

                        // Alertness progress bar
                        AlertnessProgressBar(score: wellnessData.wellnessMetrics.alertnessScore)
                            .padding(.horizontal, AppTheme.Spacing.md)

                        // Stats grid
                        statsGrid
                            .padding(.horizontal, AppTheme.Spacing.md)

                        // Rest stops section
                        restStopsSection

                        // Bottom spacing
                        Color.clear.frame(height: 200)
                    }
                }
            }

            // Fixed bottom action bar
            VStack {
                Spacer()
                actionButtons
            }
        }
    }

    // MARK: - Ambient Effects
    private var ambientEffects: some View {
        ZStack {
            Circle()
                .fill(AppTheme.Colors.dangerRed.opacity(0.1))
                .blur(radius: 120)
                .frame(width: 500, height: 500)
                .offset(x: -100, y: -100)

            Circle()
                .fill(Color.blue.opacity(0.1))
                .blur(radius: 100)
                .frame(width: 400, height: 400)
                .offset(x: 150, y: 400)
        }
        .ignoresSafeArea()
    }

    // MARK: - Top Header
    private var topHeader: some View {
        HStack {
            Text("Readiness Assessment")
                .font(AppTheme.Typography.headline)
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            Spacer()

            // Synced badge
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(AppTheme.Colors.successGreen)

                Text("Synced")
                    .font(AppTheme.Typography.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .textCase(.uppercase)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(AppTheme.Colors.glassFill)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(AppTheme.Colors.glassBorder, lineWidth: 1)
            )
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.top, AppTheme.Spacing.xl)
        .padding(.bottom, AppTheme.Spacing.md)
        .background(.ultraThinMaterial)
        .background(AppTheme.Colors.backgroundDark.opacity(0.7))
    }

    // MARK: - Warning Circle
    @State private var isPulsing = false
    private var warningCircle: some View {
        ZStack {
            // Outer pulsing glow
            Circle()
                .fill(AppTheme.Colors.dangerRed.opacity(0.2))
                .frame(width: 160, height: 160)
                .blur(radius: 40)
                .scaleEffect(isPulsing ? 1.2 : 1.0)
                .opacity(isPulsing ? 0.6 : 0.2)

            // Main circle
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            AppTheme.Colors.dangerRed.opacity(0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)
                .overlay(
                    Circle()
                        .stroke(AppTheme.Colors.dangerRed.opacity(0.5), lineWidth: 1)
                )

            // Inner circle with icon
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.black,
                            AppTheme.Colors.dangerRed.opacity(0.3)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 64
                    )
                )
                .frame(width: 128, height: 128)
                .overlay(
                    Circle()
                        .stroke(AppTheme.Colors.dangerRed.opacity(0.3), lineWidth: 1)
                )
                .overlay(
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(AppTheme.Colors.dangerRed)
                        .shadow(color: AppTheme.Colors.dangerRed.opacity(0.8), radius: 10)
                )
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 3.0)
                .repeatForever(autoreverses: true)
            ) {
                isPulsing = true
            }
        }
    }

    // MARK: - Status Text
    private var statusText: some View {
        VStack(spacing: 8) {
            Text("REST ADVISED")
                .font(.system(size: 32, weight: .extrabold, design: .rounded))
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .shadow(color: .black.opacity(0.3), radius: 5)

            Text("Alertness levels are below safe operating thresholds.")
                .font(AppTheme.Typography.callout)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
    }

    // MARK: - Stats Grid
    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            // Sleep Debt
            GlassMorphismCard(cornerRadius: 12, padding: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(AppTheme.Colors.purpleAccent)

                        Text("Sleep Debt")
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(AppTheme.Colors.textTertiary)
                    }

                    Text(wellnessData.wellnessMetrics.sleepDebt.rawValue)
                        .font(AppTheme.Typography.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.Colors.textPrimary)

                    Text(wellnessData.wellnessMetrics.sleepDebt.percentageImpact)
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.dangerRed)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Reaction Time
            GlassMorphismCard(cornerRadius: 12, padding: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "gauge.high")
                            .font(.system(size: 18))
                            .foregroundStyle(AppTheme.Colors.warningYellow)

                        Text("Reaction Time")
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(AppTheme.Colors.textTertiary)
                    }

                    Text(wellnessData.wellnessMetrics.reactionTime.rawValue)
                        .font(AppTheme.Typography.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Shift Duration (full width)
            GlassMorphismCard(cornerRadius: 12, padding: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(AppTheme.Colors.skyAccent)

                            Text("Shift Duration")
                                .font(AppTheme.Typography.caption)
                                .foregroundStyle(AppTheme.Colors.textTertiary)
                        }

                        Text(wellnessData.wellnessMetrics.formattedShiftDuration)
                            .font(AppTheme.Typography.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                    }

                    Spacer()

                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 32))
                        .foregroundStyle(AppTheme.Colors.textTertiary.opacity(0.3))
                }
            }
            .gridCellColumns(2)
        }
    }

    // MARK: - Rest Stops Section
    private var restStopsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Text("Nearest Safe Havens")
                    .font(AppTheme.Typography.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.Colors.textPrimary)

                Spacer()

                Button(action: {}) {
                    Text("View Map")
                        .font(AppTheme.Typography.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.Colors.primaryBlue)
                        .textCase(.uppercase)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(wellnessData.restStops) { stop in
                        RestStopCard(restStop: stop)
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.md)
            }
        }
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Log rest start button
            Button(action: {
                appState.logRestStart()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "bed.double.fill")
                        .font(.system(size: 20))

                    Text("Log Rest Start")
                        .font(AppTheme.Typography.headline)
                        .fontWeight(.bold)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(AppTheme.Colors.dangerRed)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: AppTheme.Colors.dangerRed.opacity(0.4), radius: 20, y: 4)
            }

            // Request supervisor review
            Button(action: {}) {
                HStack(spacing: 8) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 16))

                    Text("Request Supervisor Review")
                        .font(AppTheme.Typography.callout)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(.ultraThinMaterial)
                .background(AppTheme.Colors.glassFill)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.Colors.glassBorder, lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.top, AppTheme.Spacing.lg)
        .padding(.bottom, AppTheme.Spacing.xl)
        .background(
            LinearGradient(
                colors: [
                    Color.clear,
                    AppTheme.Colors.backgroundDark.opacity(0.95),
                    AppTheme.Colors.backgroundDark
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}

// MARK: - Rest Stop Card
struct RestStopCard: View {
    let restStop: RestStop

    var body: some View {
        GlassMorphismCard(cornerRadius: 12, padding: 0) {
            VStack(alignment: .leading, spacing: 0) {
                // Placeholder image
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.Colors.primaryBlue.opacity(0.3), AppTheme.Colors.purpleAccent.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 112)
                    .overlay(
                        ZStack(alignment: .bottomLeading) {
                            LinearGradient(
                                colors: [Color.clear, Color.black.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )

                            Text(restStop.formattedDistance)
                                .font(AppTheme.Typography.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(restStop.distance < 5 ? AppTheme.Colors.successGreen.opacity(0.9) : Color.gray.opacity(0.8))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .padding(AppTheme.Spacing.sm)
                        }
                    )

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(restStop.name)
                            .font(AppTheme.Typography.callout)
                            .fontWeight(.bold)
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                            .lineLimit(1)

                        Spacer()

                        Image(systemName: restStop.type.rawValue)
                            .font(.system(size: 16))
                            .foregroundStyle(AppTheme.Colors.textTertiary)
                    }

                    Text(restStop.location)
                        .font(AppTheme.Typography.caption2)
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        ForEach(restStop.amenities.prefix(2), id: \.self) { amenity in
                            Text(amenity)
                                .font(AppTheme.Typography.caption2)
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(AppTheme.Spacing.md)
            }
        }
        .frame(width: 260)
    }
}

// MARK: - Preview
#Preview {
    RestAdvisedView()
        .environmentObject(BiometricsViewModel.preview)
        .environmentObject({
            let service = WellnessDataService.preview
            service.wellnessMetrics.alertnessScore = 42
            return service
        }())
        .environmentObject(AppStateManager.preview)
}
