//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct ExitShare: Identifiable {
    let reason: ExitReason
    let count: Int
    let total: Int

    var id: ExitReason {
        reason
    }
}

extension ExitShare {
    var perMille: Double {
        total > 0 ? Double(count) * 1000 / Double(total) : 0
    }

    var formatted: String {
        String(format: "%.1f ‰", perMille)
    }
}
