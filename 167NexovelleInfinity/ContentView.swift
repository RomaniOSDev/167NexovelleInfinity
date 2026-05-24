//
//  ContentView.swift
//  167NexovelleInfinity
//

import Combine
import Foundation
import SwiftUI

struct ContentView: View {
    @ObservedObject private var store = AppStorageStore.shared
    @StateObject private var bannerQueue = AchievementBannerQueue()

    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            LayeredWeatherBackground()

            Group {
                if store.hasSeenOnboarding {
                    MainTabContainerView()
                } else {
                    OnboardingView()
                }
            }

            AchievementBannerOverlay(queue: bannerQueue)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .clipped()
        .background(Color.clear)
        .environmentObject(store)
        .environmentObject(bannerQueue)
        .onAppear {
            store.achievementBannerSink = bannerQueue
            bannerQueue.quietHoursBlocked = {
                AppStorageStore.shared.isGlobalQuietHoursActive()
            }
        }
        .onChange(of: scenePhase) { newPhase in
            store.handleScenePhaseChange(newPhase)
        }
        .onReceive(NotificationCenter.default.publisher(for: .dataReset)) { _ in
            bannerQueue.resetForSession()
            store.hydrateAfterResetNotification()
        }
    }
}

