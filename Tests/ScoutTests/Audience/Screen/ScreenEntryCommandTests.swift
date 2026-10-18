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
@Suite("ScreenEntry commands")
struct ScreenEntryCommandTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let identity = Identity.stub
    let date = TestDate.reference

    @Test("Trigger opens a screen in the current session")
    func triggerOpens() throws {
        let screenID = UUID()

        try ScreenEntry.Trigger(screenID: screenID, name: "Feed", previous: "Home", identity: identity.snapshot, date: date).execute(in: context)

        let screen = try #require(try context.existing(ScreenEntry.self, key: "screenID", id: screenID))
        #expect(screen.name == "Feed")
        #expect(screen.previous == "Home")
        #expect(screen.date == date)
        #expect(screen.endDate == nil)
        #expect(screen.sessionID == identity.session.current)
        #expect(screen.launchID == identity.launch)
    }

    @Test("Complete closes an open screen once")
    func completeCloses() throws {
        let screen = makeScreen(session: SessionEntry.stub(date: date, in: context))
        try context.save()

        try ScreenEntry.Complete(screenID: screen.screenID, date: date.addingTimeInterval(30)).execute(in: context)
        try ScreenEntry.Complete(screenID: screen.screenID, date: date.addingTimeInterval(90)).execute(in: context)

        #expect(screen.endDate == date.addingTimeInterval(30))
    }

    @Test("Complete ignores an unknown screen")
    func completeUnknown() throws {
        try ScreenEntry.Complete(screenID: UUID(), date: date).execute(in: context)
    }

    @Test("Recovery closes screens of previous launches at the session end")
    func recoveryClosesStale() throws {
        let launch = LaunchEntry.stub(date: date, in: context)
        launch.launchID = UUID()
        let session = SessionEntry.stub(date: date, endDate: date.addingTimeInterval(60), launch: launch, in: context)
        let screen = makeScreen(session: session)
        try context.save()

        try ScreenEntry.Recovery(launchID: identity.launch).execute(in: context)

        #expect(screen.endDate == date.addingTimeInterval(60))
    }

    @Test("Recovery keeps the screens of the current launch open")
    func recoverySkipsCurrent() throws {
        let launch = LaunchEntry.stub(date: date, in: context)
        let screen = makeScreen(session: SessionEntry.stub(date: date, launch: launch, in: context))
        try context.save()

        try ScreenEntry.Recovery(launchID: identity.launch).execute(in: context)

        #expect(screen.endDate == nil)
    }

    private func makeScreen(session: SessionEntry) -> ScreenEntry {
        let screen = context.insert(ScreenEntry.self)
        screen.screenID = UUID()
        screen.name = "Feed"
        screen.date = date
        screen.session = session
        return screen
    }
}
