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
struct AlertRegistryTests {
    private let defaults = UserDefaults(suiteName: "AlertRegistryTests-\(UUID().uuidString)")!

    private let rule = AlertRule(
        metric: .crashFreeSessions,
        condition: AlertCondition(comparison: .below, reference: .constant(0.995)),
        holdBuckets: 2
    )

    @Test("Rules survive a new registry instance")
    func rulesPersist() {
        let registry = AlertRegistry(defaults: defaults)
        registry.rules = [rule]

        #expect(AlertRegistry(defaults: defaults).rules == [rule])
    }

    @Test("States survive a new registry instance")
    func statesPersist() {
        let since = Date(timeIntervalSince1970: 1_000_000)
        let registry = AlertRegistry(defaults: defaults)
        registry.rules = [rule]
        registry.remember(.firing(since: since), for: rule)

        #expect(AlertRegistry(defaults: defaults).state(for: rule) == .firing(since: since))
    }

    @Test("An unknown rule reads as armed")
    func unknownRule() {
        #expect(AlertRegistry(defaults: defaults).state(for: rule) == .armed)
    }

    @Test("Removing a rule clears its state")
    func removalClearsState() {
        let registry = AlertRegistry(defaults: defaults)
        registry.rules = [rule]
        registry.remember(.firing(since: Date(timeIntervalSince1970: 0)), for: rule)

        registry.rules = []
        registry.rules = [rule]

        #expect(registry.state(for: rule) == .armed)
    }
}
