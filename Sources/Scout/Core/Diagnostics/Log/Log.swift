//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Logging

/// Persists a log event to Core Data.
func log(_ event: LogEvent, date: Date, context: NSManagedObjectContext) throws {
    let entity = NSEntityDescription.entity(forEntityName: "EventObject", in: context)!
    let object = EventObject(entity: entity, insertInto: context)

    object.eventID = UUID()
    object.date = date
    object.level = event.level.rawValue
    object.name = event.message.description

    if let params = event.metadata?.compactMapValues(\.stringValue) {
        object.params = try JSONEncoder().encode(params)
        object.paramCount = Int64(params.count)
    }

    try context.save()
}

extension Logger.MetadataValue {
    /// Extracts a plain string representation from a metadata value.
    ///
    fileprivate var stringValue: String? {
        switch self {
        case .string(let string):
            string
        case .stringConvertible(let convertible):
            convertible.description
        case .array(let array):
            array.compactMap(\.stringValue).joined(separator: ", ")
        case .dictionary(let dictionary):
            dictionary.compactMapValues(\.stringValue)
                .sorted(by: { $0.key < $1.key })
                .map { "\($0.key): \($0.value)" }
                .joined(separator: ", ")
        }
    }
}
