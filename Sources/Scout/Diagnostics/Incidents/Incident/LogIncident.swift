//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import SymbolTable

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
    var stackTrace: [String] { get set }
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
    func symbolicated(symbols: SymbolTable) -> Self {
        guard let backtrace else {
            return self
        }
        var symbolicated = self
        symbolicated.stackTrace = backtrace.symbolicated(stackTrace: stackTrace, symbols: symbols)
        return symbolicated
    }

    func log<Entry: IncidentEntry>(id: UUID, deviceID: UUID, idKey: String, context: NSManagedObjectContext, configure: (Entry) throws -> Void) throws {
        guard let object = try context.insertIncident(type: Entry.self, content: self, idKey: idKey, id: id) else {
            return
        }

        let identity = Identity.Snapshot(
            install: installID,
            launch: launchID,
            device: deviceID,
            session: sessionID,
            isForeground: false
        )
        try context.link(entry: object, identity: identity, date: date)
        try configure(object)

        try context.save()
    }
}

extension Backtrace {
    fileprivate func symbolicated(stackTrace: [String], symbols: SymbolTable) -> [String] {
        let frames = threads.first(where: \.attributed)?.frames ?? []
        return stackTrace.enumerated().map { index, line in
            guard frames.indices.contains(index) else {
                return line
            }
            return symbolicatedLine(frame: frames[index], index: index, symbols: symbols) ?? line
        }
    }

    private func symbolicatedLine(frame: Frame, index: Int, symbols: SymbolTable) -> String? {
        guard let image = frame.image else {
            return nil
        }
        guard images.indices.contains(image), images[image].uuid == symbols.uuid else {
            return nil
        }
        guard let function = symbols.frames(offset: index == 0 ? frame.offset : frame.offset &- 1).last else {
            return nil
        }
        return "\(index)   \(images[image].name)   \(function.name)"
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
