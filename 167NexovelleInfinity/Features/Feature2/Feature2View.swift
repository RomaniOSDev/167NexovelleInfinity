//
//  Feature2View.swift
//  167NexovelleInfinity
//

import Foundation
import SwiftUI

struct Feature2View: View {
    @EnvironmentObject private var store: AppStorageStore

    @StateObject private var viewModel = Feature2ViewModel()

    @State private var showSuccessPulse = false
    @State private var weeklyPulse = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if !store.hasSavedPreferencesOnce {
                    preferenceEmptyBanner
                }

                ScreenSectionHeader(
                    title: "Alert signals",
                    subtitle: "Fine-tune which weather patterns should qualify for outbound guidance.",
                    systemImage: "cloud.bolt.rain.fill"
                )

                GlassPanel {
                    PreferenceToggleRow(
                        symbol: "cloud.rain.fill",
                        title: "Rain sensitivity",
                        subtitle: "Treat rainfall outlooks as high-priority cues.",
                        isOn: $viewModel.rain
                    )
                    CellHairlineDivider()
                    PreferenceToggleRow(
                        symbol: "snowflake",
                        title: "Snowfall watch",
                        subtitle: "Elevate freezes and snowfall messaging.",
                        isOn: $viewModel.snow
                    )
                    CellHairlineDivider()
                    PreferenceToggleRow(
                        symbol: "exclamationmark.triangle.fill",
                        title: "Severe weather",
                        subtitle: "Lightning, hail, marine, and tornado-style warnings.",
                        isOn: $viewModel.severe
                    )
                    CellHairlineDivider()
                    PreferenceToggleRow(
                        symbol: "wind",
                        title: "Wind-sensitive mode",
                        subtitle: "Call out gust-heavy windows you care about.",
                        isOn: $viewModel.wind
                    )
                }
                .animation(.default, value: viewModel.rain)
                .animation(.default, value: viewModel.snow)
                .animation(.default, value: viewModel.severe)
                .animation(.default, value: viewModel.wind)

                GlassPanel {
                    PreferenceToggleRow(
                        symbol: "switch.2",
                        title: "Preferences active",
                        subtitle: "Globally mute planner signals when you’re heads-down elsewhere.",
                        isOn: $viewModel.masterEnabled
                    )
                    .animation(.default, value: viewModel.masterEnabled)

                    CellHairlineDivider()

                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 10) {
                            IconGlyph(symbol: "dial.medium.fill", size: 44)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Sensitivity")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.appTextPrimary)
                                Text("Higher values lean into early warnings.")
                                    .font(.caption)
                                    .foregroundStyle(Color.appTextSecondary)
                            }
                            Spacer()
                            Text(Int(viewModel.sensitivity * 100).description + "%")
                                .font(.footnote.weight(.bold))
                                .foregroundStyle(Color.appAccent)
                        }

                        Slider(value: $viewModel.sensitivity, in: 0 ... 1, step: 0.05)
                            .tint(Color.appAccent)
                    }
                    .padding(.vertical, 4)
                }

                GlassPanel {
                    Text("Weekly forecast review")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)

                    Text("Log each pass through the upcoming seven-day outlook to keep rituals on track.")
                        .font(.footnote)
                        .foregroundStyle(Color.appTextSecondary)

                    SecondaryOutlineButton(title: "Complete weekly review", action: completeWeeklyReview)
                        .pulseAccent(on: weeklyPulse)
                }

                PrimaryFullWidthButton(title: "Save preferences", action: savePreferences)
                    .pulseAccent(on: showSuccessPulse)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .padding(.bottom, 96)
        }
        .scrollIndicators(.hidden)
        .onAppear {
            viewModel.load(from: store)
        }
        .onReceive(NotificationCenter.default.publisher(for: .dataReset)) { _ in
            viewModel.load(from: store)
        }
    }

    private var preferenceEmptyBanner: some View {
        GlassPanel {
            VStack(spacing: 14) {
                Image(systemName: "bell.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.appAccent)

                Text("No alerts configured")
                    .font(.title3.bold())
                    .foregroundStyle(Color.appTextPrimary)

                Text("Once you save preferences, the planner mirrors your risk tolerance everywhere else.")
                    .font(.footnote)
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func savePreferences() {
        FeedbackCentral.tapMedium()
        viewModel.persist(using: store, markConfigured: true)

        FeedbackCentral.playSavedPing()
        FeedbackCentral.celebrateWorkflowCompletion()

        withAnimation(.easeInOut(duration: 0.35)) {
            showSuccessPulse = true
        }

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.55))
            showSuccessPulse = false
        }
    }

    private func completeWeeklyReview() {
        FeedbackCentral.tapMedium()
        store.registerWeeklyReviewCompletion()
        FeedbackCentral.playSavedPing()
        FeedbackCentral.celebrateWorkflowCompletion()

        weeklyPulse = true
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.45))
            weeklyPulse = false
        }
    }
}
