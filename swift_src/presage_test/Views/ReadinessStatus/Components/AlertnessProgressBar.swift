//
//  AlertnessProgressBar.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-10.
//

import SwiftUI

struct AlertnessProgressBar: View {
    let score: Double
    let maxScore: Double = 100

    var alertnessLevel: AlertnessLevel {
        AlertnessLevel.from(score: score)
    }

    var progressColor: Color {
        switch score {
        case 0..<50:
            return AppTheme.Colors.dangerRed
        case 50..<75:
            return AppTheme.Colors.warningOrange
        default:
            return AppTheme.Colors.successGreen
        }
    }

    var body: some View {
        GlassMorphismCard(cornerRadius: 16, padding: 20) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Alertness Score")
                            .font(AppTheme.Typography.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppTheme.Colors.textTertiary)
                            .textCase(.uppercase)

                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(String(format: "%.0f", score))
                                .font(AppTheme.Typography.title)
                                .fontWeight(.bold)
                                .foregroundStyle(AppTheme.Colors.textPrimary)

                            Text("/\(Int(maxScore))")
                                .font(AppTheme.Typography.callout)
                                .foregroundStyle(AppTheme.Colors.textTertiary)
                        }
                    }

                    Spacer()

                    // Status badge
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 12))

                        Text(alertnessLevel.rawValue)
                            .font(AppTheme.Typography.caption2)
                            .fontWeight(.bold)
                    }
                    .foregroundStyle(progressColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(progressColor.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(progressColor.opacity(0.2), lineWidth: 1)
                    )
                }

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background track
                        Capsule()
                            .fill(Color.black.opacity(0.4))
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
                            )

                        // Tick marks
                        HStack(spacing: 0) {
                            ForEach(0..<4) { index in
                                Rectangle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: 1)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }

                        // Progress fill
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [AppTheme.Colors.warningOrange, progressColor],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * (score / maxScore))
                            .shadow(color: progressColor.opacity(0.5), radius: 5)
                            .overlay(
                                Rectangle()
                                    .fill(Color.white.opacity(0.5))
                                    .frame(width: 2)
                                    .blur(radius: 1)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            )
                    }
                }
                .frame(height: 12)

                // Timestamp
                Text("Calculated 2m ago")
                    .font(AppTheme.Typography.caption2)
                    .foregroundStyle(AppTheme.Colors.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        AppTheme.Colors.backgroundDark
            .ignoresSafeArea()

        VStack(spacing: 20) {
            AlertnessProgressBar(score: 42)
            AlertnessProgressBar(score: 65)
            AlertnessProgressBar(score: 85)
        }
        .padding()
    }
}
