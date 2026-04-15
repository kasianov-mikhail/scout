//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@testable import Scout

extension VersionObject {
    @discardableResult static func stub(
        date: Date,
        synced: Bool = false,
        appVersion: String = "1.0",
        in context: NSManagedObjectContext
    ) -> VersionObject {
        let entity = NSEntityDescription.entity(forEntityName: "VersionObject", in: context)!
        let version = VersionObject(entity: entity, insertInto: context)

        version.date = date
        version.isSynced = synced
        version.appVersion = appVersion

        return version
    }
}
