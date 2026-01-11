//
//  HistoryView.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-10.
//

import SwiftUI

struct HistoryView: View {
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
                    // Header
                    headerView

                    // Time period selector
                    timePeriodSelector

                    // Metrics history list
                    metricsHistoryList

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
                .fill(AppTheme.Colors.purpleAccent.opacity(0.12))
                .blur(radius: 120)
                .frame(width: 300, height: 300)
                .offset(x: -100, y: -200)

            Circle()
                .fill(AppTheme.Colors.primaryBlue.opacity(0.08))
                .blur(radius: 100)
                .frame(width: 300, height: 300)
                .offset(x: 150, y: 400)
        }
        .ignoresSafeArea()
    }

    // MARK: - Header
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("History")
                .font(AppTheme.Typography.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            Text("Your wellness metrics over time")
                .font(AppTheme.Typography.callout)
                .foregroundStyle(AppTheme.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.top, 60)
        .padding(.bottom, AppTheme.Spacing.md)
    }

    // MARK: - Time Period Selector
    @State private var selectedPeriod: TimePeriod = .week

    enum TimePeriod: String, CaseIterable {
        case day = "Day"
        case week = "Week"
        case month = "Month"
        case all = "All"
    }

    private var timePeriodSelector: some View {
        HStack(spacing: 12) {
            ForEach(TimePeriod.allCases, id: \.self) { period in
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        selectedPeriod = period
                    }
                }) {
                    Text(period.rawValue)
                        .font(AppTheme.Typography.callout)
                        .fontWeight(.medium)
                        .foregroundStyle(selectedPeriod == period ? AppTheme.Colors.textPrimary : AppTheme.Colors.textTertiary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            selectedPeriod == period ?
                                AppTheme.Colors.primaryBlue.opacity(0.3) :
                                Color.white.opacity(0.05)
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(selectedPeriod == period ? AppTheme.Colors.primaryBlue : Color.clear, lineWidth: 1)
                        )
                }
            }
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.bottom, AppTheme.Spacing.lg)
    }

    // MARK: - Metrics History List
    private var metricsHistoryList: some View {
        VStack(spacing: 16) {
            HistoryMetricCard(
                icon: "heart.fill",
                iconColor: AppTheme.Colors.roseAccent,
                title: "Heart Rate",
                average: "72",
                unit: "BPM",
                trend: "+2%",
                trendUp: true
            )

            HistoryMetricCard(
                icon: "waveform.path.ecg",
                iconColor: AppTheme.Colors.purpleAccent,
                title: "HRV",
                average: "98",
                unit: "ms",
                trend: "+5%",
                trendUp: true
            )

            HistoryMetricCard(
                icon: "wind",
                iconColor: AppTheme.Colors.skyAccent,
                title: "Respiration Rate",
                average: "14",
                unit: "brpm",
                trend: "0%",
                trendUp: true
            )

            HistoryMetricCard(
                icon: "bolt.fill",
                iconColor: AppTheme.Colors.primaryBlue,
                title: "Alertness",
                average: "85",
                unit: "%",
                trend: "-3%",
                trendUp: false
            )
        }
        .padding(.horizontal, AppTheme.Spacing.md)
    }
}

// MARK: - History Metric Card
struct HistoryMetricCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let average: String
    let unit: String
    let trend: String
    let trendUp: Bool

    var body: some View {
        Button(action: {
            // Navigate to detailed metric view
        }) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.2))
                        .frame(width: 50, height: 50)

                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundStyle(iconColor)
                }

                // Metric info
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppTheme.Typography.callout)
                        .fontWeight(.medium)
                        .foregroundStyle(AppTheme.Colors.textPrimary)

                    HStack(spacing: 4) {
                        Text("Avg: \(average) \(unit)")
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(AppTheme.Colors.textSecondary)

                        Text("•")
                            .foregroundStyle(AppTheme.Colors.textTertiary)

                        Text(trend)
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(trendUp ? AppTheme.Colors.successGreen : AppTheme.Colors.warningYellow)
                    }
                }

                Spacer()

                // Chevron
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
    }
}

// MARK: - Preview
#Preview {
    HistoryView()
        .environmentObject(WellnessDataService.preview)
}
