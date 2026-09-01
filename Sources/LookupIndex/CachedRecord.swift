//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import SwiftData

@available(iOS 18, macOS 15, *)
@Model
final class CachedRecord {
    #Index<CachedRecord>([\.fingerprint, \.date])

    static func predicate(fingerprint: String) -> Predicate<CachedRecord> {
        #Predicate { $0.fingerprint == fingerprint }
    }

    static func predicate(fingerprint: String, in range: Range<Date>) -> Predicate<CachedRecord> {
        let lower = range.lowerBound
        let upper = range.upperBound
        return #Predicate {
            $0.fingerprint == fingerprint && $0.date >= lower && $0.date < upper
        }
    }

    static var dateSort: SortDescriptor<CachedRecord> {
        SortDescriptor(\.date)
    }

    var fingerprint: String
    var date: Date
    var payload: Data

    init(fingerprint: String, date: Date, payload: Data) {
        self.fingerprint = fingerprint
        self.date = date
        self.payload = payload
    }
}
