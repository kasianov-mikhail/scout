//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension VersionObject: PartialMonitor {
    static func trigger(in context: NSManagedObjectContext) throws {
        try trigger(
            appVersion: Bundle.main.marketingVersion,
            buildNumber: Bundle.main.buildNumber,
            in: context
        )
    }

    static func trigger(appVersion: String?, buildNumber: String?, in context: NSManagedObjectContext) throws {
        let install = context.persistentStoreCoordinator.flatMap {
            IDs.resolve($0.hubObjectIDs.install, as: InstallObject.self, in: context)
        }

        let request = NSFetchRequest<VersionObject>(entityName: "VersionObject")
        request.predicate = install.map { NSPredicate(format: "install == %@", $0) } ?? NSPredicate(format: "install == nil")
        request.sortDescriptors = [NSSortDescriptor(key: DateObject.datePrimitiveKey, ascending: false)]
        request.fetchLimit = 1
        let latest = try context.fetch(request).first

        if latest?.appVersion == appVersion && latest?.buildNumber == buildNumber {
            return
        }

        let version = context.insert(VersionObject.self)
        version.date = Date()
        version.appVersion = appVersion
        version.buildNumber = buildNumber
        try context.save()
    }
}

extension Bundle {
    var marketingVersion: String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var buildNumber: String? {
        infoDictionary?["CFBundleVersion"] as? String
    }
}
