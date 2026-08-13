//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Testing

@testable import Scout

@Suite("Migration dedupe")
struct MigrationDedupeTests {
    /// Stores written before ScoutModel 4 can hold duplicate lifecycle rows.
    ///
    /// That is exactly the data that makes the constraint-adding migration
    /// fail. This seeds a ScoutModel 3 store with a bare chain and a filled
    /// duplicate chain, then loads it with the current model and expects a
    /// single merged row per entity with the filled attributes and children
    /// preserved.
    ///
    @Test("A store with duplicate lifecycle rows migrates into merged singles")
    func duplicatesMergeDuringMigration() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let storeURL = directory.appendingPathComponent("ScoutModel.sqlite")

        let momdURL = try #require(Bundle.module.url(forResource: "ScoutModel", withExtension: "momd"))
        let oldURL = momdURL.appendingPathComponent("ScoutModel 3.mom")
        let old = try #require(NSManagedObjectModel(contentsOf: oldURL))

        let deviceID = UUID()
        let installID = UUID()
        let launchID = UUID()
        let sessionID = UUID()
        let earlyDate = Date(timeIntervalSinceNow: -600)
        let lateDate = Date(timeIntervalSinceNow: -300)

        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: old)
        let store = try coordinator.addPersistentStore(type: .sqlite, at: storeURL)
        let seed = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        seed.persistentStoreCoordinator = coordinator

        try seed.performAndWait {
            let bare = try seed.linkedSession(
                deviceID: deviceID,
                installID: installID,
                launchID: launchID,
                sessionID: sessionID,
                date: earlyDate
            )

            let delivery = seed.insert(DeliveryEntry.self)
            delivery.backendID = "backend"
            delivery.isPending = false
            delivery.attempts = 3
            delivery.object = bare

            let device = seed.insert(DeviceEntry.self)
            device.deviceID = deviceID
            device.date = lateDate
            device.model = "iPhone17,1"

            let install = seed.insert(InstallEntry.self)
            install.installID = installID
            install.date = lateDate
            install.device = device

            let launch = seed.insert(LaunchEntry.self)
            launch.launchID = launchID
            launch.date = lateDate
            launch.install = install

            let session = seed.insert(SessionEntry.self)
            session.sessionID = sessionID
            session.date = lateDate
            session.appVersion = "2.0"
            session.osVersion = "26.0"
            session.launch = launch

            let event = seed.insert(EventEntry.self)
            event.eventID = UUID()
            event.name = "purchase"
            event.level = "info"
            event.date = lateDate
            event.session = session

            try seed.save()
        }
        try coordinator.remove(store)

        let container = NSPersistentContainer(named: "ScoutModel")
        container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: storeURL)]
        try container.loadStore()

        let context = container.newBackgroundContext()
        try context.performAndWait {
            for entity in ["DeviceEntry", "InstallEntry", "LaunchEntry", "SessionEntry"] {
                let request = NSFetchRequest<NSManagedObject>(entityName: entity)
                let count = try context.count(for: request)
                #expect(count == 1, "\(entity) deduplicated")
            }

            let device = try #require(try context.existing(DeviceEntry.self, key: "deviceID", id: deviceID))
            #expect(device.model == "iPhone17,1")
            #expect(device.date == earlyDate)

            let install = try #require(try context.existing(InstallEntry.self, key: "installID", id: installID))
            #expect(install.device == device)

            let launch = try #require(try context.existing(LaunchEntry.self, key: "launchID", id: launchID))
            #expect(launch.install == install)

            let session = try #require(try context.existing(SessionEntry.self, key: "sessionID", id: sessionID))
            #expect(session.launch == launch)
            #expect(session.appVersion == "2.0")
            #expect(session.osVersion == "26.0")
            #expect(session.date == earlyDate)
            #expect(session.events.count == 1)

            let delivery = try #require(session.deliveries.first)
            #expect(delivery.isPending)
            #expect(delivery.attempts == 0)
        }
    }
}
