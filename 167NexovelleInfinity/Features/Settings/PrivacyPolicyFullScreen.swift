//
//  PrivacyPolicyFullScreen.swift
//  167NexovelleInfinity
//

import SwiftUI

enum BundledMarkdown {
    static func privacyPolicyText() -> String {
        if let url = Bundle.main.url(forResource: "privacy_policy", withExtension: "md"),
           let data = try? Data(contentsOf: url),
           let decoded = String(data: data, encoding: .utf8) {
            return decoded
        }

        return """
        # Privacy Policy
        This app does NOT collect, store, or transmit any personal data.
        """
    }
}

struct PrivacyPolicyFullScreen: View {
    @Environment(\.dismiss) private var dismiss

    private let markdownText = BundledMarkdown.privacyPolicyText()

    var body: some View {
        NavigationStack {
            WeatherScreenRoot {
                ScrollView {
                    Group {
                        if let attributed = try? AttributedString(markdown: markdownText) {
                            Text(attributed)
                                .foregroundStyle(Color.appTextPrimary)
                                .tint(Color.appPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            Text(markdownText)
                                .foregroundStyle(Color.appTextPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(22)
                    .padding(.bottom, 36)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        FeedbackCentral.tapLight()
                        dismiss()
                    }
                    .buttonStyle(.tapFeedback)
                }
            }
        }
    }
}
