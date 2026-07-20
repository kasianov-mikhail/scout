//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

protocol ChartTiming {
    var unit: Calendar.Component { get }
    var tickValues: [Date]? { get }
}

/// The time slot a bucket occupies on the x axis.
///
/// Series data is UTC-bucketed and the axis labels are formatted in UTC, so
/// bar slots, domains, and ticks are derived with `Calendar.utc` to name the
/// right bucket in any time zone. The chart views set the same UTC calendar
/// and time zone in their environment so `BarMark`'s own unit-binning agrees
/// and the marks stay pixel-aligned with these bins.
///
func binRange(of date: Date, unit: Calendar.Component) -> Range<Date> {
    let interval = Calendar.utc.dateInterval(of: unit, for: date)!
    return interval.start..<interval.end
}

extension ChartTiming {
    /// Explicit x-axis ticks for `segment`: the scale's own `tickValues`
    /// when defined, otherwise bucket bin starts thinned to at most four —
    /// the dates the automatic axis picks for binned bar charts.
    ///
    func tickDates(for segment: [ChartPoint<some ChartNumeric>]) -> [Date] {
        if let values = tickValues {
            return values
        }
        let starts = segment.map { binRange(of: $0.date, unit: unit).lowerBound }.sorted()
        let step = max(1, (starts.count + 3) / 4)
        return stride(from: 0, to: starts.count, by: step).map { starts[$0] }
    }
}

extension ChartExtent: ChartTiming {
    var unit: Calendar.Component {
        period.pointComponent
    }

    /// Explicit x‑axis tick positions for monthly charts.
    ///
    /// The default system behavior places ticks on Mondays.
    /// This implementation overrides that behavior to mark exactly 1, 2, 3, and 4 weeks ago
    ///
    var tickValues: [Date]? {
        if case .month = period.rangeComponent {
            [-28, -21, -14, -7].map(domain.upperBound.addingDay)
        } else {
            nil
        }
    }
}
