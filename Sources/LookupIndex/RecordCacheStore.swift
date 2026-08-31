//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import SwiftData

@available(iOS 17, macOS 14, *)
enum RecordCacheStore {
    private static let versionKey = "scout_record_cache_schema_version"

    static func cache() -> (any RecordCaching)? {
        let directory = URL.applicationSupportDirectory.appending(path: "Scout", directoryHint: .isDirectory)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = directory.appending(path: "RecordCache.store")
        if #available(iOS 18, macOS 15, *) {
            return cache(IndexedCachedRecord.self, at: url, defaults: .standard)
        }
        return cache(CachedRecord.self, at: url, defaults: .standard)
    }

    static func cache<Row: RecordCacheRow>(_ row: Row.Type, at url: URL, defaults: UserDefaults) -> RecordCache<Row>? {
        container(for: row, at: url, defaults: defaults).map { RecordCache<Row>(modelContainer: $0) }
    }

    // The cache is disposable: any schema mismatch destroys the store instead of migrating.
    static func container<Row: RecordCacheRow>(for row: Row.Type, at url: URL, defaults: UserDefaults) -> ModelContainer? {
        if defaults.integer(forKey: versionKey) != Row.schemaVersion || !storeHasSQLiteHeader(at: url) {
            destroyStore(at: url)
        }
        for _ in 0..<2 {
            if let container = openContainer(for: row, at: url) {
                defaults.set(Row.schemaVersion, forKey: versionKey)
                return container
            }
            destroyStore(at: url)
        }
        return nil
    }

    // SwiftData can add the store asynchronously, so a corrupt file surfaces its SQLite
    // "file is not a database" failure on a background queue that escapes `try?` and lets Core
    // Data abort the process. Destroy anything without a valid SQLite header up front so only an
    // openable (or absent) store ever reaches ModelContainer; a valid store keeps its bytes.
    private static func storeHasSQLiteHeader(at url: URL) -> Bool {
        guard let handle = try? FileHandle(forReadingFrom: url) else {
            return true
        }
        defer { try? handle.close() }
        let header = (try? handle.read(upToCount: 16)) ?? Data()
        if header.isEmpty { return true }
        return header.elementsEqual(Array("SQLite format 3\u{0}".utf8))
    }

    static func destroyStore(at url: URL) {
        for suffix in ["", "-shm", "-wal"] {
            try? FileManager.default.removeItem(atPath: url.path + suffix)
        }
    }

    private static func openContainer<Row: RecordCacheRow>(for row: Row.Type, at url: URL) -> ModelContainer? {
        let schema = Schema([Row.self, CachedSpan.self])
        let configuration = ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)
        return try? ModelContainer(for: schema, configurations: [configuration])
    }
}
