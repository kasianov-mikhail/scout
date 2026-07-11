//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Testing

@testable import Scout

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

    @Test("complete throws notFound when no session exists for the current launch")
    func completeWithoutSessionThrows() throws {
        #expect(throws: LifecycleError.notFound) {
            try SessionEntry.Complete(launchID: identity.launch).execute(in: context)
        }
    }
}
