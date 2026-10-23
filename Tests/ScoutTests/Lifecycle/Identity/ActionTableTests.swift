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
@Suite("ActionTable")
struct ActionTableTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let identity = Identity.stub
    let session = Protected(UUID())

    @Test("a quick return to the foreground keeps the new session open")
    func quickReturnKeepsSessionOpen() async throws {
        let background = Notification.Name(UUID().uuidString)
        let foreground = Notification.Name(UUID().uuidString)
        let first = session.current
        LaunchEntry.stub(date: Date(), in: context)
        try SessionEntry.Rotation(session: session, launchID: identity.launch).execute(in: context)

        let table = ActionTable(actions: [
            background: { @MainActor in
                try await Task.sleep(for: .milliseconds(100))
                try SessionEntry.Complete(launchID: identity.launch).execute(in: context)
            },
            foreground: { @MainActor in
                try SessionEntry.Rotation(session: session, launchID: identity.launch).execute(in: context)
            },
        ])
        let (completions, continuation) = AsyncStream.makeStream(of: Void.self)
        table.startListening {
            continuation.yield()
        }

        NotificationCenter.default.post(name: background, object: nil)
        NotificationCenter.default.post(name: foreground, object: nil)
        for await _ in completions.prefix(2) {}

        let current = try #require(try context.existing(SessionEntry.self, key: "sessionID", id: session.current))
        #expect(session.current != first)
        #expect(current.endDate == nil)
    }
}
