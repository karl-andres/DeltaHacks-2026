//
//  ProfileView.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-10.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var biometricsVM: BiometricsViewModel
    @EnvironmentObject var authManager: AuthenticationManager

    @State private var showEditProfile = false
    @State private var showReports = false
    @State private var showNotifications = false
    @State private var showHelp = false

    var driver: Driver? {
        authManager.currentDriver
    }

    var body: some View {
        ZStack {
            // Background
            AppTheme.Colors.backgroundDark
                .ignoresSafeArea()

            // Ambient glow effects
            ambientGlowEffects

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Profile header
                    profileHeader

                    // Stats cards
                    statsSection

                    // Profile information
                    profileInfoSection

                    // Quick actions
                    quickActionsSection

                    // Bottom spacing for tab bar
                    Color.clear.frame(height: 100)
                }
            }
        }
    }

    // MARK: - Ambient Glow Effects
    private var ambientGlowEffects: some View {
        ZStack {
            Circle()
                .fill(AppTheme.Colors.primaryBlue.opacity(0.15))
                .blur(radius: 120)
                .frame(width: 300, height: 300)
                .offset(x: -100, y: -200)

            Circle()
                .fill(AppTheme.Colors.purpleAccent.opacity(0.08))
                .blur(radius: 100)
                .frame(width: 300, height: 300)
                .offset(x: 150, y: 400)
        }
        .ignoresSafeArea()
    }

    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Profile picture
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.primaryBlue.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Circle()
                            .stroke(AppTheme.Colors.primaryBlue, lineWidth: 3)
                    )

                Image(systemName: "person.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(AppTheme.Colors.primaryBlue)

                // Online indicator
                Circle()
                    .fill(AppTheme.Colors.successGreen)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .stroke(AppTheme.Colors.backgroundDark, lineWidth: 3)
                    )
                    .offset(x: 35, y: 35)
            }

            // Name and role
            VStack(spacing: 4) {
                Text(driver?.fullname ?? "Driver")
                    .font(AppTheme.Typography.title)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.Colors.textPrimary)

                Text("Professional Driver")
                    .font(AppTheme.Typography.callout)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
        .padding(.bottom, AppTheme.Spacing.lg)
    }

    // MARK: - Stats Section
    private var statsSection: some View {
        EmptyView()
    }

    // MARK: - Profile Info Section
    private var profileInfoSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Personal Information")

            VStack(spacing: 12) {
                ProfileInfoRow(icon: "number", label: "Driver ID", value: driver?.driverId ?? "N/A")
                ProfileInfoRow(icon: "person.text.rectangle", label: "Full Name", value: driver?.fullname ?? "N/A")
            }
            .padding(AppTheme.Spacing.md)
            .background(.ultraThinMaterial)
            .background(AppTheme.Colors.glassFill)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                    .stroke(AppTheme.Colors.glassBorder, lineWidth: 1)
            )
            .padding(.horizontal, AppTheme.Spacing.md)
        }
        .padding(.bottom, AppTheme.Spacing.lg)
    }

    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Quick Actions")

            VStack(spacing: 12) {
                QuickActionButton(
                    icon: "pencil",
                    title: "Edit Profile",
                    subtitle: "Update your information",
                    action: { showEditProfile = true }
                )
                QuickActionButton(
                    icon: "chart.bar.fill",
                    title: "View Reports",
                    subtitle: "See detailed analytics",
                    action: { showReports = true }
                )
                QuickActionButton(
                    icon: "bell.fill",
                    title: "Notifications",
                    subtitle: "Manage alerts and reminders",
                    action: { showNotifications = true }
                )
                QuickActionButton(
                    icon: "questionmark.circle.fill",
                    title: "Help & Support",
                    subtitle: "Get assistance",
                    action: { showHelp = true }
                )
            }
            .padding(AppTheme.Spacing.md)
            .background(.ultraThinMaterial)
            .background(AppTheme.Colors.glassFill)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                    .stroke(AppTheme.Colors.glassBorder, lineWidth: 1)
            )
            .padding(.horizontal, AppTheme.Spacing.md)
        }
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(AppTheme.Typography.headline)
            .fontWeight(.semibold)
            .foregroundStyle(AppTheme.Colors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.bottom, AppTheme.Spacing.sm)
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(AppTheme.Colors.primaryBlue)

            Text(value)
                .font(AppTheme.Typography.headline)
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            Text(title)
                .font(AppTheme.Typography.caption)
                .foregroundStyle(AppTheme.Colors.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.md)
        .background(.ultraThinMaterial)
        .background(AppTheme.Colors.glassFill)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                .stroke(AppTheme.Colors.glassBorder, lineWidth: 1)
        )
    }
}

// MARK: - Profile Info Row
struct ProfileInfoRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(AppTheme.Colors.primaryBlue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.textTertiary)

                Text(value)
                    .font(AppTheme.Typography.callout)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
            }

            Spacer()
        }
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppTheme.Colors.primaryBlue.opacity(0.2))
                        .frame(width: 40, height: 40)

                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundStyle(AppTheme.Colors.primaryBlue)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppTheme.Typography.callout)
                        .fontWeight(.medium)
                        .foregroundStyle(AppTheme.Colors.textPrimary)

                    Text(subtitle)
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.Colors.textTertiary)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ProfileView()
        .environmentObject(BiometricsViewModel.preview)
}
