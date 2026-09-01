//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Foundation
import SwiftData

@available(iOS 18, macOS 15, *)
extension RecordCache {
    static let schema = Schema([CachedRecord.self, CachedSpan.self])

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

        let configuration = ModelConfiguration(schema: Self.schema, url: url, cloudKitDatabase: .none)

        self.init(modelContainer: try ModelContainer(for: Self.schema, configurations: [configuration]))
    }
}
