//
//  LoginView.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-10.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager

    @State private var fullName = ""
    @State private var driverID = ""
    @FocusState private var focusedField: Field?

    enum Field {
        case fullName, driverID
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
                    Spacer()
                        .frame(height: 80)

                    // Logo and title
                    headerSection

                    // Login form
                    loginForm

                    // Login button
                    loginButton

                    // Error message
                    if let errorMessage = authManager.errorMessage {
                        errorView(message: errorMessage)
                    }

                    Spacer()
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
            }
        }
        .onAppear {
            focusedField = .fullName
        }
    }

    // MARK: - Ambient Glow Effects
    private var ambientGlowEffects: some View {
        ZStack {
            Circle()
                .fill(AppTheme.Colors.primaryBlue.opacity(0.2))
                .blur(radius: 150)
                .frame(width: 400, height: 400)
                .offset(x: -100, y: -300)

            Circle()
                .fill(AppTheme.Colors.skyAccent.opacity(0.15))
                .blur(radius: 120)
                .frame(width: 350, height: 350)
                .offset(x: 150, y: 200)
        }
        .ignoresSafeArea()
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // App icon
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.primaryBlue.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Circle()
                            .stroke(AppTheme.Colors.primaryBlue, lineWidth: 2)
                    )

                Image(systemName: "waveform.path.ecg.rectangle.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(AppTheme.Colors.primaryBlue)
            }
            .padding(.bottom, 8)

            // Title
            Text("Driver Wellness")
                .font(AppTheme.Typography.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            // Subtitle
            Text("Monitor your health and alertness")
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 48)
    }

    // MARK: - Login Form
    private var loginForm: some View {
        VStack(spacing: 16) {
            // Full Name field
            VStack(alignment: .leading, spacing: 8) {
                Text("Full Name")
                    .font(AppTheme.Typography.callout)
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.Colors.textSecondary)

                HStack(spacing: 12) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(AppTheme.Colors.primaryBlue)
                        .frame(width: 24)

                    TextField("John Doe", text: $fullName)
                        .font(AppTheme.Typography.body)
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                        .textContentType(.name)
                        .autocapitalization(.words)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .fullName)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .driverID
                        }
                }
                .padding(AppTheme.Spacing.md)
                .background(.ultraThinMaterial)
                .background(AppTheme.Colors.glassFill)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                        .stroke(
                            focusedField == .fullName ? AppTheme.Colors.primaryBlue : AppTheme.Colors.glassBorder,
                            lineWidth: focusedField == .fullName ? 2 : 1
                        )
                )
            }

            // Driver ID field
            VStack(alignment: .leading, spacing: 8) {
                Text("Driver ID")
                    .font(AppTheme.Typography.callout)
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.Colors.textSecondary)

                HStack(spacing: 12) {
                    Image(systemName: "number")
                        .font(.system(size: 18))
                        .foregroundStyle(AppTheme.Colors.primaryBlue)
                        .frame(width: 24)

                    TextField("100200", text: $driverID)
                        .font(AppTheme.Typography.body)
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                        .textContentType(.none)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .driverID)
                        .submitLabel(.go)
                        .onSubmit {
                            performLogin()
                        }
                }
                .padding(AppTheme.Spacing.md)
                .background(.ultraThinMaterial)
                .background(AppTheme.Colors.glassFill)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                        .stroke(
                            focusedField == .driverID ? AppTheme.Colors.primaryBlue : AppTheme.Colors.glassBorder,
                            lineWidth: focusedField == .driverID ? 2 : 1
                        )
                )
            }
        }
        .padding(.bottom, 24)
    }

    // MARK: - Login Button
    private var loginButton: some View {
        Button(action: performLogin) {
            HStack(spacing: 12) {
                if case .authenticating = authManager.authState {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Sign In")
                        .font(AppTheme.Typography.headline)
                        .fontWeight(.semibold)

                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: [AppTheme.Colors.primaryBlue, AppTheme.Colors.skyAccent],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
            .shadow(color: AppTheme.Colors.primaryBlue.opacity(0.5), radius: 20, y: 10)
        }
        .disabled(fullName.isEmpty || driverID.isEmpty || authManager.isLoading)
        .opacity((fullName.isEmpty || driverID.isEmpty || authManager.isLoading) ? 0.6 : 1.0)
        .padding(.bottom, 24)
    }

    // MARK: - Error View
    private func errorView(message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 16))
                .foregroundStyle(AppTheme.Colors.warningYellow)

            Text(message)
                .font(AppTheme.Typography.callout)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            Spacer()
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.warningYellow.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .stroke(AppTheme.Colors.warningYellow, lineWidth: 1)
        )
        .padding(.bottom, 24)
    }

    // MARK: - Actions
    private func performLogin() {
        focusedField = nil
        Task {
            await authManager.login(fullName: fullName, driverID: driverID)
        }
    }
}

// MARK: - Preview
#Preview {
    LoginView()
        .environmentObject(AuthenticationManager())
}
