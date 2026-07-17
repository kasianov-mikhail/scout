//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import ScoutCore

struct Delta: Equatable {
    let value: Double

    init?(current: Int, previous: Int) {
        guard previous > 0 else {
            return nil
        }
        value = Double(current - previous) / Double(previous)
    }
}

extension Delta {
    var isPositive: Bool {
        value >= 0
    }

    var formatted: String {
        String(format: "%+.0f%%", value * 100)
    }
}
