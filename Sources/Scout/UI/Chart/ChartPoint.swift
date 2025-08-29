//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

typealias ChartData<T: ChartCompatible> = [T: [ChartPoint]]

struct ChartPoint: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int

    static func fromIntMatrix(_ matrix: Matrix<Cell<Int>>) -> [ChartPoint] {
        matrix.cells.map { cell in
            ChartPoint(
                date: matrix.date.addingDay(cell.row - 1).addingHour(cell.column),
                count: cell.value
            )
        }
    }
}

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

extension [ChartPoint] {
    var count: Int {
        map(\.count).reduce(0, +)
    }
}

extension ChartPoint: CustomStringConvertible {
    var description: String {
        "\(date): \(count)"
    }
}
