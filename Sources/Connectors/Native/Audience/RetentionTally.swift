//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import ScoutDB

struct RetentionTally {
    let week: Date
    let milestone: RetentionMilestone
    let system: String?
    let count: Int
}

extension RetentionTally {
    init?(point: SeriesPoint) {
        guard let key = SystemScopedKey(key: point.group), let milestone = RetentionMilestone(name: key.value) else {
            return nil
        }
        self.init(week: point.date.startOfWeek, milestone: milestone, system: key.system, count: Int(point.value))
    }
}
