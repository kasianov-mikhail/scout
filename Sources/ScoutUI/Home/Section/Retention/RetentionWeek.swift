//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct RetentionWeek: Identifiable {
    let start: Date
    let installs: Int
    let kept: Int?
    let day: RetentionDay
    var now: Date = Date()

    var id: Date { start }

    var label: String {
        DateFormatter.monthDay.string(from: start)
    }

    var rate: Double? {
        guard let kept, installs > 0 else {
            return nil
        }
        return Double(kept) / Double(installs)
    }

    var keptLabel: String? {
        kept.map { $0.formatted(.count) }
    }

    var rateLabel: String? {
        rate.map { $0.formatted(.retentionRate) }
    }

    var pendingLabel: String? {
        guard kept == nil else {
            return nil
        }
        return day.pendingLabel(week: start, now: now)
    }
}

extension RetentionWeek: Fixture {
    static var samples: [RetentionWeek] {
        let end = HomeSnapshot.date

        return [
            RetentionWeek(start: end.addingDay(-5), installs: 1104, kept: nil, day: .day7, now: end),
            RetentionWeek(start: end.addingDay(-12), installs: 960, kept: 192, day: .day7, now: end),
            RetentionWeek(start: end.addingDay(-19), installs: 1142, kept: 217, day: .day7, now: end),
            RetentionWeek(start: end.addingDay(-26), installs: 787, kept: 142, day: .day7, now: end),
        ]
    }
}

extension [RetentionWeek] {
    var maxInstalls: Int {
        map(\.installs).max() ?? 0
    }
}
