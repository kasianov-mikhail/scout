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
    @NSManaged var endDate: Date?

    func launch(in context: NSManagedObjectContext) throws -> LaunchObject? {
        let request = NSFetchRequest<LaunchObject>(entityName: "LaunchObject")
        request.predicate = NSPredicate(format: "launchID == %@", launchID as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
}

extension SessionObject: RecordEncodable {
    var record: Record {
        var record = Record(recordType: Self.recordType, recordID: sessionID.uuidString)

        record["start_date"] = date
        record["end_date"] = endDate
        record["session_id"] = sessionID.uuidString
        record["launch_id"] = launchID.uuidString
        record["app_version"] = appVersion

        record.setValues(metadata)

        return record
    }
}
