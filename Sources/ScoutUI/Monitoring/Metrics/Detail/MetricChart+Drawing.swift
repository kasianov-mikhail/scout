//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import SwiftUI

extension MetricChart {
    func drawBars(scale: MetricChartScale, context: inout GraphicsContext, size: CGSize) {
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

    func drawLine(scale: MetricChartScale, filled: Bool, context: inout GraphicsContext, size: CGSize) {
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

    func drawResets(context: inout GraphicsContext, size: CGSize) {
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
}
