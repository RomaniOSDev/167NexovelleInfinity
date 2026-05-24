//
//  WeatherModels.swift
//  167NexovelleInfinity
//

import CoreGraphics
import Foundation

struct WeatherAlertItem: Codable, Identifiable, Equatable {
    var id: UUID
    var temperatureThresholdCelsius: Double
    var windThresholdKmh: Double
    var rainEnabled: Bool
    var snowEnabled: Bool
    var severeWeatherEnabled: Bool
    var windAlertEnabled: Bool
    var locationLabel: String

    /// Silence in-app banners during this daily window for this alert (reference + future reminders).
    var quietHoursEnabled: Bool
    var quietStartMinute: Int
    var quietEndMinute: Int

    /// “Too warm” comfort-style rule (temperature above threshold).
    var warmFeelingEnabled: Bool
    var warmFeelingThresholdCelsius: Double

    /// “Feels breezy” — wind above a separate lower threshold even if main wind alerts differ.
    var breezyFeelingEnabled: Bool
    var breezyFeelingWindKmh: Double

    init(
        id: UUID = UUID(),
        temperatureThresholdCelsius: Double,
        windThresholdKmh: Double,
        rainEnabled: Bool,
        snowEnabled: Bool,
        severeWeatherEnabled: Bool,
        windAlertEnabled: Bool,
        locationLabel: String,
        quietHoursEnabled: Bool = false,
        quietStartMinute: Int = 22 * 60,
        quietEndMinute: Int = 7 * 60,
        warmFeelingEnabled: Bool = false,
        warmFeelingThresholdCelsius: Double = 28,
        breezyFeelingEnabled: Bool = false,
        breezyFeelingWindKmh: Double = 22
    ) {
        self.id = id
        self.temperatureThresholdCelsius = temperatureThresholdCelsius
        self.windThresholdKmh = windThresholdKmh
        self.rainEnabled = rainEnabled
        self.snowEnabled = snowEnabled
        self.severeWeatherEnabled = severeWeatherEnabled
        self.windAlertEnabled = windAlertEnabled
        self.locationLabel = locationLabel
        self.quietHoursEnabled = quietHoursEnabled
        self.quietStartMinute = Self.clampMinutes(quietStartMinute)
        self.quietEndMinute = Self.clampMinutes(quietEndMinute)
        self.warmFeelingEnabled = warmFeelingEnabled
        self.warmFeelingThresholdCelsius = warmFeelingThresholdCelsius
        self.breezyFeelingEnabled = breezyFeelingEnabled
        self.breezyFeelingWindKmh = breezyFeelingWindKmh
    }

