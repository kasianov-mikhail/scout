//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// A protocol that defines the requirements for a chart-compatible model.
///
/// This protocol requires conforming types to provide a point component,
/// a range component, and a date range.
/// It is used to filter and manage data for charting purposes.
///
/// - Note: The `pointComponent` and `rangeComponent` properties are used to
/// determine the granularity of the data points and the range of dates to be
/// considered for the chart.
///
protocol ChartCompatible: Identifiable, Hashable {

    /// The component used to represent individual data points.
    var pointComponent: Calendar.Component { get }

    /// The component used to represent the range of data points.
    var rangeComponent: Calendar.Component { get }

    /// The date range for the data points.
    var range: Range<Date> { get }
}

extension Array where Element: ChartCompatible {

    /// A computed property that returns an unique set of calendar components,
    /// which are used to group the data points.
    ///
    var uniqueComponents: Set<Calendar.Component> {
        Set(map(\.pointComponent))
    }
}
