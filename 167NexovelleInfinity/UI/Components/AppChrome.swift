//
//  AppChrome.swift
//  167NexovelleInfinity
//

import Foundation
import SwiftUI

struct LayeredWeatherBackground: View {
    var body: some View {
        GeometryReader { geo in
            let safeW = sanitizedBackgroundLength(geo.size.width, fallback: 393)
            let safeH = sanitizedBackgroundLength(geo.size.height, fallback: 852)
            ZStack {
                Color.appBackground.opacity(0.95)

                LinearGradient(
                    stops: [
                        .init(color: Color.appPrimary.opacity(0.62), location: 0.0),
                        .init(color: Color.appSurface.opacity(0.96), location: 0.38),
                        .init(color: Color.appBackground.opacity(0.92), location: 0.72),
                        .init(color: Color.appAccent.opacity(0.52), location: 1.0),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                LinearGradient(
                    colors: [
                        Color.appAccent.opacity(0.22),
                        Color.clear,
                        Color.appPrimary.opacity(0.28),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .blendMode(.softLight)

                RadialGradient(
                    colors: [
                        Color.appAccent.opacity(0.45),
                        Color.appPrimary.opacity(0.12),
                        Color.clear,
                    ],
                    center: UnitPoint(x: 0.18, y: 0.12),
                    startRadius: 10,
                    endRadius: min(380, min(safeW * 0.55, safeH * 0.55))
                )
                .blendMode(.screen)

                RadialGradient(
                    colors: [
                        Color.appSurface.opacity(0.55),
                        Color.clear,
                    ],
                    center: UnitPoint(x: 0.92, y: 0.88),
                    startRadius: 20,
                    endRadius: min(420, min(safeW * 0.6, safeH * 0.6))
                )
                .blendMode(.plusLighter)
                .opacity(0.55)

                Canvas { context, size in
                    let spacing: CGFloat = 26
                    let dotRadius: CGFloat = 1.4
                    let boundW = max(0, size.width)
                    let boundH = max(0, size.height)
                    context.opacity = 0.11
                    var xPos: CGFloat = 0
                    while xPos < boundW {
                        var yPos: CGFloat = 0
                        while yPos < boundH {
                            let rect = CGRect(x: xPos, y: yPos, width: dotRadius * 2, height: dotRadius * 2)
                            context.fill(Path(ellipseIn: rect), with: .color(Color.appAccent))
                            yPos += spacing
                        }
                        xPos += spacing
                    }
                }
                .blendMode(.screen)

                LinearGradient(
                    colors: [
                        Color.black.opacity(0.12),
                        Color.clear,
                        Color.black.opacity(0.18),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .blendMode(.multiply)
                .allowsHitTesting(false)
            }
            .frame(width: safeW, height: safeH, alignment: .center)
            .clipped()
            .compositingGroup()
        }
        .ignoresSafeArea()
    }
}

private func sanitizedBackgroundLength(_ value: CGFloat, fallback: CGFloat) -> CGFloat {
    guard value.isFinite, value > 2 else { return fallback }
    return min(max(value, 2), 8192)
}

/// Full-screen weather backdrop behind feature content (e.g. sheets where the host view is otherwise white).
struct WeatherScreenRoot<Content: View>: View {
    @ViewBuilder var content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        ZStack {
            LayeredWeatherBackground()
            content()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground.ignoresSafeArea())
    }
}

struct AchievementBannerOverlay: View {
    @ObservedObject var queue: AchievementBannerQueue

    var body: some View {
        VStack {
            if let bannerText = queue.activeBannerText {
                Text(bannerText)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(Color.appSurface.opacity(0.92))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.appAccent.opacity(0.6), lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            Spacer()
        }
        .padding(.top, 12)
        .animation(.spring(response: 0.45, dampingFraction: 0.72), value: queue.activeBannerText)
    }
}

struct ShakeEffectModifier: GeometryEffect {
    var travelDistance: CGFloat = 10
    var shakesPerUnit: CGFloat = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = travelDistance * sin(animatableData * .pi * shakesPerUnit)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

extension View {
    func shake(trigger: CGFloat) -> some View {
        modifier(ShakeEffectModifier(animatableData: trigger))
    }
}

struct SuccessFeedbackBadge: View {
    let isVisible: Bool

    var body: some View {
        ZStack {
            if isVisible {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 52, weight: .bold))
                    .foregroundStyle(Color.appPrimary)
                    .transition(.scale.combined(with: .opacity))
                    .animation(.spring(response: 0.35, dampingFraction: 0.65), value: isVisible)
            }
        }
        .allowsHitTesting(false)
    }
}

struct MetricChip: View {
    let title: String
    let value: String
    var systemImage: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.appAccent)
                }
                Text(title.uppercased())
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
            }
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.appSurface.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.appAccent.opacity(0.35), lineWidth: 1)
        )
    }
}

struct PulseAccentOverlay: ViewModifier {
    let shouldPulse: Bool
    @State private var animate = false

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.appAccent.opacity(animate ? 0.85 : 0), lineWidth: 3)
                    .animation(.easeInOut(duration: 0.4), value: animate)
            )
            .onChange(of: shouldPulse) { pulse in
                guard pulse else {
                    animate = false
                    return
                }
                animate = true
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(0.45))
                    animate = false
                }
            }
    }
}

extension View {
    func pulseAccent(on trigger: Bool) -> some View {
        modifier(PulseAccentOverlay(shouldPulse: trigger))
    }
}

struct TapFeedbackButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.18), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { pressed in
                if pressed {
                    FeedbackCentral.tapLight()
                }
            }
    }
}

extension ButtonStyle where Self == TapFeedbackButtonStyle {
    static var tapFeedback: TapFeedbackButtonStyle { TapFeedbackButtonStyle() }
}
