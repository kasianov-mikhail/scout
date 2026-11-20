//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

@preconcurrency import CloudKit

struct CloudSubscriptionRegistrar {
    let containerID: String
    let database: any SubscriptionDatabase
    let ledger: SubscriptionLedger

    func reconcile(desired: Set<CKSubscription.ID>) async throws {
        let signature = CloudSubscription.signature

        guard ledger.signature(containerID: containerID) != signature else {
            return
        }

        let existing = try await database.allSubscriptions()
        let plan = SubscriptionPlan.make(desired: desired, existing: Set(existing.map(\.subscriptionID)))

        if !plan.saves.isEmpty || !plan.deletions.isEmpty {
            let saves = plan.saves.compactMap(CloudSubscription.subscription(id:))
            try await database.modify(saving: saves, deleting: plan.deletions)
        }

        ledger.record(containerID: containerID, signature: signature)
    }
}
