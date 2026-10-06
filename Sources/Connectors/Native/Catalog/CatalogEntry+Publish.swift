//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import ScoutDB

extension CatalogEntry {
    static func publishAll(into store: EntityStore, registry: SchemaRegistry) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            for entry in entries {
                group.addTask {
                    try await entry.publish(into: store, registry: registry)
                }
            }
            try await group.waitForAll()
        }
    }

    func publish(into store: EntityStore, registry: SchemaRegistry) async throws {
        let declaration = declaration(on: store)

        guard let published = try await registry.publishedSchema(for: entity) else {
            return try await declaration.create()
        }
        guard !matches(published) else {
            return
        }
        try await declaration.update()
    }
}

extension CatalogEntry {
    private func declaration(on store: EntityStore) -> SchemaBuilder {
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
