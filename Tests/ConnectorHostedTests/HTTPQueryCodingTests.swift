//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import ConnectorHosted
@testable import ScoutCore

@Suite("HTTPQuery translation")
struct HTTPQueryCodingTests {
    @Test("Filters carry over to the wire query")
    func filters() {
        let from = Date(timeIntervalSince1970: 1_700_000_000)
        let to = Date(timeIntervalSince1970: 1_800_000_000)

        let query = RecordQuery(
            recordType: Event.self,
            filters: [
                RecordQuery.Filter(field: "date", op: .greaterThanOrEquals, value: .date(from)),
                RecordQuery.Filter(field: "date", op: .lessThan, value: .date(to)),
                RecordQuery.Filter(field: "name", op: .equals, value: .string("login")),
            ]
        )

        let http = HTTPQuery(query: query, fields: nil, limit: nil)

        #expect(http.recordType == "Event")
        #expect(
            http.filters == [
                RecordQuery.Filter(field: "date", op: .greaterThanOrEquals, value: .date(from)),
                RecordQuery.Filter(field: "date", op: .lessThan, value: .date(to)),
                RecordQuery.Filter(field: "name", op: .equals, value: .string("login")),
            ]
        )
    }

    @Test("IN, BEGINSWITH, and inequality operators carry over")
    func operators() {
        let query = RecordQuery(
            recordType: Session.self,
            filters: [
                RecordQuery.Filter(field: "install_id", op: .in, value: .strings(["a", "b"])),
                RecordQuery.Filter(field: "name", op: .beginsWith, value: .string("cart_")),
                RecordQuery.Filter(field: "param_count", op: .notEquals, value: .int(3)),
            ]
        )

        let http = HTTPQuery(query: query, fields: nil, limit: nil)

        #expect(
            http.filters == [
                RecordQuery.Filter(field: "install_id", op: .in, value: .strings(["a", "b"])),
                RecordQuery.Filter(field: "name", op: .beginsWith, value: .string("cart_")),
                RecordQuery.Filter(field: "param_count", op: .notEquals, value: .int(3)),
            ]
        )
    }

    @Test("A query with no filters carries an empty filter list")
    func noFilters() {
        let http = HTTPQuery(query: RecordQuery(recordType: Event.self), fields: nil, limit: nil)

        #expect(http.filters?.isEmpty == true)
    }

    @Test("Sort descriptors, fields, and limit carry over")
    func sortAndLimit() {
        let query = RecordQuery(
            recordType: Event.self,
            sort: [RecordQuery.Sort(field: "date", ascending: false)]
        )

        let http = HTTPQuery(query: query, fields: ["name", "date"], limit: 25)

        #expect(http.sort == [RecordQuery.Sort(field: "date", ascending: false)])
        #expect(http.fields == ["name", "date"])
        #expect(http.limit == 25)
    }

    @Test("The default page size travels as no limit")
    func defaultLimit() {
        let http = HTTPQuery(query: RecordQuery(recordType: Event.self), fields: nil, limit: defaultRecordPageSize)

        #expect(http.limit == nil)
    }
}
