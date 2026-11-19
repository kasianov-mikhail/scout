//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import SwiftUI

struct MetricHistogramChart: View {
    let counts: [Int]
    let bounds: [Double]
    let percentiles: Percentiles?
    let format: MetricHistogramFormat

    var body: some View {
        let layout = MetricHistogramLayout(counts: counts, bounds: bounds)

        VStack(spacing: 0) {
            GeometryReader { proxy in
                ZStack(alignment: .topLeading) {
                    HStack(alignment: .bottom, spacing: .space2) {
                        ForEach(counts.indices, id: \.self) { index in
                            RoundedRectangle(cornerRadius: .radiusBar)
                                .fill(counts[index] > 0 ? Color.metricBar : Color.surfaceGrey)
                                .frame(maxWidth: .infinity)
                                .frame(height: 96 * CGFloat(layout.fraction(counts[index])))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)

                    if let percentiles {
                        marker(value: percentiles.p50, color: .fillAccent, title: "p50", layout: layout, width: proxy.size.width)
                        marker(value: percentiles.p90, color: .metricTeal, title: "p90", layout: layout, width: proxy.size.width)
                        marker(value: percentiles.p99, color: .hangText, title: "p99", layout: layout, width: proxy.size.width)
                    }
                }
            }
            .frame(height: 110)

            axis(layout: layout)
                .frame(height: 16)
        }
        .frame(height: 126)
    }

    private func marker(value: Double, color: Color, title: String, layout: MetricHistogramLayout, width: CGFloat) -> some View {
        let x = CGFloat(layout.position(value)) * width

        return ZStack(alignment: .topLeading) {
            Rectangle()
                .fill(color)
                .frame(width: 1.5)
                .frame(maxHeight: .infinity)
                .offset(x: x)

            Text(verbatim: title)
                .font(.scoutLabelCaps)
                .foregroundStyle(color)
                .offset(x: min(x + 3, width - 26))
        }
    }

    private func axis(layout: MetricHistogramLayout) -> some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                ForEach(layout.labelIndices, id: \.self) { index in
                    Text(verbatim: layout.label(at: index, format: format))
                        .font(.book(size: 9, design: .monospaced))
                        .foregroundStyle(Color.textMuted)
                        .position(
                            x: (CGFloat(index) + 0.5) / CGFloat(counts.count) * proxy.size.width,
                            y: 8
                        )
                }
            }
        }
    }
}

#Preview {
    MetricHistogramChart(
        counts: [2, 8, 21, 34, 27, 13, 5, 3, 2, 1, 0, 0, 0, 0, 0],
        bounds: LatencyHistogram.bounds,
        percentiles: .sample,
        format: .timer
    )
    .padding(.horizontal, .gutter)
}
