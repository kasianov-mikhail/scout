//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

@preconcurrency import CoreData
import Foundation
import Testing

@testable import HostedConnector
@testable import Scout
@testable import Support

@MainActor
@Suite("Hosted delivery over HTTP")
struct HostedDeliveryTests {
    let context = NSManagedObjectContext.inMemoryContext()

    @Test("Auth and routing failures keep records pending without charging an attempt", arguments: [401, 403, 404])
    func configurationFailures(status: Int) async throws {
        let server = StubServer(status: status)
        let backend = Backend.server(url: server.url, apiKey: "key")
        let events = (0..<64).map { EventEntry.stub(name: "event-\($0)", in: context) }
        try context.save()
        try SyncableEntry.plan(backends: [backend], in: context)

        await #expect(throws: HTTPDatabaseError.self) {
            try await RecordSender<EventEntry>(backend: backend).deliver(in: context)
        }

        #expect(server.requestCount == 1)
        #expect(events.allSatisfy { $0.delivery(for: backend.id)?.isPending == true })
        #expect(events.allSatisfy { $0.delivery(for: backend.id)?.attempts == 0 })
    }

    @Test("A rejected batch is narrowed down and each record is charged an attempt")
    func rejection() async throws {
        let server = StubServer(status: 400)
        let backend = Backend.server(url: server.url, apiKey: "key")
        let events = (0..<2).map { EventEntry.stub(name: "event-\($0)", in: context) }
        try context.save()
        try SyncableEntry.plan(backends: [backend], in: context)

        await #expect(throws: HTTPDatabaseError.self) {
            try await RecordSender<EventEntry>(backend: backend).deliver(in: context)
        }

        #expect(server.requestCount == 3)
        #expect(events.allSatisfy { $0.delivery(for: backend.id)?.isPending == true })
        #expect(events.allSatisfy { $0.delivery(for: backend.id)?.attempts == 1 })
    }
}

private struct StubServer {
    private static let registration = URLProtocol.registerClass(StubURLProtocol.self)

    let id = UUID().uuidString
    let status: Int

    init(status: Int) {
        _ = Self.registration
        self.status = status
    }

    var url: URL {
        URL(string: "https://\(StubURLProtocol.host)/\(status)/\(id)/")!
    }

    var requestCount: Int {
        StubURLProtocol.ledger.count(id: id)
    }
}

private final class StubURLProtocol: URLProtocol {
    static let host = "stub.scout.test"
    static let ledger = Ledger()

    override class func canInit(with request: URLRequest) -> Bool {
        request.url?.host == host
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let url = request.url else { return }
        let components = url.pathComponents

        guard components.count > 2 else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }

        Self.ledger.record(id: components[2])

        let status = Int(components[1]) ?? 500
        let response = HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: nil)!

        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data(#"{"reason":"stubbed"}"#.utf8))
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

private final class Ledger: @unchecked Sendable {
    private let lock = NSLock()
    private var counts: [String: Int] = [:]

    func record(id: String) {
        lock.withLock { counts[id, default: 0] += 1 }
    }

    func count(id: String) -> Int {
        lock.withLock { counts[id, default: 0] }
    }
}
