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
    func rulesPersist() throws {
        let registry = AlertRegistry(defaults: defaults)
        try registry.save([rule])

        #expect(try AlertRegistry(defaults: defaults).rules() == [rule])
    }

    @Test("States survive a new registry instance")
    func statesPersist() throws {
        let since = Date(timeIntervalSince1970: 1_000_000)
        let registry = AlertRegistry(defaults: defaults)
        try registry.save([rule])
        try registry.remember(.firing(since: since), for: rule)

        #expect(try AlertRegistry(defaults: defaults).state(for: rule) == .firing(since: since))
    }

    @Test("An unknown rule reads as armed")
    func unknownRule() throws {
        #expect(try AlertRegistry(defaults: defaults).state(for: rule) == .armed)
    }

    @Test("Removing a rule clears its state")
    func removalClearsState() throws {
        let registry = AlertRegistry(defaults: defaults)
        try registry.save([rule])
        try registry.remember(.firing(since: Date(timeIntervalSince1970: 0)), for: rule)

        try registry.save([])
        try registry.save([rule])

        #expect(try registry.state(for: rule) == .armed)
    }

    @Test("Unreadable stored rules surface an error instead of an empty list")
    func unreadableRules() {
        defaults.set(Data("garbage".utf8), forKey: "scout_alert_rules")

        #expect(throws: AlertRegistry.UnreadableStoreError.self) {
            try AlertRegistry(defaults: defaults).rules()
        }
    }

    @Test("Unreadable stored states surface an error instead of resetting to armed")
    func unreadableStates() {
        defaults.set(Data("garbage".utf8), forKey: "scout_alert_states")

        #expect(throws: AlertRegistry.UnreadableStoreError.self) {
            try AlertRegistry(defaults: defaults).state(for: rule)
        }
    }

    @Test("Saving over unreadable states fails without touching the rules")
    func saveOverUnreadableStates() {
        defaults.set(Data("garbage".utf8), forKey: "scout_alert_states")

        #expect(throws: AlertRegistry.UnreadableStoreError.self) {
            try AlertRegistry(defaults: defaults).save([rule])
        }
        #expect(defaults.data(forKey: "scout_alert_rules") == nil)
    }
}
