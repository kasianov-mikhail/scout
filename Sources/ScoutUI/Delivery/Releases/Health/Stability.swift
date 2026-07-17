//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct Stability: Ratio {
    let value: Double

    init(_ value: Double) {
        self.value = value
    }

    var color: Color {
        switch value {
        case 0.995...: .green
        case 0.99..<0.995: .yellow
        case 0.98..<0.99: .orange
        default: .red
        }
    }

    var formatted: String {
        percentage(fractionDigits: 2)
    }
}

extension Stability {
    init(of affected: Int, in total: Int) {
        if total > 0 {
            value = max(0, 1 - Double(affected) / Double(total))
        } else if affected > 0 {
            value = 0
        } else {
            value = 1
        }
    }

    static func optional(of affected: Int, in total: Int) -> Stability? {
        total > 0 ? Stability(of: affected, in: total) : nil
    }
}
