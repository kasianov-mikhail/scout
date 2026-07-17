//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import ScoutHosted
import Testing

@testable import ScoutCore
@testable import ScoutUI

@MainActor
@Suite("BackendHealthProvider")
struct BackendHealthProviderTests {
    @Test("Refresh all probes every backend and records statuses with latency")
    func refreshesAllBackends() async {
        let provider = BackendHealthProvider(healths: [
            makeHealth(id: "up", probe: { .reachable }),
            makeHealth(id: "down", probe: { .unreachable }),
        ])

        await provider.refreshAll()

        let up = provider.backends.first { $0.id == "up" }
        let down = provider.backends.first { $0.id == "down" }
        #expect(up?.status == .reachable)
        #expect(up?.latency != nil)
        #expect(up?.pings.count == 1)
        #expect(up?.lastChecked != nil)
        #expect(down?.status == .unreachable)
        #expect(down?.latency == nil)
        #expect(down?.pings.count == 0)
        #expect(down?.lastChecked != nil)
    }

    @Test("Refreshing a single backend leaves the others untouched")
    func refreshesSingleBackend() async {
        let provider = BackendHealthProvider(healths: [
            makeHealth(id: "up", probe: { .reachable }),
            makeHealth(id: "idle"),
        ])

        await provider.refresh(id: "up")

        #expect(provider.backends.first { $0.id == "up" }?.status == .reachable)
        #expect(provider.backends.first { $0.id == "idle" }?.status == .unknown)
        #expect(provider.backends.first { $0.id == "idle" }?.lastChecked == nil)
    }

    @Test("Refreshing an unknown id is a no-op")
    func ignoresUnknownID() async {
        let provider = BackendHealthProvider(healths: [makeHealth(id: "up")])

        await provider.refresh(id: "missing")

        #expect(provider.backends.count == 1)
        #expect(provider.backends[0].status == .unknown)
    }

    @Test("Initializing from backends maps each one")
    func initializesFromBackends() {
        let provider = BackendHealthProvider(backends: [
            .server(url: URL(string: "https://a.scout.app")!, apiKey: nil),
            .server(url: URL(string: "https://b.scout.app")!, apiKey: nil),
        ])

        #expect(provider.backends.count == 2)
        #expect(provider.backends.allSatisfy { $0.status == .unknown })
    }
}
