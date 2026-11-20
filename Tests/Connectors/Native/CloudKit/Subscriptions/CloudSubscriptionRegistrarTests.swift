//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

@preconcurrency import CloudKit
import Foundation
import Testing

@testable import NativeConnector

@Suite("CloudSubscriptionRegistrar")
struct CloudSubscriptionRegistrarTests {
    private let containerID = "iCloud.com.example.app"

    private func makeRegistrar(
        existing: [CKSubscription] = [],
        signature: String? = nil
    ) -> (CloudSubscriptionRegistrar, SubscriptionDatabaseStub, SubscriptionLedger, UserDefaults, String) {
        let name = "scout.registrar.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        let ledger = SubscriptionLedger(defaults: defaults)
        if let signature {
            ledger.record(containerID: containerID, signature: signature)
        }

        let database = SubscriptionDatabaseStub(existing: existing)
        let registrar = CloudSubscriptionRegistrar(
            containerID: containerID,
            database: database,
            ledger: ledger
        )

        return (registrar, database, ledger, defaults, name)
    }

    @Test("A first reconcile saves the one Scout subscription and records the ledger")
    func savesFirstTime() async throws {
        let (registrar, database, ledger, defaults, name) = makeRegistrar()
        defer { defaults.removePersistentDomain(forName: name) }

        try await registrar.reconcile(desired: [CloudSubscription.id])

        #expect(database.saved.map(\.subscriptionID) == [CloudSubscription.id])
        #expect(database.deleted.isEmpty)
        #expect(database.modifyCount == 1)
        #expect(ledger.signature(containerID: containerID) == CloudSubscription.signature)
    }

    @Test("The saved subscription carries the silent notification configuration")
    func savesSilentSubscription() async throws {
        let (registrar, database, _, defaults, name) = makeRegistrar()
        defer { defaults.removePersistentDomain(forName: name) }

        try await registrar.reconcile(desired: [CloudSubscription.id])

        let subscription = try #require(database.saved.first as? CKQuerySubscription)
        let info = try #require(subscription.notificationInfo)

        #expect(subscription.recordType == CloudSubscription.recordType)
        #expect(info.shouldSendContentAvailable)
        #expect(info.desiredKeys == [CloudSubscription.entityKey])
        #expect(info.alertBody == nil)
        #expect(info.soundName == nil)
    }

    @Test("A matching ledger skips the server entirely")
    func skipsWhenUnchanged() async throws {
        let (registrar, database, _, defaults, name) = makeRegistrar(signature: CloudSubscription.signature)
        defer { defaults.removePersistentDomain(forName: name) }

        try await registrar.reconcile(desired: [CloudSubscription.id])

        #expect(database.readCount == 0)
        #expect(database.modifyCount == 0)
    }

    @Test("A stale Scout subscription is removed")
    func deletesStale() async throws {
        let stale = CKQuerySubscription(
            recordType: "Entity",
            predicate: NSPredicate(value: true),
            subscriptionID: "scout.legacy.old",
            options: [.firesOnRecordCreation]
        )
        let (registrar, database, _, defaults, name) = makeRegistrar(existing: [stale])
        defer { defaults.removePersistentDomain(forName: name) }

        try await registrar.reconcile(desired: [CloudSubscription.id])

        #expect(database.deleted == ["scout.legacy.old"])
        #expect(database.saved.map(\.subscriptionID) == [CloudSubscription.id])
    }

    @Test("A failed modify leaves the ledger untouched so the next launch retries")
    func keepsLedgerOnFailure() async {
        let name = "scout.registrar.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }

        let ledger = SubscriptionLedger(defaults: defaults)
        let database = SubscriptionDatabaseStub(existing: [])
        database.failure = CancellationError()

        let registrar = CloudSubscriptionRegistrar(
            containerID: containerID,
            database: database,
            ledger: ledger
        )

        await #expect(throws: CancellationError.self) {
            try await registrar.reconcile(desired: [CloudSubscription.id])
        }
        #expect(ledger.signature(containerID: containerID) == nil)
    }
}

final class SubscriptionDatabaseStub: SubscriptionDatabase, @unchecked Sendable {
    private let lock = NSLock()
    private var stored: [CKSubscription]
    private var savedSubscriptions: [CKSubscription] = []
    private var deletedIDs: [CKSubscription.ID] = []
    private var reads = 0
    private var modifies = 0
    private var thrown: (any Error)?

    init(existing: [CKSubscription]) {
        stored = existing
    }

    var failure: (any Error)? {
        get { lock.withLock { thrown } }
        set { lock.withLock { thrown = newValue } }
    }

    var saved: [CKSubscription] {
        lock.withLock { savedSubscriptions }
    }

    var deleted: [CKSubscription.ID] {
        lock.withLock { deletedIDs }
    }

    var readCount: Int {
        lock.withLock { reads }
    }

    var modifyCount: Int {
        lock.withLock { modifies }
    }

    func allSubscriptions() async throws -> [CKSubscription] {
        try lock.withLock {
            reads += 1
            if let thrown {
                throw thrown
            }
            return stored
        }
    }

    func modify(saving: [CKSubscription], deleting: [CKSubscription.ID]) async throws {
        try lock.withLock {
            modifies += 1
            if let thrown {
                throw thrown
            }
            savedSubscriptions = saving
            deletedIDs = deleting
        }
    }
}
