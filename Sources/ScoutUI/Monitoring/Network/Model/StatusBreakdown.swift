//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import ScoutCore
import SwiftUI

struct StatusBreakdown: Equatable {
    var counts: [Int]

    static let bucketCount = StatusBuckets.categories.count

    init() {
        counts = Array(repeating: 0, count: Self.bucketCount)
    }

    var successRate: Stability {
        Stability(of: errors, in: total)
    }

    private var errors: Int {
        counts.suffix(2).reduce(0, +)
    }

    private static let colors: [Color] = [.green, .blue, .orange, .red]

    var segments: [Segment] {
        zip(StatusBuckets.classes, zip(counts, Self.colors)).map { label, pair in
            Segment(label: label, count: pair.0, color: pair.1)
        }
    }
}

extension StatusBreakdown: MetricHistogram {
    static func bucketIndex(of category: String) -> Int? {
        StatusBuckets.index(of: category)
    }
}

extension StatusBreakdown {
    static func sample(success: Int, redirect: Int = 0, clientError: Int = 0, serverError: Int = 0) -> StatusBreakdown {
        var breakdown = StatusBreakdown()
        breakdown.add(count: success, at: 0)
        breakdown.add(count: redirect, at: 1)
        breakdown.add(count: clientError, at: 2)
        breakdown.add(count: serverError, at: 3)
        return breakdown
    }
}
