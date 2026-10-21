//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import ScoutDB
import Testing

@testable import NativeConnector
@testable import Scout
@testable import Support

@Suite("Visit gap fold")
struct VisitGapFoldTests {
    @Test("Counts a device once per window from the gap to its previous visit")
    func countsUsersFromGaps() {
        let fold = VisitGapFold(
            gaps: [
                SeriesPoint(group: "30", date: day(0, hour: 9), value: 2),
                SeriesPoint(group: "3", date: day(3, hour: 9), value: 1),
                SeriesPoint(group: "10", date: day(10, hour: 9), value: 1),
                SeriesPoint(group: "30", date: day(10, hour: 12), value: 1),
            ],
            versions: [],
            sessions: []
        )

        let points = fold.points(in: day(0)..<day(11))

        #expect(points.first.map(\.values) == [day(0).millisecondsSince1970, 2, 2, 2])
        #expect(points.first { $0.date == day(3).millisecondsSince1970 }?.values == [day(3).millisecondsSince1970, 1, 2, 2])
        #expect(points.first { $0.date == day(7).millisecondsSince1970 }?.values == [day(7).millisecondsSince1970, 0, 1, 2])
        #expect(points.last.map(\.values) == [day(10).millisecondsSince1970, 2, 2, 3])
    }

    @Test("Skips a day no window reaches a visit from")
    func skipsEmptyDays() {
        let fold = VisitGapFold(
            gaps: [SeriesPoint(group: "30", date: day(0), value: 1)],
            versions: [],
            sessions: []
        )

        #expect(fold.points(in: day(0)..<day(40)).count == 30)
    }

    @Test("A day with sessions of a version that stamps no gaps leaves its windows unstamped")
    func unstampedSpans() {
        let fold = VisitGapFold(
            gaps: [],
            versions: [SeriesPoint(group: "2.0", date: day(5), value: 1)],
            sessions: [
                SeriesPoint(group: "||2.0", date: day(5), value: 1),
                SeriesPoint(group: "||1.0", date: day(5), value: 1),
                SeriesPoint(group: "||2.0", date: day(90), value: 1),
            ]
        )

        #expect(fold.unstampedSpans(in: day(0)..<day(100)) == [day(5)..<day(35), day(90)..<day(100)])
        #expect(fold.points(in: day(0)..<day(100)).isEmpty)
    }

    @Test("Spans closer than a window apart merge into one read")
    func mergesCloseSpans() {
        let fold = VisitGapFold(
            gaps: [],
            versions: [],
            sessions: [
                SeriesPoint(group: "||1.0", date: day(5), value: 1),
                SeriesPoint(group: "||1.0", date: day(50), value: 1),
            ]
        )

        #expect(fold.unstampedSpans(in: day(0)..<day(100)) == [day(5)..<day(80)])
    }

    @Test("A span ends at the upper bound of the range")
    func spanEndsAtRangeUpperBound() {
        let fold = VisitGapFold(
            gaps: [],
            versions: [],
            sessions: [SeriesPoint(group: "||1.0", date: day(2), value: 1)]
        )

        #expect(fold.unstampedSpans(in: day(0)..<day(4, hour: 6)) == [day(2)..<day(4, hour: 6)])
    }
}

extension ActivityPoint {
    fileprivate var values: [Int64] {
        [date, Int64(dau), Int64(wau), Int64(mau)]
    }
}

private func day(_ index: Int, hour: Int = 0) -> Date {
    TestDate.reference.addingTimeInterval(TimeInterval(index) * .day + TimeInterval(hour) * .hour)
}
