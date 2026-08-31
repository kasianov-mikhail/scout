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
    private static let generationKey = "scout_record_cache_generation"
    private static let storeName = "RecordCache"
    private static let storeSuffixes = ["", "-shm", "-wal"]

    static var directory: URL {
        URL.applicationSupportDirectory.appending(path: "Scout", directoryHint: .isDirectory)
    }

    static func storeURL(in directory: URL, defaults: UserDefaults) -> URL {
        let generation = defaults.integer(forKey: generationKey)
        let name = generation > 0 ? "\(storeName)-\(generation).store" : "\(storeName).store"
        return directory.appending(path: name)
    }

    static func cache() -> (any RecordCaching)? {
        let directory = directory
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = storeURL(in: directory, defaults: .standard)
        removeStores(in: directory, besides: url)
        if #available(iOS 18, macOS 15, *) {
            return cache(IndexedCachedRecord.self, at: url, defaults: .standard)
        }
        return cache(CachedRecord.self, at: url, defaults: .standard)
    }

    static var size: Int64 {
        size(of: storeURL(in: directory, defaults: .standard))
    }

    static func clear() {
        clear(in: directory, defaults: .standard)
    }

    static func size(of url: URL) -> Int64 {
        storeSuffixes.reduce(0) { total, suffix in
            let attributes = try? FileManager.default.attributesOfItem(atPath: url.path + suffix)
            return total + ((attributes?[.size] as? Int64) ?? 0)
        }
    }

    static func clear(in directory: URL, defaults: UserDefaults) {
        destroyStore(at: storeURL(in: directory, defaults: defaults))
        defaults.set(defaults.integer(forKey: generationKey) + 1, forKey: generationKey)
    }

    static func removeStores(in directory: URL, besides url: URL) {
        let names = (try? FileManager.default.contentsOfDirectory(atPath: directory.path)) ?? []
        let current = url.lastPathComponent
        for name in names where name.hasPrefix(storeName) && !name.hasPrefix(current) {
            try? FileManager.default.removeItem(at: directory.appending(path: name))
        }
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
        for suffix in storeSuffixes {
            try? FileManager.default.removeItem(atPath: url.path + suffix)
        }
    }

    private static func openContainer<Row: RecordCacheRow>(for row: Row.Type, at url: URL) -> ModelContainer? {
        let schema = Schema([Row.self, CachedSpan.self])
        let configuration = ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)
        return try? ModelContainer(for: schema, configurations: [configuration])
    }
}
