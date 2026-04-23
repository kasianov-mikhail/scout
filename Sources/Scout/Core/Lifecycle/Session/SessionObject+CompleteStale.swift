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
    /// `endDate` is set to the most recent timestamp of any TrackedObject
    /// sharing the session's `sessionID` (events, crashes, metrics,
    /// activity, or the session itself). This approximates the real session
    /// length from the last signal emitted before the crash instead of
    /// collapsing it to zero. Sessions with no child records fall back to
    /// their start date.
    ///
    static func completeStale(in context: NSManagedObjectContext) throws {
        let request = NSFetchRequest<SessionObject>(entityName: "SessionObject")
        request.predicate = NSPredicate(format: "endDate == nil AND launchID != %@", IDs.launch as CVarArg)

        for session in try context.fetch(request) {
            session.endDate = try session.inferredEndDate(in: context)
        }

        if context.hasChanges {
            try context.save()
        }
    }

    private func inferredEndDate(in context: NSManagedObjectContext) throws -> Date? {
        guard let sessionID else { return nil }

        let request = NSFetchRequest<TrackedObject>(entityName: "TrackedObject")
        request.predicate = NSPredicate(format: "sessionID == %@", sessionID as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "datePrimitive", ascending: false)]
        request.fetchLimit = 1

        return try context.fetch(request).first?.date
    }
}
