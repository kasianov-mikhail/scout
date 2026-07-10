//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension SessionObject {
    struct Trigger: Command {
        let session: Protected<UUID>
        let launchID: UUID
        var bundle: Bundle = .main

        func execute(in context: NSManagedObjectContext) throws {
            let sessionID = UUID()
            session.current = sessionID

            let object = context.insert(SessionObject.self)
            object.sessionID = sessionID
            object.date = Date()
            object.launch = try context.existing(LaunchObject.self, key: "launchID", id: launchID)
            object.appVersion = bundle.marketingVersion
            object.buildNumber = bundle.buildNumber
            object.osVersion = SystemInfo.osVersion
            object.locale = SystemInfo.locale
            object.channel = SystemInfo.channel
            try context.save()
        }
    }
}
