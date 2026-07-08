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
        appVersion: String? = nil,
        in context: NSManagedObjectContext
    ) -> SessionObject {
        let session = context.insert(SessionObject.self)

        session.date = date
        session.id = UUID()
        session.setSynced(synced, in: context)
        session.endDate = endDate
        session.appVersion = appVersion

        return session
    }
}