    enum CodingKeys: String, CodingKey {
        case id
        case temperatureThresholdCelsius
        case windThresholdKmh
        case rainEnabled
        case snowEnabled
        case severeWeatherEnabled
        case windAlertEnabled
        case locationLabel
        case quietHoursEnabled
        case quietStartMinute
        case quietEndMinute
        case warmFeelingEnabled
        case warmFeelingThresholdCelsius
        case breezyFeelingEnabled
        case breezyFeelingWindKmh
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        temperatureThresholdCelsius = try c.decode(Double.self, forKey: .temperatureThresholdCelsius)
        windThresholdKmh = try c.decode(Double.self, forKey: .windThresholdKmh)
        rainEnabled = try c.decode(Bool.self, forKey: .rainEnabled)
        snowEnabled = try c.decode(Bool.self, forKey: .snowEnabled)
        severeWeatherEnabled = try c.decode(Bool.self, forKey: .severeWeatherEnabled)
        windAlertEnabled = try c.decode(Bool.self, forKey: .windAlertEnabled)
        locationLabel = try c.decode(String.self, forKey: .locationLabel)
        quietHoursEnabled = try c.decodeIfPresent(Bool.self, forKey: .quietHoursEnabled) ?? false
        quietStartMinute = Self.clampMinutes(try c.decodeIfPresent(Int.self, forKey: .quietStartMinute) ?? (22 * 60))
        quietEndMinute = Self.clampMinutes(try c.decodeIfPresent(Int.self, forKey: .quietEndMinute) ?? (7 * 60))
        warmFeelingEnabled = try c.decodeIfPresent(Bool.self, forKey: .warmFeelingEnabled) ?? false
        warmFeelingThresholdCelsius = try c.decodeIfPresent(Double.self, forKey: .warmFeelingThresholdCelsius) ?? 28
        breezyFeelingEnabled = try c.decodeIfPresent(Bool.self, forKey: .breezyFeelingEnabled) ?? false
        breezyFeelingWindKmh = try c.decodeIfPresent(Double.self, forKey: .breezyFeelingWindKmh) ?? 22
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(temperatureThresholdCelsius, forKey: .temperatureThresholdCelsius)
        try c.encode(windThresholdKmh, forKey: .windThresholdKmh)
        try c.encode(rainEnabled, forKey: .rainEnabled)
        try c.encode(snowEnabled, forKey: .snowEnabled)
        try c.encode(severeWeatherEnabled, forKey: .severeWeatherEnabled)
        try c.encode(windAlertEnabled, forKey: .windAlertEnabled)
        try c.encode(locationLabel, forKey: .locationLabel)
        try c.encode(quietHoursEnabled, forKey: .quietHoursEnabled)
        try c.encode(quietStartMinute, forKey: .quietStartMinute)
        try c.encode(quietEndMinute, forKey: .quietEndMinute)
        try c.encode(warmFeelingEnabled, forKey: .warmFeelingEnabled)
        try c.encode(warmFeelingThresholdCelsius, forKey: .warmFeelingThresholdCelsius)
        try c.encode(breezyFeelingEnabled, forKey: .breezyFeelingEnabled)
        try c.encode(breezyFeelingWindKmh, forKey: .breezyFeelingWindKmh)
    }

    private static func clampMinutes(_ value: Int) -> Int {
        min(1439, max(0, value))
    }

    func formattedQuietInterval() -> String {
        Self.formatMinutePair(start: quietStartMinute, end: quietEndMinute)
    }

    private static func formatMinutePair(start: Int, end: Int) -> String {
        let s = clampMinutes(start)
        let e = clampMinutes(end)
        return "\(formatHM(s)) – \(formatHM(e))"
    }

    private static func formatHM(_ minutes: Int) -> String {
        let h = minutes / 60
        let m = minutes % 60
        return String(format: "%d:%02d", h, m)
    }

    var conditionSummaryLines: [String] {
        var lines: [String] = []
        if rainEnabled { lines.append("Rain alert") }
        if snowEnabled { lines.append("Snow alert") }
        if severeWeatherEnabled { lines.append("Severe weather alert") }
        if windAlertEnabled {
            lines.append("Wind above \(Int(windThresholdKmh)) km/h")
        }
        lines.append("Cold focus below \(Int(temperatureThresholdCelsius))°C")
        if warmFeelingEnabled {
            lines.append("Warm feeling above \(Int(warmFeelingThresholdCelsius))°C")
        }
        if breezyFeelingEnabled {
            lines.append("Breezy feeling above \(Int(breezyFeelingWindKmh)) km/h")
        }
        if quietHoursEnabled {
            lines.append("Quiet hours \(formattedQuietInterval())")
        }
        if !locationLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            lines.append("Location label: \(locationLabel)")
        }
        return lines
    }
}

struct WeatherRecord: Codable, Identifiable, Equatable {
    var id: UUID
    var date: Date
    var highTemperatureCelsius: Double
    var lowTemperatureCelsius: Double
    var precipitationMillimeters: Double
    var cloudCoverPercent: Double
    var locationLabel: String

    init(
        id: UUID = UUID(),
        date: Date,
        highTemperatureCelsius: Double,
        lowTemperatureCelsius: Double,
        precipitationMillimeters: Double,
        cloudCoverPercent: Double,
        locationLabel: String
    ) {
        self.id = id
        self.date = date
        self.highTemperatureCelsius = highTemperatureCelsius
        self.lowTemperatureCelsius = lowTemperatureCelsius
        self.precipitationMillimeters = precipitationMillimeters
        self.cloudCoverPercent = cloudCoverPercent
        self.locationLabel = locationLabel
    }

