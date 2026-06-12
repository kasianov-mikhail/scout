//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import Testing

@testable import Scout

@Suite("HTTPQuery translation")
struct HTTPQueryCodingTests {
    @Test("Compound AND predicate becomes a flat filter list")
    func compoundPredicate() throws {
        let from = Date(timeIntervalSince1970: 1_700_000_000)
        let to = Date(timeIntervalSince1970: 1_800_000_000)

        let query = CKQuery(
            recordType: "DateIntMatrix",
            predicate: NSCompoundPredicate(
                type: .and,
                subpredicates: [
                    NSPredicate(format: "date >= %@ AND date < %@", from as NSDate, to as NSDate),
                    NSPredicate(format: "name == %@", "login"),
                ]
            )
        )

        let http = try HTTPQuery(query: query, fields: nil, limit: nil)

        #expect(http.recordType == "DateIntMatrix")
        #expect(
            http.filters == [
                HTTPFilter(field: "date", op: .greaterThanOrEquals, value: .date(from)),
                HTTPFilter(field: "date", op: .lessThan, value: .date(to)),
                HTTPFilter(field: "name", op: .equals, value: .string("login")),
            ]
        )
    }

    @Test("IN, BEGINSWITH, and inequality operators")
    func operators() throws {
        let query = CKQuery(
            recordType: "Session",
            predicate: NSCompoundPredicate(
                type: .and,
                subpredicates: [
                    NSPredicate(format: "install_id IN %@", ["a", "b"]),
                    NSPredicate(format: "name BEGINSWITH %@", "cart_"),
                    NSPredicate(format: "param_count != %d", 3),
                ]
            )
        )

        let http = try HTTPQuery(query: query, fields: nil, limit: nil)

        #expect(
            http.filters == [
                HTTPFilter(field: "install_id", op: .in, value: .strings(["a", "b"])),
                HTTPFilter(field: "name", op: .beginsWith, value: .string("cart_")),
                HTTPFilter(field: "param_count", op: .notEquals, value: .int(3)),
            ]
        )
    }

    @Test("TRUEPREDICATE maps to no filters")
    func truePredicate() throws {
        let query = CKQuery(recordType: "Event", predicate: NSPredicate(value: true))

        let http = try HTTPQuery(query: query, fields: nil, limit: nil)

        #expect(http.filters?.isEmpty == true)
    }

    @Test("Sort descriptors, fields, and limit carry over")
    func sortAndLimit() throws {
        let query = CKQuery(recordType: "Event", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        let http = try HTTPQuery(query: query, fields: ["name", "date"], limit: 25)

        #expect(http.sort == [HTTPSort(field: "date", ascending: false)])
        #expect(http.fields == ["name", "date"])
        #expect(http.limit == 25)
    }

    @Test("The CloudKit maximum is the server default and travels as no limit")
    func defaultLimit() throws {
        let query = CKQuery(recordType: "Event", predicate: NSPredicate(value: true))

        let http = try HTTPQuery(query: query, fields: nil, limit: CKQueryOperation.maximumResults)

        #expect(http.limit == nil)
    }

    @Test("OR predicates are rejected")
    func unsupportedPredicate() {
        let query = CKQuery(
            recordType: "Event",
            predicate: NSCompoundPredicate(
                type: .or,
                subpredicates: [
                    NSPredicate(format: "name == %@", "a"),
                    NSPredicate(format: "name == %@", "b"),
                ]
            )
        )

        #expect(throws: UnsupportedQueryError.self) {
            try HTTPQuery(query: query, fields: nil, limit: nil)
        }
    }
}
