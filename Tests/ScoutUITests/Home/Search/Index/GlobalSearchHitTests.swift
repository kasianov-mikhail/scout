//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import Testing

@testable import ScoutUI
@testable import Support

@Suite("Global search hit")
struct GlobalSearchHitTests {
    private let deviceID = UUID()
    private let date = Date(year: 2026, month: 6, day: 1)

    @Test("Each case maps to its category")
    func categories() {
        #expect(GlobalSearchHit.event(name: "session").category == .events)
        #expect(GlobalSearchHit.metric(name: "session", telemetry: .counter).category == .metrics)
        #expect(GlobalSearchHit.endpoint(name: "GET /v1/sessions").category == .network)
        #expect(GlobalSearchHit.device(device).category == .devices)
        #expect(GlobalSearchHit.release(release).category == .releases)
        #expect(GlobalSearchHit.crash(.group(crashGroup)).category == .crashes)
        #expect(GlobalSearchHit.hang(.group(hangGroup)).category == .hangs)
    }

    @Test("A named case uses the name as its title")
    func names() {
        #expect(GlobalSearchHit.event(name: "session").title == "session")
        #expect(GlobalSearchHit.metric(name: "session", telemetry: .counter).title == "session")
        #expect(GlobalSearchHit.endpoint(name: "GET /v1/sessions").title == "GET /v1/sessions")
    }

    @Test("The category prefixes the id so equal names stay apart")
    func uniqueIDs() {
        let event = GlobalSearchHit.event(name: "session")
        let metric = GlobalSearchHit.metric(name: "session", telemetry: .counter)
        let endpoint = GlobalSearchHit.endpoint(name: "session")

        #expect(event.id == "events:session")
        #expect(metric.id == "metrics:session")
        #expect(endpoint.id == "network:session")
        #expect(Set([event.id, metric.id, endpoint.id]).count == 3)
    }

    @Test("A device uses its model name and its own id")
    func deviceHit() {
        let hit = GlobalSearchHit.device(device)

        #expect(hit.title == "iPhone 13 Pro")
        #expect(hit.id == "devices:\(deviceID)")
    }

    @Test("A device without a model falls back to Unknown")
    func deviceWithoutModel() {
        let hit = GlobalSearchHit.device(
            DeviceSummary(id: deviceID, model: nil, osVersion: "18.0", lastSeen: date, sessions: 0, crashes: 0)
        )

        #expect(hit.title == "Unknown")
    }

    @Test("A release uses its version")
    func releaseHit() {
        let hit = GlobalSearchHit.release(release)

        #expect(hit.title == release.id)
        #expect(hit.id == "releases:\(release.id)")
    }

    @Test("An incident uses the group name and id")
    func incidentHits() {
        let crashHit = GlobalSearchHit.crash(.group(crashGroup))
        let hangHit = GlobalSearchHit.hang(.group(hangGroup))

        #expect(crashHit.title == "NSRangeException")
        #expect(crashHit.id == "crashes:\(crashGroup.id)")
        #expect(hangHit.title == "MainThreadStall")
        #expect(hangHit.id == "hangs:\(hangGroup.id)")
    }

    private var device: DeviceSummary {
        DeviceSummary(id: deviceID, model: "iPhone14,2", osVersion: "18.0", lastSeen: date, sessions: 3, crashes: 1)
    }

    private var release: ReleaseHealth {
        ReleaseHealth.stub(version: "3.2.0")
    }

    private var crashGroup: IncidentGroup<Crash> {
        IncidentGroup.groups(from: [Crash.stub(name: "NSRangeException")])[0]
    }

    private var hangGroup: IncidentGroup<Hang> {
        IncidentGroup.groups(from: [Hang.stub(name: "MainThreadStall")])[0]
    }
}
