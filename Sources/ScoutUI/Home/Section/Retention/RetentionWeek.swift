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

    var id: Date { start }

    var rate: Double? {
        guard let kept, installs > 0 else {
            return nil
        }
        return Double(kept) / Double(installs)
    }

    var pendingDays: Int? {
        guard kept == nil else {
            return nil
        }
        let daySeven = start.addingDay(7)
        let days = Calendar.utc.dateComponents([.day], from: Date().startOfDay, to: daySeven).day ?? 0

        return max(days, 0)
    }

    var pendingLabel: String? {
        guard let pendingDays else {
            return nil
        }
        return pendingDays > 0 ? "in \(pendingDays) d" : "today"
    }
}

extension [RetentionWeek] {
    static let sample: [RetentionWeek] = {
        let end = Date().startOfDay

        return [
            RetentionWeek(start: end.addingDay(-5), installs: 1104, kept: nil),
            RetentionWeek(start: end.addingDay(-12), installs: 960, kept: 192),
            RetentionWeek(start: end.addingDay(-19), installs: 1142, kept: 217),
            RetentionWeek(start: end.addingDay(-26), installs: 787, kept: 142),
        ]
    }()
}
