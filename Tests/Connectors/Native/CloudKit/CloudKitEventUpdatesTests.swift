//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import Scout
import Testing

@testable import NativeConnector
@testable import Support

struct CloudKitEventUpdatesTests {
    @Test("Subscribes to event creation with silent delivery")
    func subscriptionMatchesEvents() async throws {
        let (saves, continuation) = AsyncStream<CKSubscription>.makeStream()
        let database = TestSubscriptionDatabase {
            continuation.yield($0)
            continuation.finish()
        }
        let updates = CloudKitEventUpdates(containerID: "iCloud.test.Scout", database: database)
        _ = await updates.changes()

        var iterator = saves.makeAsyncIterator()
        let saved = await iterator.next()
        let subscription = try #require(saved as? CKQuerySubscription)

        #expect(subscription.subscriptionID == "scout.events.v1.iCloud.test.Scout")
        #expect(subscription.recordType == "Entity")
        #expect(subscription.predicate.predicateFormat == "s_00 == \"Event\"")
        #expect(subscription.querySubscriptionOptions == [.firesOnRecordCreation])
        #expect(subscription.notificationInfo?.shouldSendContentAvailable == true)
    }

    @Test("The public handler ignores notifications from other services")
    func ignoresUnrelatedNotification() {
        let runtime = makeRuntime(backends: [])
        #expect(!runtime.handleCloudKitNotification(["aps": ["content-available": 1]]))
    }

    @Test("A subscription routes only to its supplied backend")
    func routesBySubscriptionID() async throws {
        let (invalidations, continuation) = AsyncStream<String>.makeStream()
        let database = NativeDatabase.inMemory()
        let first = TestEventUpdates {
            continuation.yield("first")
            continuation.finish()
        }
        let second = TestEventUpdates {
            continuation.yield("second")
            continuation.finish()
        }
        let firstBackend = Backend(
            id: "iCloud.test.First",
            database: database,
            displayName: "First",
            engine: .cloudKit,
            eventUpdates: first
        )
        let secondBackend = Backend(
            id: "iCloud.test.Second",
            database: database,
            displayName: "Second",
            engine: .cloudKit,
            eventUpdates: second
        )

        let id = "scout.events.v1.\(secondBackend.id)"
        let payload: [AnyHashable: Any] = ["aps": ["content-available": 1], "ck": ["qry": ["sid": id]]]

        #expect(!makeRuntime(backends: [firstBackend]).handleCloudKitNotification(payload))
        try #require(makeRuntime(backends: [firstBackend, secondBackend]).handleCloudKitNotification(payload))

        var iterator = invalidations.makeAsyncIterator()
        #expect(await iterator.next() == "second")
    }
}

private struct TestSubscriptionDatabase: CloudKitSubscriptions {
    let onSave: @Sendable (CKSubscription) -> Void

    func subscription(for subscriptionID: String) async throws -> CKSubscription {
        throw CKError(.unknownItem)
    }

    func save(_ subscription: CKSubscription) async throws -> CKSubscription {
        onSave(subscription)
        return subscription
    }
}

private struct TestEventUpdates: EventUpdatesSource {
    let onInvalidation: @Sendable () -> Void

    func changes() async -> AsyncStream<Void> {
        AsyncStream { $0.finish() }
    }

    func invalidate() async {
        onInvalidation()
    }
}
