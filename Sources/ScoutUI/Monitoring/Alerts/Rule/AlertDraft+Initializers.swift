//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

extension AlertDraft {
    init() {
        self.init(watch: .crashFreeDrop)
    }

    init(watch: Watch, eventName: String = "") {
        self.watch = watch
        self.eventName = eventName
        self.sensitivity = .normal
        self.stabilityThreshold = 0.995
        self.countThreshold = 100
        self.notifies = true
        self.spikeReference = .median
        self.countComparison = .above
    }

    init(rule: AlertRule) {
        self.watch = .crashFreeDrop
        self.eventName = ""
        self.sensitivity = .normal
        self.stabilityThreshold = 0.995
        self.countThreshold = 100
        self.notifies = rule.notifies
        self.spikeReference = .median
        self.countComparison = .above

        switch rule.metric {
        case .crashFreeSessions:
            applyCrashFree(rule)
        case .eventCount(let name):
            self.eventName = name
            applyEvent(rule)
        }
    }

    private mutating func applyCrashFree(_ rule: AlertRule) {
        guard case .constant(let value) = rule.condition.reference else {
            return
        }
        stabilityThreshold = value
        sensitivity = Sensitivity(holdBuckets: rule.holdBuckets)
    }

    private mutating func applyEvent(_ rule: AlertRule) {
        switch (rule.condition.comparison, rule.condition.reference) {
        case (.above, .constant(let value)):
            watch = .eventCount
            countThreshold = value
            sensitivity = Sensitivity(holdBuckets: rule.holdBuckets)
        case (.below, .constant(let value)):
            watch = .eventCount
            countThreshold = value
            countComparison = .below
            sensitivity = Sensitivity(holdBuckets: rule.holdBuckets)
        case (.above, .medianFactor(let factor)):
            watch = .eventSpike
            sensitivity = Sensitivity(spikeFactor: factor)
        case (.above, .baselineFactor(let factor)):
            watch = .eventSpike
            spikeReference = .baseline
            sensitivity = Sensitivity(spikeFactor: factor)
        case (.below, .baselineFactor(let factor)):
            watch = .eventSilence
            sensitivity = Sensitivity(silenceFactor: factor)
        default:
            watch = .eventSpike
        }
    }
}
