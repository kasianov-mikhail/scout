//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct MetricsSeries<T: ChartNumeric>: Identifiable {
    let id: String
    let points: [ChartPoint<T>]

    init?(id: String, points: [ChartPoint<T>]) {
        if points.isEmpty {
            return nil
        }
        self.id = id
        self.points = points
    }

    var title: String {
        "\(id) – \(points.total)"
    }
}

// MARK: -

extension MetricsSeries: Comparable {
    static func < (lhs: MetricsSeries<T>, rhs: MetricsSeries<T>) -> Bool {
        lhs.points.total > rhs.points.total
    }
}

extension MetricsSeries: CustomStringConvertible {
    var description: String {
        let dates = points.map(\.date)
        let start = dates.min().map(ISO8601DateFormatter().string) ?? "n/a"
        let end = dates.max().map(ISO8601DateFormatter().string) ?? "n/a"

        return "MetricsSeries(id: \(id), points: \(points.count), total: \(points.total), range: \(start) – \(end))"
    }
}
