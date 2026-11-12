//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import ConnectorSupport
import Foundation
import Testing

@testable import Scout
@testable import ScoutUI

@MainActor
@Suite("IncidentContext")
struct IncidentContextTests {
    @Test("A session reads as its duration and event count")
    func sessionText() {
        let start = Date(timeIntervalSince1970: 1_760_000_000)
        let context = IncidentContext(
            sessionStart: start,
            sessionEnd: start.addingTimeInterval(221),
            eventCount: 24
        )

        #expect(context.durationText == "3 min 41 s")
        #expect(context.eventText == "24 events")
        #expect(context.sessionText == "3 min 41 s · 24 events")
    }

    @Test("An open or inverted session has no duration")
    func missingDuration() {
        let start = Date(timeIntervalSince1970: 1_760_000_000)

        #expect(IncidentContext(sessionStart: start).durationText == nil)
        #expect(IncidentContext(sessionStart: start, sessionEnd: start.addingTimeInterval(-10)).durationText == nil)
    }

    @Test("The provider reads the session, the device, and the session's events")
    func provider() async throws {
        let sessionID = UUID()
        let deviceID = UUID()
        let start = Date(timeIntervalSince1970: 1_760_000_000)
        var session = Record(recordType: Session.recordType, recordID: sessionID.uuidString)
        session["app_version"] = "3.2.0"
        session["os_version"] = "iOS 17.4"
        session["start_date"] = start
        session["end_date"] = start.addingTimeInterval(221)
        var device = Record(recordType: Device.recordType, recordID: deviceID.uuidString)
        device["model"] = "iPhone16,1"
        let events = [
            Record.eventStub(name: "a", sessionID: sessionID, date: start),
            Record.eventStub(name: "b", sessionID: sessionID, date: start),
            Record.eventStub(name: "c", sessionID: UUID(), date: start),
        ]
        let database = ContextDatabase(lookups: [sessionID.uuidString: session, deviceID.uuidString: device], events: events)

        let context = try await IncidentContextProvider(sessionID: sessionID, deviceID: deviceID).fetch(in: database)

        #expect(context.model == "iPhone16,1")
        #expect(context.osVersion == "iOS 17.4")
        #expect(context.appVersion == "3.2.0")
        #expect(context.eventCount == 2)
        #expect(context.sessionText == "3 min 41 s · 2 events")
    }

    @Test("Missing records give an empty context")
    func missingRecords() async throws {
        let context = try await IncidentContextProvider(sessionID: UUID(), deviceID: UUID()).fetch(in: ContextDatabase(lookups: [:], events: []))

        #expect(context == IncidentContext())
    }
}

private struct ContextDatabase: RecordReader {
    let lookups: [String: Record]
    let events: [Record]

    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        guard let record = lookups[recordName] else {
            throw RecordNotFoundError()
        }
        return record
    }

    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
        RecordChunk(records: events.matching(query), cursor: nil)
    }
}
