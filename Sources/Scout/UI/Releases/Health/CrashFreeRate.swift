//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct CrashFreeRate: Equatable {
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
        String(format: "%.2f%%", value * 100)
    }

    var ringTrim: Double {
        max(0, min(1, (value - 0.95) / 0.05))
    }
}

extension CrashFreeRate: ExpressibleByFloatLiteral {
    init(floatLiteral value: Double) {
        self.value = value
    }
}

extension CrashFreeRate {
    init(affected: Int, total: Int) {
        if total > 0 {
            value = max(0, 1 - Double(affected) / Double(total))
        } else {
            value = 1
        }
    }
}
