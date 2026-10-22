//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Telemetry {
    package enum Export: String, CaseIterable {
        case counter = "counter"
        case floatingCounter = "floating_counter"
        case meter = "meter"
        case recorder = "recorder"
        case timer = "timer"

        package var hasResets: Bool {
            self == .counter || self == .floatingCounter
        }
    }
}
