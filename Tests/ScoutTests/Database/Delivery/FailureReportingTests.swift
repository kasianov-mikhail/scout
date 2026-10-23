//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

@preconcurrency import CoreData
import Foundation
import Testing

@testable import Scout
@testable import Support

@MainActor
@Suite("Backend failure reporting")
struct FailureReportingTests {
    let server = InMemoryDatabase()
    let context = NSManagedObjectContext.inMemoryContext()
    let lines: Protected<[String]>
    let log: FailureLog

    init() {
        let lines = Protected<[String]>([])
        self.lines = lines
        self.log = FailureLog { line in
            lines.mutate { $0.append(line) }
        }
    }

    func makeBackend(checkAccess: @escaping AccessCheck) -> Backend {
        Backend(
            id: "server",
            database: server,
            displayName: "server",
            engine: .cloudKit,
            checkAccess: checkAccess
        )
    }

    @Test("A message is printed once however often it is reported")
    func messagePrintedOnce() {
        log.printOnce(message: "first")
        log.printOnce(message: "first")
        log.printOnce(message: "second")

        #expect(lines.current == ["first", "second"])
    }

    @Test("A misconfigured backend is dropped and printed once across passes")
    func misconfigurationPrintedOnce() async {
        let backends = [makeBackend { throw MisconfigurationTestError() }]

        let first = await backends.available(log: log)
        let second = await backends.available(log: log)

        #expect(first.isEmpty)
        #expect(second.isEmpty)
        #expect(lines.current.count == 1)
        #expect(lines.current.first?.contains("the server rejected the API key") == true)
    }

    @Test("An offline or throttled backend is dropped quietly")
    func transientAccessFailureIsQuiet() async {
        let available = await [makeBackend { throw TransientTestError() }].available(log: log)

        #expect(available.isEmpty)
        #expect(lines.current.isEmpty)
    }

    @Test("A cancelled access check is dropped quietly")
    func cancelledAccessCheckIsQuiet() async {
        let available = await [makeBackend { throw CancellationError() }].available(log: log)

        #expect(available.isEmpty)
        #expect(lines.current.isEmpty)
    }

    @Test("An account state is one line for the whole launch")
    func accountStatePrintedOnce() async {
        let backends = [makeBackend { throw Backend.AccountError.noAccount }]

        _ = await backends.available(log: log)
        _ = await backends.available(log: log)

        #expect(lines.current == ["Scout can't deliver to backend server: Sign in to iCloud to sync data."])
    }

    @Test("An unexpected access failure is printed once")
    func unexpectedAccessFailurePrintedOnce() async {
        let backends = [makeBackend { throw NSError(domain: "Test", code: 1) }]

        _ = await backends.available(log: log)
        _ = await backends.available(log: log)

        #expect(lines.current.count == 1)
        #expect(lines.current.first?.hasPrefix("Failed to check access to backend server") == true)
    }

    @Test("A reachable backend stays available without a line")
    func reachableBackendIsQuiet() async {
        let available = await [makeBackend {}].available(log: log)

        #expect(available.map(\.id) == ["server"])
        #expect(lines.current.isEmpty)
    }

    @Test("A misconfigured delivery keeps records pending and is printed once")
    func misconfiguredDeliveryKeepsRecords() async throws {
        let backend = makeBackend {}
        let event = EventEntry.stub(name: "login", in: context)
        try context.save()
        try SyncableEntry.plan(backends: [backend], in: context)

        for _ in 0..<(DeliveryEntry.maxAttempts * 2) {
            server.writeErrors.append(MisconfigurationTestError())
            await backend.deliver(EventEntry.self, in: context, log: log)
        }

        #expect(event.delivery(for: "server")?.isPending == true)
        #expect(event.delivery(for: "server")?.attempts == 0)
        #expect(lines.current.count == 1)

        await backend.deliver(EventEntry.self, in: context, log: log)

        #expect(event.delivery(for: "server")?.isDelivered == true)
    }

    @Test("An offline delivery retries quietly")
    func transientDeliveryIsQuiet() async throws {
        let backend = makeBackend {}
        let event = EventEntry.stub(name: "login", in: context)
        try context.save()
        try SyncableEntry.plan(backends: [backend], in: context)

        server.writeErrors.append(TransientTestError())
        await backend.deliver(EventEntry.self, in: context, log: log)

        #expect(event.delivery(for: "server")?.attempts == 0)
        #expect(lines.current.isEmpty)
    }
}

private struct MisconfigurationTestError: TransientFailure {
    let isTransient = true
    let misconfiguration: String? = "the server rejected the API key"
}
