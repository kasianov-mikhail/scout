//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import ScoutCore

struct RefreshSchedule {
    private static let seeds = (3, 5)
    private static let maxSeconds = 89

    private var current = RefreshSchedule.seeds.0
    private var next = RefreshSchedule.seeds.1

    var delay: Duration {
        .seconds(current)
    }

    mutating func recordSuccess() {
        (current, next) = RefreshSchedule.seeds
    }

    mutating func recordFailure() {
        (current, next) = (next, min(current + next, RefreshSchedule.maxSeconds))
    }
}
