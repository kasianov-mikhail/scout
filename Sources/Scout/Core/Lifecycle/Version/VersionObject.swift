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
        let request = NSFetchRequest<InstallObject>(entityName: "InstallObject")
        request.predicate = NSPredicate(format: "installID == %@", installID as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    func launches(in context: NSManagedObjectContext) throws -> [LaunchObject] {
        guard let appVersion else { return [] }

        let versionRequest = NSFetchRequest<NSDictionary>(entityName: "VersionObject")
        versionRequest.predicate = NSPredicate(format: "appVersion == %@", appVersion)
        versionRequest.resultType = .dictionaryResultType
        versionRequest.propertiesToFetch = ["launchID"]
        versionRequest.returnsDistinctResults = true
        let launchIDs = try context.fetch(versionRequest).compactMap { $0["launchID"] as? UUID }

        let request = NSFetchRequest<LaunchObject>(entityName: "LaunchObject")
        request.predicate = NSPredicate(format: "launchID IN %@", launchIDs)
        request.sortDescriptors = [NSSortDescriptor(key: DateObject.datePrimitiveKey, ascending: true)]
        return try context.fetch(request)
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
