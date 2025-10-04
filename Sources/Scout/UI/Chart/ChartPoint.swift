//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

typealias ChartData<T: ChartCompatible, V: MatrixValue> = [T: [ChartPoint<V>]]

struct ChartPoint<T: MatrixValue>: Identifiable {
    let id = UUID()
    let date: Date
    let count: T

    static func fromGridMatrix<V: MatrixValue>(_ matrix: Matrix<GridCell<V>>) -> [ChartPoint<V>] {
        matrix.cells.map { cell in
            ChartPoint<V>(
                date: matrix.date.addingDay(cell.row - 1).addingHour(cell.column),
                count: cell.value
            )
        }
    }
}

// MARK: - Operators

extension ChartPoint: Comparable {
    static func < (lhs: ChartPoint, rhs: ChartPoint) -> Bool {
        lhs.date < rhs.date
    }
}

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

// MARK: -

extension Array where Element == ChartPoint<Int> {
    var total: Int {
        map(\.count).reduce(0, +)
    }
}

extension ChartPoint: CustomStringConvertible {
    var description: String {
        "\(date): \(count)"
    }
}

// MARK: - Sample Data

extension [ChartPoint<Int>] {
    static var sample: Self {
        let cal = Calendar(identifier: .iso8601)
        let end = Date()
        return (1...30).compactMap { i in
            cal.date(byAdding: .day, value: -i, to: end).map {
                ChartPoint(date: $0, count: Int.random(in: 0...10))
            }
        }.sorted()
    }

    static var empty: Self { [] }
}
