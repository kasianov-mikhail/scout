//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension MetricSeries {
    package static func merge(ints: [MetricSeries], doubles: [MetricSeries], values: MetricSeriesQuery.Values?) -> [MetricSeries] {
        guard values == nil else {
            return (ints + doubles).nonEmptySorted
        }

        let keys = Set(ints.map(\.key))
        return (ints + doubles.filter { !keys.contains($0.key) }).nonEmptySorted
    }
}

extension [MetricSeries] {
    var nonEmptySorted: [MetricSeries] {
        filter {
            !$0.points.isEmpty
        }
        .sorted {
            $0.key < $1.key
        }
    }
}
