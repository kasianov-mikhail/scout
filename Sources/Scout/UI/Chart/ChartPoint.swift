//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import CloudKit

struct ChartPoint<T: ChartNumeric>: Identifiable, BucketPoint {
    let id = UUID()
    let date: Date
    let count: T
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

extension ChartPoint: CustomStringConvertible {
    var description: String {
        "\(date): \(count)"
    }
}

// MARK: - Sample Data

extension [ChartPoint<Int>] {
    static let empty: Self = []

    static var sample: Self {
        let end = Date()
        return (1...30).compactMap { i in
            Calendar(identifier: .iso8601).date(byAdding: .day, value: -i, to: end).map {
                ChartPoint(date: $0, count: .random(in: 0...10))
            }
        }
        .sorted()
    }
}
