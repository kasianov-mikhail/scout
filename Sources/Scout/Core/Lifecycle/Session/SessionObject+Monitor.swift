//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension SessionObject {
    static func trigger(session: Protected<UUID>, launchID: UUID, in context: NSManagedObjectContext) throws {
        let sessionID = UUID()
        session.current = sessionID

        let object = context.insert(SessionObject.self)
        object.sessionID = sessionID
        object.date = Date()
        object.launch = try context.existing(LaunchObject.self, key: "launchID", id: launchID)
        object.appVersion = Bundle.main.marketingVersion
        object.buildNumber = Bundle.main.buildNumber
        object.osVersion = SystemInfo.osVersion
        object.locale = SystemInfo.locale
        object.channel = SystemInfo.channel
        try context.save()
    }

    static func complete(launchID: UUID, in context: NSManagedObjectContext) throws {
        let request = NSFetchRequest<SessionObject>(entityName: "SessionObject")
        request.sortDescriptors = [NSSortDescriptor(key: DateObject.datePrimitiveKey, ascending: false)]
        request.predicate = NSPredicate(format: "launch.launchID == %@", launchID as CVarArg)
        request.fetchLimit = 1

        guard let session = try context.fetch(request).first else {
            throw MonitorError.notFound
        }

        if session.endDate == nil {
            session.endDate = Date()
            try context.save()
        }
    }
}
