//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

@preconcurrency import CloudKit

struct CloudNotificationPayload {
    let subscriptionID: String?
    let containerIdentifier: String?
    let entity: String?
    let isPruned: Bool

    init(subscriptionID: String?, containerIdentifier: String?, entity: String?, isPruned: Bool) {
        self.subscriptionID = subscriptionID
        self.containerIdentifier = containerIdentifier
        self.entity = entity
        self.isPruned = isPruned
    }

    init?(userInfo: [AnyHashable: Any]) {
        guard let notification = CKNotification(fromRemoteNotificationDictionary: userInfo) else {
            return nil
        }

        subscriptionID = notification.subscriptionID
        containerIdentifier = notification.containerIdentifier
        isPruned = notification.isPruned
        entity = (notification as? CKQueryNotification)?.recordFields?[CloudSubscription.entityKey] as? String
    }
}
