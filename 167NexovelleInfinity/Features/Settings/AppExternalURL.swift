//
//  AppExternalURL.swift
//  167NexovelleInfinity
//

import Foundation
import UIKit

/// Central place for outbound links shown from Settings (replace example.com with production URLs).
enum AppExternalURL: String {
    case privacyPolicy = "https://nexovelleinfinity167.site/privacy/169"
    case termsOfUse = "https://nexovelleinfinity167.site/terms/169"

    /// Same pattern as Settings: guard + `UIApplication.shared.open`.
    func openInBrowser() {
        if let url = URL(string: rawValue) {
            UIApplication.shared.open(url)
        }
    }
}
