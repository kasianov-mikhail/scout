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
    @NSManaged var launchID: UUID

    func sessions(in context: NSManagedObjectContext) throws -> [SessionObject] {
        let request = NSFetchRequest<SessionObject>(entityName: "SessionObject")
        request.predicate = NSPredicate(format: "launch == %@", self)
        request.sortDescriptors = [NSSortDescriptor(key: DateObject.datePrimitiveKey, ascending: true)]
        return try context.fetch(request)
    }

    func version(in context: NSManagedObjectContext) throws -> VersionObject? {
        let request = NSFetchRequest<VersionObject>(entityName: "VersionObject")
        request.predicate = NSPredicate(format: "launch == %@", self)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    static func first(launchID: UUID, in context: NSManagedObjectContext) throws -> LaunchObject? {
        let request = NSFetchRequest<LaunchObject>(entityName: "LaunchObject")
        request.predicate = NSPredicate(format: "launchID == %@", launchID as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
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
