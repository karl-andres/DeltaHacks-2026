//
//  BiometricScanView.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-10.
//

import SwiftUI

struct BiometricScanView: View {
    @EnvironmentObject var biometricsVM: BiometricsViewModel
    @EnvironmentObject var appState: AppStateManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            // Background
            AppTheme.Colors.backgroundDark
                .ignoresSafeArea()

            // Gradient overlay for depth
            LinearGradient(
                colors: [
                    Color.black.opacity(0.6),
                    Color.clear,
                    Color.black.opacity(0.8)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                topBar

                Spacer()

                // Main scanning area
                scanningArea

                Spacer()

                // Live metrics
                metricsGrid

                // Bottom controls
                bottomControls
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.top, AppTheme.Spacing.xl)
            .padding(.bottom, AppTheme.Spacing.lg)
        }
        .onAppear {
            if !biometricsVM.isScanning {
                biometricsVM.startScan()
            }
        }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Button(action: {
                biometricsVM.cancelScan()
                appState.cancelScan()
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .frame(width: 48, height: 48)
                    .background(.ultraThinMaterial)
                    .background(AppTheme.Colors.glassFill)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(AppTheme.Colors.glassBorder, lineWidth: 1)
                    )
            }

            Spacer()

            VStack(spacing: 4) {
                Text("Readiness Scan")
                    .font(AppTheme.Typography.headline)
                    .foregroundStyle(AppTheme.Colors.textPrimary)

                HStack(spacing: 6) {
                    Circle()
                        .fill(AppTheme.Colors.primaryBlue)
                        .frame(width: 8, height: 8)
                        .overlay(
                            Circle()
                                .fill(AppTheme.Colors.primaryBlue)
                                .frame(width: 8, height: 8)
                                .scaleEffect(biometricsVM.isScanning ? 1.5 : 1.0)
                                .opacity(biometricsVM.isScanning ? 0 : 1)
                                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: false), value: biometricsVM.isScanning)
                        )

                    Text("Scanning Face ID")
                        .font(AppTheme.Typography.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(AppTheme.Colors.primaryBlue)
                        .textCase(.uppercase)
                }
            }

            Spacer()

            Button(action: {}) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .frame(width: 48, height: 48)
                    .background(.ultraThinMaterial)
                    .background(AppTheme.Colors.glassFill)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(AppTheme.Colors.glassBorder, lineWidth: 1)
                    )
            }
        }
        .padding(.bottom, AppTheme.Spacing.lg)
    }

    // MARK: - Scanning Area
    private var scanningArea: some View {
        ZStack {
            // Camera feed
            if let image = biometricsVM.vitalsProcessor.imageOutput {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 300, height: 300)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(AppTheme.Colors.glassBorder, lineWidth: 1)
                    )
            } else {
                // Placeholder when camera is not ready
                Circle()
                    .fill(.black)
                    .frame(width: 300, height: 300)
            }
            
            // Scanning overlay
            ScanningCircleView(
                progress: biometricsVM.scanProgress,
                faceDetected: biometricsVM.faceDetected
            )
        }
    }

    // MARK: - Metrics Grid
    private var metricsGrid: some View {
        HStack(spacing: 16) {
            LiveMetricsCard(
                icon: "heart.fill",
                iconColor: AppTheme.Colors.dangerRed,
                title: "Heart Rate",
                value: biometricsVM.currentHeartRate,
                unit: "BPM",
                status: "Good",
                showPulse: true
            )

            LiveMetricsCard(
                icon: "wind",
                iconColor: AppTheme.Colors.primaryBlue,
                title: "Respiration",
                value: biometricsVM.currentRespirationRate,
                unit: "RR",
                status: "Good",
                showPulse: false
            )
        }
        .padding(.vertical, AppTheme.Spacing.lg)
    }

    // MARK: - Bottom Controls
    private var bottomControls: some View {
        HStack(spacing: 16) {
            // Flashlight button
            Button(action: {}) {
                Image(systemName: "flashlight.on.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .frame(width: 56, height: 56)
                    .background(.ultraThinMaterial)
                    .background(AppTheme.Colors.glassFill)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(AppTheme.Colors.glassBorder, lineWidth: 1)
                    )
            }

            // Cancel scan button
            Button(action: {
                biometricsVM.cancelScan()
                appState.cancelScan()
                dismiss()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))

                    Text("Cancel Scan")
                        .font(AppTheme.Typography.callout)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(.ultraThinMaterial)
                .background(AppTheme.Colors.glassFill)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            }

            // Help button
            Button(action: {}) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .frame(width: 56, height: 56)
                    .background(.ultraThinMaterial)
                    .background(AppTheme.Colors.glassFill)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(AppTheme.Colors.glassBorder, lineWidth: 1)
                    )
            }
        }
    }
}

// MARK: - Preview
#Preview {
    BiometricScanView()
        .environmentObject(BiometricsViewModel.preview)
        .environmentObject(AppStateManager.preview)
}
