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
        return [retentionKey: .string(RetentionKey(milestone: name, system: system.map { os in String(os.prefix { $0 != "." }) }).key)]
    }
}

struct RetentionKey {
    let milestone: String
    let system: String?

    var key: String {
        [milestone, system ?? ""].joined(separator: "|")
    }
}

extension RetentionKey {
    init?(key: String) {
        let parts = key.split(separator: "|", maxSplits: 1, omittingEmptySubsequences: false)

        guard let milestone = parts.first else {
            return nil
        }
        guard !milestone.isEmpty else {
            return nil
        }

        self.init(milestone: String(milestone), system: parts.count > 1 && !parts[1].isEmpty ? String(parts[1]) : nil)
    }
}
