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
        let generation = defaults.integer(forKey: Self.generationKey)
        let name = generation > 0 ? "\(storeName)-\(generation).store" : "\(storeName).store"
        return directory.appending(path: name)
    }

    var size: Int64 {
        storeSuffixes.reduce(0) { total, suffix in
            let attributes = try? manager.attributesOfItem(atPath: storeURL.path + suffix)
            return total + ((attributes?[.size] as? Int64) ?? 0)
        }
    }

    func retire() {
        destroyStore()
        defaults.set(defaults.integer(forKey: Self.generationKey) + 1, forKey: Self.generationKey)
    }

    func destroyStore() {
        for suffix in storeSuffixes {
            try? manager.removeItem(atPath: storeURL.path + suffix)
        }
    }

    func sweepRetired() {
        let current = storeURL.lastPathComponent
        let names = (try? manager.contentsOfDirectory(atPath: directory.path)) ?? []

        for name in names where name.hasPrefix(storeName) && !name.hasPrefix(current) {
            try? manager.removeItem(at: directory.appending(path: name))
        }
    }
}
