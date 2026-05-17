//
//  Feature3ViewModel.swift
//  167NexovelleInfinity
//

import Combine
import Foundation

@MainActor
final class Feature3ViewModel: ObservableObject {
    @Published var dateSelection = Date()
    @Published var highTemperature = ""
    @Published var lowTemperature = ""
    @Published var precipitation = ""
    @Published var clouds = ""
    @Published var locationLabel = ""
    @Published var helperText = ""

    func resetDraft() {
        dateSelection = Date()
        highTemperature = ""
        lowTemperature = ""
        precipitation = ""
        clouds = ""
        locationLabel = ""
        helperText = ""
    }

    func buildRecord() -> WeatherRecord? {
        helperText = ""

        guard let high = Double(highTemperature.replacingOccurrences(of: ",", with: ".")),
              let low = Double(lowTemperature.replacingOccurrences(of: ",", with: ".")) else {
            helperText = "Enter numeric temperatures."
            return nil
        }

        guard high <= 55, high >= -60, low <= 55, low >= -60 else {
            helperText = "Temperature looks unrealistic."
            return nil
        }

        guard low <= high else {
            helperText = "Low temperature must be below the high."
            return nil
        }

        guard let precip = Double(precipitation.replacingOccurrences(of: ",", with: ".")),
              let cloudiness = Double(clouds.replacingOccurrences(of: ",", with: ".")) else {
            helperText = "Enter precipitation and cloud cover numerically."
            return nil
        }

        guard precip >= 0, precip <= 2500 else {
            helperText = "Precipitation must be between 0 and 2500 mm."
            return nil
        }

        guard cloudiness >= 0, cloudiness <= 100 else {
            helperText = "Cloud cover must be between 0 and 100."
            return nil
        }

        let trimmedLocation = locationLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedLocation.isEmpty else {
            helperText = "Add a location label for future comparisons."
            return nil
        }

        return WeatherRecord(
            date: dateSelection,
            highTemperatureCelsius: high,
            lowTemperatureCelsius: low,
            precipitationMillimeters: precip,
            cloudCoverPercent: cloudiness,
            locationLabel: trimmedLocation
        )
    }
}
