//
//  PulsingButton.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-10.
//

import SwiftUI

struct PulsingButton: View {
    let title: String
    let icon: String?
    let color: Color
    let action: () -> Void

    init(
        title: String,
        icon: String? = nil,
        color: Color = AppTheme.Colors.primaryBlue,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.color = color
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                }

                Text(title)
                    .font(AppTheme.Typography.headline)
                    .fontWeight(.bold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: AppTheme.Sizes.buttonHeight)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
            .shadow(color: color.opacity(0.4), radius: 20, y: 4)
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        AppTheme.Colors.backgroundDark
            .ignoresSafeArea()

        VStack(spacing: 20) {
            PulsingButton(
                title: "Start Scan",
                icon: "play.fill",
                color: AppTheme.Colors.primaryBlue
            ) {
                print("Start scan tapped")
            }

            PulsingButton(
                title: "Log Rest Start",
                icon: "bed.double.fill",
                color: AppTheme.Colors.dangerRed
            ) {
                print("Log rest tapped")
            }

            PulsingButton(
                title: "Approve for Duty",
                color: AppTheme.Colors.successGreen
            ) {
                print("Approve tapped")
            }
        }
        .padding()
    }
}
