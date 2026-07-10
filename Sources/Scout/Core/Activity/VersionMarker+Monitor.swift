//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension VersionMarker: PartialMonitor {
    static func trigger(in context: NSManagedObjectContext) throws {
        let install = try context.existing(InstallObject.self, key: "installID", id: IDs.install)
        try mark(name: installName, install: install, appVersion: Bundle.main.marketingVersion, in: context)

        if context.hasChanges {
            try context.save()
        }
    }

    static func mark(name: String, install: InstallObject?, appVersion: String?, in context: NSManagedObjectContext) throws {
        guard let appVersion, let install else { return }

        let request = NSFetchRequest<VersionMarker>(entityName: "VersionMarker")
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

        let marker = context.insert(VersionMarker.self)
        marker.markerID = UUID()
        marker.name = name
        marker.appVersion = appVersion
        marker.date = Date()
        marker.install = install
    }
}
