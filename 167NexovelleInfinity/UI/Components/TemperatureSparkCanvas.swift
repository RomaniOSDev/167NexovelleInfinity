//
//  TemperatureSparkCanvas.swift
//  167NexovelleInfinity
//

import SwiftUI

struct TemperatureSparkCanvas: View {
    let samples: [CGFloat]

    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                guard samples.count > 1 else { return }
                let maxSample = samples.max() ?? 1
                let minSample = samples.min() ?? 0
                let verticalPadding: CGFloat = 6
                let usableHeight = size.height - verticalPadding * 2

                func point(for index: Int) -> CGPoint {
                    let x = CGFloat(index) / CGFloat(samples.count - 1) * size.width
                    let sample = samples[index]
                    let normalized = maxSample == minSample ? 0.5 : (sample - minSample) / (maxSample - minSample)
                    let y = size.height - verticalPadding - CGFloat(normalized) * usableHeight
                    return CGPoint(x: x, y: y)
                }

                var path = Path()
                path.move(to: point(for: 0))

                for idx in 1 ..< samples.count {
                    path.addLine(to: point(for: idx))
                }

                context.stroke(path, with: .color(Color.appAccent.opacity(0.85)), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

                for idx in stride(from: 0, to: samples.count, by: max(1, samples.count / 6)) {
                    let dotRect = CGRect(x: point(for: idx).x - 3, y: point(for: idx).y - 3, width: 6, height: 6)
                    context.fill(Path(ellipseIn: dotRect), with: .color(Color.appPrimary.opacity(0.85)))
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .frame(height: 96)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.appAccent.opacity(0.25), lineWidth: 1)
        )
    }
}