    func summaryDescription(locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateStyle = .medium
        let header = formatter.string(from: date)
        return "\(header): \(Int(lowTemperatureCelsius))–\(Int(highTemperatureCelsius))°C, \(Int(precipitationMillimeters)) mm precip., \(Int(cloudCoverPercent))% clouds."
    }

    func hourlyTemperatureSamples(count: Int = 12) -> [CGFloat] {
        guard count > 1 else { return [CGFloat(highTemperatureCelsius)] }
        let low = CGFloat(lowTemperatureCelsius)
        let high = CGFloat(highTemperatureCelsius)
        return (0 ..< count).map { index in
            let t = CGFloat(index) / CGFloat(count - 1)
            let eased = sin(t * .pi / 2)
            return low + (high - low) * eased
        }
    }
}

/// Latest manual snapshot remembered per normalized location label.
struct LocationMemorySnapshot: Codable, Equatable, Identifiable {
    var locationKey: String
    var updatedAt: Date
    var userFeelingNote: String
    var lastHighCelsius: Double?
    var lastLowCelsius: Double?
    var lastPrecipitationMm: Double?

    var id: String { locationKey }
}

enum AlertTemplateKind: String, CaseIterable, Identifiable {
    case commute
    case garden
    case weekendTrip

    var id: String { rawValue }

    var shortTitle: String {
        switch self {
        case .commute:
            return "Commute"
        case .garden:
            return "Garden"
        case .weekendTrip:
            return "Weekend trip"
        }
    }

    var subtitle: String {
        switch self {
        case .commute:
            return "Rain + wind-ready city run"
        case .garden:
            return "Frost watch + drizzle"
        case .weekendTrip:
            return "Balanced getaway mix"
        }
    }
}

enum AchievementCatalog {
    struct Definition: Identifiable {
        let id: String
        let title: String
        let detail: String
        let isHidden: Bool

        init(id: String, title: String, detail: String, isHidden: Bool = false) {
            self.id = id
            self.title = title
            self.detail = detail
            self.isHidden = isHidden
        }
    }

    static let all: [Definition] = [
        Definition(id: "first_alert", title: "First Alert", detail: "Set your first weather alert."),
        Definition(id: "daily_tracker", title: "Daily Tracker", detail: "Stay active for seven consecutive days."),
        Definition(id: "weather_enthusiast", title: "Weather Enthusiast", detail: "Stay active for thirty consecutive days."),
        Definition(id: "weekly_planner", title: "Weekly Planner", detail: "Reach twenty-eight cumulative sessions."),
        Definition(id: "persistent_observer", title: "Persistent Observer", detail: "Reach fifty cumulative sessions."),
        Definition(id: "alert_guru", title: "Alert Guru", detail: "Create ten alerts over time."),
        Definition(id: "climate_analyst", title: "Climate Analyst", detail: "Reach twenty cumulative sessions."),
        Definition(id: "location_master", title: "Location Master", detail: "Track five unique locations."),
        Definition(id: "ritual_beginner", title: "Ritual Beginner", detail: "Complete your first daily checklist.", isHidden: true),
        Definition(id: "ritual_regular", title: "Ritual Regular", detail: "Finish the daily checklist on seven separate days.", isHidden: true),
        Definition(id: "pattern_observer", title: "Pattern Observer", detail: "Log weather on ten unique days.", isHidden: true),
        Definition(id: "memory_archivist", title: "Memory Archivist", detail: "Write feeling notes for three locations.", isHidden: true),
        Definition(id: "template_traveler", title: "Template Traveler", detail: "Create an alert from a quick template.", isHidden: true),
    ]

    static func definitionsToDisplay(isUnlocked: (String) -> Bool) -> [Definition] {
        all.filter { def in !def.isHidden || isUnlocked(def.id) }
    }
}
