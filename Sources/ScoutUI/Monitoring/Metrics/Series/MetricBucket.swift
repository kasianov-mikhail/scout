//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct MetricBucket: Identifiable {
    let date: Date
    let value: Double?
    let previous: Double?
    let isFuture: Bool
    let isCurrent: Bool

    var id: Date { date }
}

struct MetricRow: Identifiable {
    let date: Date
    let value: Double?
    let previous: Double?
    let isCurrent: Bool
    let isOldest: Bool
    let fraction: Double

    var id: Date { date }

    var delta: Delta? {
        guard let value, let previous else {
            return nil
        }
        return Delta(current: value, previous: previous)
    }
}

enum MetricTone: Equatable {
    case positive
    case neutral
    case warning
}

extension [MetricBucket] {
    var rows: [MetricRow] {
        let visible = filter { !$0.isFuture }
        let maximum = visible.compactMap(\.value).max() ?? 0

        return visible.reversed().enumerated().map { index, bucket in
            MetricRow(
                date: bucket.date,
                value: bucket.value,
                previous: bucket.previous,
                isCurrent: bucket.isCurrent,
                isOldest: index == visible.count - 1,
                fraction: maximum > 0 ? (bucket.value ?? 0) / maximum : 0
            )
        }
    }
}

extension Delta {
    init?(current: Double, previous: Double) {
        guard previous > 0 else {
            return nil
        }
        value = (current - previous) / previous
    }
}
