//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

@preconcurrency import CloudKit

struct SubscriptionPlan: Equatable {
    let saves: [CKSubscription.ID]
    let deletions: [CKSubscription.ID]

    static func make(desired: Set<CKSubscription.ID>, existing: Set<CKSubscription.ID>) -> SubscriptionPlan {
        SubscriptionPlan(
            saves: desired.subtracting(existing).sorted(),
            deletions:
                existing
                .filter { $0.hasPrefix(CloudSubscription.prefix) && !desired.contains($0) }
                .sorted()
        )
    }
}
