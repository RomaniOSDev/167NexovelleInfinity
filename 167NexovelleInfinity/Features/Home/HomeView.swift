//
//  HomeView.swift
//  167NexovelleInfinity
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: AppStorageStore

    var selectTab: (RootTab) -> Void

    private let widgetColumns: [GridItem] = [
        GridItem(.flexible(minimum: 0, maximum: .infinity), spacing: 14, alignment: .top),
        GridItem(.flexible(minimum: 0, maximum: .infinity), spacing: 14, alignment: .top),
    ]

    private var enabledAlertsCount: Int {
        store.weatherAlerts.filter { store.enabledAlertIDs.contains($0.id) }.count
    }

    private var trophiesUnlocked: Int {
        AchievementCatalog.all.reduce(0) { count, definition in
            count + (store.isAchievementUnlocked(id: definition.id) ? 1 : 0)
        }
    }

    private var latestInsight: WeatherRecord? {
        store.weatherRecords.first
    }

    var body: some View {
        ZStack {
            LayeredWeatherBackground()

            GeometryReader { geo in
                let measuredWidth = geo.size.width.isFinite && geo.size.width > 0 ? geo.size.width : 393
                let safeWidth = min(measuredWidth, 1024)
                let contentWidth = max(0, safeWidth - 36)
                let heroHeight = min(220, max(176, safeWidth * 0.5))

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        heroHeader(width: contentWidth, height: heroHeight)

                        dailyRhythmStrip

                        sceneStripSection

                        Text("Shortcuts")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.appTextSecondary)
                            .tracking(1.05)

                        LazyVGrid(columns: widgetColumns, spacing: 14) {
                            HomeShortcutTile(
                                title: "Alerts",
                                subtitle: "\(enabledAlertsCount)/\(store.weatherAlerts.count) active",
                                systemImage: "bell.badge.fill",
                                tint: LinearGradient(colors: [Color.appPrimary, Color.appAccent.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            ) {
                                FeedbackCentral.tapLight()
                                selectTab(.alerts)
                            }

                            HomeShortcutTile(
                                title: "Planner",
                                subtitle: store.trackingEnabled ? "Tracking on" : "Tracking off",
                                systemImage: "calendar.badge.plus",
                                tint: LinearGradient(colors: [Color.appAccent.opacity(0.92), Color.appPrimary.opacity(0.75)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            ) {
                                FeedbackCentral.tapLight()
                                selectTab(.planner)
                            }

                            HomeShortcutTile(
                                title: "Goals",
                                subtitle: "\(trophiesUnlocked)/\(AchievementCatalog.all.count) unlocked",
                                systemImage: "trophy.circle.fill",
                                tint: LinearGradient(colors: [Color.appPrimary.opacity(0.88), Color.appSurface.opacity(0.9)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            ) {
                                FeedbackCentral.tapLight()
                                selectTab(.achievements)
                            }

                            HomeShortcutTile(
                                title: "Settings",
                                subtitle: store.globalQuietHoursEnabled ? "Quiet hours set" : "Always celebrate",
                                systemImage: "gearshape.circle.fill",
                                tint: LinearGradient(colors: [Color.appSurface.opacity(0.82), Color.appAccent.opacity(0.55)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            ) {
                                FeedbackCentral.tapLight()
                                selectTab(.settings)
                            }
                        }

                        insightSnapshotCard

                        footerTip
                    }
                    .frame(width: contentWidth, alignment: .leading)
                    .padding(.top, 2)
                    .padding(.bottom, 8)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .clipped()
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarBackground(Color.clear, for: .navigationBar)
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func heroHeader(width: CGFloat, height: CGFloat) -> some View {
        ZStack(alignment: .bottomLeading) {
            ZStack {
                Image("HomeBackdrop")
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .clipped()

                HomeWeatherHeroArtwork()
                    .frame(width: width, height: height)
                    .allowsHitTesting(false)
                    .opacity(0.5)
                    .clipped()
            }
            .frame(width: width, height: height)
            .clipped()
            .clipShape(Rectangle())

            VStack(spacing: 0) {
                Spacer(minLength: 0)
                LinearGradient(colors: [.clear, Color.black.opacity(0.52)], startPoint: .top, endPoint: .bottom)
                    .frame(height: max(86, height * 0.46))
                    .allowsHitTesting(false)
            }
            .frame(width: width, height: height)

            VStack(alignment: .leading, spacing: 8) {
                Text(greetingLine)
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color.appTextPrimary)
                    .shadow(color: Color.black.opacity(0.55), radius: 8, y: 4)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
                Text(Date(), format: Date.FormatStyle(date: .complete, time: .shortened))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appBackground.opacity(0.95))
                    .shadow(color: Color.black.opacity(0.48), radius: 6, y: 3)
                    .minimumScaleFactor(0.82)
                    .lineLimit(2)
            }
            .padding(.horizontal, 22)
            .padding(.bottom, max(12, height * 0.08))
            .padding(.top, 8)
        }
        .frame(width: width, height: height, alignment: .center)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .clipped()
        .overlay(alignment: .topTrailing) {
            if store.globalQuietHoursEnabled {
                Label("Quiet", systemImage: "moon.zzz.fill")
                    .font(.caption2.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .foregroundStyle(Color.appBackground)
                    .background(Color.black.opacity(0.35))
                    .clipShape(Capsule())
                    .padding(16)
            }
        }
    }

    private var greetingLine: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let name = "nexovelle"
        switch hour {
        case 5 ..< 12:
            return "Good morning, \(name)"
        case 12 ..< 17:
            return "Good afternoon, \(name)"
        case 17 ..< 23:
            return "Good evening, \(name)"
        default:
            return "Still up? Stay cozy"
        }
    }

    private var dailyRhythmStrip: some View {
        GlassPanel(contentSpacing: 14) {
            Text("Today's rhythm")
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)

            HStack(spacing: 12) {
                HomeMiniRing(title: "Alerts", done: store.dailyGoalsChecks.alertsVisited, symbol: "bell.fill") {
                    selectTab(.alerts)
                }
                HomeMiniRing(title: "Planner", done: store.dailyGoalsChecks.insightsVisited, symbol: "calendar") {
                    selectTab(.planner)
                }
                HomeMiniRing(title: "Create", done: store.dailyGoalsChecks.contributed, symbol: "plus.circle.fill") {
                    selectTab(.planner)
                }
            }

            HStack(spacing: 14) {
                MetricChip(title: "Streak", value: "\(store.streakDays)d", systemImage: "flame.fill")
                MetricChip(title: "Insights", value: "\(store.weatherRecords.count)", systemImage: "chart.line.uptrend.xyaxis")
            }
        }
    }

    private var sceneStripSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Featured looks")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.appTextSecondary)
                .tracking(1.1)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    HomeFeaturedSceneCard(
                        title: "Sunrise runway",
                        caption: "Open planner & log vibes",
                        systemImage: "sun.max.fill",
                        gradientColors: [.orange.opacity(0.95), Color.appAccent.opacity(0.55), Color.appPrimary.opacity(0.45)]
                    ) {
                        selectTab(.planner)
                    }

                    HomeFeaturedSceneCard(
                        title: "Rain desk",
                        caption: "Tune rain + wind cues",
                        systemImage: "cloud.rain.fill",
                        gradientColors: [Color.appPrimary.opacity(0.85), Color.appAccent.opacity(0.55), Color.appSurface.opacity(0.9)]
                    ) {
                        selectTab(.alerts)
                    }

                    HomeFeaturedSceneCard(
                        title: "Breeze scout",
                        caption: "Stack weekly reviews",
                        systemImage: "wind",
                        gradientColors: [Color.appAccent.opacity(0.7), Color.appBackground.opacity(0.75), Color.appPrimary.opacity(0.5)]
                    ) {
                        selectTab(.planner)
                    }
                }
                .padding(.vertical, 2)
                .padding(.trailing, 4)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 214, alignment: .center)
            .clipped()
        }
    }

    @ViewBuilder
    private var insightSnapshotCard: some View {
        if let record = latestInsight {
            GlassPanel {
                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.appAccent.opacity(0.32))
                            .frame(width: 78, height: 78)

                        Image(systemName: "note.text")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(Color.appTextPrimary.opacity(0.95))
                            .shadow(color: Color.appPrimary.opacity(0.45), radius: 10, y: 4)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Latest insight")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.appTextSecondary)

                        Text(record.summaryDescription())
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Color.appTextPrimary)
                            .lineLimit(3)

                        SecondaryOutlineButton(title: "Dig into planner →") {
                            selectTab(.planner)
                        }
                    }
                }
            }
        }
    }

    private var footerTip: some View {
        Text("Tip: Replace HomeBackdrop.png in Assets for your own skyline or brand photo—it pairs with the live SwiftUI skyline layer.")
            .font(.caption2.weight(.medium))
            .foregroundStyle(Color.appTextSecondary.opacity(0.92))
            .padding(.horizontal, 4)
    }
}

