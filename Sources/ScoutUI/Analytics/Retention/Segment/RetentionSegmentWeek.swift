//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct RetentionSegmentWeek: Identifiable {
    let start: Date
    let kept: Int
    let rate: Double
    let isCurrent: Bool

    var id: Date { start }

    var dateLabel: String {
        DateFormatter.monthDay.string(from: start)
    }

    var keptLabel: String {
        kept.formatted(.count)
    }

    var rateLabel: String {
        rate.formatted(.retentionRate)
    }

    var fraction: Double {
        min(rate / RetentionDayValue.barScale, 1)
    }
}
