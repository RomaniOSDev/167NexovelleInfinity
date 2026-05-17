//
//  OnboardingView.swift
//  167NexovelleInfinity
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: AppStorageStore

    @State private var selection = 0

    private let headlines = [
        "Manage Alerts",
        "Track Weather",
        "Start Tracking"
    ]

    private let descriptions = [
        "The app helps you set up and manage alerts for specific weather conditions.",
        "Easily configure your location to track daily and weekly forecasts in detail.",
        "Begin by setting your location preferences to receive accurate local forecasts."
    ]

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                TabView(selection: $selection) {
                    OnboardingIllustrationPage(kind: .alerts)
                        .tag(0)
                    OnboardingIllustrationPage(kind: .forecast)
                        .tag(1)
                    OnboardingIllustrationPage(kind: .tracking)
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .scrollContentBackground(.hidden)
                .frame(maxHeight: 320)

                VStack(spacing: 18) {
                    Text(headlines[selection])
                        .font(.largeTitle.bold())
                        .foregroundStyle(Color.appTextPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))

                    Text(descriptions[selection])
                        .font(.body)
                        .foregroundStyle(Color.appTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)

                    HStack(spacing: 8) {
                        ForEach(0 ..< headlines.count, id: \.self) { idx in
                            Circle()
                                .fill(idx == selection ? Color.appPrimary : Color.appSurface.opacity(0.55))
                                .frame(width: idx == selection ? 12 : 8, height: idx == selection ? 12 : 8)
                                .animation(.easeInOut(duration: 0.25), value: selection)
                        }
                    }
                    .padding(.vertical, 8)

                    Button(action: advance) {
                        Text(selection == headlines.count - 1 ? "Get Started" : "Next")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color.appBackground)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(Color.appPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.tapFeedback)
                    .padding(.horizontal, 28)
                    .padding(.bottom, 28)
                }
                .animation(.easeInOut(duration: 0.3), value: selection)
            }
        }
    }

    private func advance() {
        FeedbackCentral.tapMedium()
        FeedbackCentral.playSavedPing()

        if selection < headlines.count - 1 {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                selection += 1
            }
        } else {
            FeedbackCentral.celebrateWorkflowCompletion()
            store.completeOnboarding()
        }
    }
}

private enum OnboardingIllustrationKind {
    case alerts
    case forecast
    case tracking
}

private struct OnboardingIllustrationPage: View {
    let kind: OnboardingIllustrationKind

    @State private var appeared = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.appSurface.opacity(0.78))
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(Color.appAccent.opacity(0.35), lineWidth: 1)
                )
                .padding(.horizontal, 28)

            illustration
                .padding(42)
                .scaleEffect(appeared ? 1 : 0.82)
                .opacity(appeared ? 1 : 0)
                .animation(.spring(response: 0.55, dampingFraction: 0.68).delay(0.05), value: appeared)
        }
        .onAppear {
            appeared = true
        }
        .onDisappear {
            appeared = false
        }
    }

    @ViewBuilder
    private var illustration: some View {
        switch kind {
        case .alerts:
            AlertsGlyphCanvas()
        case .forecast:
            ForecastGlyphCanvas()
        case .tracking:
            TrackingGlyphCanvas()
        }
    }
}

private struct AlertsGlyphCanvas: View {
    var body: some View {
        Canvas { context, size in
            let sunCenter = CGPoint(x: size.width * 0.72, y: size.height * 0.28)
            let sunRadius = size.width * 0.13
            context.fill(Path(ellipseIn: CGRect(x: sunCenter.x - sunRadius, y: sunCenter.y - sunRadius, width: sunRadius * 2, height: sunRadius * 2)), with: .color(Color.appAccent.opacity(0.95)))

            let cloudRect = CGRect(x: size.width * 0.18, y: size.height * 0.42, width: size.width * 0.62, height: size.height * 0.34)
            let cloudPath = cloudShape(in: cloudRect)
            context.fill(cloudPath, with: .color(Color.appTextPrimary.opacity(0.92)))

            let bellCenter = CGPoint(x: size.width * 0.48, y: size.height * 0.74)
            let bellPath = bellShape(center: bellCenter, radius: size.width * 0.09)
            context.fill(bellPath, with: .color(Color.appPrimary.opacity(0.95)))
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func cloudShape(in rect: CGRect) -> Path {
        var path = Path()
        let bump = rect.height * 0.35
        path.addEllipse(in: CGRect(x: rect.minX + rect.width * 0.08, y: rect.midY - bump / 2, width: bump * 1.6, height: bump))
        path.addEllipse(in: CGRect(x: rect.midX - bump, y: rect.midY - bump * 1.05, width: bump * 2.2, height: bump * 1.35))
        path.addEllipse(in: CGRect(x: rect.maxX - bump * 2.3, y: rect.midY - bump / 2, width: bump * 1.8, height: bump * 1.05))
        path.addRoundedRect(in: CGRect(x: rect.minX + rect.width * 0.08, y: rect.midY - bump * 0.25, width: rect.width * 0.84, height: bump * 1.05), cornerSize: CGSize(width: bump / 3, height: bump / 3))
        return path
    }

    private func bellShape(center: CGPoint, radius: CGFloat) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: center.x - radius * 0.9, y: center.y + radius * 0.55))
        path.addQuadCurve(to: CGPoint(x: center.x + radius * 0.9, y: center.y + radius * 0.55), control: CGPoint(x: center.x, y: center.y - radius * 1.05))
        path.addQuadCurve(to: CGPoint(x: center.x - radius * 0.9, y: center.y + radius * 0.55), control: CGPoint(x: center.x, y: center.y + radius * 1.05))
        path.closeSubpath()

