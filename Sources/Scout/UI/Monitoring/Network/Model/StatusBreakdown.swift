//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct StatusBreakdown: Equatable {
    private(set) var counts: [Int]

    init() {
        counts = Array(repeating: 0, count: StatusBuckets.categories.count)
    }

    var total: Int {
        counts.reduce(0, +)
    }

    var successRate: Stability {
        Stability(of: errors, in: total)
    }

    private var errors: Int {
        counts.suffix(2).reduce(0, +)
    }

    mutating func add(count: Int, at index: Int) {
        guard counts.indices.contains(index) else { return }
        counts[index] += count
    }

    static func + (lhs: StatusBreakdown, rhs: StatusBreakdown) -> StatusBreakdown {
        var sum = StatusBreakdown()
        sum.counts = zip(lhs.counts, rhs.counts).map(+)
        return sum
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
