//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData
import Logging

func log(
    _ name: String,
    level: Logger.Level,
    metadata: Logger.Metadata?,
    date: Date,
    context: NSManagedObjectContext
) throws {
    let entity = NSEntityDescription.entity(forEntityName: "EventObject", in: context)!
    let event = EventObject(entity: entity, insertInto: context)

    event.date = date
    event.level = level.rawValue
    event.name = name

    if let params = metadata?.compactMapValues(\.stringValue) {
        event.params = try JSONEncoder().encode(params)
        event.paramCount = Int64(params.count)
    }

    try context.save()
}

extension Logger.MetadataValue {
    fileprivate var stringValue: String? {
        switch self {
        case .string(let string):
            return string
        case .stringConvertible(let convertible):
            return convertible.description
        case .array:
            return nil  // TODO: Implement array conversion
        case .dictionary:
            return nil  // TODO: Implement dictionary conversion
        }
    }
}
