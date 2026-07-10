//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension SessionObject: Monitor {
    static func trigger(identity: Identity, in context: NSManagedObjectContext) throws {
        let sessionID = UUID()
        identity.session.current = sessionID

        let session = context.insert(SessionObject.self)
        session.sessionID = sessionID
        session.date = Date()
        session.launch = try context.existing(LaunchObject.self, key: "launchID", id: identity.launch)
        session.appVersion = Bundle.main.marketingVersion
        session.buildNumber = Bundle.main.buildNumber
        session.osVersion = SystemInfo.osVersion
        session.locale = SystemInfo.locale
        session.channel = SystemInfo.channel
        try context.save()
    }

    static func complete(identity: Identity, in context: NSManagedObjectContext) throws {
        let request = NSFetchRequest<SessionObject>(entityName: "SessionObject")
        request.sortDescriptors = [NSSortDescriptor(key: DateObject.datePrimitiveKey, ascending: false)]
        request.predicate = NSPredicate(format: "launch.launchID == %@", identity.launch as CVarArg)
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
