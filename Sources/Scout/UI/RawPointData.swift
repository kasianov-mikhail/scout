//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// A structure representing raw point data.
/// 
/// This structure is used to store and manage raw data points.
/// It can be used in various contexts where point data is required,
/// such as in graphical representations.
/// 
/// - SeeAlso: `ChartPoint`
/// 
struct RawPointData {

    /// The starting date for the data range.
    let from: Date

    /// The end date for the data range.
    /// This date represents the upper bound of the time period for which data points are considered.
    let to: Date

    /// An array of `ChartPoint` objects representing the raw data points.
    let points: [ChartPoint]
}

extension RawPointData {

    /// Groups the points by the specified calendar component.
    ///
    /// - Parameter component: The calendar component to group the points by.
    /// - Returns: An array of `ChartPoint` grouped by the specified calendar component.
    ///
    func group(by component: Calendar.Component) -> [ChartPoint] {
        var result: [ChartPoint] = []
        var date = from

        while date < to {
            let next = date.adding(component)

            let count = points.filter { item in
                (date..<next).contains(item.date)
            }.reduce(0) {
                $0 + $1.count
            }

            result.append(ChartPoint(date: date, count: count))
            date = next
        }

        return result
    }
}
