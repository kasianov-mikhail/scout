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
    @Test("Empty query returns TRUEPREDICATE") func emptyQuery() {
        let predicate = Event.Query().buildPredicate()
        #expect(predicate.predicateFormat == "TRUEPREDICATE")
    }

    @Test("Filter by levels") func levels() {
        var query = Event.Query()
        query.levels = [.error, .critical]
        let predicate = query.buildPredicate()

        #expect(predicate.predicateFormat.contains("level IN"))
    }

    @Test("All levels produces no level predicate") func allLevels() {
        var query = Event.Query()
        query.levels = Set(Event.Level.allCases)
        let predicate = query.buildPredicate()

        #expect(predicate.predicateFormat == "TRUEPREDICATE")
    }

    @Test("Filter by text") func text() {
        var query = Event.Query()
        query.text = "Search"
        let predicate = query.buildPredicate()

        #expect(predicate.predicateFormat.contains("BEGINSWITH"))
        #expect(predicate.predicateFormat.contains("Search"))
    }

    @Test("Filter by name") func name() {
        var query = Event.Query()
        query.name = "Login"
        let predicate = query.buildPredicate()

        #expect(predicate.predicateFormat.contains("name == \"Login\""))
    }

    @Test("Filter by userID") func userID() {
        let id = UUID()
        var query = Event.Query()
        query.userID = id
        let predicate = query.buildPredicate()

        #expect(predicate.predicateFormat.contains("user_id"))
        #expect(predicate.predicateFormat.contains(id.uuidString))
    }

    @Test("Filter by sessionID") func sessionID() {
        let id = UUID()
        var query = Event.Query()
        query.sessionID = id
        let predicate = query.buildPredicate()

        #expect(predicate.predicateFormat.contains("session_id"))
        #expect(predicate.predicateFormat.contains(id.uuidString))
    }

    @Test("Filter by date range") func dates() {
        let start = Date(timeIntervalSinceReferenceDate: 0)
        let end = Date(timeIntervalSinceReferenceDate: 86400)

        var query = Event.Query()
        query.dates = start..<end
        let predicate = query.buildPredicate()

        #expect(predicate.predicateFormat.contains("date >="))
        #expect(predicate.predicateFormat.contains("date <"))
    }

    @Test("Multiple filters combine with AND") func combined() {
        var query = Event.Query()
        query.levels = [.error]
        query.text = "Search"
        query.name = "Login"
        let predicate = query.buildPredicate()

        #expect(predicate.predicateFormat.contains("AND"))
        #expect(predicate.predicateFormat.contains("level IN"))
        #expect(predicate.predicateFormat.contains("BEGINSWITH"))
        #expect(predicate.predicateFormat.contains("Login"))
    }
}
