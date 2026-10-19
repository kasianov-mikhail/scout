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

@Suite("Pending writes")
struct PendingWritesTests {
    @Test("Only the first write of a batch schedules a flush")
    func firstWriteSchedules() {
        var pending = PendingWrites()

        #expect(pending.append { _ in })
        #expect(!pending.append { _ in })
        #expect(!pending.append { _ in })
        #expect(pending.writes.count == 3)
    }

    @Test("Draining returns every write and starts a new batch")
    func drainStartsNewBatch() {
        var pending = PendingWrites()
        _ = pending.append { _ in }
        _ = pending.append { _ in }

        #expect(pending.drain().count == 2)
        #expect(pending.writes.isEmpty)
        #expect(pending.append { _ in })
    }

    @Test("A batch saves every write in one context")
    func batchSavesInOneContext() async throws {
        let store = try TemporaryStore()
        defer { store.tearDown() }
        let container = try store.container()

        let identity = Identity.stub.snapshot
        let contexts = Protected<Set<ObjectIdentifier>>([])
        let writes: [PendingWrites.Write] = (1...3).map { index in
            { context in
                contexts.mutate { $0.insert(ObjectIdentifier(context)) }
                let event = LogEvent(
                    level: .info,
                    message: "Event \(index)",
                    metadata: nil,
                    source: nil,
                    file: #file,
                    function: #function,
                    line: #line
                )
                try event.log(date: Date(), identity: identity, context: context)
            }
        }

        try await container.save(writes: writes)

        let context = container.newBackgroundContext()
        let events = try context.performAndWait {
            try context.count(for: NSFetchRequest<EventEntry>(entityName: "EventEntry"))
        }
        let sessions = try context.performAndWait {
            try context.count(for: NSFetchRequest<SessionEntry>(entityName: "SessionEntry"))
        }

        #expect(contexts.current.count == 1)
        #expect(events == 3)
        #expect(sessions == 1)
    }
}
