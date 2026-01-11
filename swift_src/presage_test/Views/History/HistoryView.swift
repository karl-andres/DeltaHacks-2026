//
//  HistoryView.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-10.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var wellnessData: WellnessDataService
    @ObservedObject var scanHistory = ScanHistoryService.shared

    @State private var showMetricDetail = false
    @State private var selectedMetric: MetricType?

    enum MetricType {
        case heartRate
        case hrv
        case respiration
        case alertness

        var title: String {
            switch self {
            case .heartRate: return "Heart Rate"
            case .hrv: return "HRV"
            case .respiration: return "Respiration Rate"
            case .alertness: return "Alertness"
            }
        }

        var icon: String {
            switch self {
            case .heartRate: return "heart.fill"
            case .hrv: return "waveform.path.ecg"
            case .respiration: return "wind"
            case .alertness: return "bolt.fill"
            }
        }

        var color: Color {
            switch self {
            case .heartRate: return AppTheme.Colors.roseAccent
            case .hrv: return AppTheme.Colors.purpleAccent
            case .respiration: return AppTheme.Colors.skyAccent
            case .alertness: return AppTheme.Colors.primaryBlue
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
            if scanHistory.scanHistory.isEmpty {
                // Empty state
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 50))
                        .foregroundStyle(AppTheme.Colors.textTertiary)

                    Text("No scan history yet")
                        .font(AppTheme.Typography.headline)
                        .foregroundStyle(AppTheme.Colors.textSecondary)

                    Text("Complete your first wellness scan to see your metrics here")
                        .font(AppTheme.Typography.callout)
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
            } else {
                HistoryMetricCard(
                    icon: "heart.fill",
                    iconColor: AppTheme.Colors.roseAccent,
                    title: "Pulse Rate",
                    average: "\(averagePulseRate)",
                    unit: "BPM",
                    trend: calculateTrend(for: \.pulse_rate),
                    trendUp: isTrendUp(calculateTrend(for: \.pulse_rate)),
                    action: {
                        selectedMetric = .heartRate
                        showMetricDetail = true
                    }
                )

                HistoryMetricCard(
                    icon: "waveform.path.ecg",
                    iconColor: AppTheme.Colors.purpleAccent,
                    title: "Integrated Vital Score",
                    average: String(format: "%.1f", averageIntegratedVitalScore),
                    unit: "",
                    trend: calculateTrend(for: \.integrated_vital_score),
                    trendUp: isTrendUp(calculateTrend(for: \.integrated_vital_score)),
                    action: {
                        selectedMetric = .hrv
                        showMetricDetail = true
                    }
                )

                HistoryMetricCard(
                    icon: "wind",
                    iconColor: AppTheme.Colors.skyAccent,
                    title: "Breathing Rate",
                    average: String(format: "%.1f", averageBreathingRate),
                    unit: "brpm",
                    trend: calculateTrend(for: \.breathing_rate),
                    trendUp: isTrendUp(calculateTrend(for: \.breathing_rate)),
                    action: {
                        selectedMetric = .respiration
                        showMetricDetail = true
                    }
                )

                HistoryMetricCard(
                    icon: "bolt.fill",
                    iconColor: AppTheme.Colors.primaryBlue,
                    title: "Alertness Index",
                    average: String(format: "%.1f", averageAlertnessIndex),
                    unit: "",
                    trend: calculateTrend(for: \.nonlinear_alertness_index),
                    trendUp: isTrendUp(calculateTrend(for: \.nonlinear_alertness_index)),
                    action: {
                        selectedMetric = .alertness
                        showMetricDetail = true
                    }
                )
            }
        }
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    // MARK: - Helper Methods for Metrics

    private var averagePulseRate: Int {
        guard !scanHistory.scanHistory.isEmpty else { return 0 }
        let sum = scanHistory.scanHistory.reduce(0.0) { $0 + $1.backendResult.pulse_rate }
        return Int(sum / Float(scanHistory.scanHistory.count))
    }

    private var averageBreathingRate: Float {
        guard !scanHistory.scanHistory.isEmpty else { return 0 }
        let sum = scanHistory.scanHistory.reduce(0.0) { $0 + $1.backendResult.breathing_rate }
        return sum / Float(scanHistory.scanHistory.count)
    }

    private var averageIntegratedVitalScore: Float {
        guard !scanHistory.scanHistory.isEmpty else { return 0 }
        let sum = scanHistory.scanHistory.reduce(0.0) { $0 + $1.backendResult.integrated_vital_score }
        return sum / Float(scanHistory.scanHistory.count)
    }

    private var averageAlertnessIndex: Float {
        guard !scanHistory.scanHistory.isEmpty else { return 0 }
        let sum = scanHistory.scanHistory.reduce(0.0) { $0 + $1.backendResult.nonlinear_alertness_index }
        return sum / Float(scanHistory.scanHistory.count)
    }

    private func calculateTrend(for keyPath: KeyPath<BackendScanResult, Float>) -> String {
        guard scanHistory.scanHistory.count >= 2 else { return "0%" }

        let latest = scanHistory.scanHistory.first!.backendResult[keyPath: keyPath]
        let previous = scanHistory.scanHistory[1].backendResult[keyPath: keyPath]

        guard previous > 0 else { return "0%" }

        let percentChange = ((latest - previous) / previous) * 100
        return String(format: "%+.0f%%", percentChange)
    }

    private func isTrendUp(_ trend: String) -> Bool {
        return trend.hasPrefix("+")
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
