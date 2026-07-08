//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import CoreData
import Foundation
import ObjectiveC

enum IDs {
    private static let sessionQueue = DispatchQueue(label: "scout.ids.session")

    nonisolated(unsafe) private(set) static var rawSession = UUID()

    static var session: UUID {
        get { sessionQueue.sync { rawSession } }
        set { sessionQueue.sync { rawSession = newValue } }
    }

    static let launch = UUID()

    static let install = UserDefaults.standard.ensure("scout_install_id")

    static let device = KeychainStorage.standard.ensure("scout_device_id")

    static func resolve<T: NSManagedObject>(_ id: NSManagedObjectID?, as type: T.Type, in context: NSManagedObjectContext) -> T? {
        guard let id, let store = id.persistentStore, context.persistentStoreCoordinator?.persistentStores.contains(store) == true else {
            return nil
        }
        return context.object(with: id) as? T
    }
}

/// Caches the current device/install/launch/session row's `NSManagedObjectID`,
/// set by each hub's own `Monitor.trigger` right after it finds or inserts that
/// row. `IDObject`/`TrackedObject.awakeFromInsert` read these from arbitrary
/// Core Data background contexts on every insert, resolving the relationship
/// via `context.object(with:)` instead of a fetch.
///
/// Scoped to the persistent store coordinator (not a process-wide global) so
/// separate containers — e.g. independent in-memory stores across tests —
/// never resolve a relationship against the wrong store.
///
final class HubObjectIDs {
    private let queue = DispatchQueue(label: "scout.ids.hub")

    nonisolated(unsafe) private var rawDevice: NSManagedObjectID?
    nonisolated(unsafe) private var rawInstall: NSManagedObjectID?
    nonisolated(unsafe) private var rawLaunch: NSManagedObjectID?
    nonisolated(unsafe) private var rawSession: NSManagedObjectID?

    var device: NSManagedObjectID? {
        get { queue.sync { rawDevice } }
        set { queue.sync { rawDevice = newValue } }
    }

    var install: NSManagedObjectID? {
        get { queue.sync { rawInstall } }
        set { queue.sync { rawInstall = newValue } }
    }

    var launch: NSManagedObjectID? {
        get { queue.sync { rawLaunch } }
        set { queue.sync { rawLaunch = newValue } }
    }

    var session: NSManagedObjectID? {
        get { queue.sync { rawSession } }
        set { queue.sync { rawSession = newValue } }
    }
}

extension NSPersistentStoreCoordinator {
    nonisolated(unsafe) private static var hubObjectIDsKey: UInt8 = 0

    var hubObjectIDs: HubObjectIDs {
        if let existing = objc_getAssociatedObject(self, &Self.hubObjectIDsKey) as? HubObjectIDs {
            return existing
        }
        let created = HubObjectIDs()
        objc_setAssociatedObject(self, &Self.hubObjectIDsKey, created, .OBJC_ASSOCIATION_RETAIN)
        return created
    }
}
