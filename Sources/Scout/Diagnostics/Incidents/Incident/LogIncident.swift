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
    var backtrace: Backtrace? { get }
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
    var fingerprint: String {
        CrashFingerprint(name: name, reason: nil, stackTrace: stackTrace).value
    }
}

extension IncidentInfo {
    func log<Entry: IncidentEntry>(id: UUID, deviceID: UUID, idKey: String, context: NSManagedObjectContext, configure: (Entry, SessionEntry) throws -> Void) throws {
        guard let object = try context.insertIncident(type: Entry.self, content: self, idKey: idKey, id: id) else {
            return
        }

        let identity = Identity.Snapshot(
            install: installID,
            launch: launchID,
            device: deviceID,
            session: sessionID
        )
        let session = try context.linkedSession(identity, date: date)
        try configure(object, session)

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

        if let backtrace = content.backtrace {
            let entry = insert(BacktraceEntry.self)
            entry.date = content.date
            entry.incidentID = id
            entry.appVersion = content.appVersion
            entry.payload = try JSONEncoder().encode(backtrace)
        }

        return object
    }
}
