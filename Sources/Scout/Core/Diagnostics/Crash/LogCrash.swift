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

    // Override IDs set by awakeFromInsert with values captured at crash time
    object.installID = crash.installID
    object.launchID = crash.launchID

    try context.save()
}
