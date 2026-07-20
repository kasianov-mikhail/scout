//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import ScoutUI

@MainActor
struct AlertStoreTests {
    private let defaults = UserDefaults(suiteName: "AlertStoreTests-\(UUID().uuidString)")!

    private let rule = AlertRule(
        metric: .crashFreeSessions,
        condition: AlertCondition(comparison: .below, reference: .constant(0.995)),
        holdBuckets: 2
    )

    @Test("Rules survive a new store instance")
    func rulesPersist() {
        let store = AlertStore(defaults: defaults)
        store.rules = [rule]

        #expect(AlertStore(defaults: defaults).rules == [rule])
    }

    @Test("States survive a new store instance")
    func statesPersist() {
        let since = Date(timeIntervalSince1970: 1_000_000)
        let store = AlertStore(defaults: defaults)
        store.rules = [rule]
        store.setState(.firing(since: since), for: rule)

        #expect(AlertStore(defaults: defaults).state(for: rule) == .firing(since: since))
    }

    @Test("An unknown rule reads as armed")
    func unknownRule() {
        #expect(AlertStore(defaults: defaults).state(for: rule) == .armed)
    }

    @Test("Removing a rule clears its state")
    func removalClearsState() {
        let store = AlertStore(defaults: defaults)
        store.rules = [rule]
        store.setState(.firing(since: Date(timeIntervalSince1970: 0)), for: rule)

        store.rules = []
        store.rules = [rule]

        #expect(store.state(for: rule) == .armed)
    }
}
