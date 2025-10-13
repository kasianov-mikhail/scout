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

    /// The exclusive upper bound (“right edge”) of the initial visible time window.
    ///
    /// Default value is “today” in most cases; for an incomplete current day,
    /// the upper bound advances to the start of the next day.
    ///
    var horizonDate: Date { get }
}

// MARK: - Helpers

extension ChartTimeScale {

    var today: Date {
        Calendar(identifier: .iso8601).startOfDay(for: Date())
    }

    var initialRange: Range<Date> {
        horizonDate.adding(rangeComponent, value: -1)..<horizonDate
    }
}
