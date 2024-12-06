//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// A structure representing a series of points.
///
/// This structure is used to manage and manipulate a collection of points.
/// It provides various functionalities to work with the series of points.
///
struct RawPointData {

    /// The date from which the event or period starts.
    let from: Date

    /// The date to which the event or action is targeted.
    let to: Date

    /// An array of `ChartPoint` representing the points in the chart.
    let points: [ChartPoint]
}

extension RawPointData {

    /// Generates chart data for the given calendar components.
    ///
    /// - Parameter components: A set of calendar components to group the points by.
    /// - Returns: A dictionary where the keys are the calendar components and the values are arrays of `ChartPoint`.
    ///
    func chartData(for components: Set<Calendar.Component>) -> ChartData {
        components.reduce(into: [:]) { dict, component in
            dict[component] = group(by: component)
        }
    }

    private func group(by component: Calendar.Component) -> [ChartPoint] {
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
