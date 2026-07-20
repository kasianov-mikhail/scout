//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout

struct RecorderHistogram: Equatable {
    var counts: [Int]

    static let bucketCount = RecorderBuckets.categories.count

    init() {
        counts = Array(repeating: 0, count: Self.bucketCount)
    }
}

extension RecorderHistogram: QuantileHistogram {
    static let bounds = RecorderBuckets.bounds.map(Double.init)

    static func bucketIndex(of category: String) -> Int? {
        RecorderBuckets.index(of: category)
    }
}
