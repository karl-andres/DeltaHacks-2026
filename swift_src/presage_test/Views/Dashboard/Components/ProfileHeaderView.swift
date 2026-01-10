//
//  ProfileHeaderView.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-10.
//

import SwiftUI

struct ProfileHeaderView: View {
    @EnvironmentObject var appState: AppStateManager

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return "Good Morning"
        case 12..<17:
            return "Good Afternoon"
        case 17..<22:
            return "Good Evening"
        default:
            return "Good Night"
        }
    }

    var shiftType: String {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 20 || hour < 6 ? "Night Shift" : "Day Shift"
    }

    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.Colors.primaryBlue, AppTheme.Colors.purpleAccent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.white)
                    )
                    .overlay(
                        Circle()
                            .stroke(AppTheme.Colors.glassBorder, lineWidth: 2)
                    )

                // Online status indicator
                Circle()
                    .fill(AppTheme.Colors.successGreen)
                    .frame(width: 14, height: 14)
                    .overlay(
                        Circle()
                            .stroke(AppTheme.Colors.backgroundDark, lineWidth: 2)
                    )
            }

            // Greeting text
            VStack(alignment: .leading, spacing: 4) {
                Text("\(greeting), Driver")
                    .font(AppTheme.Typography.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.Colors.textPrimary)

                HStack(spacing: 6) {
                    Image(systemName: shiftType.contains("Night") ? "moon.stars.fill" : "sun.max.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.Colors.indigoAccent)

                    Text(shiftType)
                        .font(AppTheme.Typography.callout)
                        .foregroundStyle(AppTheme.Colors.indigoAccent.opacity(0.7))
                }
            }

            Spacer()

            // Start Duty button
            Button(action: {
                appState.startDuty()
            }) {
                Text("Start Duty")
                    .font(AppTheme.Typography.callout)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [AppTheme.Colors.primaryBlue, Color(hex: "#1e5ed8")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: AppTheme.Colors.primaryBlue.opacity(0.4), radius: 10, y: 4)
            }
        }
        .padding(AppTheme.Spacing.md)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        AppTheme.Colors.backgroundDark
            .ignoresSafeArea()

        ProfileHeaderView()
            .environmentObject(AppStateManager.preview)
    }
}
