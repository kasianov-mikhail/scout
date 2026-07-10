//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Logging

func log(_ event: LogEvent, date: Date, sessionID: UUID, context: NSManagedObjectContext) throws {
    let object = context.insert(EventObject.self)

    object.eventID = UUID()
    object.date = date
    object.session = try context.existing(SessionObject.self, key: "sessionID", id: sessionID)
    object.level = event.level.rawValue
    object.name = event.message.description

    if let params = event.metadata?.compactMapValues(\.stringValue) {
        object.params = try JSONEncoder().encode(params)
        object.paramCount = Int64(params.count)
    }

    try context.save()
}

extension Logger.MetadataValue {
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
