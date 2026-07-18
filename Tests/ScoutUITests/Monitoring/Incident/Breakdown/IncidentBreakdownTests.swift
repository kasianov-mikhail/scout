//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Testing

@testable import Scout
@testable import ScoutUI

@Suite("IncidentBreakdown")
struct IncidentBreakdownTests {
    @Test("Counts occurrences per label")
    func countsPerLabel() {
        let segments = IncidentBreakdown.segments(from: ["A", "A", "B"])

        #expect(Set(segments.map(\.label)) == ["A", "B"])
        #expect(segments.first { $0.label == "A" }?.count == 2)
        #expect(segments.first { $0.label == "B" }?.count == 1)
    }

    @Test("Orders segments by count descending")
    func ordersByCount() {
        let segments = IncidentBreakdown.segments(from: ["C", "A", "A", "B", "B", "B"])

        #expect(segments.map(\.label) == ["B", "A", "C"])
    }

    @Test("Buckets everything past the top cutoff into Other")
    func bucketsIntoOther() {
        let labels =
            Array(repeating: "A", count: 5) + Array(repeating: "B", count: 4) + Array(repeating: "C", count: 3)
            + Array(repeating: "D", count: 2)
            + Array(repeating: "E", count: 1)
        let segments = IncidentBreakdown.segments(from: labels, top: 4)

        #expect(segments.map(\.label) == ["A", "B", "C", "D", "Other"])
        #expect(segments.last?.count == 1)
    }

    @Test("Omits Other when everything fits within the top cutoff")
    func omitsOtherWhenNothingRemains() {
        let segments = IncidentBreakdown.segments(from: ["A", "B"], top: 4)

        #expect(segments.map(\.label) == ["A", "B"])
    }

    @Test("Returns no segments for empty input")
    func emptyInput() {
        #expect(IncidentBreakdown.segments(from: []).isEmpty)
    }
}

extension IncidentBreakdownTests {
    private struct Context: SessionContext {
        let sessionID: UUID?
        let deviceID: UUID?
    }

    private func makeContext(deviceID: UUID? = nil, sessionID: UUID? = nil) -> Context {
        Context(sessionID: sessionID, deviceID: deviceID)
    }

    @Test("Filters records matching a device segment")
    func filtersByDeviceSegment() throws {
        let deviceA = UUID()
        let deviceB = UUID()
        let breakdown = IncidentBreakdown(
            devices: IncidentBreakdown.segments(from: ["iPhone15,3", "iPhone14,2"]),
            osVersions: [],
            modelsByDevice: [deviceA: "iPhone15,3", deviceB: "iPhone14,2"]
        )
        let records = [
            makeContext(deviceID: deviceA),
            makeContext(deviceID: deviceA),
            makeContext(deviceID: deviceB),
            makeContext(),
        ]

        let segment = try #require(breakdown.devices.first { $0.label == "iPhone15,3" })
        let matched = breakdown.records(from: records, in: .devices, matching: segment)

        #expect(matched.count == 2)
        #expect(matched.allSatisfy { $0.deviceID == deviceA })
    }

    @Test("Filters records matching an OS version segment")
    func filtersByOSVersionSegment() throws {
        let sessionA = UUID()
        let sessionB = UUID()
        let breakdown = IncidentBreakdown(
            devices: [],
            osVersions: IncidentBreakdown.segments(from: ["iOS 17.4", "iOS 16.7"]),
            versionsBySession: [sessionA: "iOS 17.4", sessionB: "iOS 16.7"]
        )
        let records = [
            makeContext(sessionID: sessionA),
            makeContext(sessionID: sessionB),
        ]

        let segment = try #require(breakdown.osVersions.first { $0.label == "iOS 16.7" })
        let matched = breakdown.records(from: records, in: .osVersions, matching: segment)

        #expect(matched.count == 1)
        #expect(matched.first?.sessionID == sessionB)
    }

    @Test("Matches the Other segment to labels outside the top cutoff")
    func filtersByOtherSegment() throws {
        let deviceA = UUID()
        let deviceB = UUID()
        let deviceC = UUID()
        let breakdown = IncidentBreakdown(
            devices: IncidentBreakdown.segments(from: ["A", "A", "B", "C"], top: 1),
            osVersions: [],
            modelsByDevice: [deviceA: "A", deviceB: "B", deviceC: "C"]
        )
        let records = [
            makeContext(deviceID: deviceA),
            makeContext(deviceID: deviceB),
            makeContext(deviceID: deviceC),
            makeContext(deviceID: UUID()),
            makeContext(),
        ]

        let other = try #require(breakdown.devices.first { $0.kind == .other })
        let matched = breakdown.records(from: records, in: .devices, matching: other)

        #expect(matched.count == 2)
        #expect(Set(matched.compactMap(\.deviceID)) == [deviceB, deviceC])
    }

    @Test("Keeps a real Other label separate from the aggregate segment")
    func distinguishesRealOtherLabelFromAggregate() throws {
        let deviceOther = UUID()
        let deviceX = UUID()
        let deviceY = UUID()
        let breakdown = IncidentBreakdown(
            devices: IncidentBreakdown.segments(from: ["Other", "Other", "X", "Y"], top: 1),
            osVersions: [],
            modelsByDevice: [deviceOther: "Other", deviceX: "X", deviceY: "Y"]
        )
        let records = [
            makeContext(deviceID: deviceOther),
            makeContext(deviceID: deviceOther),
            makeContext(deviceID: deviceX),
            makeContext(deviceID: deviceY),
        ]

        let value = try #require(breakdown.devices.first { $0.kind == .value("Other") })
        let matchedValue = breakdown.records(from: records, in: .devices, matching: value)
        #expect(matchedValue.count == 2)
        #expect(matchedValue.allSatisfy { $0.deviceID == deviceOther })

        let aggregate = try #require(breakdown.devices.first { $0.kind == .other })
        let matchedAggregate = breakdown.records(from: records, in: .devices, matching: aggregate)
        #expect(Set(matchedAggregate.compactMap(\.deviceID)) == [deviceX, deviceY])
    }
}
