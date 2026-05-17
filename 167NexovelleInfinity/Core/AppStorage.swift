//
//  AppStorage.swift
//  167NexovelleInfinity
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class AppStorageStore: ObservableObject {
    static let shared = AppStorageStore()

    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()

    private enum Keys {
        static let hasSeenOnboarding = "ww.hasSeenOnboarding"
        static let weatherAlerts = "ww.weatherAlerts"
        static let enabledAlertIDs = "ww.enabledAlertIDs"
        static let alertsLastModified = "ww.alertsLastModified"

        static let prefsRain = "ww.prefsRain"
        static let prefsSnow = "ww.prefsSnow"
        static let prefsSevere = "ww.prefsSevere"
        static let prefsWind = "ww.prefsWind"
        static let sensitivityLevel = "ww.sensitivityLevel"
        static let preferencesMasterEnabled = "ww.preferencesMasterEnabled"
        static let hasSavedPreferencesOnce = "ww.hasSavedPreferencesOnce"

        static let weatherRecords = "ww.weatherRecords"
        static let trackingEnabled = "ww.trackingEnabled"

        static let totalAlertsEverCreated = "ww.totalAlertsEverCreated"
        static let totalSessionsCompleted = "ww.totalSessionsCompleted"
        static let totalMinutesUsed = "ww.totalMinutesUsed"
        static let streakDays = "ww.streakDays"
        static let lastActivityDate = "ww.lastActivityDate"
        static let lastStreakAnchorDay = "ww.lastStreakAnchorDay"
        static let achievementsUnlocked = "ww.achievementsUnlocked"
        static let trackedLocations = "ww.trackedLocations"
        static let weeklyReviewsCompleted = "ww.weeklyReviewsCompleted"
        static let insightAddsCompleted = "ww.insightAddsCompleted"
        static let foregroundSessions = "ww.foregroundSessions"

        static let globalQuietHoursEnabled = "ww.globalQuietHoursEnabled"
        static let globalQuietStartMinute = "ww.globalQuietStartMinute"
        static let globalQuietEndMinute = "ww.globalQuietEndMinute"
        static let locationMemoriesBlob = "ww.locationMemoriesBlob"
        static let dailyGoalsDay = "ww.dailyGoalsDay"
        static let dailyGoalsMask = "ww.dailyGoalsMask"
        static let dailyGoalsAwardedForDay = "ww.dailyGoalsAwardedForDay"
        static let dailyGoalsCompletionsTotal = "ww.dailyGoalsCompletionsTotal"
        static let templateApplicationsCount = "ww.templateApplicationsCount"
    }

    @Published private(set) var hasSeenOnboarding: Bool
    @Published private(set) var weatherAlerts: [WeatherAlertItem]
    @Published private(set) var enabledAlertIDs: Set<UUID>
    @Published private(set) var alertsLastModified: Date?

    @Published private(set) var prefsRain: Bool
    @Published private(set) var prefsSnow: Bool
    @Published private(set) var prefsSevere: Bool
    @Published private(set) var prefsWind: Bool
    @Published private(set) var sensitivityLevel: Double
    @Published private(set) var preferencesMasterEnabled: Bool
    @Published private(set) var hasSavedPreferencesOnce: Bool

    @Published private(set) var weatherRecords: [WeatherRecord]
    @Published private(set) var trackingEnabled: Bool

    @Published private(set) var totalAlertsEverCreated: Int
    @Published private(set) var totalSessionsCompleted: Int
    @Published private(set) var totalMinutesUsed: Int
    @Published private(set) var streakDays: Int
    @Published private(set) var lastActivityDate: Date?
    @Published private(set) var achievementsUnlocked: [String: Date]
    @Published private(set) var trackedLocations: Set<String>
    @Published private(set) var weeklyReviewsCompleted: Int
    @Published private(set) var insightAddsCompleted: Int
    @Published private(set) var foregroundSessions: Int

    @Published private(set) var globalQuietHoursEnabled: Bool
    @Published private(set) var globalQuietStartMinute: Int
    @Published private(set) var globalQuietEndMinute: Int

    @Published private(set) var locationMemories: [String: LocationMemorySnapshot]

    @Published private(set) var dailyGoalsMask: Int
    @Published private(set) var dailyGoalsCompletionsTotal: Int
    @Published private(set) var templateApplicationsCount: Int

    private var usageSessionAnchor: Date?
    private var previousScenePhase: ScenePhase = .inactive

    private var dailyGoalsAnchorDay: String
    private var dailyGoalsAwardedForCurrentDay: Bool

    weak var achievementBannerSink: AchievementBannerQueue?

    private init() {
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)

        let decodedAlerts: [WeatherAlertItem] = Self.decodeJSONArray(from: defaults.data(forKey: Keys.weatherAlerts)) ?? []
        weatherAlerts = decodedAlerts
        if let ids = defaults.array(forKey: Keys.enabledAlertIDs) as? [String] {
            enabledAlertIDs = Set(ids.compactMap { UUID(uuidString: $0) })
        } else {
            enabledAlertIDs = Set(decodedAlerts.map(\.id))
        }
        alertsLastModified = defaults.object(forKey: Keys.alertsLastModified) as? Date

        prefsRain = defaults.object(forKey: Keys.prefsRain) as? Bool ?? false
        prefsSnow = defaults.object(forKey: Keys.prefsSnow) as? Bool ?? false
        prefsSevere = defaults.object(forKey: Keys.prefsSevere) as? Bool ?? false
        prefsWind = defaults.object(forKey: Keys.prefsWind) as? Bool ?? false
        sensitivityLevel = defaults.object(forKey: Keys.sensitivityLevel) as? Double ?? 0.5
        preferencesMasterEnabled = defaults.object(forKey: Keys.preferencesMasterEnabled) as? Bool ?? true
        hasSavedPreferencesOnce = defaults.bool(forKey: Keys.hasSavedPreferencesOnce)

        let decodedRecords: [WeatherRecord] = Self.decodeJSONArray(from: defaults.data(forKey: Keys.weatherRecords)) ?? []
        weatherRecords = decodedRecords
        trackingEnabled = defaults.bool(forKey: Keys.trackingEnabled)

        totalAlertsEverCreated = defaults.integer(forKey: Keys.totalAlertsEverCreated)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = max(defaults.integer(forKey: Keys.streakDays), 0)
        lastActivityDate = defaults.object(forKey: Keys.lastActivityDate) as? Date

        achievementsUnlocked = Self.decodeAchievementMap(from: defaults.data(forKey: Keys.achievementsUnlocked)) ?? [:]

        if let locations = defaults.array(forKey: Keys.trackedLocations) as? [String] {
            trackedLocations = Set(locations.map { Self.normalizeLocation($0) }.filter { !$0.isEmpty })
        } else {
            trackedLocations = []
        }

        weeklyReviewsCompleted = defaults.integer(forKey: Keys.weeklyReviewsCompleted)
        insightAddsCompleted = defaults.integer(forKey: Keys.insightAddsCompleted)
        foregroundSessions = defaults.integer(forKey: Keys.foregroundSessions)

        globalQuietHoursEnabled = defaults.object(forKey: Keys.globalQuietHoursEnabled) as? Bool ?? false
        if defaults.object(forKey: Keys.globalQuietStartMinute) != nil {
            globalQuietStartMinute = Self.clampMinutes(defaults.integer(forKey: Keys.globalQuietStartMinute))
        } else {
            globalQuietStartMinute = 22 * 60
        }
        if defaults.object(forKey: Keys.globalQuietEndMinute) != nil {
            globalQuietEndMinute = Self.clampMinutes(defaults.integer(forKey: Keys.globalQuietEndMinute))
        } else {
            globalQuietEndMinute = 7 * 60
        }

        locationMemories = Self.decodeLocationMemories(from: defaults.data(forKey: Keys.locationMemoriesBlob)) ?? [:]

        let todayTag = Self.isoDayTag(for: Date())
        let savedGoalsDay = defaults.string(forKey: Keys.dailyGoalsDay) ?? ""
        if savedGoalsDay == todayTag {
            dailyGoalsMask = defaults.integer(forKey: Keys.dailyGoalsMask)
            dailyGoalsAwardedForCurrentDay = defaults.bool(forKey: Keys.dailyGoalsAwardedForDay)
        } else {
            dailyGoalsMask = 0
            dailyGoalsAwardedForCurrentDay = false
            defaults.set(todayTag, forKey: Keys.dailyGoalsDay)
            defaults.set(0, forKey: Keys.dailyGoalsMask)
            defaults.set(false, forKey: Keys.dailyGoalsAwardedForDay)
        }
        dailyGoalsAnchorDay = todayTag
        dailyGoalsCompletionsTotal = defaults.integer(forKey: Keys.dailyGoalsCompletionsTotal)
        templateApplicationsCount = defaults.integer(forKey: Keys.templateApplicationsCount)

        hydrateTrackedLocationsFromModelsIfNeeded()
    }

    func handleScenePhaseChange(_ phase: ScenePhase) {
        if phase == .active {
            if previousScenePhase != .active {
                usageSessionAnchor = Date()
                registerForegroundActivation()
                touchActivityForStreak()
            }
        } else if phase == .inactive || phase == .background {
            finalizeUsageMinutesSession()
        }
        previousScenePhase = phase
    }

    func completeOnboarding() {
        hasSeenOnboarding = true
        defaults.set(true, forKey: Keys.hasSeenOnboarding)
    }

    func upsertWeatherAlert(_ alert: WeatherAlertItem, isNew: Bool) {
        if let idx = weatherAlerts.firstIndex(where: { $0.id == alert.id }) {
            weatherAlerts[idx] = alert
        } else {
            weatherAlerts.insert(alert, at: 0)
            enabledAlertIDs.insert(alert.id)
            if isNew {
                totalAlertsEverCreated += 1
                defaults.set(totalAlertsEverCreated, forKey: Keys.totalAlertsEverCreated)
            }
        }
        alertsLastModified = Date()
        defaults.set(alertsLastModified, forKey: Keys.alertsLastModified)
        persistAlerts()
        registerLocationLabel(alert.locationLabel)
        if isNew {
            incrementSessions(by: 1)
            markPlannerContribution()
        }
        evaluateAchievements()
    }

    func deleteWeatherAlert(id: UUID) {
        weatherAlerts.removeAll { $0.id == id }
        enabledAlertIDs.remove(id)
        alertsLastModified = Date()
        defaults.set(alertsLastModified, forKey: Keys.alertsLastModified)
        persistAlerts()
        persistEnabledIDs()
        evaluateAchievements()
    }

    func toggleAlertEnabled(id: UUID, isOn: Bool) {
        if isOn {
            enabledAlertIDs.insert(id)
        } else {
            enabledAlertIDs.remove(id)
        }
        persistEnabledIDs()
    }

    func savePreferences(
        rain: Bool,
        snow: Bool,
        severe: Bool,
        wind: Bool,
        sensitivity: Double,
        masterEnabled: Bool,
        markConfigured: Bool
    ) {
        prefsRain = rain
        prefsSnow = snow
        prefsSevere = severe
        prefsWind = wind
        sensitivityLevel = sensitivity
        preferencesMasterEnabled = masterEnabled
        if markConfigured {
            hasSavedPreferencesOnce = true
            defaults.set(true, forKey: Keys.hasSavedPreferencesOnce)
        }

        defaults.set(prefsRain, forKey: Keys.prefsRain)
        defaults.set(prefsSnow, forKey: Keys.prefsSnow)
        defaults.set(prefsSevere, forKey: Keys.prefsSevere)
        defaults.set(prefsWind, forKey: Keys.prefsWind)
        defaults.set(sensitivityLevel, forKey: Keys.sensitivityLevel)
        defaults.set(preferencesMasterEnabled, forKey: Keys.preferencesMasterEnabled)

        incrementSessions(by: 1)
        evaluateAchievements()
    }

    func setTrackingEnabled(_ enabled: Bool) {
        trackingEnabled = enabled
        defaults.set(enabled, forKey: Keys.trackingEnabled)
        evaluateAchievements()
    }

    func addWeatherRecord(_ record: WeatherRecord) {
        weatherRecords.insert(record, at: 0)
        persistRecords()
        registerLocationLabel(record.locationLabel)
        mergeLocationSnapshot(from: record)
        insightAddsCompleted += 1
        defaults.set(insightAddsCompleted, forKey: Keys.insightAddsCompleted)
        incrementSessions(by: 1)
        markPlannerContribution()
        evaluateAchievements()
    }

    func deleteWeatherRecord(id: UUID) {
        weatherRecords.removeAll { $0.id == id }
        persistRecords()
        evaluateAchievements()
    }

    func registerWeeklyReviewCompletion() {
        weeklyReviewsCompleted += 1
        defaults.set(weeklyReviewsCompleted, forKey: Keys.weeklyReviewsCompleted)
        markPlannerContribution()
        incrementSessions(by: 1)
        evaluateAchievements()
    }

    func resetAllData() {
        let domain = Bundle.main.bundleIdentifier ?? ""
        defaults.removePersistentDomain(forName: domain)

        hasSeenOnboarding = false
        weatherAlerts = []
        enabledAlertIDs = []
        alertsLastModified = nil
        prefsRain = false
        prefsSnow = false
        prefsSevere = false
        prefsWind = false
        sensitivityLevel = 0.5
        preferencesMasterEnabled = true
        hasSavedPreferencesOnce = false
        weatherRecords = []
        trackingEnabled = false
        totalAlertsEverCreated = 0
        totalSessionsCompleted = 0
        totalMinutesUsed = 0
        streakDays = 0
        lastActivityDate = nil
        achievementsUnlocked = [:]
        trackedLocations = []
        weeklyReviewsCompleted = 0
        insightAddsCompleted = 0
        foregroundSessions = 0

        globalQuietHoursEnabled = false
        globalQuietStartMinute = 22 * 60
        globalQuietEndMinute = 7 * 60
        locationMemories = [:]
        dailyGoalsMask = 0
        dailyGoalsCompletionsTotal = 0
        templateApplicationsCount = 0
        dailyGoalsAnchorDay = Self.isoDayTag(for: Date())
        dailyGoalsAwardedForCurrentDay = false

        defaults.removeObject(forKey: Keys.lastStreakAnchorDay)

        NotificationCenter.default.post(name: .dataReset, object: nil)
        evaluateAchievements()
    }

    func hydrateAfterResetNotification() {
        objectWillChange.send()
    }

    func isGlobalQuietHoursActive(at moment: Date = Date()) -> Bool {
        guard globalQuietHoursEnabled else { return false }

        let calendar = Calendar.current
        let comps = calendar.dateComponents([.hour, .minute], from: moment)
        let minutesNow = (comps.hour ?? 0) * 60 + (comps.minute ?? 0)
        let start = globalQuietStartMinute
        let end = globalQuietEndMinute
        guard start != end else { return false }

        if start < end {
            return minutesNow >= start && minutesNow < end
        }

        return minutesNow >= start || minutesNow < end
    }

    func setGlobalQuietHoursPreference(enabled: Bool, startMinute: Int, endMinute: Int) {
        globalQuietHoursEnabled = enabled
        globalQuietStartMinute = Self.clampMinutes(startMinute)
        globalQuietEndMinute = Self.clampMinutes(endMinute)

        defaults.set(enabled, forKey: Keys.globalQuietHoursEnabled)
        defaults.set(globalQuietStartMinute, forKey: Keys.globalQuietStartMinute)
        defaults.set(globalQuietEndMinute, forKey: Keys.globalQuietEndMinute)
    }

    func registerTemplateComposerUse() {
        templateApplicationsCount += 1
        defaults.set(templateApplicationsCount, forKey: Keys.templateApplicationsCount)
        evaluateAchievements()
    }

    func updateLocationFeelingNote(locationKey: String, note: String) {
        let key = Self.normalizeLocation(locationKey)
        guard !key.isEmpty, var snapshot = locationMemories[key] else { return }

        snapshot.userFeelingNote = note
        snapshot.updatedAt = Date()
        locationMemories[key] = snapshot
        persistLocationMemories()
        evaluateAchievements()
    }

    var dailyGoalsChecks: (alertsVisited: Bool, insightsVisited: Bool, contributed: Bool) {
        (
            alertsVisited: dailyGoalsMask & 1 != 0,
            insightsVisited: dailyGoalsMask & 2 != 0,
            contributed: dailyGoalsMask & 4 != 0
        )
    }

    func markVisitedAlertsPlanner() {
        registerDailyGoalsProgress(maskBit: 1)
    }

    func markVisitedInsightsPlanner() {
        registerDailyGoalsProgress(maskBit: 2)
    }

    private func markPlannerContribution() {
        registerDailyGoalsProgress(maskBit: 4)
    }

    private func ensureDailyGoalsDayAlignment() {
        let today = Self.isoDayTag(for: Date())
        guard today != dailyGoalsAnchorDay else { return }

        dailyGoalsAnchorDay = today
        dailyGoalsMask = 0
        dailyGoalsAwardedForCurrentDay = false
        defaults.set(today, forKey: Keys.dailyGoalsDay)
        defaults.set(0, forKey: Keys.dailyGoalsMask)
        defaults.set(false, forKey: Keys.dailyGoalsAwardedForDay)
    }

    private func registerDailyGoalsProgress(maskBit: Int) {
        ensureDailyGoalsDayAlignment()
        if (dailyGoalsMask & maskBit) != 0 { return }

        dailyGoalsMask = dailyGoalsMask | maskBit
        defaults.set(dailyGoalsMask, forKey: Keys.dailyGoalsMask)

        guard dailyGoalsMask == 7, !dailyGoalsAwardedForCurrentDay else { return }

        dailyGoalsAwardedForCurrentDay = true
        dailyGoalsCompletionsTotal += 1
        defaults.set(true, forKey: Keys.dailyGoalsAwardedForDay)
        defaults.set(dailyGoalsCompletionsTotal, forKey: Keys.dailyGoalsCompletionsTotal)
        achievementBannerSink?.enqueue("Daily checklist completed — stellar consistency!")
        FeedbackCentral.playSavedPing()
        evaluateAchievements()
    }

    private func mergeLocationSnapshot(from record: WeatherRecord) {
        let key = Self.normalizeLocation(record.locationLabel)
        guard !key.isEmpty else { return }

        var snapshot = locationMemories[key] ?? LocationMemorySnapshot(
            locationKey: key,
            updatedAt: Date(),
            userFeelingNote: "",
            lastHighCelsius: nil,
            lastLowCelsius: nil,
            lastPrecipitationMm: nil
        )

        snapshot.updatedAt = Date()
        snapshot.lastHighCelsius = record.highTemperatureCelsius
        snapshot.lastLowCelsius = record.lowTemperatureCelsius
        snapshot.lastPrecipitationMm = record.precipitationMillimeters
        locationMemories[key] = snapshot
        persistLocationMemories()
    }

    private func persistLocationMemories() {
        if let data = try? encoder.encode(locationMemories) {
            defaults.set(data, forKey: Keys.locationMemoriesBlob)
        }
    }

    func uniqueManualLogDayCount() -> Int {
        let calendar = Calendar.current
        let tags = Set(weatherRecords.map { Self.isoDayTag(for: calendar.startOfDay(for: $0.date)) })
        return tags.count
    }

    func locationMemoriesWithNotesCount() -> Int {
        locationMemories.values.filter { snapshot in
            !snapshot.userFeelingNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }.count
    }

    var preferenceTypesPersistedDescription: [String] {
        var values: [String] = []
        if prefsRain { values.append("rain") }
        if prefsSnow { values.append("snow") }
        if prefsSevere { values.append("severe") }
        if prefsWind { values.append("wind") }
        return values
    }

    func isAchievementUnlocked(id: String) -> Bool {
        switch id {
        case "first_alert":
            return totalAlertsEverCreated >= 1
        case "daily_tracker":
            return streakDays >= 7
        case "weather_enthusiast":
            return streakDays >= 30
        case "weekly_planner":
            return totalSessionsCompleted >= 28
        case "persistent_observer":
            return totalSessionsCompleted >= 50
        case "alert_guru":
            return totalAlertsEverCreated >= 10
        case "climate_analyst":
            return totalSessionsCompleted >= 20
        case "location_master":
            return trackedLocations.count >= 5
        case "ritual_beginner":
            return dailyGoalsCompletionsTotal >= 1
        case "ritual_regular":
            return dailyGoalsCompletionsTotal >= 7
        case "pattern_observer":
            return uniqueManualLogDayCount() >= 10
        case "memory_archivist":
            return locationMemoriesWithNotesCount() >= 3
        case "template_traveler":
            return templateApplicationsCount >= 1
        default:
            return false
        }
    }

    func formattedAchievementProgress(for id: String) -> String {
        switch id {
        case "first_alert":
            return "\(min(totalAlertsEverCreated, 1))/1 alerts"
        case "daily_tracker":
            return "\(min(streakDays, 7))/7 days"
        case "weather_enthusiast":
            return "\(min(streakDays, 30))/30 days"
        case "weekly_planner":
            return "\(min(totalSessionsCompleted, 28))/28 sessions"
        case "persistent_observer":
            return "\(min(totalSessionsCompleted, 50))/50 sessions"
        case "alert_guru":
            return "\(min(totalAlertsEverCreated, 10))/10 alerts"
        case "climate_analyst":
            return "\(min(totalSessionsCompleted, 20))/20 sessions"
        case "location_master":
            return "\(min(trackedLocations.count, 5))/5 locations"
        case "ritual_beginner":
            return "\(min(dailyGoalsCompletionsTotal, 1))/1 day"
        case "ritual_regular":
            return "\(min(dailyGoalsCompletionsTotal, 7))/7 days"
        case "pattern_observer":
            return "\(min(uniqueManualLogDayCount(), 10))/10 log days"
        case "memory_archivist":
            return "\(min(locationMemoriesWithNotesCount(), 3))/3 notes"
        case "template_traveler":
            return "\(min(templateApplicationsCount, 1))/1 template"
        default:
            return ""
        }
    }

    private func incrementSessions(by value: Int) {
        totalSessionsCompleted += value
        defaults.set(totalSessionsCompleted, forKey: Keys.totalSessionsCompleted)
        evaluateAchievements()
    }

    private func registerForegroundActivation() {
        foregroundSessions += 1
        defaults.set(foregroundSessions, forKey: Keys.foregroundSessions)
        incrementSessions(by: 1)
    }

    private func finalizeUsageMinutesSession() {
        guard let anchor = usageSessionAnchor else { return }
        let minutes = Int(Date().timeIntervalSince(anchor) / 60)
        if minutes > 0 {
            totalMinutesUsed += minutes
            defaults.set(totalMinutesUsed, forKey: Keys.totalMinutesUsed)
        }
        usageSessionAnchor = nil
    }

    private func touchActivityForStreak() {
        lastActivityDate = Date()
        defaults.set(lastActivityDate, forKey: Keys.lastActivityDate)

        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]

        if let storedRaw = defaults.string(forKey: Keys.lastStreakAnchorDay),
           let storedDate = formatter.date(from: storedRaw) {
            let storedStart = calendar.startOfDay(for: storedDate)
            if calendar.isDate(storedStart, inSameDayAs: todayStart) {
                return
            }

            if let yesterdayStart = calendar.date(byAdding: .day, value: -1, to: todayStart),
               calendar.isDate(storedStart, inSameDayAs: yesterdayStart) {
                streakDays += 1
            } else {
                streakDays = 1
            }
        } else {
            streakDays = max(streakDays, 1)
        }

        defaults.set(formatter.string(from: todayStart), forKey: Keys.lastStreakAnchorDay)
        defaults.set(streakDays, forKey: Keys.streakDays)
        evaluateAchievements()
    }

    private func persistAlerts() {
        if let data = try? encoder.encode(weatherAlerts) {
            defaults.set(data, forKey: Keys.weatherAlerts)
        }
        persistEnabledIDs()
    }

    private func persistEnabledIDs() {
        let payload = enabledAlertIDs.map { $0.uuidString }
        defaults.set(payload, forKey: Keys.enabledAlertIDs)
    }

    private func persistRecords() {
        if let data = try? encoder.encode(weatherRecords) {
            defaults.set(data, forKey: Keys.weatherRecords)
        }
    }

    private func hydrateTrackedLocationsFromModelsIfNeeded() {
        guard trackedLocations.isEmpty else { return }
        var seeds: Set<String> = []
        for alert in weatherAlerts {
            let normalized = Self.normalizeLocation(alert.locationLabel)
            if !normalized.isEmpty { seeds.insert(normalized) }
        }
        for record in weatherRecords {
            let normalized = Self.normalizeLocation(record.locationLabel)
            if !normalized.isEmpty { seeds.insert(normalized) }
        }
        if !seeds.isEmpty {
            trackedLocations = seeds
            persistTrackedLocations()
        }
    }

    private func registerLocationLabel(_ raw: String) {
        let normalized = Self.normalizeLocation(raw)
        guard !normalized.isEmpty else { return }
        trackedLocations.insert(normalized)
        persistTrackedLocations()
    }

    private func persistTrackedLocations() {
        defaults.set(Array(trackedLocations), forKey: Keys.trackedLocations)
    }

    private func evaluateAchievements() {
        let previouslyUnlocked = achievementsUnlocked
        var updated = achievementsUnlocked

        for definition in AchievementCatalog.all where isAchievementUnlocked(id: definition.id) {
            if updated[definition.id] == nil {
                updated[definition.id] = Date()
                achievementBannerSink?.enqueue("Achievement unlocked — \(definition.title)")
                FeedbackCentral.playAchievementCelebration()
            }
        }

        if updated != previouslyUnlocked {
            achievementsUnlocked = updated
            if let data = try? encoder.encode(updated) {
                defaults.set(data, forKey: Keys.achievementsUnlocked)
            }
        }
    }

    private static func normalizeLocation(_ raw: String) -> String {
        raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private static func clampMinutes(_ value: Int) -> Int {
        min(1_439, max(0, value))
    }

    private static func isoDayTag(for date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter.string(from: date)
    }

    private static func decodeLocationMemories(from data: Data?) -> [String: LocationMemorySnapshot]? {
        guard let data else { return nil }
        return try? JSONDecoder().decode([String: LocationMemorySnapshot].self, from: data)
    }

    private static func decodeJSONArray<T: Decodable>(from data: Data?) -> [T]? {
        guard let data else { return nil }
        return try? JSONDecoder().decode([T].self, from: data)
    }

    private static func decodeAchievementMap(from data: Data?) -> [String: Date]? {
        guard let data else { return nil }
        return try? JSONDecoder().decode([String: Date].self, from: data)
    }
}
