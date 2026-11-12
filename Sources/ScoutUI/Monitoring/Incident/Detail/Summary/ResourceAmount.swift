//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct ResourceAmount {
    let value: Double
    let unit: String

    init(value: Double, unit: String) {
        self.value = value
        self.unit = unit
    }

    init?(reason: String?) {
        guard let reason else {
            return nil
        }
        let parts = reason.split(separator: " ")
        guard parts.count >= 2, let value = Double(parts[0]) else {
            return nil
        }
        self.init(value: value, unit: String(parts[1]))
    }

    var text: String {
        let number = value.rounded() == value ? String(Int(value)) : String(format: "%.1f", value)
        return unit.isEmpty ? number : "\(number) \(unit)"
    }
}

extension ResourceKind {
    var peakTitle: String {
        switch self {
        case .cpu:
            "PEAK CPU"
        case .diskWrite:
            "PEAK DISK"
        }
    }
}
