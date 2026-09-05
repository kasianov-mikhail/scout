//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@testable import Scout

final class TemporaryStore {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

    private var containers: [NSPersistentContainer] = []

    var url: URL {
        directory.appendingPathComponent("ScoutModel.sqlite")
    }

    init() throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    func container() throws -> NSPersistentContainer {
        let container = NSPersistentContainer(named: "ScoutModel")
        container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: url)]
        try container.loadStore()
        containers.append(container)
        return container
    }

    func tearDown() {
        for container in containers {
            let coordinator = container.persistentStoreCoordinator
            for store in coordinator.persistentStores {
                try? coordinator.remove(store)
            }
        }
        containers.removeAll()
        try? FileManager.default.removeItem(at: directory)
    }
}
