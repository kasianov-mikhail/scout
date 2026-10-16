//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

@Suite("Crash")
struct CrashTests {
    @Test("Decoding reads the source and window start")
    func decodingReadsSourceAndWindowStart() throws {
        let end = Date(timeIntervalSince1970: 1_750_000_000)
        var record = Record(recordType: Crash.recordType, recordID: "c-1")
        record["name"] = "EXC_BAD_ACCESS"
        record["date"] = end
        record["date_start"] = end.addingTimeInterval(-600)
        record["source"] = "metrickit"

        let crash = try Crash(record: record)

        #expect(crash.source == .metricKit(windowStart: end.addingTimeInterval(-600)))
        #expect(crash.date == end)
    }

    @Test("A crash without a source decodes as caught in process")
    func decodingWithoutSource() throws {
        var record = Record(recordType: Crash.recordType, recordID: "c-1")
        record["name"] = "SIGABRT"

        let crash = try Crash(record: record)

        #expect(crash.source == .inProcess)
    }

    @Test("An unknown source decodes as caught in process")
    func decodingUnknownSource() throws {
        var record = Record(recordType: Crash.recordType, recordID: "c-1")
        record["name"] = "SIGABRT"
        record["source"] = "future-source"

        let crash = try Crash(record: record)

        #expect(crash.source == .inProcess)
    }

    @Test("Encoding round-trips the source and window start")
    func encodingRoundTrips() throws {
        let end = Date(timeIntervalSince1970: 1_750_000_000)
        let crash = Crash(
            name: "EXC_BAD_ACCESS",
            fingerprint: "fingerprint",
            reason: nil,
            stackTrace: [],
            date: end,
            source: .metricKit(windowStart: end.addingTimeInterval(-600)),
            id: "c-1",
            deviceID: nil,
            installID: nil,
            launchID: nil,
            sessionID: nil
        )

        let decoded = try Crash(record: crash.record)

        #expect(decoded.source == .metricKit(windowStart: end.addingTimeInterval(-600)))
    }

    @Test("Encoding leaves out the source of a crash caught in process")
    func encodingOmitsInProcessSource() {
        let crash = Crash(
            name: "SIGABRT",
            fingerprint: "fingerprint",
            reason: nil,
            stackTrace: [],
            date: nil,
            source: .inProcess,
            id: "c-1",
            deviceID: nil,
            installID: nil,
            launchID: nil,
            sessionID: nil
        )

        #expect(crash.record.fields["source"] == nil)
        #expect(crash.record.fields["date_start"] == nil)
    }

    @Test("A MetricKit crash without a window decodes with no window start")
    func decodingMetricKitWithoutWindow() throws {
        var record = Record(recordType: Crash.recordType, recordID: "c-1")
        record["name"] = "EXC_BAD_ACCESS"
        record["source"] = "metrickit"

        let crash = try Crash(record: record)

        #expect(crash.source == .metricKit(windowStart: nil))
    }
}
