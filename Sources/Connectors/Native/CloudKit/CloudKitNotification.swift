//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import Scout

extension Runtime {
    @discardableResult
    public func handleCloudKitNotification(_ userInfo: [AnyHashable: Any]) -> Bool {
        guard let notification = CKNotification(fromRemoteNotificationDictionary: userInfo) as? CKQueryNotification else {
            return false
        }
        guard let subscriptionID = notification.subscriptionID else {
            return false
        }

        let sources = backends.lazy
            .filter { cloudKitEventSubscriptionPrefix + $0.id == subscriptionID }
            .compactMap(\.eventUpdates)

        guard !sources.isEmpty else {
            return false
        }

        Task {
            for source in sources {
                await source.invalidate()
            }
        }

        return true
    }
}
