//
//  GlassMorphismCard.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-10.
//

import SwiftUI

struct GlassMorphismCard<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat
    var padding: CGFloat

    init(
        cornerRadius: CGFloat = AppTheme.CornerRadius.large,
        padding: CGFloat = AppTheme.Spacing.md,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content()
    }

    var body: some View {
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

// MARK: - Preview
#Preview {
    ZStack {
        AppTheme.Colors.backgroundDark
            .ignoresSafeArea()

        VStack(spacing: 20) {
            GlassMorphismCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Glass Card")
                        .font(AppTheme.Typography.headline)
                        .foregroundStyle(AppTheme.Colors.textPrimary)

                    Text("This is a glass-morphism card with blur effect")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }

            GlassMorphismCard(cornerRadius: 32, padding: 24) {
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

                    Spacer()
                }
            }
        }
        .padding()
    }
}
