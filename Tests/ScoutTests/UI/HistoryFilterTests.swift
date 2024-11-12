//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct HistoryFilterTests {
    let userID = UUID()
    let sessionID = UUID()

    @Test("Query Event option and User category") func testEventUser() {
        let filter = createFilter(option: .event, category: .user)
        let query = filter.query()

        #expect(query.name == "Test Event")
        #expect(query.userID == userID)
        #expect(query.sessionID == nil)
    }

    @Test("Query All option and User category") func testAllUser() {
        let filter = createFilter(option: .all, category: .user)
        let query = filter.query()

        #expect(query.name == "")
        #expect(query.userID == filter.userID)
        #expect(query.sessionID == nil)
    }

    @Test("Query Event option and Session category") func testEventSession() {
        let filter = createFilter(option: .event, category: .session)
        let query = filter.query()

        #expect(query.name == "Test Event")
        #expect(query.userID == nil)
        #expect(query.sessionID == sessionID)
    }

    @Test("Query All option and Session category") func testAllSession() {
        let filter = createFilter(option: .all, category: .session)
        let query = filter.query()

        #expect(query.name == "")
        #expect(query.userID == nil)
        #expect(query.sessionID == filter.sessionID)
    }

    func createFilter(option: HistoryFilter.Option, category: HistoryFilter.Category)
        -> HistoryFilter
    {
        var filter = HistoryFilter(
            name: "Test Event",
            userID: userID,
            sessionID: sessionID,
            category: category
        )
        filter.option = option
        return filter
    }
}
