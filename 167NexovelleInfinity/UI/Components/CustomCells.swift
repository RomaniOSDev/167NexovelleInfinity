//
//  CustomCells.swift
//  167NexovelleInfinity
//

import SwiftUI

// MARK: - Shell

struct GlassPanel<Content: View>: View {
    var cornerRadius: CGFloat = 22
    var contentSpacing: CGFloat = 14

    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: contentSpacing) {
            content()
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.appSurface.opacity(0.78))
                .shadow(color: Color.black.opacity(0.18), radius: 16, x: 0, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.appAccent.opacity(0.45),
                            Color.appPrimary.opacity(0.25),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

struct ScreenSectionHeader: View {
    let title: String
    var subtitle: String?
    var systemImage: String?

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let systemImage {
                IconGlyph(symbol: systemImage, size: 48)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(Color.appTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 0)
        }
    }
}

// MARK: - Icon

struct IconGlyph: View {
    let symbol: String
    var size: CGFloat = 44

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: size * 0.42, weight: .semibold))
            .foregroundStyle(Color.appTextPrimary.opacity(0.95))
            .frame(width: size, height: size)
            .background(
                LinearGradient(
                    colors: [
                        Color.appPrimary.opacity(0.95),
                        Color.appAccent.opacity(0.82),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .clipShape(RoundedRectangle(cornerRadius: size * 0.26, style: .continuous))
            )
            .overlay(
                RoundedRectangle(cornerRadius: size * 0.26, style: .continuous)
                    .stroke(Color.appTextPrimary.opacity(0.35), lineWidth: 1)
            )
            .shadow(color: Color.appAccent.opacity(0.35), radius: 6, x: 0, y: 3)
    }
}

struct CellHairlineDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.appAccent.opacity(0.22))
            .frame(height: 1)
    }
}

// MARK: - Toggle row

struct PreferenceToggleRow: View {
    let symbol: String
    let title: String
    var subtitle: String?
    @Binding var isOn: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            IconGlyph(symbol: symbol, size: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)

                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: 8)

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: Color.appAccent))
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Navigation-style row

struct SettingsDestinationRow: View {
    let symbol: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            IconGlyph(symbol: symbol, size: 48)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.appAccent.opacity(0.9))
        }
        .padding(.vertical, 6)
    }
}

struct DestructiveRowButtonLabel: View {
    let symbol: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.red.opacity(0.95))
                .frame(width: 48, height: 48)
                .background(Color.red.opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.red.opacity(0.95))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
            }
            Spacer()
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Buttons

struct PrimaryFullWidthButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.appBackground)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [Color.appPrimary, Color.appPrimary.opacity(0.88)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.appAccent.opacity(0.45), lineWidth: 1)
                )
        }
        .buttonStyle(.tapFeedback)
    }
}

struct SecondaryOutlineButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(Color.appSurface.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.appAccent.opacity(0.65), lineWidth: 1.5)
                )
        }
        .buttonStyle(.tapFeedback)
    }
}

// MARK: - Insight / metrics

struct InsightMetricCell: View {
    let icon: String
    let caption: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.appAccent)

            Text(value)
                .font(.footnote.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
                .multilineTextAlignment(.center)

            Text(caption.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 6)
        .background(Color.appBackground.opacity(0.22))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.appAccent.opacity(0.28), lineWidth: 1)
        )
    }
}

struct KeyValueInsightCell: View {
    let symbol: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.appAccent)
                .frame(width: 38, height: 38)
                .background(Color.appSurface.opacity(0.65))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(title.uppercased())
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Color.appTextSecondary)

                Text(value)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(Color.appSurface.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.appAccent.opacity(0.3), lineWidth: 1)
        )
    }
}

struct ComposerLabeledField: View {
    let symbol: String
    let title: String

    var body: some View {
        Label {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.appTextSecondary)
        } icon: {
            Image(systemName: symbol)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.appAccent.opacity(0.92))
                .frame(width: 26, alignment: .leading)
        }
        .labelStyle(.titleAndIcon)
    }
}

// MARK: - Alert preview cell line

struct AlertDetailLineCell: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.appAccent.opacity(0.9))
                .frame(width: 22)

            Text(text)
                .font(.footnote.weight(.medium))
                .foregroundStyle(Color.appTextSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
    }
}

// MARK: - Comfort chip

struct ComfortCueChip: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundStyle(Color.appTextPrimary)
            .background(Color.appBackground.opacity(0.28))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.appAccent.opacity(0.4), lineWidth: 1)
            )
    }
}

// MARK: - Glass-style text fields (manual / compose screens)

struct GlassTextFieldChrome: ViewModifier {
    var verticalPadding: CGFloat = 11
    var minHeight: CGFloat?

    func body(content: Content) -> some View {
        let padded = content
            .font(.body.weight(.medium))
            .foregroundStyle(Color.appTextPrimary)
            .tint(Color.appAccent)
            .padding(.horizontal, 14)
            .padding(.vertical, verticalPadding)

        Group {
            if let minHeight {
                padded.frame(minHeight: minHeight, alignment: .topLeading)
            } else {
                padded
            }
        }
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.appSurface.opacity(0.52))
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.ultraThinMaterial)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.appAccent.opacity(0.55),
                            Color.appPrimary.opacity(0.32),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.12), radius: 6, y: 3)
    }
}

extension View {
    /// Frosted glass chrome for `TextField` on compose / log screens — high contrast text, gradient edge.
    func glassTextFieldChrome(verticalPadding: CGFloat = 11, minHeight: CGFloat? = nil) -> some View {
        modifier(GlassTextFieldChrome(verticalPadding: verticalPadding, minHeight: minHeight))
    }
}
