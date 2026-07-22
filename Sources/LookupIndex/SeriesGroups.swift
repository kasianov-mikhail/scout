//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct SeriesKey: Hashable, Comparable {
    let name: String
    let category: String?
    let version: String?

    static func < (lhs: Self, rhs: Self) -> Bool {
        (lhs.name, lhs.category ?? "", lhs.version ?? "") < (rhs.name, rhs.category ?? "", rhs.version ?? "")
    }
}

struct SeriesGroups {
    private var points: [SeriesKey: [MetricSeriesPoint]] = [:]

    mutating func append(_ point: MetricSeriesPoint, to key: SeriesKey) {
        points[key, default: []].append(point)
    }

    mutating func append(_ series: MetricSeries) {
        let key = SeriesKey(
            name: series.name,
            category: series.category,
            version: series.version
        )
        points[key, default: []] += series.points
    }

    var series: [MetricSeries] {
        points.sorted(by: \.key).map { key, points in
            MetricSeries(
                name: key.name,
                category: key.category,
                version: key.version,
                points: points.sorted { $0.date < $1.date }
            )
        }
    }
}

extension Sequence {
    fileprivate func sorted<Value: Comparable>(by keyPath: KeyPath<Element, Value>) -> [Element] {
        sorted { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
    }
}
