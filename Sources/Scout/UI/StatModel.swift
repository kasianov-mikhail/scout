//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

/// A model that provides data for a chart.
///
/// The model is responsible for filtering the data based on the selected period.
/// It also provides the axis values for the chart.
///
@MainActor class StatModel: ObservableObject {

    @Published var period: Period {
        didSet { range = period.range }
    }

    @Published var range: Range<Date>

    init(period: Period) {
        self.period = period
        self.range = period.range
    }

    /// Returns the points for the specified data.
    /// The points are filtered based on the selected period and date range.
    ///
    /// - Parameter data: The data to filter.
    /// - Returns: An array of `ChartPoint` objects.
    ///
    func points(from data: ChartData?) -> [ChartPoint]? {
        data?[period.pointComponent]?.filter {
            range.contains($0.date)
        }
    }

    /// Returns the axis values for the chart.
    ///
    /// For a month period, the values are the last 4 weeks. This fixes the issue with the axis
    /// values not being displayed correctly for the month period. For the other periods,
    /// the chart uses default axis values
    ///
    var axisValues: [Date]? {
        if period == .month {
            return [-28, -21, -14, -7].map(range.upperBound.addingDay)
        } else {
            return nil
        }
    }
}
