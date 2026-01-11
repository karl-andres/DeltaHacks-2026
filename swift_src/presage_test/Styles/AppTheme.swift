//
//  AppTheme.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-10.
//

import SwiftUI

struct AppTheme {
    // MARK: - Colors
    struct Colors {
        // Background Colors
        static let backgroundDark = Color(hex: "#050505")
        static let cardBackground = Color(hex: "#101622")

        // Brand Colors
        static let primaryBlue = Color(hex: "#2b6cee")
        static let successGreen = Color(hex: "#10b981")
        static let dangerRed = Color(hex: "#f20d0d")
        static let warningYellow = Color(hex: "#fbbf24")
        static let warningOrange = Color(hex: "#f97316")

        // Status Colors
        static let infoBlue = Color(hex: "#3b82f6")
        static let purpleAccent = Color(hex: "#a855f7")
        static let roseAccent = Color(hex: "#f43f5e")
        static let skyAccent = Color(hex: "#0ea5e9")
        static let indigoAccent = Color(hex: "#6366f1")

        // Glass-morphism Colors
        static let glassFill = Color.white.opacity(0.1)
        static let glassBorder = Color.white.opacity(0.08)
        static let glassSurface = Color.white.opacity(0.05)

        // Text Colors
        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.7)
        static let textTertiary = Color.white.opacity(0.5)
        static let textDisabled = Color.white.opacity(0.3)
    }

    // MARK: - Typography
    struct Typography {
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let title = Font.system(size: 24, weight: .semibold, design: .rounded)
        static let title2 = Font.system(size: 20, weight: .semibold, design: .rounded)
        static let headline = Font.system(size: 18, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 16, weight: .regular, design: .rounded)
        static let callout = Font.system(size: 14, weight: .medium, design: .rounded)
        static let caption = Font.system(size: 12, weight: .medium, design: .rounded)
        static let caption2 = Font.system(size: 10, weight: .medium, design: .rounded)
        static let subheadline: Font = .subheadline

        // Metric Display
        static let metricValue = Font.system(size: 40, weight: .bold, design: .rounded)
        static let metricUnit = Font.system(size: 14, weight: .medium, design: .rounded)
    }

    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 20
        static let extraLarge: CGFloat = 32
        static let full: CGFloat = 9999
    }

    // MARK: - Animation
    struct Animation {
        static let breathingDuration: Double = 2.0
        static let pulseDuration: Double = 1.5
        static let scanDuration: Double = 45.0
        static let shimmerDuration: Double = 3.0
        static let glowDuration: Double = 4.0

        // Spring Animation
        static let springResponse: Double = 0.5
        static let springDamping: Double = 0.7
    }

    // MARK: - Shadow
    struct Shadow {
        static let glassEffect = Color.black.opacity(0.1)
        static let glow = Color.black.opacity(0.3)
    }

    // MARK: - Sizes
    struct Sizes {
        static let buttonHeight: CGFloat = 56
        static let iconSize: CGFloat = 24
        static let avatarSize: CGFloat = 56
        static let orbSize: CGFloat = 256
        static let scanCircleSize: CGFloat = 288
    }
}
