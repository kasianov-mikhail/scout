//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension AlertStatus {
    var buckets: [AlertHistory.Bucket] {
        let breached = reading.recent.suffix(24).map {
            rule.condition.isBreached(by: $0, in: reading)
        }
        let firing = isFiring ? breached.reversed().prefix(while: { $0 }).count : 0

        var buckets = [AlertHistory.Bucket](repeating: .clear, count: 24)
        let offset = 24 - breached.count

        for (index, isBreached) in breached.enumerated() where isBreached {
            buckets[offset + index] = index >= breached.count - firing ? .firing : .muted
        }

        return buckets
    }
}

extension [AlertStatus] {
    var buckets: [AlertHistory.Bucket] {
        var buckets = [AlertHistory.Bucket](repeating: .clear, count: 24)

        for status in self {
            let recent = status.reading.recent.suffix(24)
            let offset = 24 - recent.count

            for (index, value) in recent.enumerated()
            where status.rule.condition.isBreached(by: value, in: status.reading) {
                let bucketIndex = offset + index

                if case .muted = status.outcome.state {
                    if buckets[bucketIndex] == .clear {
                        buckets[bucketIndex] = .muted
                    }
                } else {
                    buckets[bucketIndex] = .firing
                }
            }
        }

        return buckets
    }
}
