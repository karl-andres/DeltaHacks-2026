//
//  StatusOrbView.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-10.
//

import SwiftUI

struct StatusOrbView: View {
    let status: ReadinessStatus
    @State private var isAnimating = false

    var orbColor: Color {
        status == .fit ? AppTheme.Colors.successGreen : AppTheme.Colors.dangerRed
    }

    var iconName: String {
        status == .fit ? "checkmark.circle.fill" : "hand.raised.fill"
    }

    var statusText: String {
        status == .fit ? "GO" : "STOP"
    }

    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(orbColor.opacity(0.4))
                .frame(width: AppTheme.Sizes.orbSize, height: AppTheme.Sizes.orbSize)
                .blur(radius: 50)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .opacity(isAnimating ? 0.8 : 0.4)

            // Main orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.8),
                            orbColor.opacity(0.8),
                            orbColor.opacity(0.9),
                            orbColor.opacity(1.0)
                        ],
                        center: UnitPoint(x: 0.3, y: 0.3),
                        startRadius: 0,
                        endRadius: 150
                    )
                )
                .frame(width: AppTheme.Sizes.orbSize, height: AppTheme.Sizes.orbSize)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 4)
                )
                .shadow(color: orbColor.opacity(0.3), radius: 20, y: 10)

            // Inner reflection highlights
            Circle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 64, height: 32)
                .blur(radius: 8)
                .rotationEffect(.degrees(-45))
                .offset(x: -40, y: -40)

            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 32, height: 16)
                .blur(radius: 4)
                .rotationEffect(.degrees(-45))
                .offset(x: 40, y: 40)

            // Icon and text
            VStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.system(size: 84))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.3), radius: 5)

                Text(statusText)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.2), radius: 3)
            }
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: AppTheme.Animation.glowDuration)
                .repeatForever(autoreverses: true)
            ) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        AppTheme.Colors.backgroundDark
            .ignoresSafeArea()

        VStack(spacing: 60) {
            StatusOrbView(status: .fit)
            StatusOrbView(status: .restAdvised)
        }
    }
}
