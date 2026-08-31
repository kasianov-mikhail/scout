//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import SwiftData

@available(iOS 17, macOS 14, *)
protocol RecordCacheRow: PersistentModel {
    var fingerprint: String { get }
    var date: Date { get }
    var payload: Data { get }

    init(fingerprint: String, date: Date, payload: Data)
}

@available(iOS 17, macOS 14, *)
extension RecordCacheRow {
    static func predicate(fingerprint: String) -> Predicate<Self> {
        #Predicate { $0.fingerprint == fingerprint }
    }

    static func predicate(fingerprint: String, in range: Range<Date>) -> Predicate<Self> {
        let lower = range.lowerBound
        let upper = range.upperBound
        return #Predicate {
            $0.fingerprint == fingerprint && $0.date >= lower && $0.date < upper
        }
    }

    static var dateSort: SortDescriptor<Self> {
        SortDescriptor(\.date)
    }
}

@available(iOS 17, macOS 14, *)
@Model
final class CachedRecord: RecordCacheRow {
    var fingerprint: String
    var date: Date
    var payload: Data

    init(fingerprint: String, date: Date, payload: Data) {
        self.fingerprint = fingerprint
        self.date = date
        self.payload = payload
    }
}

@available(iOS 18, macOS 15, *)
@Model
final class IndexedCachedRecord: RecordCacheRow {
    #Index<IndexedCachedRecord>([\.fingerprint, \.date])

    var fingerprint: String
    var date: Date
    var payload: Data

    init(fingerprint: String, date: Date, payload: Data) {
        self.fingerprint = fingerprint
        self.date = date
        self.payload = payload
    }
}

@available(iOS 17, macOS 14, *)
@Model
final class CachedSpan {
    var fingerprint: String
    var lowerDate: Date
    var upperDate: Date

    init(fingerprint: String, lowerDate: Date, upperDate: Date) {
        self.fingerprint = fingerprint
        self.lowerDate = lowerDate
        self.upperDate = upperDate
    }
}
