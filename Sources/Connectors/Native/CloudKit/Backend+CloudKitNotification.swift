//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import Scout

extension Backend {
    /// Forwards a remote notification to the backends used by the runtime and dashboard.
    ///
    /// Returns whether it belongs to Scout's CloudKit event subscription.
    ///
    @discardableResult
    public static func handleCloudKitNotification(_ userInfo: [AnyHashable: Any], backends: [Backend]) -> Bool {
        guard let notification = CKNotification(fromRemoteNotificationDictionary: userInfo) as? CKQueryNotification else {
            return false
        }
        guard let subscriptionID = notification.subscriptionID else {
            return false
        }

        let sources = backends.lazy
            .filter { cloudKitEventSubscriptionPrefix + $0.id == subscriptionID }
            .compactMap(\.eventChangeSource)

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
