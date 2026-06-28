//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct CrashGroup: Identifiable, Hashable {
    let crashes: [Crash]

    var id: String {
        representative.fingerprint
    }

    var name: String {
        representative.name
    }
}

extension CrashGroup {
    var representative: Crash {
        crashes[0]
    }

    var count: Int {
        crashes.count
    }

    var affectedDevices: Int {
        Set(crashes.compactMap(\.deviceID)).count
    }

    var affectedSessions: Int {
        Set(crashes.compactMap(\.sessionID)).count
    }

    var firstDate: Date? {
        crashes.compactMap(\.date).min()
    }

    var lastDate: Date? {
        crashes.compactMap(\.date).max()
    }
}

extension CrashGroup: Comparable {
    static func < (lhs: CrashGroup, rhs: CrashGroup) -> Bool {
        if lhs.lastDate != rhs.lastDate {
            return (lhs.lastDate ?? .distantPast) > (rhs.lastDate ?? .distantPast)
        }
        if lhs.count != rhs.count {
            return lhs.count > rhs.count
        }
        return lhs.name < rhs.name
    }
}

extension CrashGroup {
    static func groups(from crashes: [Crash]) -> [CrashGroup] {
        Dictionary(grouping: crashes, by: \.fingerprint)
            .values
            .map { CrashGroup(crashes: $0.sorted()) }
            .sorted()
    }
}
