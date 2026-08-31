//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Foundation
import SwiftData

@available(iOS 17, macOS 14, *)
extension RecordCache {
    init(directory: URL = URL.applicationSupportDirectory.appending(path: "Scout", directoryHint: .isDirectory), manager: FileManager = .default) throws {
        try manager.createDirectory(at: directory, withIntermediateDirectories: true)

        let storeName = "RecordCache"
        let url = directory.appending(path: "\(storeName).store")

        do {
            if manager.fileExists(atPath: url.path) {
                _ = try NSPersistentStoreCoordinator.metadataForPersistentStore(
                    type: .sqlite,
                    at: url,
                    options: [NSReadOnlyPersistentStoreOption: true]
                )
            }
        } catch {
            for name in try manager.contentsOfDirectory(atPath: directory.path) where name.hasPrefix(storeName) {
                try manager.removeItem(at: directory.appending(path: name))
            }
        }

        let schema = Schema([Row.self, CachedSpan.self])
        let config = ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)
        let container = try ModelContainer(for: schema, configurations: [config])

        self.init(modelContainer: container)
    }
}
