//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package protocol CacheStorage: Actor {
    func bytes() -> Int64
    func removeAll()
}

package protocol RecordCaching: CacheStorage {
    func coveredRange(for fingerprint: String) -> Range<Date>?
    func records(for fingerprint: String, in range: Range<Date>) -> [Record]?
    func store(_ records: [Record], for fingerprint: String, covering range: Range<Date>)
    func lookupRecord(for fingerprint: String) -> Record?
    func storeLookup(_ record: Record, for fingerprint: String)
}
