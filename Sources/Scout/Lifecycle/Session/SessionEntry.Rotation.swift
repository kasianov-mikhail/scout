//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension SessionEntry {
    struct Rotation: Command {
        let session: Protected<UUID>
        let launchID: UUID

        func execute(in context: NSManagedObjectContext) throws {
            if try context.existing(SessionEntry.self, key: "sessionID", id: session.current)?.endDate != nil {
                session.current = UUID()
            }

            try Trigger(session: session, launchID: launchID).execute(in: context)
        }
    }
}
