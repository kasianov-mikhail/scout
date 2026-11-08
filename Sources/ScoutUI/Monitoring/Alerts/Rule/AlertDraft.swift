//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct AlertDraft: Equatable {
    var watch: Watch
    var eventName: String
    var sensitivity: Sensitivity
    var stabilityThreshold: Double
    var countThreshold: Double
    var notifies: Bool

    private var spikeReference: SpikeReference
    private var countComparison: AlertCondition.Comparison
}

extension AlertDraft {
    enum Watch: CaseIterable, Hashable {
        case crashFreeDrop
        case eventSpike
        case eventSilence
        case eventCount
    }

    enum Sensitivity: CaseIterable, Hashable {
        case low
        case normal
        case high
    }

    fileprivate enum SpikeReference: Hashable {
        case median
        case baseline
    }
}

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
}

extension AlertDraft {
    var metric: AlertMetric {
        watch.isEvent ? .eventCount(name: eventName) : .crashFreeSessions
    }

    var rule: AlertRule {
        AlertRule(metric: metric, condition: condition, holdBuckets: holdBuckets, notifies: notifies)
    }

    var isValid: Bool {
        !watch.isEvent || !eventName.isEmpty
    }

    var title: String {
        watch.isEvent && !eventName.isEmpty ? eventName : "New Alert"
    }

    var valueText: String {
        switch watch {
        case .crashFreeDrop:
            Stability(stabilityThreshold).formatted
        case .eventCount:
            String(Int(countThreshold))
        case .eventSpike, .eventSilence:
            ""
        }
    }

    var thresholdTitle: String {
        if watch == .eventCount, countComparison == .below {
            "Alert below"
        } else {
            watch == .eventCount ? "Alert above" : "Alert below"
        }
    }

    var thresholdUnit: String {
        watch == .eventCount ? "an hour" : "crash-free"
    }

    var countIsBelow: Bool {
        countComparison == .below
    }

    var hint: String {
        switch watch {
        case .crashFreeDrop:
            "Alert after \(sensitivity.holdBuckets) \(hoursWord(sensitivity.holdBuckets)) below the line, so one bad hour does not wake you."
        case .eventSpike:
            "Alert when the event stays at this level for a full hour."
        case .eventSilence:
            "Alert when the event stays quiet for a full hour."
        case .eventCount:
            "Alert when the event stays \(countComparison == .below ? "below" : "above") this number for \(hoursWord(sensitivity.holdBuckets))."
        }
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
}

extension AlertDraft {
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

    private func hoursWord(_ hours: Int) -> String {
        hours == 1 ? "hour" : "hours"
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

extension AlertDraft.Watch {
    var title: String {
        switch self {
        case .crashFreeDrop:
            "Crash-free drops"
        case .eventSpike:
            "Event spikes"
        case .eventSilence:
            "Event goes quiet"
        case .eventCount:
            "Event passes a number"
        }
    }

    var templateTitle: String {
        switch self {
        case .crashFreeDrop:
            "Crash-free sessions drop"
        case .eventSpike:
            "An event spikes"
        case .eventSilence:
            "An event goes quiet"
        case .eventCount:
            "An event passes a number"
        }
    }

    var detail: String {
        switch self {
        case .crashFreeDrop:
            "Fewer sessions end without a crash"
        case .eventSpike:
            "An event happens much more often than usual"
        case .eventSilence:
            "An event stops arriving"
        case .eventCount:
            "An event count goes over a limit you set"
        }
    }

    var templateDetail: String {
        switch self {
        case .crashFreeDrop:
            "Alert when fewer than 99.5% of sessions end without a crash."
        case .eventSpike:
            "Alert when an event happens much more often than usual, like PaymentDeclined at night."
        case .eventSilence:
            "Alert when an event happens much less than usual, like CheckoutCompleted stopping."
        case .eventCount:
            "Alert when an event happens more than a set number of times an hour."
        }
    }

    var summary: String {
        switch self {
        case .crashFreeDrop:
            "Fewer sessions end without a crash"
        case .eventSpike:
            "It happens much more often than usual"
        case .eventSilence:
            "It stops arriving"
        case .eventCount:
            "The count goes over a limit you set"
        }
    }

    var isEvent: Bool {
        self != .crashFreeDrop
    }

    var hasThreshold: Bool {
        self == .crashFreeDrop || self == .eventCount
    }

    func detail(for sensitivity: AlertDraft.Sensitivity, isBelow: Bool = false) -> String {
        switch self {
        case .crashFreeDrop:
            "\(sensitivity.holdBuckets) h below"
        case .eventCount:
            "\(sensitivity.holdBuckets) h \(isBelow ? "below" : "above")"
        case .eventSpike:
            String(format: "%g× usual", sensitivity.spikeFactor)
        case .eventSilence:
            String(format: "%g× usual", sensitivity.silenceFactor)
        }
    }
}

extension AlertDraft.Sensitivity {
    var title: String {
        switch self {
        case .low:
            "Low"
        case .normal:
            "Normal"
        case .high:
            "High"
        }
    }

    var holdBuckets: Int {
        switch self {
        case .low:
            3
        case .normal:
            2
        case .high:
            1
        }
    }

    var spikeFactor: Double {
        switch self {
        case .low:
            5
        case .normal:
            3
        case .high:
            2
        }
    }

    var silenceFactor: Double {
        switch self {
        case .low:
            0.25
        case .normal:
            0.5
        case .high:
            0.75
        }
    }
}

extension AlertDraft.Sensitivity {
    fileprivate init(holdBuckets: Int) {
        switch holdBuckets {
        case ...1:
            self = .high
        case 2:
            self = .normal
        default:
            self = .low
        }
    }

    fileprivate init(spikeFactor: Double) {
        self =
            Self.allCases.min {
                abs($0.spikeFactor - spikeFactor) < abs($1.spikeFactor - spikeFactor)
            } ?? .normal
    }

    fileprivate init(silenceFactor: Double) {
        self =
            Self.allCases.min {
                abs($0.silenceFactor - silenceFactor) < abs($1.silenceFactor - silenceFactor)
            } ?? .normal
    }
}
