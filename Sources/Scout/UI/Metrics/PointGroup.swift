//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct PointGroup<T: ChartNumeric>: Identifiable {
    let name: String
    let points: [ChartPoint<T>]
    let id = UUID()

    var hasPoints: Bool {
        points.total > .zero
    }
}

extension PointGroup: Comparable {
    static func < (lhs: PointGroup<T>, rhs: PointGroup<T>) -> Bool {
        lhs.points.total > rhs.points.total
    }
}

// MARK: - Period Filtering

extension PointGroup {
    func group(on period: Period) -> PointGroup<T> {
        PointGroup(
            name: name,
            points: points(on: period)
        )
    }

    func points(on period: Period) -> [ChartPoint<T>] {
        points.filter { point in
            period.initialRange.contains(point.date)
        }
    }
}

// MARK: -

extension Sequence {
    func pointGroups<T: ChartNumeric>() -> [PointGroup<T>] where Element == GridMatrix<T> {
        Dictionary(grouping: self, by: \.name)
            .mapValues { $0.flatMap(\.points) }
            .map(PointGroup.init)
    }
}

extension PointGroup: CustomStringConvertible {
    var description: String {
        let dates = points.map(\.date)
        let start = dates.min().map(ISO8601DateFormatter().string)!
        let end = dates.max().map(ISO8601DateFormatter().string)!

        return """
            PointGroup(
              name: \(name),
              points: \(points.count),
              total: \(points.total),
              range: \(start) – \(end)
            )
            """
    }
}
