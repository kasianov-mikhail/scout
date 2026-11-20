//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

#if os(iOS)
    @preconcurrency import CloudKit

    struct CloudSubscriptionSource: ChangeSource {
        nonisolated(unsafe) let container: CKContainer

        func start() async {
            guard let containerID = container.containerIdentifier else {
                return
            }

            do {
                guard try await container.accountStatus() == .available else {
                    return
                }
                _ = try await container.store()
            } catch {
                print("Scout couldn't prepare the CloudKit schema for change notifications: \(error)")
                return
            }

            CloudAccountChanges.observe(containerID: containerID)

            let registrar = CloudSubscriptionRegistrar(
                containerID: containerID,
                database: container.publicCloudDatabase,
                ledger: SubscriptionLedger()
            )

            do {
                try await registrar.reconcile(desired: [CloudSubscription.id])
            } catch {
                print("Scout couldn't set up CloudKit change notifications: \(error)")
            }
        }
    }

    enum CloudAccountChanges {
        private static let lock = NSLock()
        nonisolated(unsafe) private static var observed: Set<String> = []

        static func observe(containerID: String) {
            lock.lock()
            let isNew = observed.insert(containerID).inserted
            lock.unlock()

            guard isNew else {
                return
            }

            NotificationCenter.default.addObserver(forName: .CKAccountChanged, object: nil, queue: nil) { _ in
                SubscriptionLedger().clear(containerID: containerID)
            }
        }
    }
#endif
