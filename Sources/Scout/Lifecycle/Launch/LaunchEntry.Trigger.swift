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
            try context.upsert(LaunchEntry.self, key: "launchID", id: launchID) { launch in
                launch.install = try context.existing(InstallEntry.self, key: "installID", id: installID)
            }
        }
    }
}
