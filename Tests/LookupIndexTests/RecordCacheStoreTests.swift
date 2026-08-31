//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import SwiftData
import Testing

@testable import LookupIndex
@testable import Scout

struct RecordCacheStoreTests {
    let url: URL
    let defaults: UserDefaults

    init() throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        url = directory.appending(path: "RecordCache.store")
        defaults = UserDefaults(suiteName: "RecordCacheStoreTests-\(UUID().uuidString)")!
    }

    @available(iOS 17, macOS 14, *)
    @Test("Opens a fresh store and stamps the schema version")
    func opensFreshStore() {
        #expect(RecordCacheStore.container(for: CachedRecord.self, at: url, defaults: defaults) != nil)
        #expect(defaults.integer(forKey: "scout_record_cache_schema_version") == CachedRecord.schemaVersion)
    }

    @available(iOS 17, macOS 14, *)
    @Test("A version mismatch destroys the existing store")
    func destroysOnVersionMismatch() throws {
        try Data("garbage".utf8).write(to: url)
        defaults.set(CachedRecord.schemaVersion + 1, forKey: "scout_record_cache_schema_version")

        #expect(RecordCacheStore.container(for: CachedRecord.self, at: url, defaults: defaults) != nil)
        #expect(defaults.integer(forKey: "scout_record_cache_schema_version") == CachedRecord.schemaVersion)
    }

    @available(iOS 18, macOS 15, *)
    @Test("Switching to the indexed row variant restamps the store")
    func restampsOnVariantSwitch() {
        #expect(RecordCacheStore.container(for: CachedRecord.self, at: url, defaults: defaults) != nil)
        #expect(defaults.integer(forKey: "scout_record_cache_schema_version") == CachedRecord.schemaVersion)

        #expect(RecordCacheStore.container(for: IndexedCachedRecord.self, at: url, defaults: defaults) != nil)
        #expect(defaults.integer(forKey: "scout_record_cache_schema_version") == IndexedCachedRecord.schemaVersion)
    }

    @available(iOS 17, macOS 14, *)
    @Test("An unreadable store is destroyed and recreated")
    func recoversFromUnreadableStore() throws {
        try Data("garbage".utf8).write(to: url)
        defaults.set(CachedRecord.schemaVersion, forKey: "scout_record_cache_schema_version")

        #expect(RecordCacheStore.container(for: CachedRecord.self, at: url, defaults: defaults) != nil)
    }

    // Deleting the rows would leave SQLite's freed pages in the file and the store its old size,
    // so the erase has to retire the file itself — even while a container still holds it open.
    @available(iOS 17, macOS 14, *)
    @Test("An erase drops a live store to nothing and reopens empty")
    func erasesALiveStore() async throws {
        let directory = url.deletingLastPathComponent()
        let cache = try #require(RecordCacheStore.cache(CachedRecord.self, at: url, defaults: defaults))
        let range = Date(timeIntervalSince1970: 0)..<Date(timeIntervalSince1970: 10_000)
        await cache.store(makeRecords(in: range), for: "fingerprint", covering: range)
        #expect(RecordCacheStore.size(of: url) > 0)

        RecordCacheStore.clear(in: directory, defaults: defaults)

        let next = RecordCacheStore.storeURL(in: directory, defaults: defaults)
        #expect(RecordCacheStore.size(of: next) == 0)

        let reopened = try #require(RecordCacheStore.cache(CachedRecord.self, at: next, defaults: defaults))
        #expect(await reopened.coveredRange(for: "fingerprint") == nil)
    }

    @available(iOS 17, macOS 14, *)
    @Test("The size covers the store and its sidecars")
    func sizesSidecars() throws {
        for suffix in ["", "-shm", "-wal"] {
            try Data(repeating: 7, count: 100).write(to: URL(filePath: url.path + suffix))
        }

        #expect(RecordCacheStore.size(of: url) == 300)
    }

    @available(iOS 17, macOS 14, *)
    @Test("An absent store has no size")
    func sizesAnAbsentStore() {
        #expect(RecordCacheStore.size(of: url) == 0)
    }

    @available(iOS 17, macOS 14, *)
    @Test("Clearing retires the store and moves the cache to a new generation")
    func clearsIntoANewGeneration() throws {
        let directory = url.deletingLastPathComponent()
        #expect(RecordCacheStore.storeURL(in: directory, defaults: defaults) == url)
        try Data(repeating: 7, count: 100).write(to: url)

        RecordCacheStore.clear(in: directory, defaults: defaults)

        #expect(!FileManager.default.fileExists(atPath: url.path))
        let next = RecordCacheStore.storeURL(in: directory, defaults: defaults)
        #expect(next != url)
        #expect(RecordCacheStore.size(of: next) == 0)
    }

    @available(iOS 17, macOS 14, *)
    @Test("Every erase lands on a generation of its own")
    func clearsRepeatedly() {
        let directory = url.deletingLastPathComponent()
        var seen: Set<URL> = [url]

        for _ in 0..<3 {
            RecordCacheStore.clear(in: directory, defaults: defaults)
            seen.insert(RecordCacheStore.storeURL(in: directory, defaults: defaults))
        }

        #expect(seen.count == 4)
    }

    @available(iOS 17, macOS 14, *)
    @Test("Opening the cache sweeps away retired generations")
    func sweepsRetiredGenerations() throws {
        let directory = url.deletingLastPathComponent()
        let retired = directory.appending(path: "RecordCache-1.store")
        try Data(repeating: 7, count: 100).write(to: retired)
        try Data(repeating: 7, count: 100).write(to: URL(filePath: retired.path + "-wal"))
        try Data(repeating: 7, count: 100).write(to: url)
        try Data(repeating: 7, count: 100).write(to: URL(filePath: url.path + "-wal"))

        RecordCacheStore.removeStores(in: directory, besides: url)

        #expect(!FileManager.default.fileExists(atPath: retired.path))
        #expect(!FileManager.default.fileExists(atPath: retired.path + "-wal"))
        #expect(RecordCacheStore.size(of: url) == 200)
    }

    @available(iOS 17, macOS 14, *)
    @Test("The sweep leaves files that are not cache stores alone")
    func sweepsOnlyCacheStores() throws {
        let directory = url.deletingLastPathComponent()
        let unrelated = directory.appending(path: "Something.else")
        try Data(repeating: 7, count: 100).write(to: unrelated)

        RecordCacheStore.removeStores(in: directory, besides: url)

        #expect(FileManager.default.fileExists(atPath: unrelated.path))
    }

    @available(iOS 17, macOS 14, *)
    @Test("Destroying the store removes its sidecar files")
    func destroysSidecars() throws {
        for suffix in ["", "-shm", "-wal"] {
            try Data("garbage".utf8).write(to: URL(filePath: url.path + suffix))
        }

        RecordCacheStore.destroyStore(at: url)

        for suffix in ["", "-shm", "-wal"] {
            #expect(!FileManager.default.fileExists(atPath: url.path + suffix))
        }
    }
}

private func makeRecords(in range: Range<Date>) -> [Record] {
    stride(from: 0, to: 200, by: 1).map { offset in
        Record(
            recordType: "Metric",
            recordID: "record-\(offset)",
            fields: [
                "date": .date(range.lowerBound.addingTimeInterval(Double(offset))),
                "count": .int(offset),
            ]
        )
    }
}
