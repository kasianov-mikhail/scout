//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ConnectorHosted
import Foundation
import Testing

@testable import ScoutCore
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
        #expect(connections.allSatisfy { $0.status == .unknown })
    }

    @Test("Refresh records each connection's probed status by id")
    func refreshRecordsProbedStatus() async {
        let connections = [
            Connection(id: primary.absoluteString, name: "a.scout.app", status: .unknown, probe: { .reachable }),
            Connection(id: secondary.absoluteString, name: "b.scout.app", status: .unknown, probe: { .unreachable }),
        ]

        let refreshed = await connections.refreshingStatuses()
        #expect(refreshed.first { $0.id == primary.absoluteString }?.status == .reachable)
        #expect(refreshed.first { $0.id == secondary.absoluteString }?.status == .unreachable)
    }
}
