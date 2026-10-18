//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension ScreenEntry {
    struct Complete: Command {
        let screenID: UUID
        let date: Date

        func execute(in context: NSManagedObjectContext) throws {
            guard let screen = try context.existing(ScreenEntry.self, key: "screenID", id: screenID) else {
                return
            }
            guard screen.endDate == nil else {
                return
            }

            screen.endDate = date
            screen.requeue()
            try context.save()
        }
    }
}
