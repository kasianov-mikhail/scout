//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData

@objc(VersionObject)
final class VersionObject: SyncableObject, Syncable {
    static let recordType = "Version"
    @NSManaged var appVersion: String?
    @NSManaged var buildNumber: String?

    static func group(in context: NSManagedObjectContext) throws -> [VersionObject]? {
        try batch(in: context, matching: [\.week])
    }

    func install(in context: NSManagedObjectContext) throws -> InstallObject? {
        let request = NSFetchRequest<InstallObject>(entityName: "InstallObject")
        request.predicate = NSPredicate(format: "userID == %@", userID! as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    func launches(in context: NSManagedObjectContext) throws -> [LaunchObject] {
        let versionRequest = NSFetchRequest<VersionObject>(entityName: "VersionObject")
        versionRequest.predicate = NSPredicate(format: "appVersion == %@", appVersion!)
        let versions = try context.fetch(versionRequest)
        let launchIDs = versions.compactMap(\.launchID)

        let request = NSFetchRequest<LaunchObject>(entityName: "LaunchObject")
        request.predicate = NSPredicate(format: "launchID IN %@", launchIDs)
        request.sortDescriptors = [NSSortDescriptor(key: "datePrimitive", ascending: true)]
        return try context.fetch(request)
    }
}

extension VersionObject: CKRepresentable {
    var toRecord: CKRecord {
        let record = CKRecord(recordType: Self.recordType)

        record["date"] = date
        record["app_version"] = appVersion
        record["build_number"] = buildNumber
        record["launch_id"] = launchID?.uuidString

        record.setValuesForKeys(metadata)

        return record
    }
}
