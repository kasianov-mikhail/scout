//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@testable import Scout

final class TemporaryStore {
    let directory = URL.applicationSupportDirectory.appending(path: "ScoutTests").appending(path: UUID().uuidString)

    private var containers: [NSPersistentContainer] = []

    var url: URL {
        directory.appendingPathComponent("ScoutModel.sqlite")
    }

    init() throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    func seed(model: NSManagedObjectModel, body: (NSManagedObjectContext) throws -> Void) throws {
        let seedURL = directory.appendingPathComponent("Seed.sqlite")

        try autoreleasepool {
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
            let options = [NSSQLitePragmasOption: ["journal_mode": "DELETE"] as NSDictionary]
            let store = try coordinator.addPersistentStore(type: .sqlite, at: seedURL, options: options)
            let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            context.persistentStoreCoordinator = coordinator

            try context.performAndWait {
                try body(context)
                try context.save()
            }
            try coordinator.remove(store)
        }

        try FileManager.default.copyItem(at: seedURL, to: url)
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
