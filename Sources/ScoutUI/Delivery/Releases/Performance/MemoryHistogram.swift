//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout

struct MemoryHistogram: Equatable {
    var counts: [Int]

    static let bucketCount = 80

    init() {
        counts = Array(repeating: 0, count: Self.bucketCount)
    }
}

extension MemoryHistogram: QuantileHistogram {
    static let bounds = (1...bucketCount).map { Double($0 * PerformanceMetric.memoryStep) }

    static func bucketIndex(of category: String) -> Int? {
        Int(category).map { min($0 / PerformanceMetric.memoryStep, bucketCount - 1) }
    }
}
