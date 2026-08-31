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
    init(location: RecordCacheLocation = RecordCacheLocation()) throws {
        try location.manager.createDirectory(at: location.directory, withIntermediateDirectories: true)

        let url = location.storeURL
        location.sweepRetired()

        do {
            if location.manager.fileExists(atPath: url.path) {
                _ = try NSPersistentStoreCoordinator.metadataForPersistentStore(
                    type: .sqlite,
                    at: url,
                    options: [NSReadOnlyPersistentStoreOption: true]
                )
            }
        } catch {
            location.destroyStore()
        }

        let schema = Schema([Row.self, CachedSpan.self])
        let configuration = ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)

        self.init(modelContainer: try ModelContainer(for: schema, configurations: [configuration]))
    }
}
