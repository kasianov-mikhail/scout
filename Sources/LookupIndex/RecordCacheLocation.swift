//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

// UserDefaults and FileManager are documented thread-safe but not Sendable-annotated.
struct RecordCacheLocation: @unchecked Sendable {
    private static let generationKey = "scout_record_cache_generation"
    private let storeName = "RecordCache"
    private let schemaVersion = 2
    private let storeSuffixes = ["", "-shm", "-wal"]

    let directory: URL
    let defaults: UserDefaults
    let manager: FileManager

    init(directory: URL = URL.applicationSupportDirectory.appending(path: "Scout", directoryHint: .isDirectory), defaults: UserDefaults = .standard, manager: FileManager = .default) {
        self.directory = directory
        self.defaults = defaults
        self.manager = manager
    }

    var storeURL: URL {
        storeURL(generation: generation)
    }

    var nextStoreURL: URL {
        storeURL(generation: generation + 1)
    }

    func retire() {
        destroyStore(at: storeURL)
        defaults.set(generation + 1, forKey: Self.generationKey)
    }

    func destroyStore(at url: URL) {
        for suffix in storeSuffixes {
            try? manager.removeItem(atPath: url.path + suffix)
        }
    }

    func sweepRetired() {
        let current = storeURL.lastPathComponent
        let names = (try? manager.contentsOfDirectory(atPath: directory.path)) ?? []

        for name in names where name.hasPrefix(storeName) && !name.hasPrefix(current) {
            try? manager.removeItem(at: directory.appending(path: name))
        }
    }

    private var generation: Int {
        defaults.integer(forKey: Self.generationKey)
    }

    private func storeURL(generation: Int) -> URL {
        let name = "\(storeName)-v\(schemaVersion)" + (generation > 0 ? "-\(generation)" : "")
        return directory.appending(path: "\(name).store")
    }
}
