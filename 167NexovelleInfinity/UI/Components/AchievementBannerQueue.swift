//
//  AchievementBannerQueue.swift
//  167NexovelleInfinity
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class AchievementBannerQueue: ObservableObject {
    @Published private(set) var activeBannerText: String?

    private var pipeline: [String] = []
    private var isAnimating = false

    func enqueue(_ message: String) {
        if quietHoursBlocked() {
            return
        }
        pipeline.append(message)
        drainIfNeeded()
    }

    var quietHoursBlocked: () -> Bool = { false }

    private func drainIfNeeded() {
        guard !isAnimating else { return }
        guard let next = pipeline.first else {
            activeBannerText = nil
            return
        }
        pipeline.removeFirst()
        isAnimating = true
        activeBannerText = next

        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(2.0))
            guard let self else { return }
            self.activeBannerText = nil
            self.isAnimating = false
            self.drainIfNeeded()
        }
    }

    func resetForSession() {
        pipeline.removeAll()
        activeBannerText = nil
        isAnimating = false
    }
}
