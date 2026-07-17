//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout

protocol MetricHistogram {
    init()
    var counts: [Int] { get set }
    static var bucketCount: Int { get }
    static func bucketIndex(of category: String) -> Int?
}

extension MetricHistogram {
    var total: Int {
        counts.reduce(0, +)
    }

    mutating func add(count: Int, at index: Int) {
        guard counts.indices.contains(index) else { return }
        counts[index] += count
    }

    static func + (lhs: Self, rhs: Self) -> Self {
        var sum = Self()
        sum.counts = zip(lhs.counts, rhs.counts).map(+)
        return sum
    }

    static func buckets(from series: [MetricSeries]) -> [Date: Self] {
        var result: [Date: Self] = [:]

        for singleSeries in series {
            guard let category = singleSeries.category, let index = bucketIndex(of: category) else {
                continue
            }
            for point in singleSeries.points {
                let date = Date(millisecondsSince1970: point.date)
                result[date, default: Self()].add(count: Int(point.value.doubleValue), at: index)
            }
        }

        return result
    }
}
