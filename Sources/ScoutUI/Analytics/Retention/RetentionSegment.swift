//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout

struct RetentionSegment: Identifiable {
    let name: String
    let retention: [Double?]
    let crashRate: Double
    let hangRate: Double
    var id: String { name }
}

extension RetentionCohort {
    var segments: [RetentionSegment] {
        let variants: [(name: String, factor: Double, crashRate: Double, hangRate: Double)] = [
            ("iOS 18", 1.12, 0.4, 0.9),
            ("iOS 17", 0.95, 0.9, 1.6),
            ("iOS 16", 0.76, 2.1, 3.4),
        ]

        return variants.map { variant in
            RetentionSegment(
                name: variant.name,
                retention: retention.map { $0.map { min($0 * variant.factor, 0.98) } },
                crashRate: variant.crashRate,
                hangRate: variant.hangRate
            )
        }
    }
}
