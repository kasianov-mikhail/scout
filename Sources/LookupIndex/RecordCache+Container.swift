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
    static func container(at url: URL, in location: RecordCacheLocation) throws -> ModelContainer {
        try location.manager.createDirectory(at: location.directory, withIntermediateDirectories: true)
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
            location.destroyStore(at: url)
        }

        let configuration = ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
