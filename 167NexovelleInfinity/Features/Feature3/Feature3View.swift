//
//  Feature3View.swift
//  167NexovelleInfinity
//

import Foundation
import SwiftUI
import UIKit

struct Feature3View: View {
    @EnvironmentObject private var store: AppStorageStore
    @StateObject private var draft = Feature3ViewModel()

    @State private var shakeToken: CGFloat = 0
    @State private var savePulse = false
    @State private var selectedRecord: WeatherRecord?
    @State private var showingTrackingTips = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                trackingHeader

                InsightsForecastDigestSection(records: store.weatherRecords)

                LocationMemoryPanel()

                if store.weatherRecords.isEmpty {
                    insightsEmptyHero
                }

                composerCard

                LazyVStack(spacing: 16) {
                    ForEach(store.weatherRecords) { record in
                        WeatherInsightCard(
                            record: record,
                            onOpen: {
                                FeedbackCentral.tapLight()
                                selectedRecord = record
                            },
                            onDelete: {
                                FeedbackCentral.tapMedium()
                                store.deleteWeatherRecord(id: record.id)
                                FeedbackCentral.celebrateWorkflowCompletion()
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .padding(.bottom, 96)
        }
        .scrollIndicators(.hidden)
        .onAppear {
            store.markVisitedInsightsPlanner()
        }
        .sheet(item: $selectedRecord) { record in
            NavigationStack {
                WeatherRecordDetailView(record: record)
            }
        }
        .sheet(isPresented: $showingTrackingTips) {
            NavigationStack {
                TrackingGuidanceView(locationSample: guidanceSampleLabel)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") {
                                FeedbackCentral.tapLight()
                                showingTrackingTips = false
                            }
                            .buttonStyle(.tapFeedback)
                        }
                    }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .dataReset)) { _ in
            draft.resetDraft()
            selectedRecord = nil
        }
    }

    private var guidanceSampleLabel: String {
        let trimmed = draft.locationLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Neighborhood label" : trimmed
    }

    private var trackingHeader: some View {
        GlassPanel {
            PreferenceToggleRow(
                symbol: "square.and.pencil",
                title: "Manual tracking mode",
                subtitle: "Log conditions without granting extra permissions.",
                isOn: Binding(
                    get: { store.trackingEnabled },
                    set: { newValue in
                        FeedbackCentral.tapLight()
                        store.setTrackingEnabled(newValue)
                    }
                )
            )

            CellHairlineDivider()

            SecondaryOutlineButton(title: "Start tracking", action: presentTrackingCoach)
        }
    }

    private var insightsEmptyHero: some View {
        VStack(spacing: 16) {
            Image(systemName: "cloud.sun.fill")
                .font(.system(size: 52, weight: .semibold))
                .foregroundStyle(Color.appPrimary)

            Text("No insights yet")
                .font(.title3.bold())
                .foregroundStyle(Color.appTextPrimary)

            Text("No insights yet. Gather data over time to see trends.")
                .font(.body)
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 12)
    }

    private var composerCard: some View {
        GlassPanel {
            ScreenSectionHeader(
                title: "Manual log",
                subtitle: "Ground truth for the week—numbers stay on your device.",
                systemImage: "note.text.badge.plus"
            )

            CellHairlineDivider()

            VStack(alignment: .leading, spacing: 6) {
                ComposerLabeledField(symbol: "calendar", title: "Day")
                DatePicker("", selection: $draft.dateSelection, displayedComponents: .date)
                    .labelsHidden()
                    .tint(Color.appAccent)
            }

            labeledField(symbol: "thermometer.high", title: "High (°C)", text: $draft.highTemperature)

            labeledField(symbol: "thermometer.low", title: "Low (°C)", text: $draft.lowTemperature)

            labeledNumericField(symbol: "drop.fill", title: "Precipitation (mm)", text: $draft.precipitation, pad: .decimalPad)

            labeledNumericField(symbol: "cloud.fill", title: "Cloud cover (%)", text: $draft.clouds, pad: .numbersAndPunctuation)

            labeledField(symbol: "mappin.and.ellipse", title: "Location label", text: $draft.locationLabel, capitalization: .words)

            if !draft.helperText.isEmpty {
                Text(draft.helperText)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Color.red.opacity(0.85))
            }

            PrimaryFullWidthButton(title: "Save daily snapshot", action: saveRecord)
                .pulseAccent(on: savePulse)
        }
    }

    @ViewBuilder
    private func baselineTextField(text: Binding<String>, capitalization: TextInputAutocapitalization?) -> some View {
        let prompt = Text("Value").foregroundStyle(Color.appTextSecondary)

        if let capitalization {
            TextField("", text: text, prompt: prompt)
                .textInputAutocapitalization(capitalization)
        } else {
            TextField("", text: text, prompt: prompt)
        }
    }

    private func labeledField(symbol: String, title: String, text: Binding<String>, capitalization: TextInputAutocapitalization? = nil) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ComposerLabeledField(symbol: symbol, title: title)

            baselineTextField(text: text, capitalization: capitalization)
                .glassTextFieldChrome()
                .shake(trigger: shakeToken)
        }
    }

    private func labeledNumericField(symbol: String, title: String, text: Binding<String>, pad: UIKeyboardType) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ComposerLabeledField(symbol: symbol, title: title)

            TextField("", text: text, prompt: Text("Value").foregroundStyle(Color.appTextSecondary))
                .keyboardType(pad)
                .glassTextFieldChrome()
                .shake(trigger: shakeToken)
        }
    }

    private func saveRecord() {
        FeedbackCentral.tapMedium()
        guard let record = draft.buildRecord() else {
            FeedbackCentral.notifyWarning()
            shakeToken += 1
            return
        }

        store.addWeatherRecord(record)
        FeedbackCentral.tapMedium()
        FeedbackCentral.playInsightSavedSound()

        draft.resetDraft()

        savePulse = true
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.45))
            savePulse = false
        }

        FeedbackCentral.celebrateWorkflowCompletion()
    }

    private func presentTrackingCoach() {
        FeedbackCentral.tapMedium()
        store.setTrackingEnabled(true)
        showingTrackingTips = true
    }
}

