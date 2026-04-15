//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Foundation

enum IDs {
    static var session: UUID? {
        session(in: persistentContainer.viewContext)
    }

    static func session(in context: NSManagedObjectContext) -> UUID? {
        let request = NSFetchRequest<SessionObject>(entityName: "SessionObject")
        request.sortDescriptors = [NSSortDescriptor(key: "datePrimitive", ascending: false)]
        request.predicate = NSPredicate(format: "launchID == %@", launch as CVarArg)
        request.fetchLimit = 1
        let session = try? context.fetch(request).first
        return session?.sessionID
    }

    static let launch = UUID()

    static let install: UUID = {
        let key = "scout_install_id"

        if let id = UserDefaults.standard.uuid(forKey: key) {
            return id
        }

        let id = UUID()
        UserDefaults.standard.set(id, forKey: key)
        return id
    }()

    static let device: UUID = {
        let key = "scout_device_id"

        if let id = KeychainID.load(key: key) {
            return id
        }

        let id = UUID()
        KeychainID.save(key: key, value: id)
        return id
    }()
}
