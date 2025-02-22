//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData
import Logging

/// Logs an event with the specified name, level, metadata, and date.
///
/// This function creates a new `EventModel` instance, populates it with the provided
/// information, and saves it to the Core Data context.
///
/// - Parameters:
///   - name: The name of the event to log.
///   - level: The log level of the event.
///   - metadata: Additional metadata associated with the event.
///   - date: The date and time when the event occurred.
///   - context: The Core Data context where the event should be saved.
///
/// - Throws: An error if the event could not be saved to the context.
///
func log(
    _ name: String, level: Logger.Level, metadata: Logger.Metadata?, date: Date,
    context: NSManagedObjectContext
) throws {
    let entity = NSEntityDescription.entity(forEntityName: "EventModel", in: context)!
    let event = EventModel(entity: entity, insertInto: context)

    event.date = date
    event.level = level.rawValue
    event.name = name

    if let params = metadata?.compactMapValues(\.stringValue) {
        event.params = try JSONEncoder().encode(params)
        event.paramCount = Int64(params.count)
    }

    try context.save()
}

// MARK: - Metadata

extension Logger.MetadataValue {

    /// Converts the metadata value to a string, if possible.
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
