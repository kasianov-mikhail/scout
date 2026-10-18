//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension ConditionEntry {
    struct Trigger: Command {
        let condition: Condition
        let value: Double
        let identity: Identity.Snapshot
        let date: Date

        func execute(in context: NSManagedObjectContext) throws {
            let entry = context.insert(ConditionEntry.self)
            entry.conditionID = UUID()
            entry.kind = condition.rawValue
            entry.value = value
            entry.date = date
            entry.session = try context.linkedSession(identity, date: date)
            try context.save()
        }
    }
}
