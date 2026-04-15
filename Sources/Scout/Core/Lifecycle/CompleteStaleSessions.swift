//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

/// Closes any sessions and launches from previous app launches that were
/// not properly completed — typically because the app crashed.
///
/// Sets `endDate` to the object's start date for orphaned records,
/// indicating the duration is unknown.
///
func completeStaleSessions(in context: NSManagedObjectContext) throws {
    let sessionRequest = NSFetchRequest<SessionObject>(entityName: "SessionObject")
    sessionRequest.predicate = NSPredicate(
        format: "endDate == nil AND launchID != %@", IDs.launch as CVarArg
    )

    for session in try context.fetch(sessionRequest) {
        session.endDate = session.date
    }

    let launchRequest = NSFetchRequest<LaunchObject>(entityName: "LaunchObject")
    launchRequest.predicate = NSPredicate(
        format: "endDate == nil AND launchID != %@", IDs.launch as CVarArg
    )

    for launch in try context.fetch(launchRequest) {
        launch.endDate = launch.date
    }

    if context.hasChanges {
        try context.save()
    }
}
