//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout

struct LaunchHistogram: Equatable {
    var counts: [Int]

    static let bucketCount = 100

    init() {
        counts = Array(repeating: 0, count: Self.bucketCount)
    }
}

extension LaunchHistogram: QuantileHistogram {
    static let bounds = (1...bucketCount).map { Double($0 * PerformanceMetric.launchStep) }

    static func bucketIndex(of category: String) -> Int? {
        Int(category).map { min($0 / PerformanceMetric.launchStep, bucketCount - 1) }
    }
}
