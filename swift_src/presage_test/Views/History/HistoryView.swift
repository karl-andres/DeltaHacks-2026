//
//  HistoryView.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-10.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var wellnessData: WellnessDataService
    @ObservedObject var vitalsManager = DriverVitalsManager.shared

    @State private var showMetricDetail = false
    @State private var selectedMetric: MetricType?

    enum MetricType {
        case heartRate
        case respiration
        case riskScore
        case pulseRespirationQuotient

        var title: String {
            switch self {
            case .heartRate: return "Heart Rate"
            case .respiration: return "Respiration Rate"
            case .riskScore: return "Risk Score"
            case .pulseRespirationQuotient: return "PRQ"
            }
        }

        var icon: String {
            switch self {
            case .heartRate: return "heart.fill"
            case .respiration: return "wind"
            case .riskScore: return "exclamationmark.triangle.fill"
            case .pulseRespirationQuotient: return "waveform.path.ecg"
            }
        }

        var color: Color {
            switch self {
            case .heartRate: return AppTheme.Colors.roseAccent
            case .respiration: return AppTheme.Colors.skyAccent
            case .riskScore: return AppTheme.Colors.warningYellow
            case .pulseRespirationQuotient: return AppTheme.Colors.purpleAccent
            }
        }
    }

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
        .sheet(isPresented: $showMetricDetail) {
            if let metric = selectedMetric {
                MetricDetailView(metric: metric)
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
            // Calculate averages based on selected time period
            let daysToConsider = selectedPeriod == .day ? 1 : selectedPeriod == .week ? 7 : selectedPeriod == .month ? 30 : 365
            let averages = vitalsManager.getAverageMetrics(for: daysToConsider)

            HistoryMetricCard(
                icon: "heart.fill",
                iconColor: AppTheme.Colors.roseAccent,
                title: "Heart Rate",
                average: vitalsManager.hasVitals ? String(format: "%.0f", averages.pulseRate) : "72",
                unit: "BPM",
                trend: "+2%",
                trendUp: true,
                action: {
                    selectedMetric = .heartRate
                    showMetricDetail = true
                }
            )

            HistoryMetricCard(
                icon: "wind",
                iconColor: AppTheme.Colors.skyAccent,
                title: "Respiration Rate",
                average: vitalsManager.hasVitals ? String(format: "%.1f", averages.breathingRate) : "14",
                unit: "brpm",
                trend: "0%",
                trendUp: true,
                action: {
                    selectedMetric = .respiration
                    showMetricDetail = true
                }
            )

            HistoryMetricCard(
                icon: "exclamationmark.triangle.fill",
                iconColor: AppTheme.Colors.warningYellow,
                title: "Risk Score",
                average: vitalsManager.hasVitals ? String(format: "%.2f", averages.riskScore) : "0.00",
                unit: "",
                trend: "-5%",
                trendUp: false,
                action: {
                    selectedMetric = .riskScore
                    showMetricDetail = true
                }
            )

            HistoryMetricCard(
                icon: "waveform.path.ecg",
                iconColor: AppTheme.Colors.purpleAccent,
                title: "PRQ",
                average: vitalsManager.hasVitals ? String(format: "%.1f", averages.pulseRespirationQuotient) : "0.0",
                unit: "ratio",
                trend: "+1%",
                trendUp: true,
                action: {
                    selectedMetric = .pulseRespirationQuotient
                    showMetricDetail = true
                }
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
    let action: () -> Void

    var body: some View {
        Button(action: action) {
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
