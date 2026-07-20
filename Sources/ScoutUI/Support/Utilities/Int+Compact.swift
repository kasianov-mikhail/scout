//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension Int {
    var compact: String {
        // Thresholds sit just below each round boundary so `%.1f` rounding rolls a
        // value up to the next unit instead of overflowing it (999_999 → "1.0M", not "1000.0K").
        switch self {
        case 999_950_000...: String(format: "%.1fB", Double(self) / 1_000_000_000)
        case 999_950...: String(format: "%.1fM", Double(self) / 1_000_000)
        case 1_000...: String(format: "%.1fK", Double(self) / 1_000)
        default: "\(self)"
        }
    }
}
