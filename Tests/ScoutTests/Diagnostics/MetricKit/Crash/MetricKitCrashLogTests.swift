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

@MainActor
@Suite("MetricKitCrash.log")
struct MetricKitCrashLogTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let start = Date(timeIntervalSince1970: 1_750_000_000)

    @Test("A crash links to the last session its launch started before the crash")
    func linksToSession() throws {
        let launch = makeLaunch(processID: 412, date: start)
        makeSession(launch: launch, date: start)
        let later = makeSession(launch: launch, date: start.addingTimeInterval(300))
        makeSession(launch: launch, date: start.addingTimeInterval(7_200))

        try makeCrash(processID: 412).log(installID: Identity.stub.install, context: context)

        let crash = try #require(try context.fetchAll(CrashEntry.self).first)
        #expect(crash.session == later)
        #expect(crash.source == "metrickit")
        #expect(crash.windowStart == start.addingTimeInterval(60))
        #expect(crash.name == "EXC_BAD_ACCESS")
    }

    @Test("A crash its launch already recorded in process is skipped")
    func skipsDuplicateOfInProcessCrash() throws {
        let launch = makeLaunch(processID: 412, date: start)
        let session = makeSession(launch: launch, date: start)
        let caught = context.insert(CrashEntry.self)
        caught.crashID = UUID()
        caught.name = "SIGSEGV"
        caught.date = start.addingTimeInterval(500)
        caught.session = session

        try makeCrash(processID: 412).log(installID: Identity.stub.install, context: context)

        #expect(try context.fetchAll(CrashEntry.self).count == 1)
    }

    @Test("A launch with the same process ID from another install doesn't match")
    func ignoresOtherInstalls() throws {
        let launch = makeLaunch(processID: 412, date: start)
        makeSession(launch: launch, date: start)

        try makeCrash(processID: 412, signal: 9).log(installID: UUID(), context: context)

        let crash = try #require(try context.fetchAll(CrashEntry.self).first)
        #expect(crash.session == nil)
    }

    @Test("A launch that started after the crash doesn't match")
    func ignoresLaterLaunches() throws {
        let launch = makeLaunch(processID: 412, date: start.addingTimeInterval(3_600))
        makeSession(launch: launch, date: start.addingTimeInterval(3_600))

        try makeCrash(processID: 412, signal: 9).log(installID: Identity.stub.install, context: context)

        let crash = try #require(try context.fetchAll(CrashEntry.self).first)
        #expect(crash.session == nil)
    }

    @Test("Without its launch, a crash Scout catches in process is skipped")
    func skipsUnlinkedCatchableCrash() throws {
        makeInstall()

        try makeCrash(processID: nil, signal: 11).log(installID: Identity.stub.install, context: context)

        #expect(try context.fetchAll(CrashEntry.self).isEmpty)
    }

    @Test("Without its launch, a crash Scout can't catch is kept")
    func keepsUnlinkedUncatchableCrash() throws {
        makeInstall()

        try makeCrash(processID: nil, signal: 9).log(installID: Identity.stub.install, context: context)

        let crash = try #require(try context.fetchAll(CrashEntry.self).first)
        #expect(crash.session == nil)
        #expect(crash.appVersion == "3.2.0")
    }

    @Test("The same report saved twice stays one crash")
    func idempotent() throws {
        makeInstall()
        let crash = makeCrash(processID: nil, signal: 9)

        try crash.log(installID: Identity.stub.install, context: context)
        try crash.log(installID: Identity.stub.install, context: context)

        #expect(try context.fetchAll(CrashEntry.self).count == 1)
    }

    @Test("A saved crash keeps its threads")
    func savesThreads() throws {
        let threads = [CrashThread(crashed: true, frames: ["0 MyApp"]), CrashThread(crashed: false, frames: ["0 libsystem_kernel"])]

        try makeCrash(processID: nil, signal: 9, threads: threads).log(installID: Identity.stub.install, context: context)

        let entry = try #require(try context.fetchAll(CrashEntry.self).first)
        let data = try #require(entry.threads)
        #expect(try JSONDecoder().decode([CrashThread].self, from: data) == threads)
    }

    @Test("A crash without threads stores none")
    func noThreads() throws {
        try makeCrash(processID: nil, signal: 9).log(installID: Identity.stub.install, context: context)

        let entry = try #require(try context.fetchAll(CrashEntry.self).first)
        #expect(entry.threads == nil)
    }

    @Test("A saved crash marks its version as crashed for the install")
    func marksVersion() throws {
        makeInstall()

        try makeCrash(processID: nil, signal: 9).log(installID: Identity.stub.install, context: context)

        let marker = try #require(try context.fetchAll(MarkerEntry.self).first)
        #expect(marker.name == MarkerEntry.crashName)
        #expect(marker.appVersion == "3.2.0")
    }

    @discardableResult private func makeInstall() -> InstallEntry {
        InstallEntry.stub(date: start, in: context)
    }

    private func makeLaunch(processID: Int32, date: Date) -> LaunchEntry {
        let launch = LaunchEntry.stub(date: date, install: makeInstall(), in: context)
        launch.processID = processID
        return launch
    }

    @discardableResult private func makeSession(launch: LaunchEntry, date: Date) -> SessionEntry {
        let session = SessionEntry.stub(date: date, launch: launch, in: context)
        session.sessionID = UUID()
        return session
    }

    private func makeCrash(processID: Int32?, signal: Int32 = 11, threads: [CrashThread] = []) -> MetricKitCrash {
        MetricKitCrash(
            exceptionType: signal == 9 ? 10 : 1,
            signal: signal,
            terminationReason: nil,
            exception: nil,
            appVersion: "3.2.0",
            processID: processID,
            window: DateInterval(start: start.addingTimeInterval(60), end: start.addingTimeInterval(1_800)),
            frames: [MetricKitStackTree.Frame(binaryName: "MyApp", offsetIntoBinaryTextSegment: 4096, sampleCount: 1, subFrames: [])],
            threads: threads
        )
    }
}
