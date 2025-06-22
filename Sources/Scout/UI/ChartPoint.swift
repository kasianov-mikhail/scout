//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

/// A typealias representing chart data grouped by a chart-compatible key.
typealias ChartData<T: ChartCompatible> = [T: [ChartPoint]]

/// A structure representing a point in a chart.
struct ChartPoint: Identifiable {
    let id = UUID()

    /// The date associated with the chart point, displayed on the x-axis.
    let date: Date

    /// The count value associated with the chart point, displayed on the y-axis.
    let count: Int
}

extension ChartPoint {

    /// Converts a matrix of integer cells into an array of `ChartPoint` instances.
    ///
    /// This method maps each cell in the provided matrix to a `ChartPoint` by calculating
    /// the date based on the matrix's date and the cell's row and column indices. The cell's
    /// value is used as the count for the `ChartPoint`.
    ///
    /// - Parameter matrix: A `Matrix` containing `Cell<Int>` elements.
    /// - Returns: An array of `ChartPoint` instances created from the matrix cells.
    ///
    static func fromIntMatrix(_ matrix: Matrix<Cell<Int>>) -> [ChartPoint] {
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
