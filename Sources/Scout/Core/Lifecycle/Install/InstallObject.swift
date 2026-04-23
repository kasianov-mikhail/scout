//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
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
    var toRecord: CKRecord {
        let record = CKRecord(recordType: Self.recordType)

        record["date"] = date

        record.setValuesForKeys(metadata)

        return record
    }
}
