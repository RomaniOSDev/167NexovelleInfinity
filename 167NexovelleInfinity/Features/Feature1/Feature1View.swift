//
//  Feature1View.swift
//  167NexovelleInfinity
//

import SwiftUI

struct Feature1View: View {
    @EnvironmentObject private var store: AppStorageStore

    @State private var showingComposer = false
    @State private var editingAlert: WeatherAlertItem?
    @State private var composerSeed: AlertTemplateKind?
    @State private var spotlightIdentifier: UUID?
    @State private var confirmationPulse = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    alertTemplateStrip

                    if store.weatherAlerts.isEmpty {
                        EmptyAlertsHero()
                            .padding(.top, 36)
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(store.weatherAlerts) { alert in
                                WeatherAlertSwipeCard(
                                    alert: alert,
                                    isSpotlit: spotlightIdentifier == alert.id,
                                    confirmationPulse: confirmationPulse && spotlightIdentifier == alert.id,
                                    onEdit: {
                                        FeedbackCentral.tapLight()
                                        editingAlert = alert
                                        composerSeed = nil
                                        showingComposer = true
                                    },
                                    onDelete: {
                                        FeedbackCentral.tapMedium()
                                        store.deleteWeatherAlert(id: alert.id)
                                        FeedbackCentral.celebrateWorkflowCompletion()
                                    }
                                )
                                .environmentObject(store)
                            }
                        }
                        .padding(.top, 12)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 96)
            }

            Button {
                FeedbackCentral.tapMedium()
                editingAlert = nil
                composerSeed = nil
                showingComposer = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.appBackground)
                    .frame(width: 56, height: 56)
                    .background(Color.appPrimary)
                    .clipShape(Circle())
                    .shadow(color: Color.appAccent.opacity(0.35), radius: 12, y: 6)
            }
            .buttonStyle(.tapFeedback)
            .padding(.trailing, 22)
            .padding(.bottom, 28)
            .accessibilityLabel("Add alert")
        }
        .navigationTitle("Alerts")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingComposer, onDismiss: {
            editingAlert = nil
            composerSeed = nil
        }) {
            AlertComposerSheet(existingAlert: editingAlert, seedTemplate: composerSeed)
                .environmentObject(store)
        }
        .onAppear {
            store.markVisitedAlertsPlanner()
        }
        .onReceive(NotificationCenter.default.publisher(for: .composerFinishedAlert)) { notification in
            guard
                let payload = notification.object as? [String: Any],
                let idString = payload["id"] as? String,
                let identifier = UUID(uuidString: idString),
                let isNew = payload["isNew"] as? Bool,
                isNew
            else {
                return
            }

            FeedbackCentral.tapLight()
            FeedbackCentral.playSavedPing()
            spotlightIdentifier = identifier
            withAnimation(.spring(response: 0.42, dampingFraction: 0.68)) {
                confirmationPulse = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.05) {
                confirmationPulse = false
                spotlightIdentifier = nil
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .dataReset)) { _ in
            spotlightIdentifier = nil
            confirmationPulse = false
        }
    }

    private var alertTemplateStrip: some View {
        GlassPanel(contentSpacing: 12) {
            ScreenSectionHeader(
                title: "Quick templates",
                subtitle: "Kick off a blueprint, then personalize thresholds.",
                systemImage: "sparkles.rectangle.stack.fill"
            )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(AlertTemplateKind.allCases) { template in
                        Button {
                            FeedbackCentral.tapLight()
                            composerSeed = template
                            editingAlert = nil
                            showingComposer = true
                        } label: {
                            HStack(spacing: 12) {
                                IconGlyph(symbol: templateKindIcon(template), size: 42)
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(template.shortTitle)
                                        .font(.subheadline.weight(.bold))
                                        .foregroundStyle(Color.appTextPrimary)
                                    Text(template.subtitle)
                                        .font(.caption)
                                        .foregroundStyle(Color.appTextSecondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .frame(width: 234, alignment: .leading)
                            .background(Color.appBackground.opacity(0.24))
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(Color.appAccent.opacity(0.45), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.tapFeedback)
                    }
                }
            }
        }
    }

    private func templateKindIcon(_ kind: AlertTemplateKind) -> String {
        switch kind {
        case .commute:
            return "car.side.fill"
        case .garden:
            return "leaf.fill"
        case .weekendTrip:
            return "suitcase.fill"
        }
    }
}

private struct EmptyAlertsHero: View {
    var body: some View {
        VStack(spacing: 22) {
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.appSurface.opacity(0.82))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(Color.appAccent.opacity(0.35), lineWidth: 1)
                    )

