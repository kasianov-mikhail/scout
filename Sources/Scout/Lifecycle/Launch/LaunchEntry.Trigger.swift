//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension LaunchEntry {
    package struct Trigger: Command {
        let launchID: UUID
        let installID: UUID

        func execute(in context: NSManagedObjectContext) throws {
            let launch = context.insert(LaunchEntry.self)
            launch.launchID = launchID
            launch.date = Date()
            launch.install = try context.existing(InstallEntry.self, key: "installID", id: installID)
            try context.save()
        }
    }
}
