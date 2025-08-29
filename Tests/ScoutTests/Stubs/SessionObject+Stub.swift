//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@testable import Scout

extension SessionObject {
    @discardableResult static func stub(
        date: Date,
        synced: Bool = false,
        endDate: Date? = nil,
        in context: NSManagedObjectContext
    ) -> SessionObject {
        let entity = NSEntityDescription.entity(forEntityName: "SessionObject", in: context)!
        let session = SessionObject(entity: entity, insertInto: context)

        session.date = date
        session.isSynced = synced
        session.sessionID = UUID()
        session.userID = UUID()
        session.launchID = UUID()
        session.endDate = endDate

        return session
    }
}
