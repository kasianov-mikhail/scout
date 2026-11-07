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

@Suite("IncidentSummary")
struct IncidentSummaryTests {
    @Test("The first occurrence sets the since version")
    func sinceVersion() {
        let session = UUID()
        let first = Crash.stub(reason: "first", sessionID: session, date: Date(timeIntervalSince1970: 1_000))
        let last = Crash.stub(reason: "last", date: Date(timeIntervalSince1970: 2_000))
        let breakdown = IncidentBreakdown(
            devices: [],
            osVersions: [],
            appVersions: [],
            appVersionsBySession: [session: "3.2.0"]
        )

        let summary = IncidentSummary(
            kind: .crash,
            label: "Crash",
            message: last.reason,
            group: IncidentGroup(records: [last, first]),
            breakdown: breakdown,
            cards: [],
            stack: []
        )

        #expect(summary.meta.hasPrefix("Crash · since 3.2.0 · last "))
        #expect(summary.message == "last")
    }

    @Test("A group without a resolved session omits the version")
    func missingVersion() {
        let crash = Crash.stub(reason: "reason")

        let summary = IncidentSummary(
            kind: .crash,
            label: "Crash",
            message: crash.reason,
            group: IncidentGroup(records: [crash]),
            breakdown: nil,
            cards: [],
            stack: []
        )

        #expect(summary.meta.hasPrefix("Crash · last "))
    }

    @Test("The affected rows follow the breakdown")
    func affectedRows() {
        let breakdown = IncidentBreakdown(
            devices: IncidentBreakdown.segments(from: ["iPhone15,3", "iPhone14,2"]),
            osVersions: IncidentBreakdown.segments(from: ["iOS 17.4"]),
            appVersions: IncidentBreakdown.segments(from: ["3.2.0"])
        )

        let crash = Crash.stub()

        let summary = IncidentSummary(
            kind: .crash,
            label: "Crash",
            message: crash.reason,
            group: IncidentGroup(records: [crash]),
            breakdown: breakdown,
            cards: [],
            stack: []
        )

        #expect(summary.affected.map(\.title) == IncidentAffected.titles)
        #expect(summary.affected.map(\.total) == [2, 1, 1])
    }

    @Test("The occurrence label joins the detail, device and app version")
    func occurrenceLabel() {
        let device = UUID()
        let session = UUID()
        let breakdown = IncidentBreakdown(
            devices: [],
            osVersions: [],
            appVersions: [],
            modelsByDevice: [device: "iPhone16,1"],
            appVersionsBySession: [session: "3.2.0"]
        )
        let crash = Crash.stub(deviceID: device, sessionID: session)
        let hang = Hang.stub(duration: 2.5, deviceID: device, sessionID: session)

        #expect(breakdown.occurrenceLabel(record: crash) == "iPhone 15 Pro · 3.2.0")
        #expect(breakdown.occurrenceLabel(record: hang) == "2.5 s · iPhone 15 Pro · 3.2.0")
    }

    @Test("A resource occurrence omits the app version")
    func resourceOccurrenceLabel() {
        let device = UUID()
        let session = UUID()
        let breakdown = IncidentBreakdown(
            devices: [],
            osVersions: [],
            appVersions: [],
            modelsByDevice: [device: "iPhone16,1"],
            appVersionsBySession: [session: "3.2.0"]
        )
        let resource = ResourceException(
            name: "CPU Exception",
            fingerprint: "cpu",
            reason: "84 s of CPU time in 180 s",
            stackTrace: [],
            resourceKind: .cpu,
            date: Date(),
            id: UUID().uuidString,
            deviceID: device,
            installID: nil,
            launchID: nil,
            sessionID: session
        )

        #expect(breakdown.occurrenceLabel(record: resource) == "84 s CPU · iPhone 15 Pro")
    }
}
