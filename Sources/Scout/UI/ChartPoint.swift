//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

/// This typealias is used to organize and manage chart data points
/// associated with different calendar components.
///
typealias ChartData = [Calendar.Component: [ChartPoint]]

/// A structure representing a point in a chart.
struct ChartPoint: Identifiable {
    let id = UUID()

    /// The date associated with the chart point, displayed on the x-axis.
    let date: Date

    /// The count value associated with the chart point, displayed on the y-axis.
    let count: Int
}

extension ChartPoint {
    static func fromIntMatrix(_ matrix: Matrix<Int>) -> [ChartPoint] {
        matrix.cells.map { cell in
            ChartPoint(
                date: matrix.date.addingDay(cell.row - 1).addingHour(cell.column),
                count: cell.value
            )
        }
    }
}

// MARK: - Math

extension ChartPoint: Equatable {
    static func == (lhs: ChartPoint, rhs: ChartPoint) -> Bool {
        lhs.date == rhs.date && lhs.count == rhs.count
    }
}

extension ChartPoint {
    static func + (lhs: ChartPoint, rhs: ChartPoint) -> ChartPoint {
        ChartPoint(date: lhs.date, count: lhs.count + rhs.count)
    }

    static func += (lhs: inout ChartPoint, rhs: ChartPoint) {
        lhs = lhs + rhs
    }
}

// MARK: - Collection Count

extension [ChartPoint] {
    var count: Int {
        map(\.count).reduce(0, +)
    }
}

// MARK: -

extension ChartPoint: CustomStringConvertible {
    var description: String {
        "\(date): \(count)"
    }
}
