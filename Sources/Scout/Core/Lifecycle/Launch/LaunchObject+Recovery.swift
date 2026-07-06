//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension LaunchObject: RecoveryMonitor {
    /// Closes launches from previous app runs that were not properly
    /// completed — typically because the app crashed.
    ///
    /// `endDate` is set to the most recent timestamp of any IDObject
    /// sharing the launch's `launchID` (sessions, events, crashes, metrics,
    /// activity, version, or the launch itself). This approximates the real
    /// launch length from the last signal emitted before the crash instead
    /// of collapsing it to zero. Launches with no child records fall back
    /// to their start date.
    ///
    static func completeStale(in context: NSManagedObjectContext) throws {
        let request = NSFetchRequest<LaunchObject>(entityName: "LaunchObject")
        request.predicate = NSPredicate(format: "endDate == nil AND launchID != %@", IDs.launch as CVarArg)

        for launch in try context.fetch(request) {
            launch.endDate = try launch.inferredEndDate(in: context)
        }

        if context.hasChanges {
            try context.save()
        }
    }

    private func inferredEndDate(in context: NSManagedObjectContext) throws -> Date? {
        let request = NSFetchRequest<NSDictionary>(entityName: "IDObject")
        request.predicate = NSPredicate(format: "launchID == %@", launchID as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: DateObject.datePrimitiveKey, ascending: false)]
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = [DateObject.datePrimitiveKey]
        request.fetchLimit = 1

        return try context.fetch(request).first?[DateObject.datePrimitiveKey] as? Date
    }
}
