//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension FirstSeenEntry {
    struct Trigger: Command {
        let installID: UUID

        func execute(in context: NSManagedObjectContext) throws {
            let install = try context.existing(InstallEntry.self, key: "installID", id: installID)
            try install?.mark(name: Version.installMarker, appVersion: Bundle.main.marketingVersion)

            if context.hasChanges {
                try context.save()
            }
        }
    }
}
