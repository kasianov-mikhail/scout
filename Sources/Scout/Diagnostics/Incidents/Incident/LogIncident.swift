//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

protocol IncidentContent {
    var name: String { get }
    var reason: String? { get }
    var stackTrace: [String] { get }
    var fingerprint: String { get }
    var date: Date { get }
    var appVersion: String? { get }
}

protocol IncidentInfo: IncidentContent {
    var installID: UUID { get }
    var launchID: UUID { get }
    var sessionID: UUID { get }

    func log(id: UUID, deviceID: UUID, context: NSManagedObjectContext) throws
}

extension CrashInfo: IncidentInfo {
    var fingerprint: String {
        CrashFingerprint(name: name, reason: reason, stackTrace: stackTrace).value
    }
}

extension HangInfo: IncidentInfo {
    // A hang's reason embeds the per-occurrence duration, which would make
    // every fingerprint unique — identity comes from the name and stack alone.
    var fingerprint: String {
        CrashFingerprint(name: name, reason: nil, stackTrace: stackTrace).value
    }
}

extension IncidentInfo {
    func log<Entry: IncidentEntry>(id: UUID, deviceID: UUID, idKey: String, markerName: String, context: NSManagedObjectContext, configure: (Entry, SessionEntry) -> Void) throws {
        // The id doubles as the archive file's UUID, so a flush interrupted
        // between the save and the file removal doesn't insert a duplicate
        // on the next launch.
        guard let object = try context.insertIncident(type: Entry.self, content: self, idKey: idKey, id: id) else {
            return
        }

        // Reattach to the session/launch/install chain captured at incident time,
        // materializing any hub the faulted run didn't persist.
        let identity = Identity.Snapshot(
            install: installID,
            launch: launchID,
            device: deviceID,
            session: sessionID
        )
        let session = try context.linkedSession(identity, date: date)
        configure(object, session)

        try session.launch?.install?.mark(name: markerName, appVersion: appVersion)

        try context.save()
    }
}

extension NSManagedObjectContext {
    func insertIncident<Entry: IncidentEntry>(type: Entry.Type, content: some IncidentContent, idKey: String, id: UUID) throws -> Entry? {
        let request = NSFetchRequest<Entry>(entityName: String(describing: type))
        request.predicate = NSPredicate(format: "%K == %@", idKey, id as CVarArg)
        request.fetchLimit = 1
        guard try count(for: request) == 0 else {
            return nil
        }

        let object = insert(type)
        object.setValue(id, forKey: idKey)
        object.date = content.date
        object.appVersion = content.appVersion
        object.name = content.name
        object.fingerprint = content.fingerprint
        object.reason = content.reason
        object.stackTrace = try JSONEncoder().encode(content.stackTrace)
        return object
    }
}
