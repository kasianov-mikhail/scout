//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import SwiftUI

private let monospacedAdvance: CGFloat = 6

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

    private func drawBars(scale: MetricChartScale, context: inout GraphicsContext, size: CGSize) {
        let step = size.width / CGFloat(max(buckets.count, 1))
        let width = step * 0.8

        for (index, bucket) in buckets.enumerated() {
            guard let value = bucket.value, value > 0 else {
                continue
            }

            let top = y(value, scale: scale, size: size)
            let rect = CGRect(
                x: CGFloat(index) * step + (step - width) / 2,
                y: top,
                width: width,
                height: size.height - top
            )
            context.fill(
                Path(roundedRect: rect, cornerRadius: .radiusBar),
                with: .color(bucket.isCurrent ? .metricSoft : .fillAccent)
            )
        }

        drawPrevious(scale: scale, context: &context, size: size)
    }

    private func drawLine(scale: MetricChartScale, filled: Bool, context: inout GraphicsContext, size: CGSize) {
        let step = size.width / CGFloat(max(buckets.count, 1))
        let points = buckets.enumerated().compactMap { index, bucket -> CGPoint? in
            guard let value = bucket.value else {
                return nil
            }
            return CGPoint(x: (CGFloat(index) + 0.5) * step, y: y(value, scale: scale, size: size))
        }

        drawPrevious(scale: scale, context: &context, size: size)

        if filled, points.count > 1, let first = points.first, let last = points.last {
            var area = Path()
            area.move(to: CGPoint(x: first.x, y: size.height))
            area.addLines(points)
            area.addLine(to: CGPoint(x: last.x, y: size.height))
            area.closeSubpath()
            context.fill(area, with: .color(Color.fillAccent.opacity(0.1)))
        }

        if points.count > 1 {
            var line = Path()
            line.addLines(points)
            context.stroke(line, with: .color(Color.fillAccent), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        }

        if let last = points.last {
            let dot = CGRect(x: last.x - 3.5, y: last.y - 3.5, width: 7, height: 7)
            context.fill(Path(ellipseIn: dot), with: .color(Color.fillAccent))
        }
    }

    private func drawPrevious(scale: MetricChartScale, context: inout GraphicsContext, size: CGSize) {
        let step = size.width / CGFloat(max(buckets.count, 1))
        let points = buckets.enumerated().compactMap { index, bucket -> CGPoint? in
            guard let value = bucket.previous else {
                return nil
            }
            return CGPoint(x: (CGFloat(index) + 0.5) * step, y: y(value, scale: scale, size: size))
        }

        guard points.count > 1 else {
            return
        }

        var path = Path()
        path.addLines(points)
        context.stroke(
            path,
            with: .color(Color.lineSeparator),
            style: StrokeStyle(lineWidth: 1.5, dash: [4, 3])
        )
    }

    private func drawResets(context: inout GraphicsContext, size: CGSize) {
        let step = size.width / CGFloat(max(buckets.count, 1))

        for date in resets {
            guard let index = buckets.lastIndex(where: { $0.date <= date }) else {
                continue
            }

            let x = (CGFloat(index) + 0.5) * step
            var path = Path()
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: size.height))
            context.stroke(path, with: .color(Color.fillLevel), style: StrokeStyle(lineWidth: 1, dash: [2, 3]))

            let label = Text(verbatim: "reset")
                .font(.scoutMicro)
                .foregroundColor(Color.textMuted)
            let resolved = context.resolve(label)
            context.draw(resolved, at: CGPoint(x: x + 4, y: 8), anchor: .leading)
        }
    }

    private func y(_ value: Double, scale: MetricChartScale, size: CGSize) -> CGFloat {
        let top: CGFloat = 12
        let fraction = min(max(value / scale.upper, 0), 1)
        return size.height - CGFloat(fraction) * (size.height - top)
    }
}

struct MetricChartScale {
    let upper: Double
    let ticks: [Double]

    init(values: [Double]) {
        let maximum = values.filter(\.isFinite).max() ?? 0

        guard maximum > 0 else {
            upper = 1
            ticks = []
            return
        }

        let magnitude = pow(10, floor(log10(maximum / 4)))
        let candidates = [1.0, 2.0, 2.5, 5.0, 10.0].map { $0 * magnitude }
        let steps = candidates.filter { step in
            let count = Int(ceil(maximum / step))
            return count >= 2 && count <= 5
        }
        let step =
            steps.min { lhs, rhs in
                abs(Int(ceil(maximum / lhs)) - 4) < abs(Int(ceil(maximum / rhs)) - 4)
            } ?? magnitude

        upper = ceil(maximum / step) * step
        ticks = (1...Int((upper / step).rounded())).map { Double($0) * step }
    }
}

struct MetricAxisLabels: View {
    let labels: [MetricAxisLabel]

    var body: some View {
        GeometryReader { proxy in
            ForEach(labels.indices, id: \.self) { index in
                Text(verbatim: labels[index].text)
                    .position(x: x(labels[index], width: proxy.size.width), y: proxy.size.height / 2)
            }
        }
        .frame(height: 12)
        .padding(.top, .space4)
        .font(.scoutAxis)
        .foregroundStyle(Color.textMuted)
    }

    private func x(_ label: MetricAxisLabel, width: CGFloat) -> CGFloat {
        let half = CGFloat(label.text.count) * monospacedAdvance / 2
        return min(max(width * CGFloat(label.position), half), width - half)
    }
}

struct MetricLegend: View {
    let title: String
    let note: String?

    var body: some View {
        HStack(spacing: .space12) {
            HStack(spacing: .space4) {
                MetricDashedSample()
                Text(verbatim: title)
            }

            if let note {
                Text(verbatim: note)
                    .lineLimit(2)
            }
        }
        .font(.scoutFootnote)
        .foregroundStyle(Color.textMuted)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, .space10)
    }
}

private struct MetricDashedSample: View {
    var body: some View {
        GeometryReader { proxy in
            Path { path in
                path.move(to: CGPoint(x: 0, y: 1))
                path.addLine(to: CGPoint(x: proxy.size.width, y: 1))
            }
            .stroke(Color.lineSeparator, style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
        }
        .frame(width: 16, height: 2)
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
