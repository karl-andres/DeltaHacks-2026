//
//  GlassMorphismModifier.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-10.
//

import SwiftUI

struct GlassMorphismModifier: ViewModifier {
    var cornerRadius: CGFloat = AppTheme.CornerRadius.large
    var padding: CGFloat = AppTheme.Spacing.md

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(.ultraThinMaterial)
            .background(AppTheme.Colors.glassFill)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(AppTheme.Colors.glassBorder, lineWidth: 1)
            )
            .shadow(color: AppTheme.Shadow.glassEffect, radius: 10, x: 0, y: 4)
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = AppTheme.CornerRadius.large, padding: CGFloat = AppTheme.Spacing.md) -> some View {
        self.modifier(GlassMorphismModifier(cornerRadius: cornerRadius, padding: padding))
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        AppTheme.Colors.backgroundDark
            .ignoresSafeArea()

        VStack(spacing: 20) {
            Text("Glass Card Example")
                .font(AppTheme.Typography.headline)
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .glassCard()

            HStack {
                Image(systemName: "heart.fill")
                    .foregroundStyle(AppTheme.Colors.dangerRed)

                VStack(alignment: .leading) {
                    Text("Heart Rate")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.textSecondary)

                    Text("72 BPM")
                        .font(AppTheme.Typography.title)
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                }
            }
            .glassCard(cornerRadius: 16)
        }
        .padding()
    }
}
