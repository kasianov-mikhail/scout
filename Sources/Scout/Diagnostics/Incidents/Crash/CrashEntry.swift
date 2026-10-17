//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(CrashEntry)
package final class CrashEntry: IncidentEntry, HasSession, KeyedIncident {
    package static let recordType = "Crash"
    static let idKey = "crashID"

    @NSManaged var session: SessionEntry?
    @NSManaged var crashID: UUID
    @NSManaged var threads: Data?
}

package struct CrashThread: Codable, Equatable, Sendable {
    package let crashed: Bool
    package let frames: [String]

    package init(crashed: Bool, frames: [String]) {
        self.crashed = crashed
        self.frames = frames
    }
}

extension CrashEntry: RecordEncodable {
    package var record: Record {
        var record = incident(type: Self.recordType, id: crashID)
        record["threads"] = threads
        return record
    }
}
