//
//  ScanningCircleView.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-10.
//

import SwiftUI

struct ScanningCircleView: View {
    let progress: Double
    let faceDetected: Bool

    var body: some View {
        ZStack {
            // Outer glow ring
            Circle()
                .stroke(Color.white.opacity(0.05), lineWidth: 6)
                .frame(width: AppTheme.Sizes.scanCircleSize, height: AppTheme.Sizes.scanCircleSize)
                .shadow(color: AppTheme.Colors.primaryBlue.opacity(0.3), radius: 50)

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [AppTheme.Colors.primaryBlue, AppTheme.Colors.successGreen],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .frame(width: AppTheme.Sizes.scanCircleSize - 6, height: AppTheme.Sizes.scanCircleSize - 6)
                .rotationEffect(.degrees(-90))
                .shadow(color: AppTheme.Colors.primaryBlue.opacity(0.6), radius: 15)
                .animation(.linear(duration: 0.3), value: progress)

            // Inner glass circle
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        AppTheme.Colors.primaryBlue.opacity(0.1),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        Circle()
                            .stroke(AppTheme.Colors.glassBorder, lineWidth: 1)
                    )

                // Face icon
                Image(systemName: "faceid")
                    .font(.system(size: 140))
                    .foregroundStyle(Color.white.opacity(0.3))

                // Scanning line animation
                if progress > 0 && progress < 1 {
                    Rectangle()
                        .fill(AppTheme.Colors.primaryBlue.opacity(0.5))
                        .frame(height: 2)
                        .shadow(color: AppTheme.Colors.primaryBlue, radius: 20)
                        .offset(y: sin(progress * .pi * 4) * 100)
                }
            }
            .frame(width: AppTheme.Sizes.scanCircleSize - 30, height: AppTheme.Sizes.scanCircleSize - 30)

            // Status indicator at bottom
            VStack {
                Spacer()

                Text("Keep head still")
                    .font(AppTheme.Typography.callout)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(.ultraThinMaterial)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(AppTheme.Colors.glassBorder, lineWidth: 1)
                    )
            }
            .frame(width: AppTheme.Sizes.scanCircleSize - 30, height: AppTheme.Sizes.scanCircleSize - 30)
            .padding(.bottom, -24)
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        AppTheme.Colors.backgroundDark
            .ignoresSafeArea()

        VStack(spacing: 40) {
            ScanningCircleView(progress: 0.0, faceDetected: false)
            ScanningCircleView(progress: 0.5, faceDetected: true)
            ScanningCircleView(progress: 1.0, faceDetected: true)
        }
        .padding()
    }
}
