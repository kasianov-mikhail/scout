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
    static let retentionKey = "milestone"

    static func retentionKey(for record: Record) -> [String: ScoutDB.RecordValue] {
        let name: String? = record["name"]
        let system: String? = record["os_version"]

        guard let name else {
            return [:]
        }
        return [retentionKey: .string(SystemScopedKey(value: name, system: system.map { os in String(os.prefix { $0 != "." }) }).key)]
    }
}
