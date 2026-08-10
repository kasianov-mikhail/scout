//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import ScoutDB

struct CatalogEntry {
    let entity: String
    let fields: [Field]
    let aggregates: [Aggregate]
    let derive: @Sendable (Record) -> [String: ScoutDB.RecordValue]

    struct Field {
        let name: String
        let type: FieldType
    }

    enum Aggregate {
        case count(by: String, at: String)
        case sum(String, by: String, at: String)
    }

    init(
        entity: String, fields: [Field], aggregates: [Aggregate] = [],
        derive: @escaping @Sendable (Record) -> [String: ScoutDB.RecordValue] = { _ in [:] }
    ) {
        self.entity = entity
        self.fields = fields + Self.metadata
        self.aggregates = aggregates
        self.derive = derive
    }

    private static let metadata: [Field] = [
        Field(name: "hour", type: .timestamp),
        Field(name: "day", type: .timestamp),
        Field(name: "week", type: .timestamp),
        Field(name: "month", type: .timestamp),
        Field(name: "device_id", type: .string),
        Field(name: "install_id", type: .string),
        Field(name: "launch_id", type: .string),
        Field(name: "version", type: .int),
    ]
}

extension CatalogEntry {
    func declaration(on store: EntityStore) -> SchemaBuilder {
        var builder = store.schema(entity)

        for field in fields {
            builder = builder.field(field.name, field.type, .ungrouped)
        }
        for aggregate in aggregates {
            switch aggregate {
            case .count(let group, let date):
                builder = builder.count(by: group, at: date)
            case .sum(let field, let group, let date):
                builder = builder.sum(field, by: group, at: date)
            }
        }

        return builder
    }

    func matches(_ schema: EntitySchema) -> Bool {
        guard schema.fields.count == fields.count else {
            return false
        }
        return zip(schema.fields, fields).allSatisfy {
            $0.name == $1.name && $0.type == $1.type
        }
    }
}
