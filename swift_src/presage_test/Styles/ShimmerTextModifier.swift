//
//  ShimmerTextModifier.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-10.
//

import SwiftUI

struct ShimmerTextModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.4),
                        Color.white.opacity(0.9),
                        Color.white.opacity(0.4)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .mask(
                content
                    .overlay(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white,
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .rotationEffect(.degrees(0))
                        .offset(x: phase)
                    )
            )
            .onAppear {
                withAnimation(
                    .linear(duration: AppTheme.Animation.shimmerDuration)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 400
                }
            }
    }
}

extension View {
    func shimmerText() -> some View {
        self.modifier(ShimmerTextModifier())
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        AppTheme.Colors.backgroundDark
            .ignoresSafeArea()

        Text("FIT TO DRIVE")
            .font(.system(size: 36, weight: .black, design: .rounded))
            .shimmerText()
    }
}
