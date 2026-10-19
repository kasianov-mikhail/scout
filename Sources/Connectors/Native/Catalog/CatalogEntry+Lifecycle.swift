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
    static let lifecycleKey = "lifecycle_key"

    static func lifecycleKey(for record: Record) -> [String: ScoutDB.RecordValue] {
        lifecycleKey(name: nil, record: record)
    }

    static func metricLifecycleKey(for record: Record) -> [String: ScoutDB.RecordValue] {
        lifecycleKey(name: record["name"], record: record)
    }

    private static func lifecycleKey(name: String?, record: Record) -> [String: ScoutDB.RecordValue] {
        let category: String? = record["category"]
        let version: String? = record["app_version"]
        let key = [name, category, version].map { ($0 ?? "").escaped }.joined(separator: "|")

        return [lifecycleKey: .string(key)]
    }
}

struct LifecycleKey {
    let name: String?
    let category: String?
    let version: String?

    init(_ key: String) {
        var parts: [String] = []
        var current = ""
        var isEscaped = false

        for character in key {
            if isEscaped {
                current.append(character)
                isEscaped = false
            } else if character == "\\" {
                isEscaped = true
            } else if character == "|" {
                parts.append(current)
                current = ""
            } else {
                current.append(character)
            }
        }
        parts.append(current)

        let values = parts.map { $0.isEmpty ? nil : $0 }
        name = values.count == 3 ? values[0] : nil
        category = values.count == 3 ? values[1] : nil
        version = values.count == 3 ? values[2] : nil
    }
}
