//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

func logHang(_ hang: HangInfo, id: UUID = UUID(), context: NSManagedObjectContext) throws {
    // The id doubles as the archive file's UUID, so a flush interrupted
    // between the save and the file removal doesn't insert a duplicate
    // on the next launch.
    let request = NSFetchRequest<HangObject>(entityName: "HangObject")
    request.predicate = NSPredicate(format: "hangID == %@", id as CVarArg)
    request.fetchLimit = 1
    guard try context.count(for: request) == 0 else { return }

    let object = context.insert(HangObject.self)

    object.hangID = id
    object.date = hang.date
    object.appVersion = hang.appVersion
    object.name = hang.name
    object.fingerprint = CrashFingerprint(name: hang.name, reason: hang.reason, stackTrace: hang.stackTrace).value
    object.reason = hang.reason
    object.stackTrace = try? JSONEncoder().encode(hang.stackTrace)
    object.duration = hang.duration

    // Override IDs set by awakeFromInsert with values captured at hang time
    object.installID = hang.installID
    object.launchID = hang.launchID
    object.sessionID = hang.sessionID

    try VersionMarker.mark(
        name: VersionMarker.hangName,
        installID: hang.installID,
        appVersion: hang.appVersion,
        in: context
    )

    try context.save()
}
