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
    static func publishAll(into store: EntityStore, registry: SchemaRegistry) async {
        await withTaskGroup(of: Void.self) { group in
            for entry in entries {
                group.addTask {
                    try? await entry.publish(into: store, registry: registry)
                }
            }
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
