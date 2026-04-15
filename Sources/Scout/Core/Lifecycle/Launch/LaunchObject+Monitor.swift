//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension LaunchObject: Monitor {
    static func trigger(in context: NSManagedObjectContext) throws {
        let entity = NSEntityDescription.entity(forEntityName: "LaunchObject", in: context)!
        let launch = LaunchObject(entity: entity, insertInto: context)
        launch.date = Date()
        try context.save()
    }

    static func complete(in context: NSManagedObjectContext) throws {
        let request = NSFetchRequest<LaunchObject>(entityName: "LaunchObject")
        request.sortDescriptors = [NSSortDescriptor(key: "datePrimitive", ascending: false)]
        request.predicate = NSPredicate(format: "launchID == %@", IDs.launch as CVarArg)
        request.fetchLimit = 1

        guard let launch = try context.fetch(request).first else {
            throw MonitorError.notFound
        }

        launch.endDate = Date()
        try context.save()
    }
}
