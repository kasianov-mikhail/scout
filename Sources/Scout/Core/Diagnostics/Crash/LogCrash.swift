//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

func logCrash(_ crash: CrashInfo, id: UUID = UUID(), context: NSManagedObjectContext) throws {
    // The id doubles as the archive file's UUID, so a flush interrupted
    // between the save and the file removal doesn't insert a duplicate
    // on the next launch.
    let request = NSFetchRequest<CrashObject>(entityName: "CrashObject")
    request.predicate = NSPredicate(format: "crashID == %@", id as CVarArg)
    request.fetchLimit = 1
    guard try context.count(for: request) == 0 else { return }

    let object = context.insert(CrashObject.self)

    object.crashID = id
    object.date = crash.date
    object.appVersion = crash.appVersion
    object.name = crash.name
    object.fingerprint = CrashFingerprint(name: crash.name, reason: crash.reason, stackTrace: crash.stackTrace).value
    object.reason = crash.reason
    object.stackTrace = try? JSONEncoder().encode(crash.stackTrace)

    // Override the relationships set by awakeFromInsert from the current process's
    // IDs with the ones captured at crash time — nil if that row is already gone.
    object.install = try InstallObject.first(installID: crash.installID, in: context)
    object.launch = try LaunchObject.first(launchID: crash.launchID, in: context)
    object.session = try SessionObject.first(sessionID: crash.sessionID, in: context)

    try VersionMarker.mark(
        name: VersionMarker.crashName,
        installID: crash.installID,
        appVersion: crash.appVersion,
        in: context
    )

    try context.save()
}
