//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension SessionObject: Monitor {
    static func trigger(in context: NSManagedObjectContext) throws {
        IDs.session = UUID()

        let session = context.insert(SessionObject.self)
        session.date = Date()
        session.id = IDs.session
        session.appVersion = Bundle.main.marketingVersion
        session.buildNumber = Bundle.main.buildNumber
        session.osVersion = SystemInfo.osVersion
        session.locale = SystemInfo.locale
        session.channel = SystemInfo.channel
        try context.save()
        context.persistentStoreCoordinator?.hubObjectIDs.session = session.objectID
    }

    static func complete(in context: NSManagedObjectContext) throws {
        guard let coordinator = context.persistentStoreCoordinator,
            let launch = IDs.resolve(
                coordinator.hubObjectIDs.launch,
                as: LaunchObject.self,
                in: context
            )
        else {
            throw MonitorError.notFound
        }

        let request = NSFetchRequest<SessionObject>(entityName: "SessionObject")
        request.sortDescriptors = [NSSortDescriptor(key: DateObject.datePrimitiveKey, ascending: false)]
        request.predicate = NSPredicate(format: "launch == %@", launch)
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