// MARK: - Illustrated hero (embedded “image” artwork)

private struct HomeWeatherHeroArtwork: View {
    private var ambientColors: [Color] {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5 ..< 10:
            return [
                Color.appAccent.opacity(0.65),
                Color.appPrimary.opacity(0.92),
                Color.appBackground.opacity(0.92),
            ]
        case 10 ..< 18:
            return [
                Color.appPrimary.opacity(0.65),
                Color.appAccent.opacity(0.92),
                Color.appSurface.opacity(0.85),
            ]
        default:
            return [
                Color.appPrimary.opacity(0.92),
                Color.black.opacity(0.35),
                Color.appAccent.opacity(0.72),
            ]
        }
    }

    var body: some View {
        Canvas { ctx, sz in
            let skyRect = CGRect(origin: .zero, size: sz)
            ctx.fill(
                Rectangle().path(in: skyRect),
                with: .linearGradient(
                    Gradient(colors: ambientColors),
                    startPoint: CGPoint(x: skyRect.minX + skyRect.width * 0.05, y: skyRect.maxY),
                    endPoint: CGPoint(x: skyRect.maxX * 1.02, y: skyRect.minY + 40)
                )
            )

            let sunPt = CGPoint(x: sz.width * 0.78, y: sz.height * 0.22)
            let haloR = sz.width * 0.21
            ctx.fill(
                Path(ellipseIn: CGRect(x: sunPt.x - haloR, y: sunPt.y - haloR, width: haloR * 2, height: haloR * 2)),
                with: .radialGradient(
                    Gradient(colors: [
                        Color.appAccent.opacity(0.7),
                        Color.appAccent.opacity(0),
                    ]),
                    center: sunPt,
                    startRadius: 0,
                    endRadius: haloR
                )
            )

            let sunDiameter = sz.width * 0.095
            ctx.fill(
                Path(ellipseIn: CGRect(x: sunPt.x - sunDiameter / 2, y: sunPt.y - sunDiameter / 2, width: sunDiameter, height: sunDiameter)),
                with: .color(Color.appBackground.opacity(0.98))
            )

            let skylineY = sz.height * 0.53
            var wave = Path()
            wave.move(to: CGPoint(x: 0, y: sz.height))
            wave.addLine(to: CGPoint(x: 0, y: skylineY))
            for step in stride(from: CGFloat(0), through: sz.width + 16, by: 42) {
                let cp1 = CGPoint(x: step + 12, y: skylineY + sin(step / sz.width * 4) * 16)
                let cp2 = CGPoint(x: step + 34, y: skylineY - cos(step / sz.width * 7) * 18)
                let end = CGPoint(x: step + 42, y: skylineY)
                wave.addCurve(to: end, control1: cp1, control2: cp2)
            }
            wave.addLine(to: CGPoint(x: sz.width, y: sz.height))
            wave.closeSubpath()
            ctx.fill(wave, with: .linearGradient(.init(colors: [Color.black.opacity(0.14), Color.appSurface.opacity(0.55)]), startPoint: .zero, endPoint: CGPoint(x: 0, y: sz.height)))

            let cloudTone = Gradient(colors: [
                Color.appBackground.opacity(0.95),
                Color.appPrimary.opacity(0.45),
                Color.appAccent.opacity(0.35),
            ])

            cloudLayer(ctx: ctx, anchor: CGPoint(x: sz.width * 0.2, y: sz.height * 0.35), scale: sz.width / 390, tint: cloudTone)

            rainLayer(ctx: ctx, size: sz)
        }
        .accessibilityHidden(true)
    }

    private func puff(_ ctx: GraphicsContext, center: CGPoint, r: CGFloat) {
        ctx.fill(Path(ellipseIn: CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)), with: .color(.white.opacity(0.94)))
    }

    private func cloudLayer(ctx: GraphicsContext, anchor: CGPoint, scale: CGFloat, tint: Gradient) {
        let r = CGFloat(22) * scale
        puff(ctx, center: CGPoint(x: anchor.x, y: anchor.y), r: r * 1.15)
        puff(ctx, center: CGPoint(x: anchor.x + r * 2.05, y: anchor.y), r: r * 1.45)
        puff(ctx, center: CGPoint(x: anchor.x + r * 4, y: anchor.y), r: r * 1.2)
        let cloudRect = CGRect(x: anchor.x - r * 0.95, y: anchor.y + r * 0.06, width: r * 5.7, height: r * 1.1)
        ctx.fill(Path(roundedRect: cloudRect, cornerRadius: r * 0.9), with: .linearGradient(tint, startPoint: cloudRect.origin, endPoint: CGPoint(x: cloudRect.maxX, y: cloudRect.maxY)))
        puff(ctx, center: CGPoint(x: anchor.x + r * 0.62, y: anchor.y), r: r * 0.94)
        puff(ctx, center: CGPoint(x: anchor.x + r * 3.52, y: anchor.y - r * 0.18), r: r * 1.2)
        puff(ctx, center: CGPoint(x: anchor.x + r * 2.16, y: anchor.y + r * 0.92), r: r * 1.58)
        puff(ctx, center: CGPoint(x: anchor.x + r * 3.94, y: anchor.y + r * 0.78), r: r * 1.52)
        puff(ctx, center: CGPoint(x: anchor.x + r * 1.24, y: anchor.y + r * 0.85), r: r * 1.54)
        puff(ctx, center: CGPoint(x: anchor.x + r * 0.94, y: anchor.y + r * 0.78), r: r * 1.22)
        puff(ctx, center: CGPoint(x: anchor.x + r * 2.94, y: anchor.y + r * 0.94), r: r * 1.6)
    }

    private func rainLayer(ctx: GraphicsContext, size: CGSize) {
        let hour = Calendar.current.component(.hour, from: Date())
        guard hour >= 20 || hour <= 7 else { return }
        var drip = Path()
        for idx in stride(from: 0, through: 18, by: 1) {
            let jitter = CGFloat(idx) / 18 * size.width + sin(CGFloat(idx) * 0.71) * 30
            let top = CGPoint(x: jitter + 110, y: size.height * 0.72 + CGFloat(idx * 11))
            let bot = CGPoint(x: top.x + CGFloat(idx % 3) - 2, y: top.y + CGFloat(42 + idx * 2))
            drip.move(to: top)
            drip.addLine(to: bot)
        }
        ctx.stroke(drip, with: .color(Color.white.opacity(0.22)), lineWidth: 1.3)
    }
}

