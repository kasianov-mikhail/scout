//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

protocol ChartTiming {
    var unit: Calendar.Component { get }
    var tickValues: [Date]? { get }
}

/// The time slot a bucket occupies on the x axis.
///
/// `BarMark` bins dates with the local calendar, so charts derive their bar
/// slots, domains, and ticks from the same bins to stay pixel-aligned with
/// the binned marks.
///
func binRange(of date: Date, unit: Calendar.Component) -> Range<Date> {
    let interval = Calendar.autoupdatingCurrent.dateInterval(of: unit, for: date)!
    return interval.start..<interval.end
}

extension ChartTiming {
    /// Explicit x-axis ticks for `segment`: the scale's own `tickValues`
    /// when defined, otherwise bucket bin starts thinned to at most four —
    /// the dates the automatic axis picks for binned bar charts.
    ///
    func tickDates<T: ChartNumeric>(for segment: [ChartPoint<T>]) -> [Date] {
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
