//
//  PulseAnimationModifier.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-10.
//

import SwiftUI

struct PulseAnimationModifier: ViewModifier {
    @State private var isAnimating = false
    let duration: Double

    func body(content: Content) -> some View {
        content
            .scaleEffect(isAnimating ? 1.05 : 1.0)
            .opacity(isAnimating ? 0.8 : 1.0)
            .animation(
                .easeInOut(duration: duration)
                .repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

struct GlowEffectModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    @State private var isGlowing = false

    func body(content: Content) -> some View {
        content
            .shadow(
                color: color.opacity(isGlowing ? 0.8 : 0.4),
                radius: isGlowing ? radius * 1.5 : radius
            )
            .animation(
                .easeInOut(duration: AppTheme.Animation.glowDuration)
                .repeatForever(autoreverses: true),
                value: isGlowing
            )
            .onAppear {
                isGlowing = true
            }
    }
}

extension View {
    func pulseAnimation(duration: Double = AppTheme.Animation.pulseDuration) -> some View {
        self.modifier(PulseAnimationModifier(duration: duration))
    }

    func glowEffect(color: Color, radius: CGFloat = 20) -> some View {
        self.modifier(GlowEffectModifier(color: color, radius: radius))
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        AppTheme.Colors.backgroundDark
            .ignoresSafeArea()

        VStack(spacing: 40) {
            Circle()
                .fill(AppTheme.Colors.primaryBlue)
                .frame(width: 100, height: 100)
                .pulseAnimation()

            Circle()
                .fill(AppTheme.Colors.successGreen)
                .frame(width: 100, height: 100)
                .glowEffect(color: AppTheme.Colors.successGreen)

            Circle()
                .fill(AppTheme.Colors.dangerRed)
                .frame(width: 100, height: 100)
                .pulseAnimation()
                .glowEffect(color: AppTheme.Colors.dangerRed)
        }
    }
}
