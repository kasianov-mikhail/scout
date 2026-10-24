//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Foundation
import Testing

@testable import Scout
@testable import Support

/// A crash whose logging failed stays in the archive and is retried on a later launch.
///
/// The launch in between must not close and purge the crashed launch, or the retry
/// re-creates bare Launch and Session rows that overwrite the delivered records.
///
@MainActor
@Suite("Incident retry")
struct IncidentRetryTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let start = TestDate.reference

    @Test("A retried crash links to the delivered launch and session instead of bare copies")
    func retryKeepsDeliveredRecords() throws {
        let crash = makeCrash()
        let (launch, session) = try deliveredLaunch()

        try recover(openLaunchIDs: [UUID(), crash.launchID])
        try SyncableEntry.purge(to: ["cloud"], in: context)
        try context.save()

        try crash.log(deviceID: UUID(), context: context)

        #expect(try context.fetchAll(LaunchEntry.self) == [launch])
        #expect(try context.fetchAll(SessionEntry.self) == [session])
        #expect(launch.record["start_date"] == start)
        #expect(session.record["start_date"] == start)
        #expect(session.record["app_version"] as String? == "1.0")
        #expect(launch.delivery(for: "cloud")?.isPending == false)
        #expect(session.delivery(for: "cloud")?.isPending == false)
        #expect(try context.fetchAll(CrashEntry.self).first?.session == session)
    }

    @Test("Recovery closes the crashed launch once its crash is logged")
    func recoveryClosesLaunchAfterRetry() throws {
        let crash = makeCrash()
        let (launch, session) = try deliveredLaunch()

        try recover(openLaunchIDs: [UUID(), crash.launchID])
        #expect(launch.endDate == nil)
        #expect(session.endDate == nil)

        try crash.log(deviceID: UUID(), context: context)
        try recover(openLaunchIDs: [UUID()])

        #expect(launch.endDate != nil)
        #expect(session.endDate != nil)
    }

    private func deliveredLaunch() throws -> (LaunchEntry, SessionEntry) {
        let launch = LaunchEntry.stub(date: start, install: InstallEntry.stub(date: start, in: context), in: context)
        let session = SessionEntry.stub(date: start, appVersion: "1.0", launch: launch, in: context)
        launch.seedDelivery(pending: false, for: "cloud", in: context)
        session.seedDelivery(pending: false, for: "cloud", in: context)
        try context.save()
        return (launch, session)
    }

    private func recover(openLaunchIDs: Set<UUID>) throws {
        try SessionEntry.Recovery(openLaunchIDs: openLaunchIDs).execute(in: context)
        try ScreenEntry.Recovery(openLaunchIDs: openLaunchIDs).execute(in: context)
        try LaunchEntry.Recovery(openLaunchIDs: openLaunchIDs).execute(in: context)
    }

    private func makeCrash() -> CrashInfo {
        CrashInfo(name: "SIGSEGV", reason: nil, stackTrace: [], backtrace: Backtrace(images: [], threads: []), identity: .stub)
    }
}