// MARK: - Widget primitives

private struct HomeShortcutTile: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let tint: LinearGradient
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 28) {
                Image(systemName: systemImage)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(colors: [.white.opacity(0.98), Color.appBackground.opacity(0.85)], startPoint: .top, endPoint: .bottom)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text(subtitle)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(3)
                        .minimumScaleFactor(0.82)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 6)
                Image(systemName: "arrow.forward.circle.fill")
                    .foregroundStyle(Color.appAccent)
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 150, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(tint.opacity(0.75))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.appAccent.opacity(0.42), lineWidth: 1)
                    )
                    .overlay(alignment: .topTrailing) {
                        Circle()
                            .fill(Color.appAccent.opacity(0.22))
                            .frame(width: 38, height: 38)
                            .padding(10)
                            .allowsHitTesting(false)
                    }
            )
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .buttonStyle(.tapFeedback)
    }
}

private struct HomeMiniRing: View {
    let title: String
    let done: Bool
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .stroke(Color.appAccent.opacity(0.32), lineWidth: 10)
                    .frame(width: 68, height: 68)

                Circle()
                    .trim(from: 0, to: done ? 1 : 0.22)
                    .stroke(done ? Color.appPrimary : Color.appAccent.opacity(0.92), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 68, height: 68)
                    .animation(.easeInOut(duration: 0.32), value: done)

