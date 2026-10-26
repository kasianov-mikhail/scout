//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Logging
import Testing

@testable import Scout
@testable import Support

@MainActor
@Suite("Identity+Bootstrap")
struct IdentityBootstrapTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let identity = Identity.stub
    let bundle = Bundle.stub(appVersion: "1.0", buildNumber: "1")

    private func startup(_ identity: Identity) throws {
        for command in identity.startupCommands(bundle: bundle) {
            try command.execute(in: context)
        }
    }

    private func enterForeground(_ identity: Identity) throws {
        for command in identity.foregroundCommands {
            try command.execute(in: context)
        }
    }

    private func log(_ identity: Identity, date: Date) throws {
        let event = LogEvent(level: .info, message: "refresh", metadata: nil, source: nil, file: #file, function: #function, line: #line)
        try event.log(date: date, identity: identity.snapshot, context: context)
    }

    @Test("startup links the launch, install and device in one pass")
    func startupLinksChain() throws {
        try startup(identity)

        let launch = try #require(try context.fetchAll(LaunchEntry.self).first)
        #expect(launch.launchID == identity.launch)
        #expect(launch.install?.installID == identity.install)
        #expect(launch.install?.device?.deviceID == identity.device)
    }

    @Test("startup opens no session and no visit, so a background launch is not counted")
    func startupOpensNoSession() throws {
        try startup(identity)

        #expect(try context.fetchAll(SessionEntry.self).isEmpty)
        #expect(try context.fetchAll(VisitEntry.self).isEmpty)
    }

    @Test("entering the foreground after startup opens one session and one visit for the launch")
    func foregroundAfterStartupOpensSession() throws {
        let identity = Identity(install: UUID(), launch: UUID(), device: UUID(), session: Protected(UUID()), foreground: Protected(true))
        let first = identity.session.current

        try startup(identity)
        try enterForeground(identity)

        let session = try #require(try context.fetchAll(SessionEntry.self).first)
        #expect(try context.fetchAll(SessionEntry.self).count == 1)
        #expect(session.sessionID == first)
        #expect(session.launch?.install?.device?.deviceID == identity.device)

        let visit = try #require(try context.fetchAll(VisitEntry.self).first)
        #expect(visit.launch?.launchID == identity.launch)
    }

    @Test("a log written before the first foreground opens no session and keeps the launch, install and device")
    func backgroundLogOpensNoSession() throws {
        let identity = Identity(install: UUID(), launch: UUID(), device: UUID(), session: Protected(UUID()), foreground: Protected(false))

        try startup(identity)
        try log(identity, date: Date())

        let event = try #require(try context.fetchAll(EventEntry.self).first)
        #expect(try context.fetchAll(SessionEntry.self).isEmpty)
        #expect(event.sessionID == nil)
        #expect(event.launchID == identity.launch)
        #expect(event.installID == identity.install)
        #expect(event.deviceID == identity.device)
    }

    @Test("entering the foreground after a background log opens a session that starts at the foreground")
    func foregroundAfterBackgroundLogStartsFresh() throws {
        let identity = Identity(install: UUID(), launch: UUID(), device: UUID(), session: Protected(UUID()), foreground: Protected(false))
        let logDate = Date().addingTimeInterval(-3_600)

        try startup(identity)
        try log(identity, date: logDate)
        try enterForeground(identity)

        let session = try #require(try context.fetchAll(SessionEntry.self).first)
        #expect(try context.fetchAll(SessionEntry.self).count == 1)
        #expect(try #require(session.date) > logDate)
    }

    @Test("startup links the version to the launch it was recorded in")
    func startupLinksVersionToLaunch() throws {
        try startup(identity)

        let version = try #require(try context.fetchAll(VersionEntry.self).first)
        #expect(version.launch?.launchID == identity.launch)
        #expect(version.installID == identity.install)
    }

    @Test("a later launch adds no second version for an unchanged build")
    func laterLaunchKeepsOneVersion() throws {
        try startup(identity)
        try startup(
            Identity(install: identity.install, launch: UUID(), device: identity.device, session: identity.session, foreground: Protected(true))
        )

        #expect(try context.fetchAll(VersionEntry.self).count == 1)
    }
}
