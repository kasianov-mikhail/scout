//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import HostedConnector
import Testing

@testable import Scout
@testable import ScoutUI
@testable import Support

@Suite("BackendHealth")
struct BackendHealthTests {
    @Test("Maps a server backend to endpoint, transport, and API key state")
    func mapsServerBackend() {
        let backend = Backend.server(url: URL(string: "http://localhost:8080")!, apiKey: "secret")
        let health = BackendHealth(backend: backend)

        #expect(health.engine == .server)
        #expect(health.endpoint == "localhost:8080")
        #expect(health.hasAPIKey)
        #expect(!health.isSecure)
        #expect(health.status == .unknown)
        #expect(health.pings.count == 0)
    }

    @Test("Marks HTTPS server backends as secure and keyless ones as not set")
    func mapsSecureServerBackend() {
        let backend = Backend.server(url: URL(string: "https://api.scout.app")!, apiKey: nil)
        let health = BackendHealth(backend: backend)

        #expect(health.isSecure)
        #expect(!health.hasAPIKey)
        #expect(health.endpoint == "api.scout.app")
    }

    @Test("Maps a non-server backend to the CloudKit engine with its id as endpoint")
    func mapsCloudKitBackend() {
        let health = BackendHealth(backend: makeBackend(id: "iCloud.com.example"))

        #expect(health.engine == .cloudKit)
        #expect(health.endpoint == "iCloud.com.example")
    }

    @Test("Recording a reachable probe stores latency and appends a ping")
    func recordsReachableProbe() {
        let date = Date(timeIntervalSince1970: 1_000)
        let health = makeHealth().recording(status: .reachable, latency: 120, at: date)

        #expect(health.status == .reachable)
        #expect(health.latency == 120)
        #expect(health.lastChecked == date)
        #expect(health.pings == [120])
    }

    @Test("Recording an unreachable probe clears latency but keeps ping history")
    func recordsUnreachableProbe() {
        var health = makeHealth().recording(status: .reachable, latency: 120, at: Date())
        health = health.recording(status: .unreachable, latency: nil, at: Date())

        #expect(health.status == .unreachable)
        #expect(health.latency == nil)
        #expect(health.pings == [120])
    }

    @Test("Ping history is capped at the last 12 samples")
    func capsPingHistory() {
        var health = makeHealth()
        for latency in 1...15 {
            health = health.recording(status: .reachable, latency: latency, at: Date())
        }

        #expect(health.pings.count == 12)
        #expect(health.pings == Array(4...15))
    }

    @Test("Ping spread reports min, average, and max of the history")
    func reportsPingSpread() {
        var health = makeHealth()
        for latency in [100, 200, 300] {
            health = health.recording(status: .reachable, latency: latency, at: Date())
        }

        #expect(health.pingSpreadLabel == "100 / 200 / 300 ms")
    }
}

typealias StatusProbe = @Sendable () async -> Backend.Status

func makeHealth(id: String = "backend", status: Backend.Status = .unknown, probe: @escaping StatusProbe = { .unknown })
    -> BackendHealth
{
    BackendHealth(id: id, name: id, endpoint: id, engine: .server, status: status, probe: probe)
}
