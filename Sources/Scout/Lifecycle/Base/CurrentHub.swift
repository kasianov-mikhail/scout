//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension NSManagedObjectContext {
    func existing<T: NSManagedObject>(_ type: T.Type, key: String, id: UUID) throws -> T? {
        try latest(type: type, predicate: NSPredicate(format: "%K == %@", key, id as CVarArg))
    }

    func latest<T: NSManagedObject>(type: T.Type, predicate: NSPredicate) throws -> T? {
        let request = NSFetchRequest<T>(entityName: String(describing: type))
        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(key: DateEntry.datePrimitiveKey, ascending: false)]
        request.fetchLimit = 1
        return try fetch(request).first
    }

    func link(entry: SessionScopeEntry, identity: Identity.Snapshot, date: Date) throws {
        let launch = try linkedLaunch(identity: identity, date: date)
        entry.launch = launch
        entry.session = try linkedSession(identity: identity, launch: launch, date: date)
    }

    func linkedLaunch(identity: Identity.Snapshot, date: Date) throws -> LaunchEntry {
        let device = try fetchOrCreate(DeviceEntry.self, key: "deviceID", id: identity.device) {
            $0.deviceID = identity.device
            $0.date = date
        }
        let install = try fetchOrCreate(InstallEntry.self, key: "installID", id: identity.install) {
            $0.installID = identity.install
            $0.date = date
            $0.device = device
            $0.startCohort()
        }
        return try fetchOrCreate(LaunchEntry.self, key: "launchID", id: identity.launch) {
            $0.launchID = identity.launch
            $0.date = date
            $0.install = install
        }
    }

    func linkedSession(identity: Identity.Snapshot, launch: LaunchEntry, date: Date) throws -> SessionEntry? {
        guard identity.isForeground else {
            return try existing(SessionEntry.self, key: "sessionID", id: identity.session)
        }
        return try fetchOrCreate(SessionEntry.self, key: "sessionID", id: identity.session) {
            $0.sessionID = identity.session
            $0.date = date
            $0.launch = launch
        }
    }

    func upsert<T: SyncableEntry>(_ type: T.Type, key: String, id: UUID, update: (T) throws -> Void) throws {
        let object = try fetchOrCreate(type, key: key, id: id) {
            $0.setValue(id, forKey: key)
            $0.date = Date()
        }

        try update(object)

        if object.hasChanges {
            object.requeue()
        }
        if hasChanges {
            try save()
        }
    }

    private func fetchOrCreate<T: NSManagedObject>(_ type: T.Type, key: String, id: UUID, configure: (T) -> Void) throws -> T {
        if let object = try existing(type, key: key, id: id) {
            return object
        }
        let object = insert(type)
        configure(object)
        return object
    }
}