                VStack(spacing: 4) {
                    Image(systemName: symbol)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(done ? Color.appPrimary : Color.appTextSecondary)

                    Text(title)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                }
            }
        }
        .buttonStyle(.tapFeedback)
        .frame(maxWidth: .infinity)
    }
}

private struct HomeFeaturedSceneCard: View {
    let title: String
    let caption: String
    let systemImage: String
    let gradientColors: [Color]
    let tap: () -> Void

    var body: some View {
        Button {
            FeedbackCentral.tapLight()
            tap()
        } label: {
            VStack(alignment: .leading, spacing: 44) {
                Image(systemName: systemImage)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(Color.appBackground.opacity(0.96))
                    .shadow(color: Color.black.opacity(0.42), radius: 12, y: 8)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline.bold())
                        .foregroundStyle(Color.appBackground.opacity(0.98))
                        .shadow(color: Color.black.opacity(0.52), radius: 6, y: 4)
                    Text(caption)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.appBackground.opacity(0.94))
                        .shadow(color: Color.black.opacity(0.45), radius: 6, y: 4)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(18)
            .frame(width: 188, alignment: .leading)
            .background(
                LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(Color.appBackground.opacity(0.52), lineWidth: 2)
            )
            .overlay(alignment: .bottomTrailing) {
                Image(systemName: "arrow.forward.circle.fill")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.appBackground.opacity(0.94))
                    .padding(14)
            }
            .shadow(color: Color.black.opacity(0.26), radius: 10, y: 6)
        }
        .buttonStyle(.tapFeedback)
    }
}
