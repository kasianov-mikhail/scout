//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import SwiftData

@available(iOS 17, macOS 14, *)
@Model
final class CachedRecord {
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

@available(iOS 17, macOS 14, *)
enum RecordCacheStore {
    static let schemaVersion = 1

    private static let versionKey = "scout_record_cache_schema_version"

    static func container() -> ModelContainer? {
        let directory = URL.applicationSupportDirectory.appending(path: "Scout", directoryHint: .isDirectory)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return container(at: directory.appending(path: "RecordCache.store"), defaults: .standard)
    }

    // The cache is disposable: any schema mismatch destroys the store instead of migrating.
    static func container(at url: URL, defaults: UserDefaults) -> ModelContainer? {
        if defaults.integer(forKey: versionKey) != schemaVersion {
            destroyStore(at: url)
        }
        if let container = openContainer(at: url) {
            defaults.set(schemaVersion, forKey: versionKey)
            return container
        }
        destroyStore(at: url)
        guard let container = openContainer(at: url) else { return nil }
        defaults.set(schemaVersion, forKey: versionKey)
        return container
    }

    static func destroyStore(at url: URL) {
        for suffix in ["", "-shm", "-wal"] {
            try? FileManager.default.removeItem(atPath: url.path + suffix)
        }
    }

    private static func openContainer(at url: URL) -> ModelContainer? {
        let schema = Schema([CachedRecord.self, CachedSpan.self])
        let configuration = ModelConfiguration(schema: schema, url: url)
        return try? ModelContainer(for: schema, configurations: [configuration])
    }
}
