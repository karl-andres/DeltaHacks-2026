//
//  ScanningCircleView.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-10.
//

import SwiftUI

import SwiftUI

struct ScanningCircleView: View {
    let progress: Double
    let faceDetected: Bool
    @StateObject var manager = VitalsManager.shared
    
    // 1. Initialize the camera handler
    @StateObject private var cameraModel = FrameHandler()

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

            // Inner circle area
            ZStack {
                // 1. Background layer (the "glass" effect should be BEHIND the camera)
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Circle()
                            .stroke(AppTheme.Colors.glassBorder, lineWidth: 1)
                    )

                // 2. Display the live camera feed ON TOP of the glass
                // This prevents the "gray" blur from covering the video
                if manager.isRecording {
                    FrameView(image: cameraModel.frame)
                        .clipShape(Circle())
                } else {
                    // Optional: Show a placeholder or icon when not recording
                    Image(systemName: "faceid")
                        .font(.system(size: 80))
                        .foregroundStyle(AppTheme.Colors.primaryBlue.opacity(0.3))
                }

                // 3. Scanning line animation (should be on the very top)
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
