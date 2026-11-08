//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct MetricTileView: View {
    let tile: MetricTile
    let isLeading: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(verbatim: tile.displayName)
                .font(.weight450(size: 12, design: .monospaced))
                .foregroundStyle(Color(.systemGray))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(verbatim: tile.valueLabel)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .monospacedDigit()

                Text(verbatim: tile.suffix)
                    .font(.weight450(size: 12))
                    .foregroundStyle(Color(.systemGray))
            }
            .lineLimit(1)

            MetricSparkline(values: tile.series)
                .frame(height: 28)
        }
        .padding(.vertical, 14)
        .padding(.leading, isLeading ? 0 : 12)
        .padding(.trailing, isLeading ? 12 : 0)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .overlay(alignment: .trailing) {
            if isLeading {
                Rectangle()
                    .fill(Color.separator)
                    .frame(width: 0.5)
            }
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)
        }
        .contentShape(.rect)
    }
}

private struct MetricSparkline: View {
    let values: [Double]

    var body: some View {
        GeometryReader { proxy in
            let points = points(in: proxy.size)

            ZStack {
                if points.count > 1 {
                    area(points, size: proxy.size)
                        .fill(Color.blue.opacity(0.12))

                    line(points)
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
                }
            }
        }
    }

    private func points(in size: CGSize) -> [CGPoint] {
        guard values.count > 1 else {
            return []
        }

        let maximum = values.max() ?? 0
        let minimum = values.min() ?? 0
        let span = max(maximum - minimum, 1)
        let bottom = minimum - span * 0.1
        let top = maximum + span * 0.1
        let step = size.width / CGFloat(values.count - 1)

        return values.enumerated().map { index, value in
            CGPoint(
                x: CGFloat(index) * step,
                y: size.height - CGFloat((value - bottom) / (top - bottom)) * size.height
            )
        }
    }

    private func line(_ points: [CGPoint]) -> Path {
        var path = Path()
        path.addLines(points)
        return path
    }

    private func area(_ points: [CGPoint], size: CGSize) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: size.height))
        path.addLines(points)
        path.addLine(to: CGPoint(x: points[points.count - 1].x, y: size.height))
        path.closeSubpath()
        return path
    }
}

#Preview {
    VStack(spacing: 0) {
        ForEach(Array(MetricTile.samples.prefix(4).enumerated()), id: \.element.id) { _, tile in
            HStack(spacing: 0) {
                MetricTileView(tile: tile, isLeading: true)
                MetricTileView(tile: tile, isLeading: false)
            }
        }
    }
    .padding(.horizontal, 16)
}
