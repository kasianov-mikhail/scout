//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout

extension RetentionCohort: Fixture {
    static var samples: [RetentionCohort] {
        let weeks = 10
        let end = Date().startOfDay
        let targets: [Int: Double] = [0: 1, 1: 0.42, 3: 0.28, 7: 0.19, 14: 0.13, 30: 0.08]

        return (0..<weeks).compactMap { index -> RetentionCohort? in
            guard let start = Calendar.utc.date(byAdding: .day, value: -7 * (weeks - index), to: end) else {
                return nil
            }

            let elapsed = 7 * (weeks - index)
            let quality = 0.85 + Double(index) * 0.02
            let size = 620 + (index * 173) % 540

            let retention = dayOffsets.map { day -> Double? in
                guard day <= elapsed, let target = targets[day] else { return nil }
                return day == 0 ? 1 : min(target * quality, 0.95)
            }

            return RetentionCohort(id: start, size: size, retention: retention)
        }
    }
}
