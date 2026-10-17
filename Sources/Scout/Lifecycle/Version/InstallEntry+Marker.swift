//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension InstallEntry {
    func mark(name: String, appVersion: String?) throws {
        guard let appVersion else { return }
        guard let context = managedObjectContext else {
            return
        }

        let request = NSFetchRequest<MarkerEntry>(entityName: "MarkerEntry")
        request.predicate = NSPredicate(
            format: "install == %@ AND name == %@ AND appVersion == %@",
            self,
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
        marker.install = self
    }
}
