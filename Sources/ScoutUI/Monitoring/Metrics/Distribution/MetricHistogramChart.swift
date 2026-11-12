//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import SwiftUI

enum MetricHistogramFormat {
    case timer
    case recorder
}

extension MetricHistogramFormat {
    func label(_ bound: Double) -> String {
        switch self {
        case .timer:
            Self.durationLabel(bound)
        case .recorder:
            Self.countLabel(bound)
        }
    }

    func overflowLabel(_ bound: Double) -> String {
        ">" + label(bound)
    }

    private static func durationLabel(_ seconds: Double) -> String {
        let milliseconds = seconds * 1_000

        if milliseconds < 1_000 {
            return String(format: "%.0f", milliseconds)
        }

        let value = milliseconds / 1_000
        if value.rounded() == value {
            return "\(Int(value))s"
        }
        return String(format: "%.1fs", value)
    }

    private static func countLabel(_ value: Double) -> String {
        if value >= 1_000_000 {
            return compact(value / 1_000_000, "M")
        }
        if value >= 1_000 {
            return compact(value / 1_000, "k")
        }
        return String(format: "%.0f", value)
    }

    private static func compact(_ value: Double, _ suffix: String) -> String {
        value.rounded() == value ? "\(Int(value))\(suffix)" : String(format: "%.1f%@", value, suffix)
    }
}

struct MetricHistogramLayout {
    let bounds: [Double]
    let maximum: Int

    init(counts: [Int], bounds: [Double]) {
        self.bounds = bounds
        self.maximum = counts.max() ?? 0
    }

    var labelIndices: [Int] {
        let total = bounds.count + 1
        let step = max(1, Int(ceil(Double(total) / 8)))
        return Array(stride(from: 0, to: total, by: step))
    }

    func fraction(_ count: Int) -> Double {
        maximum > 0 ? Double(count) / Double(maximum) : 0
    }

    func position(_ value: Double) -> Double {
        guard !bounds.isEmpty else {
            return 0
        }
        guard value > 0 else {
            return 0
        }

        let index = bounds.firstIndex { value <= $0 } ?? bounds.count

        guard index < bounds.count else {
            return 1
        }

        let lower = index == 0 ? 0 : bounds[index - 1]
        let upper = bounds[index]
        let fraction: Double

        if lower > 0, upper > lower {
            fraction = log(value / lower) / log(upper / lower)
        } else {
            fraction = (value - lower) / (upper - lower)
        }

        return (Double(index) + min(max(fraction, 0), 1)) / Double(bounds.count + 1)
    }

    func label(at index: Int, format: MetricHistogramFormat) -> String {
        guard index < bounds.count else {
            return format.overflowLabel(bounds.last ?? 0)
        }
        return format.label(bounds[index])
    }
}

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
                    HStack(alignment: .bottom, spacing: 2) {
                        ForEach(counts.indices, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(counts[index] > 0 ? Color.metricBar : Color(.systemGray6))
                                .frame(maxWidth: .infinity)
                                .frame(height: 96 * CGFloat(layout.fraction(counts[index])))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)

                    if let percentiles {
                        marker(value: percentiles.p50, color: .blue, title: "p50", layout: layout, width: proxy.size.width)
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
                .font(.system(size: 11, weight: .semibold))
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
                        .foregroundStyle(Color(.systemGray))
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
    .padding(.horizontal, 16)
}
