//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension RecordCacheStorage {
    nonisolated(unsafe) static let model: NSManagedObjectModel = {
        let record = NSEntityDescription()
        record.name = "CachedRecord"
        record.managedObjectClassName = NSStringFromClass(CachedRecord.self)
        let fingerprint = attribute("fingerprint", .stringAttributeType)
        let date = attribute("date", .dateAttributeType)
        record.properties = [
            fingerprint,
            date,
            attribute("payload", .binaryDataAttributeType),
            attribute("size", .integer64AttributeType),
        ]
        record.indexes = [
            NSFetchIndexDescription(
                name: "fingerprintDate",
                elements: [fingerprint, date].map {
                    NSFetchIndexElementDescription(property: $0, collationType: .binary)
                }
            )
        ]

        let span = NSEntityDescription()
        span.name = "CachedSpan"
        span.managedObjectClassName = NSStringFromClass(CachedSpan.self)
        span.properties = [
            attribute("fingerprint", .stringAttributeType),
            attribute("lowerDate", .dateAttributeType),
            attribute("upperDate", .dateAttributeType),
        ]

        let model = NSManagedObjectModel()
        model.entities = [record, span]
        return model
    }()

    private static func attribute(_ name: String, _ type: NSAttributeType) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = type
        attribute.isOptional = false
        return attribute
    }
}