private struct WeatherInsightCard: View {
    let record: WeatherRecord
    let onOpen: () -> Void
    let onDelete: () -> Void

    private var dayLabel: String {
        record.date.formatted(date: .abbreviated, time: .omitted)
    }

    var body: some View {
        GlassPanel {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(dayLabel)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.appBackground)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.appPrimary)
                        .clipShape(Capsule())

                    Text(record.locationLabel)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(2)

                    Text(record.summaryDescription())
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(3)
                }

                Spacer(minLength: 8)

                Menu {
                    ShareLink(item: record.summaryDescription()) {
                        Label("Share summary", systemImage: "square.and.arrow.up")
                    }

                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        Label("Delete entry", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.appAccent)
                        .padding(8)
                        .background(Color.appBackground.opacity(0.22))
                        .clipShape(Circle())
                }
                .buttonStyle(.tapFeedback)
            }

            HStack(spacing: 10) {
                InsightMetricCell(
                    icon: "thermometer.medium",
                    caption: "Range",
                    value: "\(Int(record.lowTemperatureCelsius))–\(Int(record.highTemperatureCelsius))°"
                )
                InsightMetricCell(
                    icon: "drop.fill",
                    caption: "Precip",
                    value: "\(Int(record.precipitationMillimeters)) mm"
                )
                InsightMetricCell(
                    icon: "cloud.fill",
                    caption: "Clouds",
                    value: "\(Int(record.cloudCoverPercent))%"
                )
            }

            TemperatureSparkCanvas(samples: record.hourlyTemperatureSamples())

            PrimaryFullWidthButton(title: "View details", action: onOpen)
        }
        .contextMenu {
            ShareLink(item: record.summaryDescription()) {
                Label("Share summary", systemImage: "square.and.arrow.up")
            }

            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete entry", systemImage: "trash")
            }
        }
    }
}

private struct WeatherRecordDetailView: View {
    let record: WeatherRecord
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                GlassPanel {
                    ScreenSectionHeader(
                        title: record.date.formatted(date: .long, time: .omitted),
                        subtitle: record.summaryDescription(),
                        systemImage: "chart.xyaxis.line"
                    )
                }

                TemperatureSparkCanvas(samples: record.hourlyTemperatureSamples(count: 24))

                KeyValueInsightCell(symbol: "drop.fill", title: "Precipitation", value: "\(Int(record.precipitationMillimeters)) mm")
                KeyValueInsightCell(symbol: "cloud.fill", title: "Cloud cover", value: "\(Int(record.cloudCoverPercent))%")
                KeyValueInsightCell(symbol: "mappin.and.ellipse", title: "Location label", value: record.locationLabel)

                ShareLink(item: record.summaryDescription()) {
                    Label("Share summary", systemImage: "square.and.arrow.up")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.appBackground)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [Color.appPrimary, Color.appPrimary.opacity(0.88)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.appAccent.opacity(0.45), lineWidth: 1)
                        )
                }
                .buttonStyle(.tapFeedback)
            }
            .padding(22)
            .padding(.bottom, 36)
        }
        .scrollIndicators(.hidden)
        .background(Color.appBackground.opacity(0.15))
        .navigationTitle("Insights")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    FeedbackCentral.tapLight()
                    dismiss()
                }
                .buttonStyle(.tapFeedback)
            }
        }
    }

}

private struct TrackingGuidanceView: View {
    let locationSample: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Tracking checklist")
                    .font(.title2.bold())
                    .foregroundStyle(Color.appTextPrimary)

                bullet("Pick a recognizable label such as \(locationSample).")
                bullet("Capture highs and lows around the same time each day.")
                bullet("Estimate precipitation using trusted regional summaries.")
                bullet("Adjust cloud cover percentages based on hourly observations.")

                Text("These logs stay on-device so you can assemble trustworthy weekly snapshots.")
                    .font(.footnote)
                    .foregroundStyle(Color.appTextSecondary)
                    .padding(.top, 8)
            }
            .padding(22)
            .padding(.bottom, 36)
        }
        .scrollIndicators(.hidden)
        .background(Color.appBackground.opacity(0.35))
        .navigationTitle("Insights")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(Color.appAccent)
                .frame(width: 8, height: 8)
                .padding(.top, 6)

            Text(text)
                .font(.body)
                .foregroundStyle(Color.appTextPrimary)
        }
    }
}
