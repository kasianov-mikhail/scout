//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import NativeConnector

@Suite("SubscriptionPlan")
struct SubscriptionPlanTests {
    @Test("Nothing desired and nothing stored makes an empty plan")
    func empty() {
        let plan = SubscriptionPlan.make(desired: [], existing: [])

        #expect(plan.saves.isEmpty)
        #expect(plan.deletions.isEmpty)
    }

    @Test("A missing subscription is saved")
    func savesMissing() {
        let plan = SubscriptionPlan.make(desired: ["scout.entity.changes"], existing: [])

        #expect(plan.saves == ["scout.entity.changes"])
        #expect(plan.deletions.isEmpty)
    }

    @Test("A matching subscription is left alone")
    func keepsMatching() {
        let plan = SubscriptionPlan.make(desired: ["scout.entity.changes"], existing: ["scout.entity.changes"])

        #expect(plan.saves.isEmpty)
        #expect(plan.deletions.isEmpty)
    }

    @Test("A stale Scout subscription is deleted")
    func deletesStale() {
        let plan = SubscriptionPlan.make(
            desired: ["scout.entity.changes"],
            existing: ["scout.entity.changes", "scout.legacy.old"]
        )

        #expect(plan.saves.isEmpty)
        #expect(plan.deletions == ["scout.legacy.old"])
    }

    @Test("Subscriptions that do not belong to Scout are never deleted")
    func keepsForeignSubscriptions() {
        let plan = SubscriptionPlan.make(desired: [], existing: ["com.example.changes"])

        #expect(plan.saves.isEmpty)
        #expect(plan.deletions.isEmpty)
    }

    @Test("A missing desired and a stale stored one are both handled")
    func savesAndDeletes() {
        let plan = SubscriptionPlan.make(
            desired: ["scout.entity.changes"],
            existing: ["scout.legacy.old"]
        )

        #expect(plan.saves == ["scout.entity.changes"])
        #expect(plan.deletions == ["scout.legacy.old"])
    }
}
