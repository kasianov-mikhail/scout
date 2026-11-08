//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct TimelineSample {
    let rail: Rail
    let incidents: TimelineIncidents

    var focus: TimelineFocus? {
        incidents.crashes.first { $0.sessionID != nil }.map { TimelineFocus(crash: $0) }
    }

    static var sample: TimelineSample {
        let records = Records.sample
        return TimelineSample(rail: records.rail, incidents: records.incidents)
    }
}

extension TimelineSample {
    struct Records {
        let rail: Rail
        let incidents: TimelineIncidents
    }
}
