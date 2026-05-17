//
//  AchievementsView.swift
//  167NexovelleInfinity
//

import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var store: AppStorageStore

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14),
    ]

    private var visibleAchievements: [AchievementCatalog.Definition] {
        AchievementCatalog.definitionsToDisplay { store.isAchievementUnlocked(id: $0) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                summaryCard

                dailyEngagementCard

                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(visibleAchievements) { badge in
                        let unlocked = store.isAchievementUnlocked(id: badge.id)
                        AchievementBadgeTile(
                            title: tileTitle(for: badge, unlocked: unlocked),
                            detail: tileDetail(for: badge, unlocked: unlocked),
                            unlocked: unlocked,
                            progress: unlocked || !badge.isHidden ? store.formattedAchievementProgress(for: badge.id) : ""
                        )
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .padding(.bottom, 96)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var summaryCard: some View {
        GlassPanel(contentSpacing: 16) {
            ScreenSectionHeader(
                title: "Momentum overview",
                subtitle: "Celebrate micro-wins—they unlock hidden trophies over time.",
                systemImage: "trophy.circle.fill"
            )

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: 12) {
                MetricChip(title: "Alerts created", value: "\(store.totalAlertsEverCreated)", systemImage: "bell.badge.fill")
                MetricChip(title: "Insight logs", value: "\(store.insightAddsCompleted)", systemImage: "chart.line.uptrend.xyaxis")
                MetricChip(title: "Weekly reviews", value: "\(store.weeklyReviewsCompleted)", systemImage: "calendar.circle.fill")
                MetricChip(title: "Sessions", value: "\(store.totalSessionsCompleted)", systemImage: "checkmark.seal.fill")
                MetricChip(title: "Minutes engaged", value: "\(store.totalMinutesUsed)m", systemImage: "clock.fill")
                MetricChip(title: "Active streak", value: "\(store.streakDays)d", systemImage: "flame.fill")
            }
        }
    }

    private var dailyEngagementCard: some View {
        let checks = store.dailyGoalsChecks

        return GlassPanel {
            Text("Daily engagement checklist")
                .font(.title3.bold())
                .foregroundStyle(Color.appTextPrimary)

            Text("Peek at Alerts, Planner insights, then log something new — rings stack for ritual achievements.")
                .font(.footnote)
                .foregroundStyle(Color.appTextSecondary)

            HStack(spacing: 10) {
                checklistPill(title: "Alerts", done: checks.alertsVisited)
                checklistPill(title: "Insights", done: checks.insightsVisited)
                checklistPill(title: "Create", done: checks.contributed)
            }

            Text("Lifetime ritual days: \(store.dailyGoalsCompletionsTotal)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.appAccent)
        }
    }

    private func checklistPill(title: String, done: Bool) -> some View {
        Text(title)
            .font(.caption.weight(.bold))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .foregroundStyle(done ? Color.appBackground : Color.appTextSecondary)
            .background(done ? Color.appPrimary : Color.appSurface.opacity(0.55))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.appAccent.opacity(done ? 0.9 : 0.35), lineWidth: 1)
            )
    }

    private func tileTitle(for definition: AchievementCatalog.Definition, unlocked: Bool) -> String {
        if unlocked || !definition.isHidden {
            return definition.title
        }
        return "Hidden trophy"
    }

    private func tileDetail(for definition: AchievementCatalog.Definition, unlocked: Bool) -> String {
        if unlocked || !definition.isHidden {
            return definition.detail
        }
        return "Explore alerts, templates, and the insight digest to reveal it."
    }
}

private struct AchievementBadgeTile: View {
    let title: String
    let detail: String
    let unlocked: Bool
    let progress: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            LinearGradient(
                colors: [
                    Color.appPrimary.opacity(unlocked ? 0.92 : 0.35),
                    Color.appAccent.opacity(unlocked ? 0.82 : 0.22),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 7)

            VStack(alignment: .leading, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.appSurface.opacity(unlocked ? 0.95 : 0.55))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.appAccent.opacity(unlocked ? 0.85 : 0.35), lineWidth: 1)
                        )

                    Image(systemName: unlocked ? "seal.fill" : "lock.fill")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(unlocked ? Color.appPrimary : Color.appTextSecondary.opacity(0.92))
                        .padding(.vertical, 18)
                }
                .frame(height: 92)

                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)

                Text(detail)
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                if !progress.isEmpty {
                    Text(progress)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Color.appAccent)
                }
            }
            .padding(14)
        }
        .background(Color.appBackground.opacity(0.35))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.appAccent.opacity(0.25), lineWidth: 1)
        )
    }
}
