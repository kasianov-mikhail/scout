//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct ExitSummary {
    let counts: [ExitReason: Int]
}

extension ExitSummary {
    var total: Int {
        counts.values.reduce(0, +)
    }

    var clean: Stability? {
        Stability.optional(of: abnormal.map(\.count).reduce(0, +), in: total)
    }

    var abnormal: [ExitShare] {
        counts
            .filter { !$0.key.isClean && $0.value > 0 }
            .map { ExitShare(reason: $0.key, count: $0.value, total: total) }
            .sorted { $0.count == $1.count ? $0.reason.rawValue < $1.reason.rawValue : $0.count > $1.count }
    }
}
