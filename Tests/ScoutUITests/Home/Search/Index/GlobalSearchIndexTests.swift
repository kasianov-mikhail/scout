//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout
@testable import ScoutUI

struct GlobalSearchIndexTests {
    private func makeIndex(
        series: [MetricSeries] = [], devices: [DeviceSummary] = [], releases: [ReleaseHealth] = [],
        crashes: [IncidentGroup<Crash>] = [], hangs: [IncidentGroup<Hang>] = []
    ) -> GlobalSearchIndex {
        GlobalSearchIndex(series: series, devices: devices, releases: releases, crashes: crashes, hangs: hangs)!
    }

    private func makeSeries(_ name: String, category: String? = nil) -> MetricSeries {
        MetricSeries(name: name, category: category, points: [])
    }

    private func makeDevice(model: String) -> DeviceSummary {
        DeviceSummary(id: UUID(), model: model, osVersion: "18.0", lastSeen: Date(), sessions: 1, crashes: 0)
    }

    private func makeRelease(_ version: String) -> ReleaseHealth {
        ReleaseHealth(
            id: version,
            freeSessions: 1.0,
            freeUsers: nil,
            crashes: 0,
            hangs: 0,
            sessions: 1,
            adoption: 1.0,
            trend: []
        )
    }

    @Test("Empty query produces no hits") func emptyQuery() {
        let index = makeIndex(series: [makeSeries("session_start")])

        #expect(index.hits(matching: "").isEmpty)
        #expect(index.hits(matching: "   ").isEmpty)
    }

    @Test("Event names match case-insensitively") func eventMatch() {
        let index = makeIndex(series: [makeSeries("Session_Start"), makeSeries("purchase")])
        let hits = index.hits(matching: "session")

        #expect(hits.map(\.title) == ["Session_Start"])
        #expect(hits.map(\.category) == [.events])
    }

    @Test("Lifecycle and incident series are not events") func reservedNames() {
        let index = makeIndex(series: [
            makeSeries(SessionEntry.recordType),
            makeSeries(CrashEntry.recordType),
            makeSeries(HangEntry.recordType),
        ])

        #expect(index.hits(matching: "s").isEmpty)
    }

    @Test("Metric series match by telemetry category") func metricMatch() {
        let index = makeIndex(series: [
            makeSeries("api_calls", category: Telemetry.Export.counter.rawValue),
            makeSeries("api_latency", category: Telemetry.Export.timer.rawValue),
            makeSeries("api_payload", category: Telemetry.Export.recorder.rawValue),
            makeSeries("api_meter", category: Telemetry.Export.meter.rawValue),
        ])
        let hits = index.hits(matching: "api")

        #expect(Set(hits.map(\.title)) == ["api_calls", "api_latency", "api_payload", "api_meter"])
        #expect(hits.allSatisfy { $0.category == .metrics })
    }

    @Test("Reset and bucket categories stay out of the results") func auxiliaryCategoriesAreIgnored() {
        let index = makeIndex(series: [
            makeSeries("api_calls", category: ResetMarker.category),
            makeSeries("api_calls", category: RecorderBuckets.categories[0]),
        ])

        #expect(index.hits(matching: "api").isEmpty)
    }

    @Test("Endpoint series match on status and latency categories") func endpointMatch() {
        let index = makeIndex(series: [
            makeSeries("GET /v1/sessions", category: StatusBuckets.categories[0]),
            makeSeries("GET /v1/sessions", category: LatencyBuckets.categories[0]),
            makeSeries("POST /v1/metrics", category: StatusBuckets.categories[1]),
        ])
        let hits = index.hits(matching: "sessions")

        #expect(hits.map(\.title) == ["GET /v1/sessions"])
        #expect(hits.map(\.category) == [.network])
    }

    @Test("Devices match on model name") func deviceMatch() {
        let index = makeIndex(devices: [makeDevice(model: "iPhone14,6"), makeDevice(model: "iPad13,1")])
        let hits = index.hits(matching: "iphone")

        #expect(hits.count == 1)
        #expect(hits.allSatisfy { $0.category == .devices })
    }

    @Test("Releases match on version") func releaseMatch() {
        let index = makeIndex(releases: [makeRelease("3.2.0"), makeRelease("2.9.9")])
        let hits = index.hits(matching: "3.2")

        #expect(hits.map(\.title) == ["3.2.0"])
        #expect(hits.map(\.category) == [.releases])
    }

    @Test("Crash groups match on name") func crashMatch() {
        let crashes = [Crash.stub(name: "NSRangeException"), Crash.stub(name: "SIGSEGV")]
        let index = makeIndex(crashes: IncidentGroup.groups(from: crashes))
        let hits = index.hits(matching: "range")

        #expect(hits.map(\.title) == ["NSRangeException"])
        #expect(hits.map(\.category) == [.crashes])
    }

    @Test("Hang groups match on name") func hangMatch() {
        let hangs = [Hang.stub(name: "MainThreadStall"), Hang.stub(name: "DiskWriteStall")]
        let index = makeIndex(hangs: IncidentGroup.groups(from: hangs))
        let hits = index.hits(matching: "mainthread")

        #expect(hits.map(\.title) == ["MainThreadStall"])
        #expect(hits.map(\.category) == [.hangs])
    }

    @Test("Categories keep a stable order") func categoryOrder() {
        let index = makeIndex(
            series: [
                makeSeries("session_start"),
                makeSeries("sessions_per_user", category: Telemetry.Export.counter.rawValue),
                makeSeries("GET /v1/sessions", category: StatusBuckets.categories[0]),
            ],
            devices: [makeDevice(model: "iPhone SE")],
            releases: [makeRelease("1.0-session")],
            crashes: IncidentGroup.groups(from: [Crash.stub(name: "SessionStoreCrash")]),
            hangs: IncidentGroup.groups(from: [Hang.stub(name: "SessionSaveStall")])
        )
        let hits = index.hits(matching: "se")

        #expect(hits.map(\.category) == [.events, .metrics, .network, .devices, .releases, .crashes, .hangs])
    }

    @Test("Hits are unique per name within a category") func deduplication() {
        let index = makeIndex(series: [makeSeries("session_start"), makeSeries("session_start")])

        #expect(index.hits(matching: "session").count == 1)
    }
}
