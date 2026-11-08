//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct MetricSummary: Equatable {
    let value: String
    let unit: String
    let detail: String?
    let tone: MetricTone
}

extension MetricSummary {
    init(total: Double, previous: Double, range: MetricRange, format: MetricValueFormat) {
        let delta = Delta(current: total, previous: previous)

        self.init(
            value: format.label(total),
            unit: range.totalTitle,
            detail: delta.map { "\($0.formatted) \(range.headlineComparison)" },
            tone: delta.map { $0.value > 0 ? .positive : .neutral } ?? .neutral
        )
    }

    init(latest: ChartPoint<Double>?, peak: ChartPoint<Double>?, range: MetricRange, format: MetricValueFormat) {
        self.init(
            value: latest.map { format.label($0.value) } ?? "—",
            unit: latest.map { "latest · \($0.date.relativeString)" } ?? "latest",
            detail: peak.map { "peak \(range.caption) \(format.label($0.value)) at \(range.rowLabel(date: $0.date))" },
            tone: .neutral
        )
    }
}
