//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import CoreData

extension VisitEntry {
    struct Trigger: Command {
        let launchID: UUID
        var date: Date = Date()

        func execute(in context: NSManagedObjectContext) throws {
            let request = NSFetchRequest<VisitEntry>(entityName: "VisitEntry")
            request.predicate = NSPredicate(format: "day == %@", date.startOfDay as NSDate)
            request.fetchLimit = 1

            guard try context.fetch(request).first == nil else { return }

            let visit = context.insert(VisitEntry.self)
            visit.visitID = UUID()
            visit.date = date
            visit.launch = try context.existing(LaunchEntry.self, key: "launchID", id: launchID)
            try context.save()
        }
    }
}
