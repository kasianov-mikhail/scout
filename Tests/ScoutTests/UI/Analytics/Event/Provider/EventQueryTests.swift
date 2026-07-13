//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct EventQueryTests {
    @Test("Empty query produces no filters") func emptyQuery() {
        #expect(EventQuery().buildFilters().isEmpty)
    }

    @Test("Filter by levels") func levels() {
        let filters = EventQuery(levels: [.error, .critical]).buildFilters()

        #expect(filters.contains { $0.field == "level" && $0.op == .in })
    }

    @Test("All levels produces no level filter") func allLevels() {
        #expect(EventQuery(levels: Set(EventLevel.allCases)).buildFilters().isEmpty)
    }

    @Test("Filter by text") func text() {
        let filters = EventQuery(text: "Search").buildFilters()

        #expect(filters.contains(RecordQuery.Filter(field: "name", op: .beginsWith, value: .string("Search"))))
    }

    @Test("Filter by name") func name() {
        let filters = EventQuery(name: "Login").buildFilters()

        #expect(filters.contains(RecordQuery.Filter(field: "name", op: .equals, value: .string("Login"))))
    }

    @Test("Filter by session") func session() {
        let sessionID = UUID()
        let filters = EventQuery(sessionID: sessionID).buildFilters()

        #expect(
            filters.contains(RecordQuery.Filter(field: "session_id", op: .equals, value: .string(sessionID.uuidString)))
        )
    }

    @Test("No session produces no session filter") func noSession() {
        #expect(EventQuery().buildFilters().contains { $0.field == "session_id" } == false)
    }

    @Test("Filter by device") func device() {
        let deviceID = UUID()
        let filters = EventQuery(deviceID: deviceID).buildFilters()

        #expect(
            filters.contains(RecordQuery.Filter(field: "device_id", op: .equals, value: .string(deviceID.uuidString))))
    }

    @Test("Filter by date range") func dates() {
        let start = Date(timeIntervalSinceReferenceDate: 0)
        let end = Date(timeIntervalSinceReferenceDate: 86400)
        let filters = EventQuery(dates: start..<end).buildFilters()

        #expect(filters.contains(RecordQuery.Filter(field: "date", op: .greaterThanOrEquals, value: .date(start))))
        #expect(filters.contains(RecordQuery.Filter(field: "date", op: .lessThan, value: .date(end))))
    }

    @Test("Multiple filters combine") func combined() {
        let filters = EventQuery(levels: [.error], text: "Search", name: "Login").buildFilters()

        #expect(filters.contains { $0.field == "level" && $0.op == .in })
        #expect(filters.contains(RecordQuery.Filter(field: "name", op: .beginsWith, value: .string("Search"))))
        #expect(filters.contains(RecordQuery.Filter(field: "name", op: .equals, value: .string("Login"))))
    }
}
