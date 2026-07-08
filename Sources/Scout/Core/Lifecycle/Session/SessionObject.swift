//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(SessionObject)
final class SessionObject: TrackedObject {
    static let recordType = "Session"

    @NSManaged var appVersion: String?
    @NSManaged var buildNumber: String?
    @NSManaged var endDate: Date?
    @NSManaged var osVersion: String?
    @NSManaged var locale: String?
    @NSManaged var channel: String?
    @NSManaged var id: UUID

    static func first(sessionID: UUID, in context: NSManagedObjectContext) throws -> SessionObject? {
        let request = NSFetchRequest<SessionObject>(entityName: "SessionObject")
        request.predicate = NSPredicate(format: "id == %@", sessionID as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
}

extension SessionObject: RecordEncodable {
    var record: Record {
        var record = Record(recordType: Self.recordType, recordID: id.uuidString)

        record["start_date"] = date
        record["end_date"] = endDate
        record["session_id"] = id.uuidString
        record["launch_id"] = launchIDString
        record["app_version"] = appVersion
        record["build_number"] = buildNumber
        record["os_version"] = osVersion
        record["locale"] = locale
        record["channel"] = channel

        record.setValues(metadata)

        return record
    }
}
