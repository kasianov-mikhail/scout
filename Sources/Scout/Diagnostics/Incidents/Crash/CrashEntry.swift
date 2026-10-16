//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(CrashEntry)
package final class CrashEntry: IncidentEntry, HasSession {
    package static let recordType = "Crash"

    @NSManaged var session: SessionEntry?
    @NSManaged var crashID: UUID
}

extension CrashEntry: RecordEncodable {
    package var record: Record {
        incident(type: Self.recordType, id: crashID)
    }
}
