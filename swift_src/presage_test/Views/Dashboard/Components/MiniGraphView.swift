//
//  MiniGraphView.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-10.
//

import SwiftUI

enum GraphType {
    case line
    case wave
    case curve
}

struct MiniGraphView: View {
    let data: [Double]
    let color: Color
    let graphType: GraphType

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                // Gradient fill
                graphPath(in: CGSize(width: width, height: height))
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.3), color.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                // Line stroke
                graphPath(in: CGSize(width: width, height: height))
                    .stroke(color, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
            }
        }
        .frame(height: 80)
    }

    private func graphPath(in size: CGSize) -> Path {
        guard !data.isEmpty else { return Path() }

        let maxY = data.max() ?? 1
        let minY = data.min() ?? 0
        let range = maxY - minY

        var path = Path()

        let stepX = size.width / CGFloat(data.count - 1)

        for (index, value) in data.enumerated() {
            let x = CGFloat(index) * stepX
            let normalizedY = range > 0 ? (value - minY) / range : 0.5
            let y = size.height * (1 - normalizedY)

            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                switch graphType {
                case .line:
                    path.addLine(to: CGPoint(x: x, y: y))
                case .wave, .curve:
                    // Smooth curve using quadratic bezier
                    let previousX = CGFloat(index - 1) * stepX
                    let previousValue = data[index - 1]
                    let previousNormalizedY = range > 0 ? (previousValue - minY) / range : 0.5
                    let previousY = size.height * (1 - previousNormalizedY)

                    let midX = (previousX + x) / 2
                    let controlPoint = CGPoint(x: midX, y: previousY)

                    path.addQuadCurve(to: CGPoint(x: x, y: y), control: controlPoint)
                }
            }
        }

        // Close path for fill
        path.addLine(to: CGPoint(x: size.width, y: size.height))
        path.addLine(to: CGPoint(x: 0, y: size.height))
        path.closeSubpath()

        return path
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        AppTheme.Colors.backgroundDark
            .ignoresSafeArea()

        VStack(spacing: 20) {
            MiniGraphView(
                data: MockDataGenerator.shared.generateHeartRateHistory(points: 30),
                color: AppTheme.Colors.dangerRed,
                graphType: .line
            )

            MiniGraphView(
                data: MockDataGenerator.shared.generateHRVHistory(points: 30),
                color: AppTheme.Colors.purpleAccent,
                graphType: .wave
            )

            MiniGraphView(
                data: MockDataGenerator.shared.generateAlertnessHistory(points: 30),
                color: AppTheme.Colors.primaryBlue,
                graphType: .curve
            )
        }
        .padding()
    }
}
