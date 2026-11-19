//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import SwiftUI

struct MetricChart: View {
    enum Style {
        case bars
        case line(filled: Bool)
    }

    let buckets: [MetricBucket]
    let style: Style
    let format: MetricValueFormat
    var resets: [Date] = []

    var body: some View {
        let scale = MetricChartScale(values: values)

        Canvas { context, size in
            drawGrid(scale: scale, context: &context, size: size)

            switch style {
            case .bars:
                drawBars(scale: scale, context: &context, size: size)
            case .line(let filled):
                drawLine(scale: scale, filled: filled, context: &context, size: size)
            }

            drawAxisLabels(scale: scale, context: &context, size: size)
            drawResets(context: &context, size: size)
        }
        .frame(height: 150)
        .accessibilityHidden(true)
    }

    private var values: [Double] {
        buckets.flatMap { bucket in
            [bucket.value, bucket.previous].compactMap(\.self)
        }
    }

    private func drawGrid(scale: MetricChartScale, context: inout GraphicsContext, size: CGSize) {
        for tick in scale.ticks {
            let y = y(tick, scale: scale, size: size)
            var path = Path()
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: size.width, y: y))
            context.stroke(path, with: .color(Color.surfaceSkeleton), lineWidth: 0.5)
        }
    }

    private func drawAxisLabels(scale: MetricChartScale, context: inout GraphicsContext, size: CGSize) {
        for tick in scale.ticks {
            let y = y(tick, scale: scale, size: size)
            let label = Text(verbatim: format.label(tick, compact: true))
                .font(.scoutAxis)
                .foregroundColor(Color.textMuted)
            let resolved = context.resolve(label)
            context.draw(resolved, at: CGPoint(x: size.width - 2, y: y - 6), anchor: .trailing)
        }
    }

    func y(_ value: Double, scale: MetricChartScale, size: CGSize) -> CGFloat {
        let top: CGFloat = 12
        let fraction = min(max(value / scale.upper, 0), 1)
        return size.height - CGFloat(fraction) * (size.height - top)
    }
}

#Preview("Bars") {
    MetricChart(
        buckets: [
            MetricBucket(date: .now, value: 12, previous: 8, isFuture: false, isCurrent: false),
            MetricBucket(date: .now.addingTimeInterval(.hour), value: 18, previous: 12, isFuture: false, isCurrent: false),
            MetricBucket(date: .now.addingTimeInterval(.hour * 2), value: 9, previous: 14, isFuture: false, isCurrent: false),
        ],
        style: .bars,
        format: .counter
    )
    .padding(.horizontal, .gutter)
}
