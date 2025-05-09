//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

// MARK: - StatModel

/// A model that provides data for a chart.
///
/// The model is responsible for filtering the data based on the selected period.
///
struct StatModel<T: ChartCompatible> {

    var period: T {
        didSet { range = period.range }
    }

    var range: Range<Date>

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
}

extension StatModel {

    /// Initializes a new instance of `StatModel` with the specified period.
    ///
    /// - Parameter period: The period to use for filtering the data.
    ///
    init(period: T) {
        self.period = period
        self.range = period.range
    }
}
