//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension LaunchObject: PartialMonitor {
    /// A launch represents the lifetime of the current process.
    ///
    /// Created once during `setup()` and finalised only on the next
    /// process start via `completeStale`, which sets `endDate` from the
    /// latest signal recorded against this launch — the OS provides no
    /// reliable hook for "process about to die".
    ///
    static func trigger(in context: NSManagedObjectContext) throws {
        let launch = context.insert(LaunchObject.self)
        launch.date = Date()
        launch.launchID = IDs.launch
        try context.save()
        context.persistentStoreCoordinator?.hubObjectIDs.launch = launch.objectID
    }
}
