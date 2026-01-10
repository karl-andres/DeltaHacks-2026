//
//  MetricCardView.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-10.
//

import SwiftUI

struct MetricCardView: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let unit: String
    let status: String
    let statusColor: Color
    let graphData: [Double]
    let graphColor: Color
    let graphType: GraphType

    var body: some View {
        GlassMorphismCard(cornerRadius: 32, padding: 20) {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: icon)
                            .font(.system(size: 16))
                            .foregroundStyle(iconColor)

                        Text(title.uppercased())
                            .font(AppTheme.Typography.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(iconColor.opacity(0.8))
                    }

                    Spacer()

                    Text(status)
                        .font(AppTheme.Typography.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(statusColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(statusColor.opacity(0.1))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(statusColor.opacity(0.2), lineWidth: 1)
                        )
                }
                .padding(.bottom, 8)

                // Value
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.textPrimary)

                    Text(unit)
                        .font(AppTheme.Typography.headline.weight(.medium))
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                }
                .padding(.bottom, 12)

                // Graph
                MiniGraphView(data: graphData, color: graphColor, graphType: graphType)
                    .padding(.bottom, -8)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        AppTheme.Colors.backgroundDark
            .ignoresSafeArea()

        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            MetricCardView(
                icon: "heart.fill",
                iconColor: AppTheme.Colors.roseAccent,
                title: "Heart Rate",
                value: "72",
                unit: "BPM",
                status: "Resting",
                statusColor: AppTheme.Colors.successGreen,
                graphData: MockDataGenerator.shared.generateHeartRateHistory(points: 30),
                graphColor: AppTheme.Colors.roseAccent,
                graphType: .line
            )

            MetricCardView(
                icon: "waveform.path.ecg",
                iconColor: AppTheme.Colors.purpleAccent,
                title: "HRV",
                value: "45",
                unit: "ms",
                status: "Ready",
                statusColor: AppTheme.Colors.purpleAccent,
                graphData: MockDataGenerator.shared.generateHRVHistory(points: 30),
                graphColor: AppTheme.Colors.purpleAccent,
                graphType: .wave
            )

            MetricCardView(
                icon: "wind",
                iconColor: AppTheme.Colors.skyAccent,
                title: "Resp Rate",
                value: "14",
                unit: "brpm",
                status: "Normal",
                statusColor: AppTheme.Colors.skyAccent,
                graphData: MockDataGenerator.shared.generateRespirationHistory(points: 30),
                graphColor: AppTheme.Colors.skyAccent,
                graphType: .curve
            )

            MetricCardView(
                icon: "bolt.fill",
                iconColor: AppTheme.Colors.primaryBlue,
                title: "Alertness",
                value: "94",
                unit: "%",
                status: "Peak Focus",
                statusColor: AppTheme.Colors.primaryBlue,
                graphData: MockDataGenerator.shared.generateAlertnessHistory(points: 30),
                graphColor: AppTheme.Colors.primaryBlue,
                graphType: .line
            )
        }
        .padding()
    }
}
