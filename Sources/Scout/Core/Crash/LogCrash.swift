//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

func logCrash(_ crash: CrashInfo, context: NSManagedObjectContext) throws {
    let entity = NSEntityDescription.entity(forEntityName: "CrashObject", in: context)!
    let object = CrashObject(entity: entity, insertInto: context)

    object.crashID = UUID()
    object.date = crash.date
    object.name = crash.name
    object.reason = crash.reason
    object.stackTrace = try? JSONEncoder().encode(crash.stackTrace)

    // Override IDs from crash info (captured at crash time)
    object.setValue(crash.userID, forKey: "userID")
    object.setValue(crash.launchID, forKey: "launchID")

    try context.save()
}
