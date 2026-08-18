//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import HostedConnector
import Testing

@testable import Scout
@testable import ScoutUI

@MainActor
@Suite("Connection")
struct ConnectionSwitcherTests {
    let primary = URL(string: "https://a.scout.app")!
    let secondary = URL(string: "https://b.scout.app")!

    var backends: [Backend] {
        [.server(url: primary, apiKey: nil), .server(url: secondary, apiKey: nil)]
    }

    @Test("Maps backends to connections with unknown status by default")
    func mapsConnections() {
        let connections = backends.map(Connection.init)

        #expect(connections.count == 2)
        #expect(connections[0].id == primary.absoluteString)
        #expect(connections[0].name == "a.scout.app")
        #expect(connections.allSatisfy { $0.status == nil })
    }

    @Test("Refresh records each connection's probed status by id")
    func refreshRecordsProbedStatus() async throws {
        let connections = [
            Connection(id: primary.absoluteString, name: "a.scout.app", status: nil, probe: { .reachable }),
            Connection(id: secondary.absoluteString, name: "b.scout.app", status: nil, probe: { .unreachable }),
        ]

        let refreshed = await connections.refreshingStatuses()

        let first = try #require(refreshed.first { $0.id == primary.absoluteString })
        let second = try #require(refreshed.first { $0.id == secondary.absoluteString })

        #expect(first.status == .reachable)
        #expect(second.status == .unreachable)
    }
}
