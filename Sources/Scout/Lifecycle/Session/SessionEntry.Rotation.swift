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
            session.current = UUID()

            try Trigger(session: session, launchID: launchID).execute(in: context)
        }
    }
}
