//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct AlertStatus: Equatable {
    let rule: AlertRule
    let outcome: AlertOutcome
    let reading: MetricReading
}

extension AlertStatus {
    var isFiring: Bool {
        if case .firing = outcome.state { true } else { false }
    }

    var isArmed: Bool {
        outcome.state == .armed
    }

    var isMuted: Bool {
        if case .muted = outcome.state { true } else { false }
    }

    var detail: String? {
        guard let current = reading.recent.last else {
            return nil
        }
        return "\(rule.metric.format(current)) — \(rule.condition.summary(format: rule.metric.format))"
    }

    var value: String? {
        reading.recent.last.map(rule.metric.format)
    }

    var summary: String {
        let condition = rule.condition
        var text = condition.summary(format: rule.metric.format)

        switch condition.reference {
        case .constant:
            break
        case .baselineFactor, .medianFactor:
            if let reference = reading.reference(for: condition) {
                text += " · \(rule.metric.format(reference))"
            }
        }

        return "\(text) for \(rule.holdBuckets) h"
    }

    func firingLabel(now: Date = .now) -> String? {
        guard case .firing(let since) = outcome.state else {
            return nil
        }
        let hours = max(1, Int(now.timeIntervalSince(since) / 3600))
        return "Firing \(hours) h"
    }

    var mutedLabel: String? {
        guard case .muted(let until) = outcome.state else {
            return nil
        }
        let time = until.formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits))
        return "Muted till \(time)"
    }
}

extension [AlertStatus] {
    var firing: [AlertStatus] {
        filter(\.isFiring)
    }

    var armed: [AlertStatus] {
        filter(\.isArmed)
    }

    var muted: [AlertStatus] {
        filter(\.isMuted)
    }
}
