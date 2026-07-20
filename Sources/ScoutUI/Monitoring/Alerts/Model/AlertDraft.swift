//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct AlertDraft: Equatable {
    var choice = MetricChoice.crashFreeSessions
    var eventName = ""
    var kind = Kind.fallsBelow
    var stabilityThreshold = 0.995
    var countThreshold = 100.0
    var factor = 2.0
    var hold = Hold.oneHour
    var notifies = true
}

extension AlertDraft {
    enum MetricChoice: CaseIterable {
        case crashFreeSessions
        case eventCount

        var label: String {
            switch self {
            case .crashFreeSessions:
                "Crash-free sessions"
            case .eventCount:
                "Event count"
            }
        }
    }

    enum Kind: CaseIterable {
        case fallsBelow
        case risesAbove
        case spikes

        var label: String {
            switch self {
            case .fallsBelow:
                "Falls below"
            case .risesAbove:
                "Rises above"
            case .spikes:
                "Spikes"
            }
        }
    }

    enum Hold: CaseIterable {
        case oneHour
        case twoHours
        case sixHours
        case day

        var buckets: Int {
            switch self {
            case .oneHour:
                1
            case .twoHours:
                2
            case .sixHours:
                6
            case .day:
                24
            }
        }

        var label: String {
            switch self {
            case .oneHour:
                "1h"
            case .twoHours:
                "2h"
            case .sixHours:
                "6h"
            case .day:
                "24h"
            }
        }
    }
}

extension AlertDraft {
    var metric: AlertMetric {
        switch choice {
        case .crashFreeSessions:
            .crashFreeSessions
        case .eventCount:
            .eventCount(name: eventName)
        }
    }

    var rule: AlertRule {
        AlertRule(metric: metric, condition: condition, holdBuckets: hold.buckets, notifies: notifies)
    }

    var isValid: Bool {
        choice == .crashFreeSessions || eventName.count > 0
    }

    private var condition: AlertCondition {
        switch kind {
        case .fallsBelow:
            AlertCondition(comparison: .below, reference: .constant(constant))
        case .risesAbove:
            AlertCondition(comparison: .above, reference: .baselineFactor(factor))
        case .spikes:
            AlertCondition(comparison: .above, reference: .medianFactor(factor))
        }
    }

    private var constant: Double {
        choice == .crashFreeSessions ? stabilityThreshold : countThreshold
    }
}

extension AlertDraft {
    var valueText: String {
        switch kind {
        case .fallsBelow:
            choice == .crashFreeSessions ? Stability(stabilityThreshold).formatted : String(Int(countThreshold))
        case .risesAbove, .spikes:
            String(format: "%g×", factor)
        }
    }

    mutating func increment() {
        step(1)
    }

    mutating func decrement() {
        step(-1)
    }

    private mutating func step(_ direction: Double) {
        switch kind {
        case .fallsBelow where choice == .crashFreeSessions:
            stabilityThreshold = min(0.9999, max(0.9, stabilityThreshold + direction * 0.001))
        case .fallsBelow:
            countThreshold = min(100_000, max(1, countThreshold + direction * 10))
        case .risesAbove, .spikes:
            factor = min(10, max(1.5, factor + direction * 0.5))
        }
    }
}
