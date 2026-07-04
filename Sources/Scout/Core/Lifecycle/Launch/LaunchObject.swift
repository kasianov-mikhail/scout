//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(LaunchObject)
final class LaunchObject: SyncableObject {
    static let recordType = "Launch"

    @NSManaged var endDate: Date?

    func sessions(in context: NSManagedObjectContext) throws -> [SessionObject] {
        try context.objects(SessionObject.self, where: "launchID == %@", launchID, dateAscending: true)
    }

    func version(in context: NSManagedObjectContext) throws -> VersionObject? {
        try context.objects(VersionObject.self, where: "launchID == %@", launchID, limit: 1).first
    }
}

extension LaunchObject: RecordEncodable {
    var record: Record {
        var record = Record(recordType: Self.recordType, recordID: launchID.uuidString)

        record["start_date"] = date
        record["end_date"] = endDate
        record["launch_id"] = launchID.uuidString

        record.setValues(metadata)

        return record
    }
}
