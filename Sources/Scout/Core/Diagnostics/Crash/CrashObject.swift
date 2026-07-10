//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(CrashObject)
final class CrashObject: IncidentObject, HasSession {
    static let recordType = "Crash"

    @NSManaged var session: SessionObject?
    @NSManaged var crashID: UUID
}

extension CrashObject: RecordEncodable {
    var record: Record {
        incident(type: Self.recordType, id: crashID)
    }
}
