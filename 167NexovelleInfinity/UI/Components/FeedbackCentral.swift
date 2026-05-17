//
//  FeedbackCentral.swift
//  167NexovelleInfinity
//

import AudioToolbox
import SwiftUI
import UIKit

enum FeedbackCentral {
    static func tapLight() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func tapMedium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func notifySuccess() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func notifyWarning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    static func playSystemSound(_ identifier: SystemSoundID) {
        AudioServicesPlaySystemSound(identifier)
    }

    static func celebrateWorkflowCompletion() {
        notifySuccess()
        playSystemSound(1057)
    }

    static func playAchievementCelebration() {
        notifySuccess()
        playSystemSound(1057)
    }

    static func playSavedPing() {
        playSystemSound(1103)
    }

    static func playInsightSavedSound() {
        playSystemSound(1104)
    }

    static func playTickSound() {
        playSystemSound(1003)
    }
}
