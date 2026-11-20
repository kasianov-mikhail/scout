//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CryptoKit
import Foundation

enum CloudSubscription {
    static let prefix = "scout."
    static let id: CKSubscription.ID = "scout.entity.changes"
    static let recordType = "Entity"
    static let entityKey = "s_00"
    static let version = "v1"

    static var signature: String {
        let names = CatalogEntry.entries.map(\.entity).sorted().joined(separator: "\n")
        let digest = SHA256.hash(data: Data("\(version)\n\(names)".utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    static func subscription(id: CKSubscription.ID) -> CKSubscription? {
        guard id == Self.id else {
            return nil
        }

        let subscription = CKQuerySubscription(
            recordType: recordType,
            predicate: NSPredicate(value: true),
            subscriptionID: id,
            options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
        )

        let info = CKSubscription.NotificationInfo()
        info.shouldSendContentAvailable = true
        info.shouldBadge = false
        info.desiredKeys = [entityKey]
        subscription.notificationInfo = info

        return subscription
    }
}
