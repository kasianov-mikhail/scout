//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import CoreData

// A SyncableObject that other records identify themselves by (DeviceObject,
// InstallObject, LaunchObject, SessionObject), so cleanup must not delete
// it while any such record still exists.
protocol HubObject {
    var isReferenced: Bool { get }
}

extension DeviceObject: HubObject {
    var isReferenced: Bool {
        guard let context = managedObjectContext else { return false }
        let request = NSFetchRequest<NSManagedObject>(entityName: "IDObject")
        request.predicate = NSPredicate(format: "deviceID == %@ AND SELF != %@", deviceID as CVarArg, self)
        request.fetchLimit = 1
        return ((try? context.count(for: request)) ?? 0) > 0
    }
}

extension InstallObject: HubObject {
    var isReferenced: Bool {
        guard let context = managedObjectContext else { return false }
        let request = NSFetchRequest<NSManagedObject>(entityName: "IDObject")
        request.predicate = NSPredicate(format: "installID == %@ AND SELF != %@", installID as CVarArg, self)
        request.fetchLimit = 1
        return ((try? context.count(for: request)) ?? 0) > 0
    }
}

extension LaunchObject: HubObject {
    var isReferenced: Bool {
        guard let context = managedObjectContext else { return false }
        let request = NSFetchRequest<NSManagedObject>(entityName: "IDObject")
        request.predicate = NSPredicate(format: "launchID == %@ AND SELF != %@", launchID as CVarArg, self)
        request.fetchLimit = 1
        return ((try? context.count(for: request)) ?? 0) > 0
    }
}

extension SessionObject: HubObject {
    var isReferenced: Bool {
        guard let context = managedObjectContext else { return false }
        let request = NSFetchRequest<NSManagedObject>(entityName: "TrackedObject")
        request.predicate = NSPredicate(format: "sessionID == %@ AND SELF != %@", sessionID as CVarArg, self)
        request.fetchLimit = 1
        return ((try? context.count(for: request)) ?? 0) > 0
    }
}
