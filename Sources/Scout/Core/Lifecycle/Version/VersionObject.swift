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

    func install(in context: NSManagedObjectContext) throws -> InstallObject? {
        try context.objects(InstallObject.self, where: "installID == %@", installID, limit: 1).first
    }

    func launches(in context: NSManagedObjectContext) throws -> [LaunchObject] {
        let versions = try context.objects(VersionObject.self, where: "appVersion == %@", appVersion!)
        let launchIDs = versions.compactMap(\.launchID)

        return try context.objects(LaunchObject.self, where: "launchID IN %@", launchIDs, dateAscending: true)
    }
}

extension VersionObject: RecordEncodable {
    var record: Record {
        let recordName = "\(installID.uuidString)-\(appVersion ?? "")-\(buildNumber ?? "")"
        var record = Record(recordType: Self.recordType, recordID: recordName)

        record["date"] = date
        record["app_version"] = appVersion
        record["build_number"] = buildNumber
        record["launch_id"] = launchID.uuidString

        record.setValues(metadata)

        return record
    }
}
