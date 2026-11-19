//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout

extension Telemetry.Export {
    var rank: Int {
        switch self {
        case .counter:
            0
        case .floatingCounter:
            1
        case .timer:
            2
        case .recorder:
            3
        case .meter:
            4
        }
    }
}
