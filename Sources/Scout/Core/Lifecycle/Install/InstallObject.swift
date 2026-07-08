//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(InstallObject)
final class InstallObject: SyncableObject {
    static let recordType = "Install"

    @NSManaged var installID: UUID

    func versions(in context: NSManagedObjectContext) throws -> [VersionObject] {
        let request = NSFetchRequest<VersionObject>(entityName: "VersionObject")
        request.predicate = NSPredicate(format: "install == %@", self)
        request.sortDescriptors = [NSSortDescriptor(key: DateObject.datePrimitiveKey, ascending: true)]
        return try context.fetch(request)
    }

    static func first(installID: UUID, in context: NSManagedObjectContext) throws -> InstallObject? {
        let request = NSFetchRequest<InstallObject>(entityName: "InstallObject")
        request.predicate = NSPredicate(format: "installID == %@", installID as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
}

extension InstallObject: RecordEncodable {
    var record: Record {
        var record = Record(recordType: Self.recordType, recordID: installID.uuidString)

        record["date"] = date
        record.setValues(metadata)

        return record
    }
}
