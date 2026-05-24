//
//  SettingsView.swift
//  167NexovelleInfinity
//

import Foundation
import StoreKit
import SwiftUI
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var store: AppStorageStore
    @EnvironmentObject private var bannerQueue: AchievementBannerQueue

    @State private var showingResetConfirm = false

    private var versionText: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                GlassPanel(contentSpacing: 16) {
                    ScreenSectionHeader(
                        title: "Usage snapshot",
                        subtitle: "Everything stays local—this grid is how you peek at momentum.",
                        systemImage: "chart.bar.doc.horizontal.fill"
                    )

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                    ], spacing: 12) {
                        MetricChip(title: "Alerts saved", value: "\(store.weatherAlerts.count)", systemImage: "bell.badge.fill")
                        MetricChip(title: "Insight rows", value: "\(store.weatherRecords.count)", systemImage: "chart.line.uptrend.xyaxis")
                        MetricChip(title: "Minutes used", value: "\(store.totalMinutesUsed)m", systemImage: "clock.fill")
                        MetricChip(title: "Day streak", value: "\(store.streakDays)d", systemImage: "flame.fill")
                        MetricChip(title: "Sessions", value: "\(store.totalSessionsCompleted)", systemImage: "checkmark.circle.fill")
                        MetricChip(title: "Foreground visits", value: "\(store.foregroundSessions)", systemImage: "arrow.triangle.2.circlepath")
                    }
                }

                GlassPanel {
                    ScreenSectionHeader(
                        title: "Celebration quiet hours",
                        subtitle: "Mute achievement toast banners overnight or whenever you need calm.",
                        systemImage: "moon.stars.fill"
                    )

                    PreferenceToggleRow(
                        symbol: "speaker.slash.fill",
                        title: "Respect quiet hours",
                        subtitle: "Blocks celebratory banners between the hours you pick.",
                        isOn: Binding(
                            get: { store.globalQuietHoursEnabled },
                            set: { newValue in
                                FeedbackCentral.tapLight()
                                store.setGlobalQuietHoursPreference(
                                    enabled: newValue,
                                    startMinute: store.globalQuietStartMinute,
                                    endMinute: store.globalQuietEndMinute
                                )
                            }
                        )
                    )

                    if store.globalQuietHoursEnabled {
                        CellHairlineDivider()

                        Stepper(
                            "Start near \(store.globalQuietStartMinute / 60):00",
                            value: Binding(
                                get: { store.globalQuietStartMinute / 60 },
                                set: { hour in
                                    let clamped = min(23, max(0, hour))
                                    store.setGlobalQuietHoursPreference(
                                        enabled: store.globalQuietHoursEnabled,
                                        startMinute: clamped * 60,
                                        endMinute: store.globalQuietEndMinute
                                    )
                                }
                            ),
                            in: 0 ... 23,
                            step: 1
                        )
                        .foregroundStyle(Color.appTextPrimary)

                        Stepper(
                            "End near \(store.globalQuietEndMinute / 60):00",
                            value: Binding(
                                get: { store.globalQuietEndMinute / 60 },
                                set: { hour in
                                    let clamped = min(23, max(0, hour))
                                    store.setGlobalQuietHoursPreference(
                                        enabled: store.globalQuietHoursEnabled,
                                        startMinute: store.globalQuietStartMinute,
                                        endMinute: clamped * 60
                                    )
                                }
                            ),
                            in: 0 ... 23,
                            step: 1
                        )
                        .foregroundStyle(Color.appTextPrimary)
                    }
                }

                GlassPanel {
                    ScreenSectionHeader(
                        title: "App & legal",
                        subtitle: "Rate the app or open privacy and terms in Safari.",
                        systemImage: "link.circle.fill"
                    )

                    CellHairlineDivider()

                    Button {
                        FeedbackCentral.tapLight()
                        rateApp()
                    } label: {
                        SettingsDestinationRow(
                            symbol: "star.fill",
                            title: "Rate us",
                            subtitle: "Tell others how this app helps"
                        )
                    }
                    .buttonStyle(.tapFeedback)

                    CellHairlineDivider()

                    Button {
                        FeedbackCentral.tapLight()
                        AppExternalURL.privacyPolicy.openInBrowser()
                    } label: {
                        SettingsDestinationRow(
                            symbol: "hand.raised.fill",
                            title: "Privacy Policy",
                            subtitle: "Opens the policy in your browser"
                        )
                    }
                    .buttonStyle(.tapFeedback)

                    CellHairlineDivider()

                    Button {
                        FeedbackCentral.tapLight()
                        AppExternalURL.termsOfUse.openInBrowser()
                    } label: {
                        SettingsDestinationRow(
                            symbol: "doc.text.fill",
                            title: "Terms of Use",
                            subtitle: "Opens terms in your browser"
                        )
                    }
                    .buttonStyle(.tapFeedback)
                }

                GlassPanel {
                    Button(role: .destructive) {
                        FeedbackCentral.tapMedium()
                        showingResetConfirm = true
                    } label: {
                        DestructiveRowButtonLabel(
                            symbol: "arrow.counterclockwise.circle.fill",
                            title: "Reset All Data",
                            subtitle: "Clears alerts, preferences, logs, achievements, and counters."
                        )
                    }
                    .buttonStyle(.tapFeedback)
                }

                Text("Version \(versionText)")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Color.appTextSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 22)
            .padding(.bottom, 96)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Reset everything?", isPresented: $showingResetConfirm) {
            Button("Cancel", role: .cancel) {
                FeedbackCentral.tapLight()
            }
            Button("Reset", role: .destructive) {
                FeedbackCentral.tapMedium()
                bannerQueue.resetForSession()
                store.resetAllData()
                FeedbackCentral.celebrateWorkflowCompletion()
            }
        } message: {
            Text("This clears alerts, preferences, logs, achievements, and counters.")
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
