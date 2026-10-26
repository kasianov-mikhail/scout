//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@testable import Scout

extension SessionEntry {
    @discardableResult static func stub(date: Date, endDate: Date? = nil, appVersion: String? = nil, launch: LaunchEntry? = nil, in context: NSManagedObjectContext) -> SessionEntry {
        let session = context.insert(SessionEntry.self)

        session.sessionID = Identity.stub.session.current
        session.date = date
        session.endDate = endDate
        session.appVersion = appVersion
        session.launch = launch

        return session
    }
}

extension NSManagedObjectContext {
    func makeLinkedSession(identity: Identity.Snapshot) throws -> SessionEntry? {
        try linkedSession(identity: identity, launch: linkedLaunch(identity: identity, date: Date()), date: Date())
    }
}
