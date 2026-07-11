//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@testable import Scout

extension LaunchEntry {
    @discardableResult static func stub(
        date: Date,
        synced: Bool = false,
        endDate: Date? = nil,
        install: InstallEntry? = nil,
        in context: NSManagedObjectContext
    ) -> LaunchEntry {
        let launch = context.insert(LaunchEntry.self)

        launch.launchID = Identity.stub.launch
        launch.date = date
        launch.setSynced(synced, in: context)
        launch.endDate = endDate
        launch.install = install

        return launch
    }
}
