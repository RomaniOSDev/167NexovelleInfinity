//
//  RootTab.swift
//  167NexovelleInfinity
//

import SwiftUI

enum RootTab: Int, CaseIterable, Identifiable {
    case home
    case alerts
    case planner
    case achievements
    case settings

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home:
            return "Home"
        case .alerts:
            return "Alerts"
        case .planner:
            return "Planner"
        case .achievements:
            return "Achievements"
        case .settings:
            return "Settings"
        }
    }

    var symbolName: String {
        switch self {
        case .home:
            return "house.fill"
        case .alerts:
            return "bell.fill"
        case .planner:
            return "calendar.circle.fill"
        case .achievements:
            return "trophy.fill"
        case .settings:
            return "gearshape.fill"
        }
    }
}
