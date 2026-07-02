//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct FunnelPlotView: View {
    let steps: [FunnelStep]
    var color: Color = .blue

    private let labelSpace: CGFloat = 24

    var body: some View {
        GeometryReader { geometry in
            let metrics = steps.metrics
            let count = CGFloat(metrics.count)
            let column = geometry.size.width / (count + 0.618 * (count - 1))
            let gap = column * 0.618
            let plotHeight = geometry.size.height - labelSpace

            ZStack(alignment: .topLeading) {
                connectors(metrics: metrics, column: column, gap: gap, plotHeight: plotHeight)

                ForEach(metrics) { metric in
                    let height = max(plotHeight * metric.fractionOfFirst, 4)
                    let x = CGFloat(metric.index) * (column + gap)
                    let top = labelSpace + plotHeight - height

                    UnevenRoundedRectangle(topLeadingRadius: 5, topTrailingRadius: 5)
                        .fill(color.gradient)
                        .frame(width: column, height: height)
                        .offset(x: x, y: top)

                    Text(verbatim: metric.fractionOfFirst.funnelPercent)
                        .font(.caption.weight(.semibold))
                        .monospacedDigit()
                        .foregroundStyle(metric.index == 0 ? AnyShapeStyle(.secondary) : AnyShapeStyle(color))
                        .frame(width: column)
                        .offset(x: x, y: top - labelSpace + 4)
                }
            }
        }
        .aspectRatio(1.618, contentMode: .fit)
    }

    private func connectors(metrics: [FunnelStepMetrics], column: CGFloat, gap: CGFloat, plotHeight: CGFloat) -> some View {
        Path { path in
            for index in metrics.indices.dropLast() {
                let from = metrics[index]
                let to = metrics[index + 1]
                let leading = CGFloat(index) * (column + gap) + column
                let trailing = leading + gap
                let bottom = labelSpace + plotHeight

                path.move(to: CGPoint(x: leading, y: bottom - plotHeight * from.fractionOfFirst))
                path.addLine(to: CGPoint(x: trailing, y: bottom - plotHeight * to.fractionOfFirst))
                path.addLine(to: CGPoint(x: trailing, y: bottom))
                path.addLine(to: CGPoint(x: leading, y: bottom))
                path.closeSubpath()
            }
        }
        .fill(color.opacity(0.12))
    }
}

#Preview("Funnel plot") {
    FunnelPlotView(steps: FunnelStep.samples)
        .padding()
}
