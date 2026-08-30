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
    @Test("The default draft is a crash-free threshold rule")
    func defaults() {
        let rule = AlertDraft().rule

        #expect(rule.metric == .crashFreeSessions)
        #expect(rule.condition == AlertCondition(comparison: .below, reference: .constant(0.995)))
        #expect(rule.holdBuckets == 1)
        #expect(rule.notifies)
    }

    @Test("Rising above maps to a baseline factor")
    func risesAbove() {
        var draft = AlertDraft()
        draft.kind = .risesAbove

        #expect(draft.rule.condition == AlertCondition(comparison: .above, reference: .baselineFactor(2)))
    }

    @Test("Spiking maps to a median factor")
    func spikes() {
        var draft = AlertDraft()
        draft.kind = .spikes
        draft.factor = 3

        #expect(draft.rule.condition == AlertCondition(comparison: .above, reference: .medianFactor(3)))
    }

    @Test("An event draft carries its name and count threshold")
    func event() {
        var draft = AlertDraft()
        draft.choice = .eventCount
        draft.eventName = "Error"
        draft.countThreshold = 50

        #expect(draft.rule.metric == .eventCount(name: "Error"))
        #expect(draft.rule.condition == AlertCondition(comparison: .below, reference: .constant(50)))
    }

    @Test("An event draft without a name is invalid")
    func invalid() {
        var draft = AlertDraft()
        draft.choice = .eventCount

        #expect(!draft.isValid)

        draft.eventName = "Error"

        #expect(draft.isValid)
    }

    @Test("The hold pills map to hourly buckets")
    func hold() {
        #expect(AlertDraft.Hold.allCases.map(\.buckets) == [1, 2, 6, 24])
    }

    @Test("Values format per metric and kind")
    func valueText() {
        var draft = AlertDraft()

        #expect(draft.valueText == "99.50%")

        draft.kind = .risesAbove

        #expect(draft.valueText == "2×")

        draft.kind = .fallsBelow
        draft.choice = .eventCount

        #expect(draft.valueText == "100")
    }

    @Test("Stepping the stability threshold respects its bounds")
    func stabilityBounds() {
        var draft = AlertDraft()
        draft.stabilityThreshold = 0.9995

        for _ in 0..<10 { draft.increment() }

        #expect(draft.stabilityThreshold == 0.9999)

        for _ in 0..<200 { draft.decrement() }

        #expect(draft.stabilityThreshold == 0.9)
    }

    @Test("Stepping the factor respects its bounds")
    func factorBounds() {
        var draft = AlertDraft()
        draft.kind = .spikes

        for _ in 0..<30 { draft.increment() }

        #expect(draft.factor == 10)

        for _ in 0..<30 { draft.decrement() }

        #expect(draft.factor == 1.5)
    }
}
