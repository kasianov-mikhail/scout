//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(InstallObject)
final class InstallObject: SyncableObject, Syncable, GridBatch {
    static let recordType = "Install"

    func versions(in context: NSManagedObjectContext) throws -> [VersionObject] {
        let request = NSFetchRequest<VersionObject>(entityName: "VersionObject")
        request.predicate = NSPredicate(format: "installID == %@", installID as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "datePrimitive", ascending: true)]
        return try context.fetch(request)
    }
}

extension InstallObject {
    var toRecord: Record {
        var record = Record(recordType: Self.recordType, id: RecordID(recordName: installID.uuidString))

        record["date"] = date

        record.setValues(metadata)

        return record
    }
}
