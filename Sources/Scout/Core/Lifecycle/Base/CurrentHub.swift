//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension NSManagedObjectContext {
    func existing<T: NSManagedObject>(_ type: T.Type, key: String, id: UUID) throws -> T? {
        let request = NSFetchRequest<T>(entityName: String(describing: type))
        request.predicate = NSPredicate(format: "%K == %@", key, id as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: DateObject.datePrimitiveKey, ascending: false)]
        request.fetchLimit = 1
        return try fetch(request).first
    }

    func linkedSession(deviceID: UUID, installID: UUID, launchID: UUID, sessionID: UUID, date: Date) throws -> SessionObject {
        let device = try fetchOrCreate(DeviceObject.self, key: "deviceID", id: deviceID) {
            $0.deviceID = deviceID
            $0.date = date
        }
        let install = try fetchOrCreate(InstallObject.self, key: "installID", id: installID) {
            $0.installID = installID
            $0.date = date
            $0.device = device
        }
        let launch = try fetchOrCreate(LaunchObject.self, key: "launchID", id: launchID) {
            $0.launchID = launchID
            $0.date = date
            $0.install = install
        }
        return try fetchOrCreate(SessionObject.self, key: "sessionID", id: sessionID) {
            $0.sessionID = sessionID
            $0.date = date
            $0.launch = launch
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
