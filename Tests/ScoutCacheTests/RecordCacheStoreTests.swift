//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import SwiftData
import Testing

@testable import ScoutCache
@testable import ScoutCore

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
