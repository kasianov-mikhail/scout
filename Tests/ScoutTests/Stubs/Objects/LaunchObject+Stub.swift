//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@testable import Scout

extension LaunchObject {
    @discardableResult static func stub(
        date: Date,
        synced: Bool = false,
        endDate: Date? = nil,
        in context: NSManagedObjectContext
    ) -> LaunchObject {
        let entity = NSEntityDescription.entity(forEntityName: "LaunchObject", in: context)!
        let launch = LaunchObject(entity: entity, insertInto: context)

        launch.date = date
        launch.setSynced(synced, in: context)
        launch.endDate = endDate

        return launch
    }
}
