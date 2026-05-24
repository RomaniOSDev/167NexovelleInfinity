//
//  AlertComposerSheet.swift
//  167NexovelleInfinity
//

import Foundation
import SwiftUI

struct AlertComposerSheet: View {
    @EnvironmentObject private var store: AppStorageStore
    @Environment(\.dismiss) private var dismiss

    let existingAlert: WeatherAlertItem?
    var seedTemplate: AlertTemplateKind?

    @StateObject private var model = Feature1ViewModel()
    @State private var shakeSignal: CGFloat = 0
    @State private var shouldHonorTemplateAchievement = false

    var body: some View {
        NavigationStack {
            WeatherScreenRoot {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        temperatureSection
                        windSection

                        quietHoursSection

                        feelingsSection

                        locationSection

                        Text("Classic condition switches")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color.appTextPrimary)

                        Toggle("Rain", isOn: $model.rainEnabled)
                            .toggleStyle(SwitchToggleStyle(tint: Color.appAccent))
                            .animation(.default, value: model.rainEnabled)
                        Toggle("Snow", isOn: $model.snowEnabled)
                            .toggleStyle(SwitchToggleStyle(tint: Color.appAccent))
                            .animation(.default, value: model.snowEnabled)
                        Toggle("Severe weather", isOn: $model.severeEnabled)
                            .toggleStyle(SwitchToggleStyle(tint: Color.appAccent))
                            .animation(.default, value: model.severeEnabled)
                        Toggle("Wind speed alert", isOn: $model.windAlertEnabled)
                            .toggleStyle(SwitchToggleStyle(tint: Color.appAccent))
                            .animation(.default, value: model.windAlertEnabled)

                        if !model.helperMessage.isEmpty {
                            Text(model.helperMessage)
                                .font(.footnote.weight(.medium))
                                .foregroundStyle(Color.red.opacity(0.85))
                        }

                        Button(action: saveAlert) {
                            Text(existingAlert == nil ? "Save alert" : "Update alert")
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
                        .padding(.top, 8)
                    }
                    .padding(22)
                    .padding(.bottom, 36)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle(existingAlert == nil ? "New alert" : "Edit alert")
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
            .onAppear {
                if let existingAlert {
                    model.load(from: existingAlert)
                    shouldHonorTemplateAchievement = false
                } else if let seedTemplate {
                    seedTemplate.apply(to: model)
                    shouldHonorTemplateAchievement = true
                } else {
                    model.resetDraft()
                    shouldHonorTemplateAchievement = false
                }
            }
        }
    }

    private var temperatureSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cold focus threshold (°C)")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.appTextSecondary)

            TextField("", text: $model.temperatureField, prompt: Text("e.g. 12").foregroundStyle(Color.appTextSecondary))
                .keyboardType(.numbersAndPunctuation)
                .glassTextFieldChrome()
                .shake(trigger: shakeSignal)
        }
    }

    private var windSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Severe wind ceiling (km/h)")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.appTextSecondary)

            TextField("", text: $model.windField, prompt: Text("e.g. 40").foregroundStyle(Color.appTextSecondary))
                .keyboardType(.numbersAndPunctuation)
                .glassTextFieldChrome()
        }
    }

    private var quietHoursSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quiet window")
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)

            Text("Reference hours for calmer in-app moments (per alert).")
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)

            Toggle("Note quiet hours", isOn: $model.quietHoursEnabled)
                .toggleStyle(SwitchToggleStyle(tint: Color.appAccent))

            if model.quietHoursEnabled {
                Stepper("Start around \(model.quietStartHour):00", value: $model.quietStartHour, in: 0 ... 23)
                    .foregroundStyle(Color.appTextPrimary)

                Stepper("End around \(model.quietEndHour):00", value: $model.quietEndHour, in: 0 ... 23)
                    .foregroundStyle(Color.appTextPrimary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.appSurface.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.appAccent.opacity(0.25), lineWidth: 1)
        )
    }

    private var feelingsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Comfort cues")
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)

            Text("Track “feels too warm” or “feels breezy” without waiting for classic switches alone.")
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)

            Toggle("Warm feeling watch", isOn: $model.warmFeelingEnabled)
                .toggleStyle(SwitchToggleStyle(tint: Color.appAccent))

            if model.warmFeelingEnabled {
                TextField("", text: $model.warmFeelingThresholdField, prompt: Text("Warm threshold (°C)").foregroundStyle(Color.appTextSecondary))
                    .keyboardType(.numbersAndPunctuation)
                    .glassTextFieldChrome()
            }

            Toggle("Breezy feeling watch", isOn: $model.breezyFeelingEnabled)
                .toggleStyle(SwitchToggleStyle(tint: Color.appAccent))

            if model.breezyFeelingEnabled {
                TextField("", text: $model.breezyFeelingWindField, prompt: Text("Gentle wind floor (km/h)").foregroundStyle(Color.appTextSecondary))
                    .keyboardType(.numbersAndPunctuation)
                    .glassTextFieldChrome()
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.appSurface.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.appAccent.opacity(0.25), lineWidth: 1)
        )
    }

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Location label")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.appTextSecondary)

            TextField("", text: $model.locationField, prompt: Text("Home city label").foregroundStyle(Color.appTextSecondary))
                .textInputAutocapitalization(.words)
                .glassTextFieldChrome()
        }
    }

    private func saveAlert() {
        FeedbackCentral.tapMedium()
        guard let alert = model.buildAlert(existingID: existingAlert?.id) else {
            FeedbackCentral.notifyWarning()
            shakeSignal += 1
            return
        }

        let isNew = existingAlert == nil
        if shouldHonorTemplateAchievement, isNew {
            store.registerTemplateComposerUse()
        }
        shouldHonorTemplateAchievement = false

        store.upsertWeatherAlert(alert, isNew: isNew)
        FeedbackCentral.tapLight()
        FeedbackCentral.playSavedPing()

        if isNew {
            FeedbackCentral.celebrateWorkflowCompletion()
        }

        dismiss()

        Task { @MainActor in
            let payload: [String: Any] = [
                "id": alert.id.uuidString,
                "isNew": isNew,
            ]
            NotificationCenter.default.post(name: .composerFinishedAlert, object: payload as NSDictionary)
        }
    }
}
