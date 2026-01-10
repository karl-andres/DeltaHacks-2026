//
//  LiveMetricsCard.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-10.
//

import SwiftUI

struct LiveMetricsCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: Int
    let unit: String
    let status: String
    let showPulse: Bool

    var body: some View {
        GlassMorphismCard(cornerRadius: 16, padding: 16) {
            VStack(alignment: .leading, spacing: 12) {
                // Header with icon and status
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: icon)
                            .font(.system(size: 16))
                            .foregroundStyle(iconColor)
                            .symbolEffect(.pulse, isActive: showPulse)

                        Text(title.uppercased())
                            .font(AppTheme.Typography.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }

                    Spacer()

                    Text(status)
                        .font(AppTheme.Typography.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.Colors.successGreen)
                }

                // Value display
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(value)")
                        .font(AppTheme.Typography.metricValue.weight(.bold))
                        .foregroundStyle(AppTheme.Colors.textPrimary)

                    Text(unit)
                        .font(AppTheme.Typography.callout)
                        .fontWeight(.medium)
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        AppTheme.Colors.backgroundDark
            .ignoresSafeArea()

        VStack(spacing: 16) {
            HStack(spacing: 16) {
                LiveMetricsCard(
                    icon: "heart.fill",
                    iconColor: AppTheme.Colors.dangerRed,
                    title: "Heart Rate",
                    value: 72,
                    unit: "BPM",
                    status: "Good",
                    showPulse: true
                )

                LiveMetricsCard(
                    icon: "wind",
                    iconColor: AppTheme.Colors.primaryBlue,
                    title: "Respiration",
                    value: 14,
                    unit: "RR",
                    status: "Good",
                    showPulse: false
                )
            }
        }
        .padding()
    }
}