                Canvas { context, size in
                    let sunCenter = CGPoint(x: size.width * 0.68, y: size.height * 0.28)
                    let sunRadius = size.width * 0.14
                    context.fill(Path(ellipseIn: CGRect(x: sunCenter.x - sunRadius, y: sunCenter.y - sunRadius, width: sunRadius * 2, height: sunRadius * 2)), with: .color(Color.appAccent.opacity(0.95)))

                    let cloudRect = CGRect(x: size.width * 0.14, y: size.height * 0.42, width: size.width * 0.62, height: size.height * 0.34)
                    context.fill(fluffyCloud(in: cloudRect), with: .color(Color.appTextPrimary.opacity(0.95)))
                }
                .frame(height: 220)
                .padding(.horizontal, 28)
                .padding(.vertical, 28)
            }

            Image(systemName: "bell")
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(Color.appPrimary)

            Text("No alerts set yet")
                .font(.title3.bold())
                .foregroundStyle(Color.appTextPrimary)

            Text("No alerts set yet. Tap + to add your first alert.")
                .font(.body)
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity)
    }

    private func fluffyCloud(in rect: CGRect) -> Path {
        var path = Path()
        let bump = rect.height * 0.38
        path.addEllipse(in: CGRect(x: rect.minX + rect.width * 0.06, y: rect.midY - bump / 2, width: bump * 1.8, height: bump))
        path.addEllipse(in: CGRect(x: rect.midX - bump * 1.05, y: rect.midY - bump * 1.05, width: bump * 2.45, height: bump * 1.35))
        path.addEllipse(in: CGRect(x: rect.maxX - bump * 2.35, y: rect.midY - bump / 3, width: bump * 2.05, height: bump * 1.1))
        path.addRoundedRect(in: CGRect(x: rect.minX + rect.width * 0.07, y: rect.midY - bump * 0.25, width: rect.width * 0.88, height: bump), cornerSize: CGSize(width: bump / 4, height: bump / 4))
        return path
    }
}

private struct WeatherAlertSwipeCard: View {
    @EnvironmentObject private var store: AppStorageStore

    let alert: WeatherAlertItem
    let isSpotlit: Bool
    let confirmationPulse: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var dragOffset: CGFloat = 0

    private let actionZone: CGFloat = 150

    var body: some View {
        ZStack(alignment: .trailing) {
            HStack(spacing: 10) {
                Button(role: .destructive) {
                    closeActions()
                    onDelete()
                } label: {
                    Text("Delete")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .frame(maxHeight: .infinity)
                        .background(Color.red.opacity(0.78))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.tapFeedback)

                Button {
                    closeActions()
                    onEdit()
                } label: {
                    Text("Edit")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(Color.appBackground)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .frame(maxHeight: .infinity)
                        .background(Color.appPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.tapFeedback)
            }
            .frame(width: actionZone)
            .padding(.vertical, 4)

            cardBody
                .offset(x: dragOffset)
                .animation(.easeInOut(duration: 0.2), value: dragOffset)
                .highPriorityGesture(
                    DragGesture(minimumDistance: 18)
                        .onChanged { value in
                            let proposed = value.translation.width
                            dragOffset = min(0, max(proposed, -actionZone))
                        }
                        .onEnded { value in
                            let projection = value.translation.width + value.predictedEndTranslation.width * 0.18
                            if projection < -(actionZone / 2.5) {
                                dragOffset = -actionZone
                            } else {
                                dragOffset = 0
                            }
                        }
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var cardBody: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                IconGlyph(symbol: "bell.badge.fill", size: 48)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Alert rules")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text("Swipe left for quick actions.")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
                Spacer(minLength: 0)
            }

            CellHairlineDivider()

            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Alert enabled")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text("Pause this card without deleting it.")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
                Spacer(minLength: 8)
                Toggle("", isOn: Binding(
                    get: { store.enabledAlertIDs.contains(alert.id) },
                    set: { newValue in
                        FeedbackCentral.tapLight()
                        store.toggleAlertEnabled(id: alert.id, isOn: newValue)
                    }
                ))
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: Color.appAccent))
            }
            .padding(.vertical, 2)

            CellHairlineDivider()

            if alert.quietHoursEnabled || alert.warmFeelingEnabled || alert.breezyFeelingEnabled {
                HStack(spacing: 8) {
                    if alert.quietHoursEnabled {
                        ComfortCueChip(title: "Quiet", systemImage: "moon.zzz.fill")
                    }
                    if alert.warmFeelingEnabled {
                        ComfortCueChip(title: "Warm cue", systemImage: "thermometer.sun.fill")
                    }
                    if alert.breezyFeelingEnabled {
                        ComfortCueChip(title: "Breeze cue", systemImage: "wind")
                    }
                }
                CellHairlineDivider()
            }

            VStack(alignment: .leading, spacing: 10) {
                ForEach(alert.conditionSummaryLines, id: \.self) { line in
                    AlertDetailLineCell(icon: "cloud.sun.fill", text: line)
                }
            }

            SuccessFeedbackBadge(isVisible: confirmationPulse)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 6)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.appSurface.opacity(0.92))
                .shadow(color: Color.black.opacity(0.12), radius: 14, x: 0, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.appAccent.opacity(0.5),
                            Color.appPrimary.opacity(0.28),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .scaleEffect(isSpotlit ? 1.03 : 1)
        .animation(.spring(response: 0.38, dampingFraction: 0.68), value: isSpotlit)
        .pulseAccent(on: confirmationPulse)
    }

    private func closeActions() {
        dragOffset = 0
    }
}
