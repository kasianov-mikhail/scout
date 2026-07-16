//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct CachedQueryTests {
    let lower = Date(timeIntervalSince1970: 0)
    let upper = Date(timeIntervalSince1970: 4_000_000)
    let cutoff = Date(timeIntervalSince1970: 3_000_000)

    func makeQuery(filters: [RecordQuery.Filter] = [], sort: [RecordQuery.Sort] = []) -> RecordQuery {
        RecordQuery(
            recordType: GridMatrix<Int>.self,
            filters: (lower..<upper).dateFilters + filters,
            sort: sort
        )
    }

    @Test("Parses a matrix query with a date range")
    func parsesMatrixQuery() throws {
        let plan = try #require(CachedQuery(query: makeQuery(), scope: "s", cutoff: cutoff))

        #expect(plan.range == lower..<upper)
        #expect(plan.frozenUpper == cutoff)
    }

    @Test("Frozen upper bound stops at the query upper bound")
    func frozenUpperClamped() throws {
        let plan = try #require(CachedQuery(query: makeQuery(), scope: "s", cutoff: upper.addingDay()))

        #expect(plan.frozenUpper == upper)
    }

    @Test("Rejects sorted queries")
    func rejectsSort() {
        let query = makeQuery(sort: [RecordQuery.Sort(field: "date", ascending: false)])

        #expect(CachedQuery(query: query, scope: "s", cutoff: cutoff) == nil)
    }

    @Test("Rejects non-matrix record types")
    func rejectsOtherRecordTypes() {
        let query = RecordQuery(recordType: Event.self, filters: (lower..<upper).dateFilters)

        #expect(CachedQuery(query: query, scope: "s", cutoff: cutoff) == nil)
    }

    @Test("Rejects queries without a date range")
    func rejectsMissingRange() {
        let query = RecordQuery(recordType: GridMatrix<Int>.self)

        #expect(CachedQuery(query: query, scope: "s", cutoff: cutoff) == nil)
    }

    @Test("Rejects fully live ranges")
    func rejectsLiveRange() {
        #expect(CachedQuery(query: makeQuery(), scope: "s", cutoff: lower) == nil)
    }

    @Test("Fingerprint is stable across date ranges")
    func fingerprintIgnoresDates() throws {
        let name = RecordQuery.Filter(field: "name", op: .equals, value: .string("Session"))
        let narrow = RecordQuery(
            recordType: GridMatrix<Int>.self,
            filters: (lower..<cutoff).dateFilters + [name]
        )

        let a = try #require(CachedQuery(query: makeQuery(filters: [name]), scope: "s", cutoff: cutoff))
        let b = try #require(CachedQuery(query: narrow, scope: "s", cutoff: cutoff))

        #expect(a.fingerprint == b.fingerprint)
    }

    @Test("Fingerprint separates filters and scopes")
    func fingerprintSeparates() throws {
        let session = RecordQuery.Filter(field: "name", op: .equals, value: .string("Session"))
        let crash = RecordQuery.Filter(field: "name", op: .equals, value: .string("Crash"))

        let a = try #require(CachedQuery(query: makeQuery(filters: [session]), scope: "s", cutoff: cutoff))
        let b = try #require(CachedQuery(query: makeQuery(filters: [crash]), scope: "s", cutoff: cutoff))
        let c = try #require(CachedQuery(query: makeQuery(filters: [session]), scope: "t", cutoff: cutoff))

        #expect(a.fingerprint != b.fingerprint)
        #expect(a.fingerprint != c.fingerprint)
    }

    @Test("Rebuilds the query for a subrange")
    func rebuildsQuery() throws {
        let name = RecordQuery.Filter(field: "name", op: .equals, value: .string("Session"))
        let plan = try #require(CachedQuery(query: makeQuery(filters: [name]), scope: "s", cutoff: cutoff))

        let rebuilt = plan.query(in: cutoff..<upper)

        #expect(rebuilt.recordType.recordType == GridMatrix<Int>.recordType)
        #expect(rebuilt.filters == (cutoff..<upper).dateFilters + [name])
        #expect(rebuilt.sort.count == 0)
    }
}
