//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

protocol IncidentInfo {
    var name: String { get }
    var reason: String? { get }
    var stackTrace: [String] { get }
    var date: Date { get }
    var installID: UUID { get }
    var launchID: UUID { get }
    var sessionID: UUID { get }
    var appVersion: String? { get }
}

extension CrashInfo: IncidentInfo {}
extension HangInfo: IncidentInfo {}

func logIncident<Entry: IncidentEntry, Info: IncidentInfo>(
    _ info: Info, id: UUID, deviceID: UUID, entityName: String, idKey: String, markerName: String,
    context: NSManagedObjectContext, configure: (Entry, SessionEntry) -> Void
) throws {
    // The id doubles as the archive file's UUID, so a flush interrupted
    // between the save and the file removal doesn't insert a duplicate
    // on the next launch.
    let request = NSFetchRequest<Entry>(entityName: entityName)
    request.predicate = NSPredicate(format: "%K == %@", idKey, id as CVarArg)
    request.fetchLimit = 1
    guard try context.count(for: request) == 0 else { return }

    let object = context.insert(Entry.self)

    object.date = info.date
    object.appVersion = info.appVersion
    object.name = info.name
    object.fingerprint = CrashFingerprint(name: info.name, reason: info.reason, stackTrace: info.stackTrace).value
    object.reason = info.reason
    object.stackTrace = try? JSONEncoder().encode(info.stackTrace)

    // Reattach to the session/launch/install chain captured at incident time,
    // materializing any hub the faulted run didn't persist.
    let session = try context.linkedSession(
        deviceID: deviceID,
        installID: info.installID,
        launchID: info.launchID,
        sessionID: info.sessionID,
        date: info.date
    )
    configure(object, session)

    try MarkerEntry.mark(
        name: markerName,
        install: session.launch?.install,
        appVersion: info.appVersion,
        in: context
    )

    try context.save()
}
