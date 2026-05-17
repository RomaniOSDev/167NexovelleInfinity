//
//  Feature1ViewModel.swift
//  167NexovelleInfinity
//

import Combine
import Foundation

@MainActor
final class Feature1ViewModel: ObservableObject {
    @Published var temperatureField = ""
    @Published var windField = ""
    @Published var locationField = ""
    @Published var rainEnabled = false
    @Published var snowEnabled = false
    @Published var severeEnabled = false
    @Published var windAlertEnabled = false

    @Published var quietHoursEnabled = false
    @Published var quietStartHour = 22
    @Published var quietEndHour = 7

    @Published var warmFeelingEnabled = false
    @Published var warmFeelingThresholdField = ""

    @Published var breezyFeelingEnabled = false
    @Published var breezyFeelingWindField = ""

    @Published var helperMessage = ""

    func load(from alert: WeatherAlertItem) {
        temperatureField = formatNumber(alert.temperatureThresholdCelsius)
        windField = formatNumber(alert.windThresholdKmh)
        locationField = alert.locationLabel
        rainEnabled = alert.rainEnabled
        snowEnabled = alert.snowEnabled
        severeEnabled = alert.severeWeatherEnabled
        windAlertEnabled = alert.windAlertEnabled

        quietHoursEnabled = alert.quietHoursEnabled
        quietStartHour = clampHour(alert.quietStartMinute / 60)
        quietEndHour = clampHour(alert.quietEndMinute / 60)

        warmFeelingEnabled = alert.warmFeelingEnabled
        warmFeelingThresholdField = formatNumber(alert.warmFeelingThresholdCelsius)

        breezyFeelingEnabled = alert.breezyFeelingEnabled
        breezyFeelingWindField = formatNumber(alert.breezyFeelingWindKmh)

        helperMessage = ""
    }

    func resetDraft() {
        temperatureField = ""
        windField = "35"
        locationField = ""
        rainEnabled = true
        snowEnabled = false
        severeEnabled = false
        windAlertEnabled = false

        quietHoursEnabled = false
        quietStartHour = 22
        quietEndHour = 7

        warmFeelingEnabled = false
        warmFeelingThresholdField = "28"

        breezyFeelingEnabled = false
        breezyFeelingWindField = "22"

        helperMessage = ""
    }

    func buildAlert(existingID: UUID?) -> WeatherAlertItem? {
        helperMessage = ""

        guard let temperatureValue = Double(temperatureField.replacingOccurrences(of: ",", with: ".")) else {
            helperMessage = "Enter a valid cold-focus temperature threshold."
            return nil
        }

        guard temperatureValue >= -80, temperatureValue <= 70 else {
            helperMessage = "Temperature threshold looks unrealistic."
            return nil
        }

        var warmThreshold = Double(warmFeelingThresholdField.replacingOccurrences(of: ",", with: ".")) ?? 28
        if warmFeelingEnabled {
            guard warmThreshold >= -40, warmThreshold <= 55 else {
                helperMessage = "Warm feeling threshold looks unrealistic."
                return nil
            }
        }

        var breezyWind = Double(breezyFeelingWindField.replacingOccurrences(of: ",", with: ".")) ?? 22
        if breezyFeelingEnabled {
            guard breezyWind >= 0, breezyWind <= 220 else {
                helperMessage = "Breezy wind threshold looks unrealistic."
                return nil
            }
        } else {
            breezyWind = max(breezyWind, 0)
        }

        let anyConditionSelected = rainEnabled || snowEnabled || severeEnabled || windAlertEnabled || warmFeelingEnabled || breezyFeelingEnabled
        guard anyConditionSelected else {
            helperMessage = "Enable at least one alert channel."
            return nil
        }

        var windValue = Double(windField.replacingOccurrences(of: ",", with: ".")) ?? 35
        if windAlertEnabled {
            guard windValue >= 0, windValue <= 300 else {
                helperMessage = "Enter a realistic wind threshold."
                return nil
            }
        } else {
            windValue = max(windValue, 0)
        }

        if breezyFeelingEnabled, windAlertEnabled, breezyWind >= windValue {
            helperMessage = "Breezy feeling should stay below the severe wind ceiling."
            return nil
        }

        let identifier = existingID ?? UUID()
        let startMinute = clampHour(quietStartHour) * 60
        let endMinute = clampHour(quietEndHour) * 60

        return WeatherAlertItem(
            id: identifier,
            temperatureThresholdCelsius: temperatureValue,
            windThresholdKmh: windValue,
            rainEnabled: rainEnabled,
            snowEnabled: snowEnabled,
            severeWeatherEnabled: severeEnabled,
            windAlertEnabled: windAlertEnabled,
            locationLabel: locationField.trimmingCharacters(in: .whitespacesAndNewlines),
            quietHoursEnabled: quietHoursEnabled,
            quietStartMinute: startMinute,
            quietEndMinute: endMinute,
            warmFeelingEnabled: warmFeelingEnabled,
            warmFeelingThresholdCelsius: warmThreshold,
            breezyFeelingEnabled: breezyFeelingEnabled,
            breezyFeelingWindKmh: breezyWind
        )
    }

    private func formatNumber(_ value: Double) -> String {
        if abs(value.rounded() - value) < 0.01 {
            return String(Int(value.rounded()))
        }
        return String(format: "%.1f", value)
    }

    private func clampHour(_ value: Int) -> Int {
        min(23, max(0, value))
    }
}

extension AlertTemplateKind {
    @MainActor
    func apply(to model: Feature1ViewModel) {
        switch self {
        case .commute:
            model.resetDraft()
            model.locationField = model.locationField.isEmpty ? "Commute corridor" : model.locationField
            model.temperatureField = "4"
            model.windField = "45"
            model.rainEnabled = true
            model.snowEnabled = false
            model.severeEnabled = true
            model.windAlertEnabled = true
            model.warmFeelingEnabled = false
            model.breezyFeelingEnabled = true
            model.breezyFeelingWindField = "28"
            model.quietHoursEnabled = true
            model.quietStartHour = 21
            model.quietEndHour = 6
        case .garden:
            model.resetDraft()
            model.locationField = model.locationField.isEmpty ? "Back garden" : model.locationField
            model.temperatureField = "2"
            model.windField = "30"
            model.rainEnabled = true
            model.snowEnabled = true
            model.severeEnabled = false
            model.windAlertEnabled = true
            model.warmFeelingEnabled = false
            model.breezyFeelingEnabled = false
            model.quietHoursEnabled = false
        case .weekendTrip:
            model.resetDraft()
            model.locationField = model.locationField.isEmpty ? "Highway waypoint" : model.locationField
            model.temperatureField = "-1"
            model.windField = "55"
            model.rainEnabled = true
            model.snowEnabled = true
            model.severeEnabled = true
            model.windAlertEnabled = true
            model.warmFeelingEnabled = true
            model.warmFeelingThresholdField = "30"
            model.breezyFeelingEnabled = true
            model.breezyFeelingWindField = "35"
            model.quietHoursEnabled = true
            model.quietStartHour = 23
            model.quietEndHour = 8
        }
    }
}
