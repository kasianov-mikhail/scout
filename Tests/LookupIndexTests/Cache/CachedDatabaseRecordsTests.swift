//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import LookupIndex
@testable import Scout

struct CachedDatabaseRecordsTests {
    @available(iOS 18, macOS 15, *)
    @Test("Lookup keys sort the requested fields and mark a full fetch")
    func lookupFingerprint() {
        let sorted = CachedDatabase.fingerprint(scope: "s", recordName: "event-1", fields: ["name", "date"])
        let reversed = CachedDatabase.fingerprint(scope: "s", recordName: "event-1", fields: ["date", "name"])
        let full = CachedDatabase.fingerprint(scope: "s", recordName: "event-1", fields: nil)

        #expect(sorted == "s|lookup|event-1|date,name")
        #expect(sorted == reversed)
        #expect(full == "s|lookup|event-1|*")
    }
}
