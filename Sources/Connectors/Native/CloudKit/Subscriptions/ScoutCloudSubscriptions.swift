//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

@preconcurrency import CloudKit
import Foundation
import Scout

public enum ScoutCloudSubscriptions {
    @discardableResult
    public static func enable(for container: CKContainer) async -> Bool {
        guard let containerID = container.containerIdentifier else {
            return false
        }

        do {
            guard try await container.accountStatus() == .available else {
                return false
            }
            _ = try await container.store()

            let registrar = CloudSubscriptionRegistrar(
                containerID: containerID,
                database: container.publicCloudDatabase,
                ledger: SubscriptionLedger()
            )
            try await registrar.reconcile(desired: [CloudSubscription.id])
            return true
        } catch {
            print("Scout couldn't set up CloudKit change notifications: \(error)")
            return false
        }
    }

    public static func disable(for container: CKContainer) async {
        guard let containerID = container.containerIdentifier else {
            return
        }

        do {
            let database = container.publicCloudDatabase
            let existing = try await database.allSubscriptions()
            let ids =
                existing
                .map(\.subscriptionID)
                .filter { $0.hasPrefix(CloudSubscription.prefix) }

            if !ids.isEmpty {
                try await database.modify(saving: [], deleting: ids)
            }

            SubscriptionLedger().clear(containerID: containerID)
        } catch {
            print("Scout couldn't remove its CloudKit change notifications: \(error)")
        }
    }

    @discardableResult
    public static func handleRemoteNotification(_ userInfo: [AnyHashable: Any]) async -> Bool {
        guard let payload = CloudNotificationPayload(userInfo: userInfo) else {
            return false
        }
        guard let change = change(for: payload) else {
            return false
        }

        await DatabaseChangeHub.shared.publish(change)

        return true
    }
}

extension ScoutCloudSubscriptions {
    static func change(for payload: CloudNotificationPayload) -> DatabaseChange? {
        guard let subscriptionID = payload.subscriptionID, subscriptionID.hasPrefix(CloudSubscription.prefix) else {
            return nil
        }

        return DatabaseChange(
            backendID: payload.containerIdentifier ?? "",
            origin: .remote,
            entities: payload.entity.map { [$0] } ?? []
        )
    }
}
