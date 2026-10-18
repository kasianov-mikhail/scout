//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

private let memoryInterval: TimeInterval = 60

struct ConditionLog {
    private var states: [Condition.Group: Condition] = [:]
    private var memory: [Condition: Date] = [:]

    mutating func start(current: [Condition]) -> [Condition] {
        for condition in current {
            states[condition.group] = condition
        }
        return current.filter { !$0.isDefault }
    }

    mutating func admits(condition: Condition, date: Date) -> Bool {
        switch condition.group {
        case .memory:
            if let last = memory[condition], date.timeIntervalSince(last) < memoryInterval {
                return false
            }
            memory[condition] = date
            return true
        case .thermal, .power:
            guard states[condition.group] != condition else {
                return false
            }
            states[condition.group] = condition
            return true
        }
    }
}
