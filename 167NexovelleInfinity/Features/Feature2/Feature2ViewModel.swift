//
//  Feature2ViewModel.swift
//  167NexovelleInfinity
//

import Combine
import Foundation

@MainActor
final class Feature2ViewModel: ObservableObject {
    @Published var rain = false
    @Published var snow = false
    @Published var severe = false
    @Published var wind = false
    @Published var sensitivity: Double = 0.5
    @Published var masterEnabled = true

    func load(from store: AppStorageStore) {
        rain = store.prefsRain
        snow = store.prefsSnow
        severe = store.prefsSevere
        wind = store.prefsWind
        sensitivity = store.sensitivityLevel
        masterEnabled = store.preferencesMasterEnabled
    }

    func persist(using store: AppStorageStore, markConfigured: Bool) {
        store.savePreferences(
            rain: rain,
            snow: snow,
            severe: severe,
            wind: wind,
            sensitivity: sensitivity,
            masterEnabled: masterEnabled,
            markConfigured: markConfigured
        )
    }
}
