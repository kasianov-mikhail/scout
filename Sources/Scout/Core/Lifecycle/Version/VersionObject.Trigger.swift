//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension VersionObject {
    struct Trigger: Command {
        let installID: UUID
        let launchID: UUID
        var bundle: Bundle = .main

        func execute(in context: NSManagedObjectContext) throws {
            let appVersion = bundle.marketingVersion
            let buildNumber = bundle.buildNumber

            let request = NSFetchRequest<VersionObject>(entityName: "VersionObject")
            request.predicate = NSPredicate(format: "launch.install.installID == %@", installID as CVarArg)
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
            version.launch = try context.existing(LaunchObject.self, key: "launchID", id: launchID)
            try context.save()
        }
    }
}
