//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@testable import ScoutCore

extension VersionEntry {
    @discardableResult static func stub(
        date: Date,
        synced: Bool = false,
        appVersion: String = "1.0",
        buildNumber: String? = nil,
        launch: LaunchEntry? = nil,
        in context: NSManagedObjectContext
    ) -> VersionEntry {
        let version = context.insert(VersionEntry.self)

        version.date = date
        version.setSynced(synced, in: context)
        version.appVersion = appVersion
        version.buildNumber = buildNumber
        version.launch = launch

        return version
    }
}
