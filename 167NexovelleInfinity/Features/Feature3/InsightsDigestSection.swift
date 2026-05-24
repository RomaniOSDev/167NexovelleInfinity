//
//  InsightsDigestSection.swift
//  167NexovelleInfinity
//

import Foundation
import SwiftUI

struct InsightsForecastDigestSection: View {
    let records: [WeatherRecord]

    private var rollingRecords: [WeatherRecord] {
        let cal = Calendar.current
        let todayStart = cal.startOfDay(for: Date())
        guard let start = cal.date(byAdding: .day, value: -7, to: todayStart) else { return [] }
        return records.filter { cal.startOfDay(for: $0.date) >= start }
    }

    private var groupedByDay: [Date: [WeatherRecord]] {
        let cal = Calendar.current
        return Dictionary(grouping: rollingRecords, by: { cal.startOfDay(for: $0.date) })
    }

    private var patternStats: (rainyDays: Int, cloudyDays: Int, warmDays: Int) {
        guard !groupedByDay.isEmpty else { return (0, 0, 0) }
        var rainy = 0
        var cloudy = 0
        var warm = 0
        for (_, dayRecords) in groupedByDay {
            let precip = dayRecords.map(\.precipitationMillimeters).max() ?? 0
            let cloud = dayRecords.map(\.cloudCoverPercent).max() ?? 0
            let high = dayRecords.map(\.highTemperatureCelsius).max() ?? 0
            if precip >= 1 { rainy += 1 }
            if cloud >= 60 { cloudy += 1 }
            if high >= 25 { warm += 1 }
        }
        return (rainyDays: rainy, cloudyDays: cloudy, warmDays: warm)
    }

    private var aggregatedWeek: (highAvg: Double, lowAvg: Double, precipSum: Double, days: Int) {
        guard !groupedByDay.isEmpty else { return (0, 0, 0, 0) }
        var daySummaries: [(high: Double, low: Double, precipSum: Double)] = []
        for (_, dayRecords) in groupedByDay {
            guard let mxHigh = dayRecords.map(\.highTemperatureCelsius).max(),
                  let mnLow = dayRecords.map(\.lowTemperatureCelsius).min() else { continue }

            let prec = dayRecords.map(\.precipitationMillimeters).reduce(0, +)
            daySummaries.append((high: mxHigh, low: mnLow, precipSum: prec))
        }
        guard !daySummaries.isEmpty else { return (0, 0, 0, 0) }
        let highAvg = daySummaries.map(\.high).reduce(0, +) / Double(daySummaries.count)
        let lowAvg = daySummaries.map(\.low).reduce(0, +) / Double(daySummaries.count)
        let precipWeek = daySummaries.map(\.precipSum).reduce(0, +)
        return (highAvg, lowAvg, precipWeek, groupedByDay.count)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Rolling forecast outlook")
                .font(.title3.bold())
                .foregroundStyle(Color.appTextPrimary)

            Text("Seven-day synthesis from logs you captured in this planner.")
                .font(.footnote)
                .foregroundStyle(Color.appTextSecondary)

            weekCard

            patternsCard

            if rollingRecords.isEmpty {
                Text("Log a few days to populate this digest.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appAccent.opacity(0.92))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(18)
        .background(Color.appSurface.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.appAccent.opacity(0.35), lineWidth: 1)
        )
    }

    private var weekCard: some View {
        let agg = aggregatedWeek

        return VStack(alignment: .leading, spacing: 10) {
            Text("Weekly stats")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)

            HStack {
                metricColumn(title: "Avg high", value: String(format: "%.0f °C", agg.highAvg))
                metricColumn(title: "Avg low", value: String(format: "%.0f °C", agg.lowAvg))
                metricColumn(title: "Σ precip", value: String(format: "%.1f mm", agg.precipSum))
                metricColumn(title: "Tracked days", value: "\(agg.days)")
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(Color.appSurface.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var patternsCard: some View {
        let p = patternStats
        return VStack(alignment: .leading, spacing: 8) {
            Text("Emerging patterns")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)

            Label("Rainy moods (≥1 mm): \(p.rainyDays) day(s)", systemImage: "cloud.rain.fill")
                .font(.footnote.weight(.medium))
                .foregroundStyle(Color.appTextSecondary)

            Label("Heavy cloud (>60%): \(p.cloudyDays) day(s)", systemImage: "cloud.fill")
                .font(.footnote.weight(.medium))
                .foregroundStyle(Color.appTextSecondary)

            Label("Warm highs (≥25°C): \(p.warmDays) day(s)", systemImage: "sun.max.fill")
                .font(.footnote.weight(.medium))
                .foregroundStyle(Color.appTextSecondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.appSurface.opacity(0.62))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func metricColumn(title: String, value: String) -> some View {
        VStack(spacing: 6) {
            Text(title.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(Color.appTextSecondary)

            Text(value)
                .font(.caption.monospacedDigit().weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct LocationMemoryPanel: View {
    @EnvironmentObject private var store: AppStorageStore

    private var snapshots: [LocationMemorySnapshot] {
        store.locationMemories.values.sorted { $0.updatedAt > $1.updatedAt }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Location memory lane")
                .font(.title3.bold())
                .foregroundStyle(Color.appTextPrimary)

            Text("Sticky notes keyed to each normalized label updated whenever you capture an insight.")
                .font(.footnote)
                .foregroundStyle(Color.appTextSecondary)

            if snapshots.isEmpty {
                Text("Add a labeled manual log — we keep a corkboard preview here.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appAccent.opacity(0.92))
                    .padding(.vertical, 6)
            } else {
                ForEach(snapshots.prefix(12)) { snap in
                    LocationMemoryEditableRow(snapshot: snap, store: store)
                }
            }
        }
        .padding(18)
        .background(Color.appSurface.opacity(0.82))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.appAccent.opacity(0.35), lineWidth: 1)
        )
    }
}

private struct LocationMemoryEditableRow: View {
    let snapshot: LocationMemorySnapshot
    @ObservedObject var store: AppStorageStore

    @State private var draftNote = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(snapshot.locationKey.capitalized)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                Text(snapshot.updatedAt, style: .date)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Color.appTextSecondary.opacity(0.9))
            }

            TextField("", text: $draftNote, prompt: Text("How did it feel on site?").foregroundStyle(Color.appTextSecondary), axis: .vertical)
                .lineLimit(2 ... 5)
                .glassTextFieldChrome(verticalPadding: 12, minHeight: 76)
                .onAppear {
                    if draftNote.isEmpty {
                        draftNote = snapshot.userFeelingNote
                    }
                }

            Button("Save feeling note") {
                FeedbackCentral.tapLight()
                store.updateLocationFeelingNote(locationKey: snapshot.locationKey, note: draftNote)
            }
            .buttonStyle(.tapFeedback)
            .font(.footnote.weight(.bold))
            .foregroundStyle(Color.appAccent)
        }
        .padding(.vertical, 4)
        Divider().overlay(Color.appAccent.opacity(0.18))
    }
}

private extension Date {
    func startOfDay(in calendar: Calendar = .current) -> Date {
        calendar.startOfDay(for: self)
    }
}
