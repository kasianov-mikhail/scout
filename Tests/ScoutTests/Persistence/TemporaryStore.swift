//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@testable import Scout

// Uniqueness constraints and row versioning are only enforced by the SQLite
// store, so the persistence suites need a real file on disk — an in-memory
// store silently allows a duplicate and never conflicts.
//
// SQLite tracks an open file once per (device, inode) for the whole process,
// so deleting a store the coordinator still holds open leaves that entry
// pointing at an unlinked vnode — "BUG IN CLIENT OF libsqlite3.dylib: vnode
// unlinked while in use" — and the next store the file system hands the
// recycled inode inherits it and fails to open. Every store here is closed
// before its directory goes away.
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
