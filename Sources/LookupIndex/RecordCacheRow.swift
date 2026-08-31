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
    static func predicate(fingerprint: String) -> Predicate<Self>
    static func predicate(fingerprint: String, in range: Range<Date>) -> Predicate<Self>

    static var dateSort: SortDescriptor<Self> { get }

    var fingerprint: String { get }
    var date: Date { get }
    var payload: Data { get }

    init(fingerprint: String, date: Date, payload: Data)
}

@available(iOS 17, macOS 14, *)
@Model
final class CachedRecord: RecordCacheRow {
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

@available(iOS 18, macOS 15, *)
@Model
final class IndexedCachedRecord: RecordCacheRow {
    #Index<IndexedCachedRecord>([\.fingerprint, \.date])

    static func predicate(fingerprint: String) -> Predicate<IndexedCachedRecord> {
        #Predicate { $0.fingerprint == fingerprint }
    }

    static func predicate(fingerprint: String, in range: Range<Date>) -> Predicate<IndexedCachedRecord> {
        let lower = range.lowerBound
        let upper = range.upperBound
        return #Predicate {
            $0.fingerprint == fingerprint && $0.date >= lower && $0.date < upper
        }
    }

    static var dateSort: SortDescriptor<IndexedCachedRecord> {
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
