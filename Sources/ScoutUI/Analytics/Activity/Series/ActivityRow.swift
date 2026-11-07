//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct ActivityRow: Identifiable {
    let date: Date
    let metric: ActivityMetric
    let fraction: Double
    let isOldest: Bool

    var id: Date { date }

    var dayLabel: String {
        DateFormatter.weekdayDay.string(from: date)
    }

    var valueLabel: String {
        metric.valueLabel
    }

    var deltaLabel: String {
        metric.deltaLabel(precision: 0)
    }

    var isRising: Bool {
        metric.isRising
    }
}

extension DateFormatter {
    static let weekdayDay = DateFormatter(format: "EEE d")
}
