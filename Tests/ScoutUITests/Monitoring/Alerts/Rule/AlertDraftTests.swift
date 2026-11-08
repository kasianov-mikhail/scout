//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import ScoutUI

struct AlertDraftTests {
    @Test("The default draft is a crash-free drop")
    func defaults() {
        let rule = AlertDraft().rule

        #expect(rule.metric == .crashFreeSessions)
        #expect(rule.condition == AlertCondition(comparison: .below, reference: .constant(0.995)))
        #expect(rule.holdBuckets == 2)
        #expect(rule.notifies)
    }

    @Test("An event spike uses the median factor")
    func spike() {
        let draft = AlertDraft(watch: .eventSpike, eventName: "Error")

        #expect(draft.rule.metric == .eventCount(name: "Error"))
        #expect(draft.rule.condition == AlertCondition(comparison: .above, reference: .medianFactor(3)))
        #expect(draft.rule.holdBuckets == 1)
    }

    @Test("A quiet event falls below the baseline factor")
    func silence() {
        let draft = AlertDraft(watch: .eventSilence, eventName: "Checkout")

        #expect(draft.rule.condition == AlertCondition(comparison: .below, reference: .baselineFactor(0.5)))
        #expect(draft.rule.holdBuckets == 1)
    }

    @Test("An event count passes a constant number")
    func count() {
        var draft = AlertDraft(watch: .eventCount, eventName: "Error")
        draft.countThreshold = 50

        #expect(draft.rule.condition == AlertCondition(comparison: .above, reference: .constant(50)))
        #expect(draft.rule.holdBuckets == 2)
    }

    @Test("An event draft without a name is invalid")
    func invalid() {
        var draft = AlertDraft(watch: .eventSpike)

        #expect(!draft.isValid)

        draft.eventName = "Error"

        #expect(draft.isValid)
    }

    @Test("The sensitivity labels follow the watch")
    func labels() {
        #expect(AlertDraft.Watch.crashFreeDrop.detail(for: .normal) == "2 h below")
        #expect(AlertDraft.Watch.eventSpike.detail(for: .normal) == "3× usual")
        #expect(AlertDraft.Watch.eventSilence.detail(for: .low) == "0.25× usual")
        #expect(AlertDraft.Watch.eventCount.detail(for: .high) == "1 h above")
        #expect(AlertDraft.Watch.eventCount.detail(for: .high, isBelow: true) == "1 h below")
    }

    @Test("The threshold steps respect their bounds")
    func stepping() {
        var draft = AlertDraft()
        draft.stabilityThreshold = 0.9995

        for _ in 0..<10 {
            draft.increment()
        }

        #expect(draft.stabilityThreshold == 0.9999)

        for _ in 0..<200 {
            draft.decrement()
        }

        #expect(draft.stabilityThreshold == 0.9)

        draft.select(.eventCount)
        draft.countThreshold = 1
        draft.decrement()

        #expect(draft.countThreshold == 1)
    }

    @Test("A rule round-trips through the draft")
    func roundTrip() {
        let rules = [
            AlertRule(metric: .crashFreeSessions, condition: AlertCondition(comparison: .below, reference: .constant(0.997)), holdBuckets: 2),
            AlertRule(metric: .eventCount(name: "Error"), condition: AlertCondition(comparison: .above, reference: .medianFactor(3))),
            AlertRule(metric: .eventCount(name: "Error"), condition: AlertCondition(comparison: .below, reference: .baselineFactor(0.5))),
            AlertRule(metric: .eventCount(name: "Error"), condition: AlertCondition(comparison: .above, reference: .constant(40)), holdBuckets: 2),
            AlertRule(metric: .eventCount(name: "Error"), condition: AlertCondition(comparison: .below, reference: .constant(40)), holdBuckets: 2),
        ]

        for rule in rules {
            #expect(AlertDraft(rule: rule).rule == rule)
        }
    }

    @Test("An older baseline spike keeps its reference")
    func baselineSpike() {
        let rule = AlertRule(metric: .eventCount(name: "Error"), condition: AlertCondition(comparison: .above, reference: .baselineFactor(2)))

        #expect(AlertDraft(rule: rule).rule == rule)
    }

    @Test("The hint describes the selected sensitivity")
    func hint() {
        let draft = AlertDraft()

        #expect(draft.hint == "Alert after 2 hours below the line, so one bad hour does not wake you.")
    }
}
