//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension SessionObject {
    /// Closes sessions from previous launches that were not properly
    /// completed — typically because the app crashed.
    ///
    static func completeStale(in context: NSManagedObjectContext) throws {
        let request = NSFetchRequest<SessionObject>(entityName: "SessionObject")
        request.predicate = stalePredicate

        for session in try context.fetch(request) {
            session.endDate = session.date
        }

        if context.hasChanges {
            try context.save()
        }
    }
}
