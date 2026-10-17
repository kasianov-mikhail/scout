//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension MetricKitResource {
    func log(installID: UUID, context: NSManagedObjectContext) throws {
        let install = try context.existing(InstallEntry.self, key: "installID", id: installID)
        let launch = try install.flatMap { try processLaunch(install: $0, context: context) }

        guard let entry = try context.insertIncident(type: ResourceEntry.self, content: self, idKey: "resourceID", id: id) else {
            return
        }
        entry.kind = kind.rawValue
        entry.value = amount
        entry.session = try launch?.lastSession(date: date, context: context)
        source.apply(to: entry)

        try context.save()
    }
}