        let clapper = CGRect(x: center.x - radius * 0.14, y: center.y + radius * 0.55, width: radius * 0.28, height: radius * 0.42)
        path.addEllipse(in: clapper)
        return path
    }
}

private struct ForecastGlyphCanvas: View {
    var body: some View {
        Canvas { context, size in
            let baseline = size.height * 0.72
            let chartRect = CGRect(x: size.width * 0.12, y: size.height * 0.28, width: size.width * 0.76, height: size.height * 0.42)

            var trend = Path()
            trend.move(to: CGPoint(x: chartRect.minX, y: chartRect.maxY))
            trend.addQuadCurve(to: CGPoint(x: chartRect.midX, y: chartRect.minY + chartRect.height * 0.25), control: CGPoint(x: chartRect.minX + chartRect.width * 0.35, y: chartRect.minY))
            trend.addQuadCurve(to: CGPoint(x: chartRect.maxX, y: chartRect.midY), control: CGPoint(x: chartRect.midX + chartRect.width * 0.25, y: chartRect.maxY))

            context.stroke(trend, with: .color(Color.appAccent.opacity(0.95)), style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))

            let ground = CGRect(x: size.width * 0.08, y: baseline, width: size.width * 0.84, height: size.height * 0.06)
            context.fill(Path(roundedRect: ground, cornerRadius: 6), with: .color(Color.appSurface.opacity(0.95)))

            let pinCenter = CGPoint(x: size.width * 0.52, y: size.height * 0.34)
            let pinPath = locationPin(center: pinCenter, height: size.height * 0.28)
            context.fill(pinPath, with: .color(Color.appPrimary.opacity(0.95)))
            context.stroke(pinPath, with: .color(Color.appAccent.opacity(0.85)), lineWidth: 2)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func locationPin(center: CGPoint, height: CGFloat) -> Path {
        var path = Path()
        let width = height * 0.62
        path.move(to: CGPoint(x: center.x, y: center.y - height / 2))
        path.addCurve(to: CGPoint(x: center.x, y: center.y + height / 2),
                      control1: CGPoint(x: center.x + width / 2, y: center.y - height * 0.12),
                      control2: CGPoint(x: center.x + width / 2.6, y: center.y + height * 0.25))
        path.addCurve(to: CGPoint(x: center.x, y: center.y - height / 2),
                      control1: CGPoint(x: center.x - width / 2.6, y: center.y + height * 0.25),
                      control2: CGPoint(x: center.x - width / 2, y: center.y - height * 0.12))
        path.closeSubpath()
        let inner = CGRect(x: center.x - width / 7, y: center.y - height / 8, width: width / 3.5, height: width / 3.5)
        path.addEllipse(in: inner)
        return path
    }
}

private struct TrackingGlyphCanvas: View {
    var body: some View {
        Canvas { context, size in
            let thermometerRect = CGRect(x: size.width * 0.52, y: size.height * 0.22, width: size.width * 0.14, height: size.height * 0.52)
            context.fill(Path(roundedRect: thermometerRect, cornerRadius: thermometerRect.width / 3), with: .color(Color.appSurface.opacity(0.95)))
            context.stroke(Path(roundedRect: thermometerRect, cornerRadius: thermometerRect.width / 3), with: .color(Color.appAccent.opacity(0.85)), lineWidth: 2)

            let mercuryHeight = thermometerRect.height * 0.62
            let mercuryRect = CGRect(x: thermometerRect.midX - thermometerRect.width * 0.25,
                                     y: thermometerRect.maxY - mercuryHeight - thermometerRect.height * 0.08,
                                     width: thermometerRect.width * 0.5,
                                     height: mercuryHeight)
            context.fill(Path(roundedRect: mercuryRect, cornerRadius: mercuryRect.width / 3), with: .color(Color.appPrimary.opacity(0.96)))

            let bulbRect = CGRect(x: thermometerRect.midX - thermometerRect.width * 0.68,
                                  y: thermometerRect.maxY - thermometerRect.width * 0.55,
                                  width: thermometerRect.width * 1.36,
                                  height: thermometerRect.width * 1.36)
            context.fill(Path(ellipseIn: bulbRect), with: .color(Color.appAccent.opacity(0.92)))

            let cloudRect = CGRect(x: size.width * 0.08, y: size.height * 0.42, width: size.width * 0.58, height: size.height * 0.34)
            context.fill(cloudBlob(in: cloudRect), with: .color(Color.appTextPrimary.opacity(0.92)))
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func cloudBlob(in rect: CGRect) -> Path {
        var path = Path()
        let bump = rect.height * 0.38
        path.addEllipse(in: CGRect(x: rect.minX + rect.width * 0.05, y: rect.midY - bump / 2, width: bump * 1.8, height: bump))
        path.addEllipse(in: CGRect(x: rect.midX - bump * 1.05, y: rect.midY - bump * 1.05, width: bump * 2.5, height: bump * 1.35))
        path.addEllipse(in: CGRect(x: rect.maxX - bump * 2.45, y: rect.midY - bump / 3, width: bump * 2, height: bump * 1.1))
        path.addRoundedRect(in: CGRect(x: rect.minX + rect.width * 0.07, y: rect.midY - bump * 0.25, width: rect.width * 0.88, height: bump), cornerSize: CGSize(width: bump / 4, height: bump / 4))
        return path
    }
}
