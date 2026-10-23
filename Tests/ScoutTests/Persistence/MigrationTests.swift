//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Testing

@testable import Scout
@testable import Support

@Suite("ScoutModel migrations")
struct MigrationTests {
    @Test("Every historical model version migrates to the current model")
    func historicalVersionsMigrate() throws {
        let momdURL = try #require(Bundle.module.url(forResource: "ScoutModel", withExtension: "momd"))
        let current = NSManagedObjectModel.scout

        let versions = try FileManager.default
            .contentsOfDirectory(at: momdURL, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "mom" }

        // A broken resource lookup would make the loop below pass vacuously;
        // the model ships at least three versions, so fewer means enumeration
        // silently failed.
        try #require(versions.count >= 3)

        for versionURL in versions {
            let old = try #require(NSManagedObjectModel(contentsOf: versionURL))
            guard old.entityVersionHashesByName != current.entityVersionHashesByName else {
                continue
            }

            let store = try TemporaryStore()
            defer { store.tearDown() }
            let storeURL = store.url

            try store.seed(model: old) { _ in }

            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: current)
            let options: [String: Any] = [
                NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true,
            ]

            do {
                let store = try coordinator.addPersistentStore(
                    ofType: NSSQLiteStoreType,
                    configurationName: nil,
                    at: storeURL,
                    options: options
                )
                let metadata = coordinator.metadata(for: store)
                #expect(current.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata))
                try coordinator.remove(store)
            } catch {
                Issue.record("Store created by \(versionURL.lastPathComponent) failed to migrate: \(error)")
            }
        }
    }

    @Test("A ScoutModel 4 store keeps its crashes and launches after migration")
    func version4DataSurvives() throws {
        let store = try TemporaryStore()
        defer { store.tearDown() }

        let momdURL = try #require(Bundle.module.url(forResource: "ScoutModel", withExtension: "momd"))
        let old = try #require(NSManagedObjectModel(contentsOf: momdURL.appendingPathComponent("ScoutModel 4.mom")))

        let launchID = UUID()
        let crashID = UUID()
        let date = Date(timeIntervalSince1970: 1_750_000_000)

        try store.seed(model: old) { seed in
            let launch = seed.insert(LaunchEntry.self)
            launch.launchID = launchID
            launch.date = date

            let crash = seed.insert(CrashEntry.self)
            crash.crashID = crashID
            crash.name = "SIGSEGV"
            crash.reason = "Signal 11 received"
            crash.date = date
        }

        let context = try store.container().newBackgroundContext()
        try context.performAndWait {
            let launch = try #require(try context.existing(LaunchEntry.self, key: "launchID", id: launchID))
            #expect(launch.processID == 0)

            let crash = try #require(try context.existing(CrashEntry.self, key: "crashID", id: crashID))
            #expect(crash.name == "SIGSEGV")
            #expect(crash.reason == "Signal 11 received")
            #expect(crash.source == nil)
            #expect(crash.windowStart == nil)
        }
    }

    @Test("A ScoutModel 11 store keeps the session of every scoped entry after migration")
    func version11ScopedSessionsSurvive() throws {
        let store = try TemporaryStore()
        defer { store.tearDown() }

        let momdURL = try #require(Bundle.module.url(forResource: "ScoutModel", withExtension: "momd"))
        let old = try #require(NSManagedObjectModel(contentsOf: momdURL.appendingPathComponent("ScoutModel 11.mom")))

        let sessionID = UUID()
        let date = Date(timeIntervalSince1970: 1_750_000_000)

        try store.seed(model: old) { seed in
            let session = seed.insert(SessionEntry.self)
            session.sessionID = sessionID
            session.date = date

            let event = seed.insert(EventEntry.self)
            event.eventID = UUID()
            event.name = "purchase"
            event.level = "info"

            let screen = seed.insert(ScreenEntry.self)
            screen.screenID = UUID()
            screen.name = "Home"

            let condition = seed.insert(ConditionEntry.self)
            condition.conditionID = UUID()
            condition.kind = "thermal_state"

            let metrics = seed.insert(IntMetricsEntry.self)
            metrics.name = "requests"
            metrics.telemetry = "counter"
            metrics.value = 1

            let crash = seed.insert(CrashEntry.self)
            crash.crashID = UUID()
            crash.name = "SIGSEGV"

            let hang = seed.insert(HangEntry.self)
            hang.hangID = UUID()
            hang.name = "Hang"
            hang.duration = 2

            let resource = seed.insert(ResourceEntry.self)
            resource.resourceID = UUID()
            resource.name = "CPU"
            resource.kind = "cpu"

            let scopedEntries: [SessionScopeEntry] = [event, screen, condition, metrics, crash, hang, resource]
            for scopedEntry in scopedEntries {
                scopedEntry.date = date
                scopedEntry.session = session
            }
        }

        let context = try store.container().newBackgroundContext()
        try context.performAndWait {
            let session = try #require(try context.existing(SessionEntry.self, key: "sessionID", id: sessionID))

            let entities = ["EventEntry", "ScreenEntry", "ConditionEntry", "IntMetricsEntry", "CrashEntry", "HangEntry", "ResourceEntry"]
            for entity in entities {
                let scopedEntries = try context.fetch(NSFetchRequest<SessionScopeEntry>(entityName: entity))
                #expect(scopedEntries.count == 1, "\(entity) survives")
                #expect(scopedEntries.allSatisfy { $0.session == session }, "\(entity) keeps its session")
            }

            #expect(session.scopedEntries.count == entities.count)
        }
    }

    @Test("A ScoutModel 12 store keeps the launch of every scoped entry after migration")
    func version12ScopedLaunchesSurvive() throws {
        let store = try TemporaryStore()
        defer { store.tearDown() }

        let momdURL = try #require(Bundle.module.url(forResource: "ScoutModel", withExtension: "momd"))
        let old = try #require(NSManagedObjectModel(contentsOf: momdURL.appendingPathComponent("ScoutModel 12.mom")))

        let launchID = UUID()
        let sessionID = UUID()
        let date = Date(timeIntervalSince1970: 1_750_000_000)

        try store.seed(model: old) { seed in
            let launch = seed.insert(LaunchEntry.self)
            launch.launchID = launchID
            launch.date = date

            let session = seed.insert(SessionEntry.self)
            session.sessionID = sessionID

            let version = seed.insert(VersionEntry.self)
            version.appVersion = "2.0"

            let visit = seed.insert(VisitEntry.self)
            visit.visitID = UUID()

            let scopedEntries: [LaunchScopeEntry] = [session, version, visit]
            for scopedEntry in scopedEntries {
                scopedEntry.date = date
                scopedEntry.launch = launch
            }

            let event = seed.insert(EventEntry.self)
            event.eventID = UUID()
            event.name = "purchase"
            event.level = "info"
            event.date = date
            event.session = session
        }

        let context = try store.container().newBackgroundContext()
        try context.performAndWait {
            let launch = try #require(try context.existing(LaunchEntry.self, key: "launchID", id: launchID))

            let entities = ["SessionEntry", "VersionEntry", "VisitEntry"]
            for entity in entities {
                let scopedEntries = try context.fetch(NSFetchRequest<LaunchScopeEntry>(entityName: entity))
                #expect(scopedEntries.count == 1, "\(entity) survives")
                #expect(scopedEntries.allSatisfy { $0.launch == launch }, "\(entity) keeps its launch")
            }

            #expect(launch.scopedEntries.count == entities.count)

            let session = try #require(try context.existing(SessionEntry.self, key: "sessionID", id: sessionID))
            #expect(session.scopedEntries.count == 1)
        }
    }

    @Test("A ScoutModel 15 store drops its local markers and keeps the install after migration")
    func version15MarkersDropped() throws {
        let store = try TemporaryStore()
        defer { store.tearDown() }

        let momdURL = try #require(Bundle.module.url(forResource: "ScoutModel", withExtension: "momd"))
        let old = try #require(NSManagedObjectModel(contentsOf: momdURL.appendingPathComponent("ScoutModel 15.mom")))

        let installID = UUID()
        let date = Date(timeIntervalSince1970: 1_750_000_000)

        try store.seed(model: old) { seed in
            let install = seed.insert(InstallEntry.self)
            install.installID = installID
            install.date = date

            let marker = NSEntityDescription.insertNewObject(forEntityName: "MarkerEntry", into: seed)
            marker.setValue(UUID(), forKey: "markerID")
            marker.setValue(Version.installMarker, forKey: "name")
            marker.setValue("2.0", forKey: "appVersion")
            for key in ["datePrimitive", "hour", "day", "week", "month"] {
                marker.setValue(date, forKey: key)
            }
            marker.setValue(install, forKey: "install")
        }

        let context = try store.container().newBackgroundContext()
        try context.performAndWait {
            let install = try #require(try context.existing(InstallEntry.self, key: "installID", id: installID))
            #expect(install.firstSeen.isEmpty)
            #expect(try context.fetchAll(FirstSeenEntry.self).isEmpty)
        }
    }

    @Test("A ScoutModel 16 install migrates without an OS stamp or retention marks")
    func version16InstallsStayOutOfCohorts() throws {
        let store = try TemporaryStore()
        defer { store.tearDown() }

        let momdURL = try #require(Bundle.module.url(forResource: "ScoutModel", withExtension: "momd"))
        let old = try #require(NSManagedObjectModel(contentsOf: momdURL.appendingPathComponent("ScoutModel 16.mom")))

        let installID = UUID()
        let date = Date(timeIntervalSince1970: 1_750_000_000)

        try store.seed(model: old) { seed in
            let install = seed.insert(InstallEntry.self)
            install.installID = installID
            install.date = date
        }

        let context = try store.container().newBackgroundContext()
        try context.performAndWait {
            let install = try #require(try context.existing(InstallEntry.self, key: "installID", id: installID))
            #expect(install.date == date)
            #expect(install.osVersion == nil)
            #expect(install.retentionMarks.isEmpty)

            try install.markVisit(date: date.addingDay())
            #expect(try context.fetchAll(RetentionMarkEntry.self).isEmpty)
        }
    }

    @Test("A ScoutModel 18 pending delivery stays due after migration")
    func version18DeliveriesStayDue() throws {
        let store = try TemporaryStore()
        defer { store.tearDown() }

        let momdURL = try #require(Bundle.module.url(forResource: "ScoutModel", withExtension: "momd"))
        let old = try #require(NSManagedObjectModel(contentsOf: momdURL.appendingPathComponent("ScoutModel 18.mom")))

        try store.seed(model: old) { seed in
            EventEntry.stub(name: "login", in: seed).seedDelivery(attempts: 1, for: "cloud", in: seed)
        }

        let context = try store.container().newBackgroundContext()
        try context.performAndWait {
            let now = Date()
            let request = NSFetchRequest<EventEntry>(entityName: "EventEntry", pendingBackendID: "cloud", now: now)
            let event = try #require(try context.fetch(request).first)
            let delivery = try #require(event.delivery(for: "cloud"))
            #expect(delivery.attempts == 1)
            #expect(delivery.nextAttemptDate == nil)

            delivery.reject(now: now)
            try context.save()
            #expect(try context.fetch(request).isEmpty)
        }
    }
}
