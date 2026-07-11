//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension MarkerEntry {
    struct Trigger: Command {
        let installID: UUID

        func execute(in context: NSManagedObjectContext) throws {
            let install = try context.existing(InstallEntry.self, key: "installID", id: installID)
            try MarkerEntry.mark(name: MarkerEntry.installName, install: install, appVersion: Bundle.main.marketingVersion, in: context)

            if context.hasChanges {
                try context.save()
            }
        }
    }

    static func mark(name: String, install: InstallEntry?, appVersion: String?, in context: NSManagedObjectContext) throws {
        guard let appVersion, let install else { return }

        let request = NSFetchRequest<MarkerEntry>(entityName: "MarkerEntry")
        request.predicate = NSPredicate(
            format: "install == %@ AND name == %@ AND appVersion == %@",
            install,
            name,
            appVersion
        )
        request.fetchLimit = 1

        guard try context.fetch(request).first == nil else {
            return
        }

        let marker = context.insert(MarkerEntry.self)
        marker.markerID = UUID()
        marker.name = name
        marker.appVersion = appVersion
        marker.date = Date()
        marker.install = install
    }
}
