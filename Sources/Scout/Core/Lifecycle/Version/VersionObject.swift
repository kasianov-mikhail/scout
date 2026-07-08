//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(VersionObject)
final class VersionObject: SyncableObject {
    static let recordType = "Version"

    @NSManaged var appVersion: String?
    @NSManaged var buildNumber: String?

    func launches(in context: NSManagedObjectContext) throws -> [LaunchObject] {
        guard let appVersion else { return [] }

        let request = NSFetchRequest<VersionObject>(entityName: "VersionObject")
        request.predicate = NSPredicate(format: "appVersion == %@", appVersion)
        request.sortDescriptors = [NSSortDescriptor(key: "launch.\(DateObject.datePrimitiveKey)", ascending: true)]
        return try context.fetch(request).compactMap(\.launch)
    }
}

extension VersionObject: RecordEncodable {
    var record: Record {
        let recordName = "\(installIDString)-\(appVersion ?? "")-\(buildNumber ?? "")"
        var record = Record(recordType: Self.recordType, recordID: recordName)

        record["date"] = date
        record["app_version"] = appVersion
        record["build_number"] = buildNumber
        record["launch_id"] = launchIDString

        record.setValues(metadata)

        return record
    }
}
