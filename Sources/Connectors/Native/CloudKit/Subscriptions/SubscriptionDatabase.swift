//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

@preconcurrency import CloudKit

protocol SubscriptionDatabase: Sendable {
    func allSubscriptions() async throws -> [CKSubscription]
    func modify(saving: [CKSubscription], deleting: [CKSubscription.ID]) async throws
}

extension CKDatabase: SubscriptionDatabase {
    func modify(saving: [CKSubscription], deleting: [CKSubscription.ID]) async throws {
        _ = try await modifySubscriptions(saving: saving, deleting: deleting)
    }
}
