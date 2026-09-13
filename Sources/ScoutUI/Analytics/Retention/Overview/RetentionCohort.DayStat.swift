//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout

extension RetentionCohort {
    struct DayStat: Identifiable {
        let day: Int
        let average: Double
        let low: Double
        let high: Double
        var id: Int { day }
    }
}

extension [RetentionCohort] {
    var stats: [RetentionCohort.DayStat] {
        RetentionCohort.dayOffsets.compactMap { day in
            let rates = compactMap {
                RetentionCohort.rate($0.retention, onDay: day)
            }
            guard rates.count > 0 else {
                return nil
            }
            return RetentionCohort.DayStat(
                day: day, average: rates.reduce(0, +) / Double(rates.count), low: rates.min() ?? 0,
                high: rates.max() ?? 0
            )
        }
    }
}
