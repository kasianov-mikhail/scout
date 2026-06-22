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
        #expect(Event.Query().buildFilters().isEmpty)
    }

    @Test("Filter by levels") func levels() {
        var query = Event.Query()
        query.levels = [.error, .critical]
        let filters = query.buildFilters()

        #expect(filters.contains { $0.field == "level" && $0.op == .in })
    }

    @Test("All levels produces no level filter") func allLevels() {
        var query = Event.Query()
        query.levels = Set(Event.Level.allCases)

        #expect(query.buildFilters().isEmpty)
    }

    @Test("Filter by text") func text() {
        var query = Event.Query()
        query.text = "Search"
        let filters = query.buildFilters()

        #expect(filters.contains(RecordQuery.Filter(field: "name", op: .beginsWith, value: .string("Search"))))
    }

    @Test("Filter by name") func name() {
        var query = Event.Query()
        query.name = "Login"
        let filters = query.buildFilters()

        #expect(filters.contains(RecordQuery.Filter(field: "name", op: .equals, value: .string("Login"))))
    }

    @Test("Filter by date range") func dates() {
        let start = Date(timeIntervalSinceReferenceDate: 0)
        let end = Date(timeIntervalSinceReferenceDate: 86400)

        var query = Event.Query()
        query.dates = start..<end
        let filters = query.buildFilters()

        #expect(filters.contains(RecordQuery.Filter(field: "date", op: .greaterThanOrEquals, value: .date(start))))
        #expect(filters.contains(RecordQuery.Filter(field: "date", op: .lessThan, value: .date(end))))
    }

    @Test("Multiple filters combine") func combined() {
        var query = Event.Query()
        query.levels = [.error]
        query.text = "Search"
        query.name = "Login"
        let filters = query.buildFilters()

        #expect(filters.contains { $0.field == "level" && $0.op == .in })
        #expect(filters.contains(RecordQuery.Filter(field: "name", op: .beginsWith, value: .string("Search"))))
        #expect(filters.contains(RecordQuery.Filter(field: "name", op: .equals, value: .string("Login"))))
    }
}
