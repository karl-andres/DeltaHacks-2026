//
//  SlideToStartButton.swift
//  presage_test
//
//  Created by Claude Code on 2026-01-10.
//

import SwiftUI

struct SlideToStartButton: View {
    @State private var sliderOffset: CGFloat = 0
    @State private var isCompleted = false
    let onComplete: () -> Void

    private let sliderHeight: CGFloat = 64
    private let knobSize: CGFloat = 56

    var body: some View {
        GeometryReader { geometry in
            let maxOffset = geometry.size.width - knobSize - 8

            ZStack(alignment: .leading) {
                // Background track
                Capsule()
                    .fill(.ultraThinMaterial)
                    .background(AppTheme.Colors.glassFill)
                    .overlay(
                        Capsule()
                            .stroke(AppTheme.Colors.glassBorder, lineWidth: 1)
                    )

                // Shimmer text
                if !isCompleted {
                    Text("Slide to Start Engine")
                        .font(AppTheme.Typography.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.4),
                                    Color.white.opacity(0.9),
                                    Color.white.opacity(0.4)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(maxWidth: .infinity)
                        .textCase(.uppercase)
                        .opacity(1 - Double(sliderOffset / maxOffset) * 0.5)
                }

                // Draggable knob
                HStack {
                    ZStack {
                        Capsule()
                            .fill(AppTheme.Colors.primaryBlue)
                            .shadow(color: AppTheme.Colors.primaryBlue.opacity(0.5), radius: 20)
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )

                        Image(systemName: isCompleted ? "key.fill" : "chevron.right")
                            .font(.system(size: isCompleted ? 28 : 24, weight: .bold))
                            .foregroundStyle(.white)
                            .opacity(isCompleted ? 1 : 1 - Double(sliderOffset / maxOffset) * 0.3)
                    }
                    .frame(width: knobSize + (sliderOffset / maxOffset * (geometry.size.width - knobSize - 8)), height: knobSize)
                }
                .padding(4)
                .offset(x: sliderOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            guard !isCompleted else { return }
                            let newOffset = max(0, min(value.translation.width, maxOffset))
                            sliderOffset = newOffset

                            // Completion threshold at 90%
                            if newOffset >= maxOffset * 0.9 {
                                completeSlide()
                            }
                        }
                        .onEnded { _ in
                            guard !isCompleted else { return }
                            // Snap back if not completed
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                                sliderOffset = 0
                            }
                        }
                )
            }
            .frame(height: sliderHeight)
        }
        .frame(height: sliderHeight)
    }

    private func completeSlide() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isCompleted = true
        }

        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()

        // Delay before calling completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onComplete()
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        AppTheme.Colors.backgroundDark
            .ignoresSafeArea()

        SlideToStartButton {
            print("Slide completed!")
        }
        .padding()
    }
}
