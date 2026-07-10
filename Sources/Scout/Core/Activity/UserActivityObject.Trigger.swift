//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension UserActivityObject {
    struct Trigger: Command {
        let session: Protected<UUID>
        var date: Date = Date().startOfDay

        func execute(in context: NSManagedObjectContext) throws {
            let sessionID = session.current

            for period in ActivityPeriod.allCases {
                let provider = Provider(date: date, period: period)
                let activities = try provider.fetch(sessionID: sessionID, in: context)

                let limit = date.adding(period.spreadComponent)

                for activity in activities {
                    if let day = activity.day, day < limit, activity[keyPath: period.countField] == 0 {
                        activity[keyPath: period.countField] = 1
                    }
                }
            }

            if context.hasChanges {
                try context.save()
            }
        }
    }
}
