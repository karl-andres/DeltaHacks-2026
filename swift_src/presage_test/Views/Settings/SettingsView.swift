//
//  SettingsView.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-10.
//

import SwiftUI

struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var alertnessAlertsEnabled = true
    @State private var biometricSyncEnabled = true
    @State private var darkModeEnabled = true

    var body: some View {
        ZStack {
            // Background
            AppTheme.Colors.backgroundDark
                .ignoresSafeArea()

            // Ambient glow effects
            ambientGlowEffects

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    headerView

                    // Notifications section
                    notificationsSection

                    // Monitoring section
                    monitoringSection

                    // Appearance section
                    appearanceSection

                    // Account section
                    accountSection

                    // About section
                    aboutSection

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
                .fill(AppTheme.Colors.primaryBlue.opacity(0.12))
                .blur(radius: 120)
                .frame(width: 300, height: 300)
                .offset(x: -100, y: -200)

            Circle()
                .fill(AppTheme.Colors.skyAccent.opacity(0.08))
                .blur(radius: 100)
                .frame(width: 300, height: 300)
                .offset(x: 150, y: 400)
        }
        .ignoresSafeArea()
    }

    // MARK: - Header
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Settings")
                .font(AppTheme.Typography.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            Text("Customize your experience")
                .font(AppTheme.Typography.callout)
                .foregroundStyle(AppTheme.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.top, 60)
        .padding(.bottom, AppTheme.Spacing.md)
    }

    // MARK: - Notifications Section
    private var notificationsSection: some View {
        VStack(spacing: 0) {
            SettingsSectionHeader(title: "Notifications", icon: "bell.fill")

            VStack(spacing: 0) {
                SettingsToggleRow(
                    icon: "bell.badge.fill",
                    title: "Push Notifications",
                    subtitle: "Receive alerts and updates",
                    isOn: $notificationsEnabled
                )

                Divider()
                    .background(AppTheme.Colors.glassBorder)
                    .padding(.leading, 52)

                SettingsToggleRow(
                    icon: "exclamationmark.triangle.fill",
                    title: "Alertness Warnings",
                    subtitle: "Get notified when alertness drops",
                    isOn: $alertnessAlertsEnabled
                )
            }
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

    // MARK: - Monitoring Section
    private var monitoringSection: some View {
        VStack(spacing: 0) {
            SettingsSectionHeader(title: "Monitoring", icon: "waveform.path.ecg")

            VStack(spacing: 0) {
                SettingsToggleRow(
                    icon: "applewatch.watchface",
                    title: "Auto-Sync Wearable",
                    subtitle: "Sync biometrics automatically",
                    isOn: $biometricSyncEnabled
                )

                Divider()
                    .background(AppTheme.Colors.glassBorder)
                    .padding(.leading, 52)

                SettingsNavigationRow(
                    icon: "heart.text.square.fill",
                    title: "Health Data",
                    subtitle: "Manage health data access"
                )

                Divider()
                    .background(AppTheme.Colors.glassBorder)
                    .padding(.leading, 52)

                SettingsNavigationRow(
                    icon: "clock.arrow.circlepath",
                    title: "Monitoring Frequency",
                    subtitle: "Every 5 minutes"
                )
            }
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

    // MARK: - Appearance Section
    private var appearanceSection: some View {
        VStack(spacing: 0) {
            SettingsSectionHeader(title: "Appearance", icon: "paintbrush.fill")

            VStack(spacing: 0) {
                SettingsToggleRow(
                    icon: "moon.fill",
                    title: "Dark Mode",
                    subtitle: "Use dark theme",
                    isOn: $darkModeEnabled
                )

                Divider()
                    .background(AppTheme.Colors.glassBorder)
                    .padding(.leading, 52)

                SettingsNavigationRow(
                    icon: "textformat.size",
                    title: "Text Size",
                    subtitle: "Medium"
                )
            }
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

    // MARK: - Account Section
    private var accountSection: some View {
        VStack(spacing: 0) {
            SettingsSectionHeader(title: "Account", icon: "person.circle.fill")

            VStack(spacing: 0) {
                SettingsNavigationRow(
                    icon: "lock.fill",
                    title: "Privacy & Security",
                    subtitle: "Manage your privacy settings"
                )

                Divider()
                    .background(AppTheme.Colors.glassBorder)
                    .padding(.leading, 52)

                SettingsNavigationRow(
                    icon: "shield.checkered",
                    title: "Data & Storage",
                    subtitle: "Manage stored data"
                )

                Divider()
                    .background(AppTheme.Colors.glassBorder)
                    .padding(.leading, 52)

                SettingsButton(
                    icon: "arrow.right.square.fill",
                    title: "Sign Out",
                    color: AppTheme.Colors.warningYellow
                )
            }
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

    // MARK: - About Section
    private var aboutSection: some View {
        VStack(spacing: 0) {
            SettingsSectionHeader(title: "About", icon: "info.circle.fill")

            VStack(spacing: 0) {
                SettingsNavigationRow(
                    icon: "doc.text.fill",
                    title: "Terms & Conditions",
                    subtitle: "Read our terms"
                )

                Divider()
                    .background(AppTheme.Colors.glassBorder)
                    .padding(.leading, 52)

                SettingsNavigationRow(
                    icon: "hand.raised.fill",
                    title: "Privacy Policy",
                    subtitle: "How we protect your data"
                )

                Divider()
                    .background(AppTheme.Colors.glassBorder)
                    .padding(.leading, 52)

                SettingsNavigationRow(
                    icon: "info.circle",
                    title: "App Version",
                    subtitle: "1.0.0 (Build 1)"
                )
            }
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

// MARK: - Settings Section Header
struct SettingsSectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(AppTheme.Colors.primaryBlue)

            Text(title)
                .font(AppTheme.Typography.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            Spacer()
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.bottom, AppTheme.Spacing.sm)
    }
}

// MARK: - Settings Toggle Row
struct SettingsToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(AppTheme.Colors.primaryBlue)
                .frame(width: 24)

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

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(AppTheme.Colors.primaryBlue)
        }
        .padding(AppTheme.Spacing.md)
    }
}

// MARK: - Settings Navigation Row
struct SettingsNavigationRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        Button(action: {
            // Handle navigation
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(AppTheme.Colors.primaryBlue)
                    .frame(width: 24)

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
            .padding(AppTheme.Spacing.md)
        }
    }
}

// MARK: - Settings Button
struct SettingsButton: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        Button(action: {
            // Handle action
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(color)
                    .frame(width: 24)

                Text(title)
                    .font(AppTheme.Typography.callout)
                    .fontWeight(.medium)
                    .foregroundStyle(color)

                Spacer()
            }
            .padding(AppTheme.Spacing.md)
        }
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
}
