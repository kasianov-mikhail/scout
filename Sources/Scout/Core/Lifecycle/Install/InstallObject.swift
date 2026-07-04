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

    func versions(in context: NSManagedObjectContext) throws -> [VersionObject] {
        try context.objects(VersionObject.self, where: "installID == %@", installID, dateAscending: true)
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
