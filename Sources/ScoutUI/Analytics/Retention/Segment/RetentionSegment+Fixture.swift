//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout

extension RetentionSegment {
    static func samples(size: Int, retention: [Double?]) -> [RetentionSegment] {
        let variants: [(name: String, share: Double, factor: Double, crashed: Double, hanged: Double)] = [
            ("iOS 18", 0.55, 1.12, 0.004, 0.009),
            ("iOS 17", 0.31, 0.95, 0.009, 0.016),
            ("iOS 16", 0.14, 0.76, 0.021, 0.034),
        ]

        return variants.map { variant in
            let installs = Int(Double(size) * variant.share)

            return RetentionSegment(
                name: variant.name,
                size: installs,
                retention: retention.map { $0.map { min($0 * variant.factor, 0.98) } },
                crashes: Int((Double(installs) * variant.crashed).rounded()),
                hangs: Int((Double(installs) * variant.hanged).rounded())
            )
        }
    }
}
