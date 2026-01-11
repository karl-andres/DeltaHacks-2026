//
//  MetricDetailView.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-10.
//

import SwiftUI
import Charts

struct MetricDetailView: View {
    let metric: HistoryView.MetricType
    @Environment(\.dismiss) var dismiss

    // Sample data for the chart
    private var chartData: [DataPoint] {
        (0..<30).map { day in
            DataPoint(
                day: day,
                value: Double.random(in: valueRange)
            )
        }
    }

    private var valueRange: ClosedRange<Double> {
        switch metric {
        case .heartRate: return 60...90
        case .hrv: return 80...110
        case .respiration: return 12...18
        case .alertness: return 70...95
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                AppTheme.Colors.backgroundDark
                    .ignoresSafeArea()

                // Ambient glow effects
                ambientGlowEffects

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppTheme.Spacing.lg) {
                        // Header card
                        headerCard

                        // Chart card
                        chartCard

                        // Statistics card
                        statisticsCard

                        // Insights card
                        insightsCard

                        // Bottom spacing
                        Color.clear.frame(height: 20)
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.top, AppTheme.Spacing.md)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(AppTheme.Colors.textTertiary)
                    }
                }
            }
        }
    }

    // MARK: - Ambient Glow Effects
    private var ambientGlowEffects: some View {
        ZStack {
            Circle()
                .fill(metric.color.opacity(0.15))
                .blur(radius: 120)
                .frame(width: 300, height: 300)
                .offset(x: -100, y: -200)

            Circle()
                .fill(metric.color.opacity(0.08))
                .blur(radius: 100)
                .frame(width: 300, height: 300)
                .offset(x: 150, y: 400)
        }
        .ignoresSafeArea()
    }

    // MARK: - Header Card
    private var headerCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(metric.color.opacity(0.2))
                    .frame(width: 80, height: 80)

                Image(systemName: metric.icon)
                    .font(.system(size: 36))
                    .foregroundStyle(metric.color)
            }

            Text(metric.title)
                .font(AppTheme.Typography.title)
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            Text("Last 30 days")
                .font(AppTheme.Typography.callout)
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.Spacing.lg)
        .background(.ultraThinMaterial)
        .background(AppTheme.Colors.glassFill)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                .stroke(AppTheme.Colors.glassBorder, lineWidth: 1)
        )
    }

    // MARK: - Chart Card
    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Trend")
                .font(AppTheme.Typography.headline)
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            Chart(chartData) { dataPoint in
                LineMark(
                    x: .value("Day", dataPoint.day),
                    y: .value("Value", dataPoint.value)
                )
                .foregroundStyle(metric.color)
                .lineStyle(StrokeStyle(lineWidth: 3))

                AreaMark(
                    x: .value("Day", dataPoint.day),
                    y: .value("Value", dataPoint.value)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [metric.color.opacity(0.3), metric.color.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                }
            }
            .chartYAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                }
            }
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

    // MARK: - Statistics Card
    private var statisticsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistics")
                .font(AppTheme.Typography.headline)
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            HStack(spacing: 12) {
                StatisticItem(
                    title: "Average",
                    value: statisticValues.average,
                    color: metric.color
                )

                StatisticItem(
                    title: "Highest",
                    value: statisticValues.highest,
                    color: AppTheme.Colors.successGreen
                )

                StatisticItem(
                    title: "Lowest",
                    value: statisticValues.lowest,
                    color: AppTheme.Colors.warningYellow
                )
            }
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

    // MARK: - Insights Card
    private var insightsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(AppTheme.Colors.primaryBlue)

                Text("Insights")
                    .font(AppTheme.Typography.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
            }

            Text(insightText)
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
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

    // MARK: - Helper Properties
    private var statisticValues: (average: String, highest: String, lowest: String) {
        switch metric {
        case .heartRate:
            return ("72 BPM", "88 BPM", "64 BPM")
        case .hrv:
            return ("98 ms", "108 ms", "82 ms")
        case .respiration:
            return ("14 brpm", "17 brpm", "12 brpm")
        case .alertness:
            return ("85%", "94%", "73%")
        }
    }

    private var insightText: String {
        switch metric {
        case .heartRate:
            return "Your heart rate has been consistently within a healthy range. The slight increase during afternoon shifts is normal and indicates good cardiovascular response to activity."
        case .hrv:
            return "Your HRV shows good variability, indicating strong recovery and stress management. The upward trend suggests improving cardiovascular fitness."
        case .respiration:
            return "Your breathing rate is stable and within the optimal range. This indicates good respiratory health and effective stress management during shifts."
        case .alertness:
            return "Your alertness levels remain high throughout most shifts. The slight dips in the evening are normal. Consider short breaks to maintain peak performance."
        }
    }
}

// MARK: - Data Point Model
struct DataPoint: Identifiable {
    let id = UUID()
    let day: Int
    let value: Double
}

// MARK: - Statistic Item
struct StatisticItem: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(AppTheme.Typography.caption)
                .foregroundStyle(AppTheme.Colors.textTertiary)

            Text(value)
                .font(AppTheme.Typography.headline)
                .fontWeight(.bold)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
    }
}

// MARK: - Preview
#Preview {
    MetricDetailView(metric: .heartRate)
}
