//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

protocol MetricHistogram {
    init()
    mutating func add(count: Int, at index: Int)
    static func bucketIndex(of category: String) -> Int?
}

extension MetricHistogram {
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
