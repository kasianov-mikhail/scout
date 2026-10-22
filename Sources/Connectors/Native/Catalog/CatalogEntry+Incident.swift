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
    static let incidentKey = "incident_key"

    // Decoding gives the fingerprint the feeds group by: a hang's is recomputed from its stack.
    static func crashKey(for record: Record) -> [String: ScoutDB.RecordValue] {
        guard let crash = try? Crash(record: record) else {
            return [:]
        }
        return [incidentKey: .string(IncidentKey(fingerprint: crash.fingerprint, name: crash.name).key)]
    }

    static func hangKey(for record: Record) -> [String: ScoutDB.RecordValue] {
        guard let hang = try? Hang(record: record) else {
            return [:]
        }
        return [incidentKey: .string(IncidentKey(fingerprint: hang.fingerprint, name: hang.name).key)]
    }
}

struct IncidentKey: Hashable {
    let fingerprint: String
    let name: String

    var key: String {
        [fingerprint, name].joined(separator: "|")
    }
}

extension IncidentKey {
    // A fingerprint is a hash and never holds a `|`, so the name keeps any it has.
    init?(key: String) {
        let parts = key.split(separator: "|", maxSplits: 1, omittingEmptySubsequences: false)

        guard parts.count == 2, !parts[0].isEmpty else {
            return nil
        }

        self.init(fingerprint: String(parts[0]), name: String(parts[1]))
    }
}
