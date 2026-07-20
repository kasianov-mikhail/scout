//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct AlertOutcome: Equatable {
    let state: AlertState
    let shouldNotify: Bool
}

struct AlertEvaluator {
    func evaluate(_ rule: AlertRule, reading: MetricReading, state: AlertState, now: Date) -> AlertOutcome {
        if case .muted(let until) = state, now < until {
            return AlertOutcome(state: state, shouldNotify: false)
        }

        guard rule.isSustained(in: reading) else {
            return AlertOutcome(state: .armed, shouldNotify: false)
        }

        if case .firing(let since) = state {
            return AlertOutcome(state: .firing(since: since), shouldNotify: false)
        }

        return AlertOutcome(state: .firing(since: now), shouldNotify: true)
    }
}
