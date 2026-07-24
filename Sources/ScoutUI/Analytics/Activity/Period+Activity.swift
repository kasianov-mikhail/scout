//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension Period {
    var activityPeriod: ActivityPeriod? {
        switch self {
        case .today, .yesterday:
            .daily
        case .week:
            .weekly
        case .month:
            .monthly
        case .year:
            nil
        }
    }
}

extension ActivityPeriod: ChartTimeScale {
    var horizonDate: Date { today }

    var rangeComponent: Calendar.Component { .month }

    var pointComponent: Calendar.Component { .day }

    var acronym: String {
        switch self {
        case .daily:
            "DAU"
        case .weekly:
            "WAU"
        case .monthly:
            "MAU"
        }
    }
}
