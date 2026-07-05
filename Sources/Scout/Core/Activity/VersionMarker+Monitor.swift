//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension VersionMarker: PartialMonitor {
    static func trigger(in context: NSManagedObjectContext) throws {
        try mark(name: installName, installID: IDs.install, appVersion: Bundle.main.marketingVersion, in: context)

        if context.hasChanges {
            try context.save()
        }
    }

    static func mark(name: String, installID: UUID, appVersion: String?, in context: NSManagedObjectContext) throws {
        guard let appVersion else { return }

        let request = NSFetchRequest<VersionMarker>(entityName: "VersionMarker")
        request.predicate = NSPredicate(
            format: "installID == %@ AND name == %@ AND appVersion == %@",
            installID as CVarArg,
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
        marker.installID = installID
    }
}
