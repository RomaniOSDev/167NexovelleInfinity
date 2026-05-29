//
//  MainTabContainerView.swift
//  167NexovelleInfinity
//

import SwiftUI

struct MainTabContainerView: View {
    @State private var selectedTab: RootTab = .home

    var body: some View {
        ZStack {
            LayeredWeatherBackground()

            Group {
                switch selectedTab {
                case .home:
                    NavigationStack {
                        HomeView { selectedTab = $0 }
                    }
                    .background(Color.clear)
                    .toolbarBackground(.hidden, for: .navigationBar)
                    .toolbarBackground(Color.clear, for: .navigationBar)
                    .toolbar(.hidden, for: .navigationBar)
                case .alerts:
                    NavigationStack {
                        WeatherScreenRoot {
                            Feature1View()
                        }
                    }
                    .background(Color.clear)
                    .toolbarBackground(.hidden, for: .navigationBar)
                    .toolbarBackground(Color.clear, for: .navigationBar)
                    .toolbar(.hidden, for: .navigationBar)
                case .planner:
                    NavigationStack {
                        WeatherScreenRoot {
                            PlannerShellView()
                        }
                    }
                    .background(Color.clear)
                    .toolbarBackground(.hidden, for: .navigationBar)
                    .toolbarBackground(Color.clear, for: .navigationBar)
                    .toolbar(.hidden, for: .navigationBar)
                case .achievements:
                    NavigationStack {
                        WeatherScreenRoot {
                            AchievementsView()
                        }
                    }
                    .background(Color.clear)
                    .toolbarBackground(.hidden, for: .navigationBar)
                    .toolbarBackground(Color.clear, for: .navigationBar)
                    .toolbar(.hidden, for: .navigationBar)
                case .settings:
                    NavigationStack {
                        WeatherScreenRoot {
                            SettingsView()
                        }
                    }
                    .background(Color.clear)
                    .toolbarBackground(.hidden, for: .navigationBar)
                    .toolbarBackground(Color.clear, for: .navigationBar)
                    .toolbar(.hidden, for: .navigationBar)
                }
            }
            .transaction { transaction in
                transaction.animation = nil
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .clipped()
        .background(Color.appBackground)
        .safeAreaInset(edge: .bottom) {
            customTabBar
        }
    }

    private var customTabBar: some View {
        HStack(spacing: 6) {
            ForEach(RootTab.allCases) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: tab.symbolName)
                            .font(.system(size: 18, weight: .semibold))

                        Text(tab.title)
                            .font(.caption2.weight(.semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.38)
                            .multilineTextAlignment(.center)
                    }
                    .foregroundStyle(selectedTab == tab ? Color.appBackground : Color.appTextSecondary)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(selectedTab == tab ? Color.appPrimary : Color.appSurface.opacity(0.48))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.appAccent.opacity(selectedTab == tab ? 0.85 : 0.32), lineWidth: 1)
                    )
                    .scaleEffect(selectedTab == tab ? 1 : 0.96)
                    .animation(.spring(response: 0.38, dampingFraction: 0.78), value: selectedTab)
                }
                .buttonStyle(.tapFeedback)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.appSurface.opacity(0.42))
                .background(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.appAccent.opacity(0.45),
                            Color.appPrimary.opacity(0.22),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.22), radius: 20, x: 0, y: 12)
        .padding(.horizontal, 8)
        .padding(.bottom, 4)
    }
}
