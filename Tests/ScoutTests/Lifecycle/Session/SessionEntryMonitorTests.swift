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
@Suite("SessionEntry+Monitor")
struct SessionEntryMonitorTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let identity = Identity.stub

    @Test("complete sets endDate on an open session")
    func completeOpenSession() throws {
        LaunchEntry.stub(date: Date(), in: context)
        try SessionEntry.Trigger(session: identity.session, launchID: identity.launch).execute(in: context)

        try SessionEntry.Complete(launchID: identity.launch).execute(in: context)

        let sessions = try context.fetchAll(SessionEntry.self)
        #expect(sessions.count == 1)
        #expect(sessions.first?.endDate != nil)
    }

    @Test("trigger stamps the session with the current app version")
    func triggerStampsAppVersion() throws {
        try SessionEntry.Trigger(session: identity.session, launchID: identity.launch).execute(in: context)

        let session = try #require(try context.fetchAll(SessionEntry.self).first)
        #expect(session.appVersion == Bundle.main.marketingVersion)
        #expect(session.buildNumber == Bundle.main.buildNumber)
    }

    @Test("trigger stamps the session with the runtime environment")
    func triggerStampsEnvironment() throws {
        try SessionEntry.Trigger(session: identity.session, launchID: identity.launch).execute(in: context)

        let session = try #require(try context.fetchAll(SessionEntry.self).first)
        #expect(session.osVersion == SystemInfo.osVersion)
        #expect(session.locale == SystemInfo.locale)
        #expect(session.channel == SystemInfo.channel)
    }

    @Test("complete is a no-op when the session is already closed")
    func completeTwiceIsNoop() throws {
        LaunchEntry.stub(date: Date(), in: context)
        try SessionEntry.Trigger(session: identity.session, launchID: identity.launch).execute(in: context)
        try SessionEntry.Complete(launchID: identity.launch).execute(in: context)

        let firstEndDate = try #require(try context.fetchAll(SessionEntry.self).first?.endDate)

        try SessionEntry.Complete(launchID: identity.launch).execute(in: context)

        let session = try #require(try context.fetchAll(SessionEntry.self).first)
        #expect(session.endDate == firstEndDate)
    }

    @Test("complete queues the closed session for delivery again")
    func completeRequeuesDelivery() throws {
        LaunchEntry.stub(date: Date(), in: context)
        try SessionEntry.Trigger(session: identity.session, launchID: identity.launch).execute(in: context)

        let session = try #require(try context.fetchAll(SessionEntry.self).first)
        let delivery = session.seedDelivery(pending: false, attempts: 3, for: "cloud", in: context)

        try SessionEntry.Complete(launchID: identity.launch).execute(in: context)

        #expect(delivery.isPending)
        #expect(delivery.attempts == 0)
    }

    @Test("complete is a no-op when the launch never opened a session")
    func completeWithoutSessionIsNoop() throws {
        try SessionEntry.Complete(launchID: identity.launch).execute(in: context)

        #expect(try context.fetchAll(SessionEntry.self).isEmpty)
    }

    @Test("trigger records the session identifier it was handed")
    func triggerAdoptsCurrentSession() throws {
        try SessionEntry.Trigger(session: identity.session, launchID: identity.launch).execute(in: context)

        let session = try #require(try context.fetchAll(SessionEntry.self).first)
        #expect(session.sessionID == identity.session.current)
    }

    @Test("trigger fills in the session an earlier record created")
    func triggerFillsExistingSession() throws {
        let snapshot = identity.snapshot
        _ = try context.makeLinkedSession(identity: snapshot)
        try context.save()

        try SessionEntry.Trigger(session: identity.session, launchID: identity.launch).execute(in: context)

        let sessions = try context.fetchAll(SessionEntry.self)
        #expect(sessions.count == 1)
        #expect(sessions.first?.sessionID == snapshot.session)
        #expect(sessions.first?.appVersion == Bundle.main.marketingVersion)
    }

    @Test("rotation opens the current session when the launch has none yet")
    func rotationOpensCurrentSession() throws {
        let session = Protected(UUID())
        let first = session.current

        try SessionEntry.Rotation(session: session, launchID: identity.launch).execute(in: context)

        #expect(session.current == first)
        #expect(try context.fetchAll(SessionEntry.self).map(\.sessionID) == [first])
    }

    @Test("rotation keeps the current session while it is still open")
    func rotationKeepsOpenSession() throws {
        let session = Protected(UUID())
        let first = session.current
        LaunchEntry.stub(date: Date(), in: context)

        try SessionEntry.Rotation(session: session, launchID: identity.launch).execute(in: context)
        try SessionEntry.Rotation(session: session, launchID: identity.launch).execute(in: context)

        #expect(session.current == first)
        #expect(try context.fetchAll(SessionEntry.self).count == 1)
    }

    @Test("rotation opens a session under a fresh identifier after the current one closed")
    func rotationOpensNewSession() throws {
        let session = Protected(UUID())
        let first = session.current
        LaunchEntry.stub(date: Date(), in: context)

        try SessionEntry.Rotation(session: session, launchID: identity.launch).execute(in: context)
        try SessionEntry.Complete(launchID: identity.launch).execute(in: context)
        try SessionEntry.Rotation(session: session, launchID: identity.launch).execute(in: context)

        #expect(session.current != first)
        #expect(Set(try context.fetchAll(SessionEntry.self).map(\.sessionID)) == [first, session.current])
    }

    @Test("rotation opens a fresh session after the closed one was delivered, and leaves the closed one as it was")
    func rotationAfterDeliveryOpensNewSession() throws {
        let session = Protected(UUID())
        let first = session.current
        LaunchEntry.stub(date: Date(), in: context)

        try SessionEntry.Rotation(session: session, launchID: identity.launch).execute(in: context)
        try SessionEntry.Complete(launchID: identity.launch).execute(in: context)
        let closed = try #require(try context.fetchAll(SessionEntry.self).first)
        let closedDate = closed.date
        try purgeDelivered(closed)

        try SessionEntry.Rotation(session: session, launchID: identity.launch).execute(in: context)

        #expect(session.current != first)
        #expect(Set(try context.fetchAll(SessionEntry.self).map(\.sessionID)) == [first, session.current])
        #expect(closed.date == closedDate)
        #expect(closed.endDate != nil)
        #expect(closed.delivery(for: "cloud")?.isPending == false)
    }

    @Test("a record written after the session closed and was delivered links to it without reopening it")
    func linkedSessionKeepsDeliveredSessionClosed() throws {
        LaunchEntry.stub(date: Date(), in: context)
        try SessionEntry.Trigger(session: identity.session, launchID: identity.launch).execute(in: context)
        try SessionEntry.Complete(launchID: identity.launch).execute(in: context)
        let closed = try #require(try context.fetchAll(SessionEntry.self).first)
        try purgeDelivered(closed)

        let linked = try #require(try context.makeLinkedSession(identity: identity.snapshot))

        #expect(linked == closed)
        #expect(linked.endDate != nil)
        #expect(linked.delivery(for: "cloud")?.isPending == false)
        #expect(try context.fetchAll(SessionEntry.self).count == 1)
    }

    @Test("a background record after its session was purged links to the launch and creates no session")
    func backgroundRecordAfterPurgeCreatesNoSession() throws {
        LaunchEntry.stub(date: Date(), in: context)
        try SessionEntry.Trigger(session: identity.session, launchID: identity.launch).execute(in: context)
        try SessionEntry.Complete(launchID: identity.launch).execute(in: context)
        context.delete(try #require(try context.fetchAll(SessionEntry.self).first))
        try context.save()

        let snapshot = Identity.Snapshot(install: identity.install, launch: identity.launch, device: identity.device, session: identity.session.current, isForeground: false)
        let event = context.insert(EventEntry.self)
        try context.link(entry: event, identity: snapshot, date: Date())

        #expect(try context.fetchAll(SessionEntry.self).isEmpty)
        #expect(event.session == nil)
        #expect(event.launchID == identity.launch)
    }

    @Test("trigger queues a delivered session again after stamping it")
    func triggerRequeuesStampedSession() throws {
        let launch = LaunchEntry.stub(date: Date(), in: context)
        let session = SessionEntry.stub(date: Date(), launch: launch, in: context)
        let delivery = session.seedDelivery(pending: false, attempts: 3, for: "cloud", in: context)
        try context.save()

        try SessionEntry.Trigger(session: identity.session, launchID: identity.launch).execute(in: context)

        #expect(delivery.isPending)
        #expect(delivery.attempts == 0)
    }

    private func purgeDelivered(_ session: SessionEntry) throws {
        session.seedDelivery(pending: false, for: "cloud", in: context)
        try context.save()
        try SyncableEntry.purge(to: ["cloud"], in: context)
        try context.save()
    }
}
