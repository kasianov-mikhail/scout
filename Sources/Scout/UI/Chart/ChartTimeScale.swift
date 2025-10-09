//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

protocol ChartTimeScale: Identifiable, Hashable {

    /// Major axis segmentation (big bands).
    ///
    /// Each block represents one whole Calendar.Component in the visible time window (`range`).
    /// The chart window is aligned to and typically paged by this component.
    ///
    /// Examples:
    /// - .day        → a single day band (e.g., “Today”)
    /// - .weekOfYear → weekly bands (e.g., “Week 1”, “Week 2”, …)
    /// - .month      → monthly bands (e.g., “Jan”, “Feb”, “Mar”, …)
    /// - .year       → yearly bands (e.g., “2024”, “2025”, …)
    ///
    var rangeComponent: Calendar.Component { get }

    /// Minor tick spacing inside each major band.
    ///
    /// Minor ticks or data points are placed at this Calendar.Component granularity
    /// within each `rangeComponent` block.
    ///
    /// Typical pairings:
    /// - rangeComponent = .day        → pointComponent = .hour    (00 | 01 | … | 23)
    /// - rangeComponent = .weekOfYear → pointComponent = .day     (Mon | Tue | … | Sun)
    /// - rangeComponent = .month      → pointComponent = .day     (1 | 2 | … | 31)
    /// - rangeComponent = .year       → pointComponent = .month   (Jan | Feb | … | Dec)
    ///
    var pointComponent: Calendar.Component { get }

    /// The currently visible time window on the x‑axis.
    var range: Range<Date> { get }
}

extension ChartTimeScale {

    /// Explicit x‑axis tick positions for monthly charts.
    ///
    /// The default system behavior places ticks on Mondays.
    /// This implementation overrides that behavior to mark exactly 1, 2, 3, and 4 weeks ago
    /// relative to the current upper bound of the visible range.
    ///
    var axisValues: [Date]? {
        if case .month = rangeComponent {
            [-28, -21, -14, -7].map(range.upperBound.addingDay)
        } else {
            nil
        }
    }
}
