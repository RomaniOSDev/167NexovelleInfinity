//
//  PlannerShellView.swift
//  167NexovelleInfinity
//

import SwiftUI

private enum PlannerSegment: String, CaseIterable, Identifiable {
    case settings
    case insights

    var id: String { rawValue }

    var title: String {
        switch self {
        case .settings:
            return "Alert Settings"
        case .insights:
            return "Insights"
        }
    }
}

struct PlannerShellView: View {
    @State private var segment: PlannerSegment = .settings

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 5) {
                ForEach(PlannerSegment.allCases) { option in
                    Button {
                        withAnimation(.easeInOut(duration: 0.22)) {
                            segment = option
                        }
                    } label: {
                        Text(option.capsuleTitle)
                            .font(.caption.weight(.bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)
                            .foregroundStyle(segment == option ? Color.appBackground : Color.appTextSecondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 11)
                            .frame(maxWidth: .infinity)
                            .background(
                                Capsule()
                                    .fill(segment == option ? Color.appPrimary : Color.clear)
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.appAccent.opacity(segment == option ? 0.55 : 0), lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(.tapFeedback)
                }
            }
            .padding(6)
            .background(
                Capsule()
                    .fill(Color.appSurface.opacity(0.58))
                    .overlay(Capsule().stroke(Color.appAccent.opacity(0.38), lineWidth: 1))
            )
            .padding(.horizontal, 22)
            .padding(.top, 12)

            Group {
                switch segment {
                case .settings:
                    Feature2View()
                case .insights:
                    Feature3View()
                }
            }
            .animation(.easeInOut(duration: 0.22), value: segment)

            Spacer(minLength: 0)
        }
        .navigationTitle(segment.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension PlannerSegment {
    var capsuleTitle: String {
        switch self {
        case .settings:
            return "Settings"
        case .insights:
            return "Insights"
        }
    }
}
