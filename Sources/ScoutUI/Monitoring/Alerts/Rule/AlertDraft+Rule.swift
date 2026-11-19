//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

extension AlertDraft {
    var metric: AlertMetric {
        watch.isEvent ? .eventCount(name: eventName) : .crashFreeSessions
    }

    var rule: AlertRule {
        AlertRule(metric: metric, condition: condition, holdBuckets: holdBuckets, notifies: notifies)
    }

    mutating func select(_ watch: Watch) {
        guard watch != self.watch else {
            return
        }
        self.watch = watch
        if watch == .eventSpike {
            spikeReference = .median
        }
        if watch == .eventCount {
            countComparison = .above
        }
    }

    mutating func increment() {
        step(1)
    }

    mutating func decrement() {
        step(-1)
    }

    private var condition: AlertCondition {
        switch watch {
        case .crashFreeDrop:
            AlertCondition(comparison: .below, reference: .constant(stabilityThreshold))
        case .eventSpike:
            AlertCondition(comparison: .above, reference: spikeReference == .baseline ? .baselineFactor(sensitivity.spikeFactor) : .medianFactor(sensitivity.spikeFactor))
        case .eventSilence:
            AlertCondition(comparison: .below, reference: .baselineFactor(sensitivity.silenceFactor))
        case .eventCount:
            AlertCondition(comparison: countComparison, reference: .constant(countThreshold))
        }
    }

    private var holdBuckets: Int {
        watch.hasThreshold ? sensitivity.holdBuckets : 1
    }

    private mutating func step(_ direction: Double) {
        switch watch {
        case .crashFreeDrop:
            stabilityThreshold = min(0.9999, max(0.9, stabilityThreshold + direction * 0.001))
        case .eventCount:
            countThreshold = min(100_000, max(1, countThreshold + direction * 10))
        case .eventSpike, .eventSilence:
            break
        }
    }
}
