//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Support
import SwiftData
import Testing

@testable import Cache
@testable import Scout

@available(iOS 17, macOS 14, *)
func makeRecordCache<Row: CacheRow>(_ row: Row.Type) throws -> RecordCache<Row> {
    let schema = Schema([Row.self, CachedSpan.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try SerializedStore.connect { try ModelContainer(for: schema, configurations: [configuration]) }
    return RecordCache<Row>(modelContainer: container)
}

struct RecordCacheTests {
    func makeRecord(date: Date, name: String = "Session") -> Record {
        var record = Record(recordType: "MetricSeriesPoint", recordID: UUID().uuidString)
        record.fields["date"] = .date(date)
        record.fields["name"] = .string(name)
        record.fields["value"] = .int(5)
        return record
    }

    func date(_ interval: TimeInterval) -> Date {
        Date(timeIntervalSince1970: interval)
    }

    @available(iOS 17, macOS 14, *)
    @Test("Stored records round-trip through the cache")
    func roundTrip() async throws {
        let cache = try makeRecordCache(CachedRecord.self)
        let records = [makeRecord(date: date(100)), makeRecord(date: date(200))]

        await cache.store(records, for: "fp", covering: date(0)..<date(300))

        let cached = try #require(await cache.records(for: "fp", in: date(0)..<date(300)))
        #expect(cached.map(\.recordID) == records.map(\.recordID))
        #expect(cached.first?.fields == records.first?.fields)
        #expect(await cache.coveredRange(for: "fp") == date(0)..<date(300))
    }

    @available(iOS 17, macOS 14, *)
    @Test("Contiguous stores extend the covered span")
    func extendsSpan() async throws {
        let cache = try makeRecordCache(CachedRecord.self)

        await cache.store([makeRecord(date: date(100))], for: "fp", covering: date(0)..<date(300))
        await cache.store([makeRecord(date: date(400))], for: "fp", covering: date(300)..<date(600))

        #expect(await cache.coveredRange(for: "fp") == date(0)..<date(600))

        let cached = try #require(await cache.records(for: "fp", in: date(0)..<date(600)))
        #expect(cached.count == 2)
    }

    @available(iOS 17, macOS 14, *)
    @Test("A disjoint store replaces the previous span")
    func replacesDisjointSpan() async throws {
        let cache = try makeRecordCache(CachedRecord.self)

        await cache.store([makeRecord(date: date(100))], for: "fp", covering: date(0)..<date(300))
        await cache.store([makeRecord(date: date(700))], for: "fp", covering: date(600)..<date(900))

        #expect(await cache.coveredRange(for: "fp") == date(600)..<date(900))

        let cached = try #require(await cache.records(for: "fp", in: date(0)..<date(900)))
        #expect(cached.count == 1)
        #expect(cached.first?.fields["date"] == .date(date(700)))
    }

    @available(iOS 17, macOS 14, *)
    @Test("Overlapping stores do not duplicate records")
    func deduplicatesOverlap() async throws {
        let cache = try makeRecordCache(CachedRecord.self)
        let record = makeRecord(date: date(100))

        await cache.store([record], for: "fp", covering: date(0)..<date(300))
        await cache.store([record], for: "fp", covering: date(0)..<date(300))

        let cached = try #require(await cache.records(for: "fp", in: date(0)..<date(300)))
        #expect(cached.count == 1)
    }

    @available(iOS 17, macOS 14, *)
    @Test("Fingerprints are isolated from each other")
    func isolatesFingerprints() async throws {
        let cache = try makeRecordCache(CachedRecord.self)

        await cache.store([makeRecord(date: date(100))], for: "a", covering: date(0)..<date(300))

        #expect(await cache.coveredRange(for: "b") == nil)

        let cached = try #require(await cache.records(for: "b", in: date(0)..<date(300)))
        #expect(cached.count == 0)
    }

    @available(iOS 17, macOS 14, *)
    @Test("A record without a date aborts the store")
    func abortsWithoutDate() async throws {
        let cache = try makeRecordCache(CachedRecord.self)
        let record = Record(recordType: "MetricSeriesPoint", recordID: UUID().uuidString)

        await cache.store([record], for: "fp", covering: date(0)..<date(300))

        #expect(await cache.coveredRange(for: "fp") == nil)
    }

    @available(iOS 17, macOS 14, *)
    @Test("Records outside the covered range are skipped")
    func skipsOutOfRange() async throws {
        let cache = try makeRecordCache(CachedRecord.self)
        let records = [makeRecord(date: date(100)), makeRecord(date: date(500))]

        await cache.store(records, for: "fp", covering: date(0)..<date(300))

        let cached = try #require(await cache.records(for: "fp", in: date(0)..<date(900)))
        #expect(cached.count == 1)
        #expect(cached.first?.fields["date"] == .date(date(100)))
    }

    @available(iOS 18, macOS 15, *)
    @Test("Indexed records round-trip through range predicates")
    func indexedRoundTrip() async throws {
        let cache = try makeRecordCache(IndexedCachedRecord.self)
        let records = [makeRecord(date: date(100)), makeRecord(date: date(200)), makeRecord(date: date(500))]

        await cache.store(records, for: "fp", covering: date(0)..<date(600))

        let inRange = try #require(await cache.records(for: "fp", in: date(0)..<date(300)))
        #expect(inRange.map(\.recordID) == Array(records.prefix(2)).map(\.recordID))
        #expect(await cache.coveredRange(for: "fp") == date(0)..<date(600))
    }
}
