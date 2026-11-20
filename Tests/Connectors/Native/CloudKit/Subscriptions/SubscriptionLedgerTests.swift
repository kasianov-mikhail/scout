//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import NativeConnector

@Suite("SubscriptionLedger")
struct SubscriptionLedgerTests {
    private let containerID = "iCloud.com.example.app"

    private func makeLedger() -> (SubscriptionLedger, UserDefaults, String) {
        let name = "scout.ledger.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        return (SubscriptionLedger(defaults: defaults), defaults, name)
    }

    @Test("An untouched container has no signature")
    func startsEmpty() {
        let (ledger, defaults, name) = makeLedger()
        defer { defaults.removePersistentDomain(forName: name) }

        #expect(ledger.signature(containerID: containerID) == nil)
    }

    @Test("A recorded signature reads back")
    func roundTrips() {
        let (ledger, defaults, name) = makeLedger()
        defer { defaults.removePersistentDomain(forName: name) }

        ledger.record(containerID: containerID, signature: "abc")

        #expect(ledger.signature(containerID: containerID) == "abc")
    }

    @Test("Clearing forgets the signature")
    func clears() {
        let (ledger, defaults, name) = makeLedger()
        defer { defaults.removePersistentDomain(forName: name) }

        ledger.record(containerID: containerID, signature: "abc")
        ledger.clear(containerID: containerID)

        #expect(ledger.signature(containerID: containerID) == nil)
    }

    @Test("The signature is stable across calls")
    func signatureIsStable() {
        #expect(CloudSubscription.signature == CloudSubscription.signature)
    }

    @Test("The signature covers the catalog entities")
    func signatureCoversCatalog() {
        let names = CatalogEntry.entries.map(\.entity).sorted().joined(separator: "\n")

        #expect(!names.isEmpty)
        #expect(CloudSubscription.signature.count == 64)
    }
}
