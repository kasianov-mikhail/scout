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

@Suite("CloudNotificationPayload")
struct CloudNotificationPayloadTests {
    @Test("A payload without a CloudKit body is not a notification")
    func rejectsMalformed() {
        #expect(CloudNotificationPayload(userInfo: [:]) == nil)
        #expect(CloudNotificationPayload(userInfo: ["aps": ["content-available": 1]]) == nil)
    }

    @Test("A query notification turns into a remote change for its container")
    func makesChange() throws {
        let payload = CloudNotificationPayload(
            subscriptionID: "scout.entity.changes",
            containerIdentifier: "iCloud.com.example.app",
            entity: "Event",
            isPruned: false
        )

        let change = try #require(ScoutCloudSubscriptions.change(for: payload))

        #expect(change.backendID == "iCloud.com.example.app")
        #expect(change.origin == .remote)
        #expect(change.entities == ["Event"])
    }

    @Test("A pruned payload still means the data moved")
    func keepsPrunedChange() throws {
        let payload = CloudNotificationPayload(
            subscriptionID: "scout.entity.changes",
            containerIdentifier: "iCloud.com.example.app",
            entity: nil,
            isPruned: true
        )

        let change = try #require(ScoutCloudSubscriptions.change(for: payload))

        #expect(change.entities.isEmpty)
    }

    @Test("A subscription that is not Scout's makes no change")
    func ignoresForeignSubscription() {
        let payload = CloudNotificationPayload(
            subscriptionID: "com.example.changes",
            containerIdentifier: "iCloud.com.example.app",
            entity: "Event",
            isPruned: false
        )

        #expect(ScoutCloudSubscriptions.change(for: payload) == nil)
    }

    @Test("A payload without a subscription id makes no change")
    func ignoresMissingSubscription() {
        let payload = CloudNotificationPayload(
            subscriptionID: nil,
            containerIdentifier: "iCloud.com.example.app",
            entity: "Event",
            isPruned: false
        )

        #expect(ScoutCloudSubscriptions.change(for: payload) == nil)
    }
}
