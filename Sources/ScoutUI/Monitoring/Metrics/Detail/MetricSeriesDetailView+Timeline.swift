//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension MetricSeriesDetailView {
    var isEmpty: Bool {
        guard case .success(let data) = series.result else {
            return false
        }
        return !timeline(from: data).containsData(range: range, now: Date())
    }

    func timeline(from data: [MetricSeries]) -> MetricTimeline {
        let points =
            data
            .filter { $0.name == name }
            .flatMap(\.points)
            .map { ChartPoint<Double>(date: $0.date, value: $0.value) }
            .sorted()

        return MetricTimeline(points: points)
    }

    func tone(_ row: MetricRow) -> MetricTone {
        guard telemetry == .counter || telemetry == .floatingCounter else {
            return .neutral
        }
        guard let delta = row.delta, delta.value > 0 else {
            return .neutral
        }
        return .positive
    }

    func legendNote(resetDates: [Date]) -> String? {
        switch telemetry {
        case .meter:
            range.peakNote
        case .counter, .floatingCounter:
            resetDates.isEmpty ? nil : "reset = the app restarted the counter"
        case .timer, .recorder:
            nil
        }
    }
}
