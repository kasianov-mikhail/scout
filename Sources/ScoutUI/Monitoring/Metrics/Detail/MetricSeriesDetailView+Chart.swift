//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension MetricSeriesDetailView {
    var chartStyle: MetricChart.Style {
        telemetry == .meter ? .line(filled: false) : .bars
    }

    func summary(timeline: MetricTimeline, now: Date, format: MetricValueFormat) -> MetricSummary {
        telemetry == .meter
            ? timeline.gaugeSummary(range: range, now: now, format: format)
            : timeline.summary(range: range, now: now, format: format)
    }
}
