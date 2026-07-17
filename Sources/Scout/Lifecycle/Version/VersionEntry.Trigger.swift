//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension VersionEntry {
    package struct Trigger: Command {
        let installID: UUID
        let launchID: UUID
        var bundle: Bundle = .main

        func execute(in context: NSManagedObjectContext) throws {
            let appVersion = bundle.marketingVersion
            let buildNumber = bundle.buildNumber

            let request = NSFetchRequest<VersionEntry>(entityName: "VersionEntry")
            request.predicate = NSPredicate(format: "launch.install.installID == %@", installID as CVarArg)
            request.sortDescriptors = [NSSortDescriptor(key: DateEntry.datePrimitiveKey, ascending: false)]
            request.fetchLimit = 1
            let latest = try context.fetch(request).first

            if latest?.appVersion == appVersion && latest?.buildNumber == buildNumber {
                return
            }

            let version = context.insert(VersionEntry.self)
            version.date = Date()
            version.appVersion = appVersion
            version.buildNumber = buildNumber
            version.launch = try context.existing(LaunchEntry.self, key: "launchID", id: launchID)
            try context.save()
        }
    }
}
