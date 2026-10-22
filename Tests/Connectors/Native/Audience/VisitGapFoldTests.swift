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
            gaps: dailyGaps(days: -29...10) + [
                SeriesPoint(group: "30", date: day(0, hour: 9), value: 2),
                SeriesPoint(group: "3", date: day(3, hour: 9), value: 1),
                SeriesPoint(group: "10", date: day(10, hour: 9), value: 1),
                SeriesPoint(group: "30", date: day(10, hour: 12), value: 1),
            ],
            versions: [],
            sessions: []
        )

        let points = fold.points(in: day(0)..<day(11))

        #expect(points.first.map(\.values) == [day(0).millisecondsSince1970, 3, 3, 3])
        #expect(points.first { $0.date == day(3).millisecondsSince1970 }?.values == [day(3).millisecondsSince1970, 2, 3, 3])
        #expect(points.first { $0.date == day(7).millisecondsSince1970 }?.values == [day(7).millisecondsSince1970, 1, 2, 3])
        #expect(points.last.map(\.values) == [day(10).millisecondsSince1970, 3, 3, 4])
    }

    @Test("A window with a day that has no gaps is left to the device series")
    func gaplessDaysAreUnstamped() {
        let fold = VisitGapFold(
            gaps: dailyGaps(days: -29...20) + dailyGaps(days: 22...60),
            versions: [],
            sessions: []
        )

        #expect(fold.unstampedSpans(in: day(0)..<day(60)) == [day(21)..<day(51)])
        #expect(fold.points(in: day(0)..<day(60)).count == 30)
    }

    @Test("Only sessions of a version with no gaps in the read leave their windows unstamped")
    func unstampedSpans() {
        let fold = VisitGapFold(
            gaps: dailyGaps(days: -29...99),
            versions: [SeriesPoint(group: "2.0", date: day(5), value: 1)],
            sessions: [
                SeriesPoint(group: "||2.0", date: day(5), value: 1),
                SeriesPoint(group: "||1.0", date: day(5), value: 1),
                SeriesPoint(group: "||2.0", date: day(90), value: 1),
            ]
        )

        #expect(fold.unstampedSpans(in: day(0)..<day(100)) == [day(5)..<day(35)])
        #expect(fold.points(in: day(0)..<day(100)).count == 70)
    }

    @Test("A window stays stamped while old versions hold at most 1% of its sessions")
    func legacyShareBoundary() {
        let atLimit = VisitGapFold(
            gaps: dailyGaps(days: -29...99),
            versions: [SeriesPoint(group: "2.0", date: day(5), value: 1)],
            sessions: [
                SeriesPoint(group: "||2.0", date: day(5), value: 99),
                SeriesPoint(group: "||1.0", date: day(5), value: 1),
            ]
        )
        let overLimit = VisitGapFold(
            gaps: dailyGaps(days: -29...99),
            versions: [SeriesPoint(group: "2.0", date: day(5), value: 1)],
            sessions: [
                SeriesPoint(group: "||2.0", date: day(5), value: 98),
                SeriesPoint(group: "||1.0", date: day(5), value: 2),
            ]
        )

        #expect(atLimit.unstampedSpans(in: day(0)..<day(100)).isEmpty)
        #expect(overLimit.unstampedSpans(in: day(0)..<day(100)) == [day(5)..<day(35)])
    }

    @Test("A range counts devices while old versions hold at most 1% of its sessions")
    func devicesLegacyShare() {
        let atLimit = VisitGapFold(
            gaps: dailyGaps(days: 0...6),
            versions: [SeriesPoint(group: "2.0", date: day(0), value: 1)],
            sessions: [
                SeriesPoint(group: "||2.0", date: day(3), value: 9),
                SeriesPoint(group: "||1.0", date: day(3), value: 1),
                SeriesPoint(group: "||2.0", date: day(5), value: 90),
            ]
        )
        let overLimit = VisitGapFold(
            gaps: dailyGaps(days: 0...6),
            versions: [SeriesPoint(group: "2.0", date: day(0), value: 1)],
            sessions: [
                SeriesPoint(group: "||2.0", date: day(3), value: 8),
                SeriesPoint(group: "||1.0", date: day(3), value: 2),
                SeriesPoint(group: "||2.0", date: day(5), value: 90),
            ]
        )

        #expect(atLimit.devices(in: day(0)..<day(7)) == 1)
        #expect(overLimit.devices(in: day(0)..<day(7)) == nil)
    }

    @Test("A rare device on an old version leaves the year stamped")
    func rareLegacyDevice() {
        let fold = VisitGapFold(
            gaps: dailyGaps(days: -29...364),
            versions: [SeriesPoint(group: "2.0", date: day(0), value: 1)],
            sessions: (-29...364).flatMap { index in
                [SeriesPoint(group: "||2.0", date: day(index), value: 200)]
                    + (index.isMultiple(of: 60) ? [SeriesPoint(group: "||1.0", date: day(index), value: 1)] : [])
            }
        )

        #expect(fold.unstampedSpans(in: day(0)..<day(365)).isEmpty)
        #expect(fold.points(in: day(0)..<day(365)).count == 365)
    }

    @Test("Spans closer than a window apart merge into one read")
    func mergesCloseSpans() {
        let fold = VisitGapFold(
            gaps: dailyGaps(days: -29...99),
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
            gaps: dailyGaps(days: -29...99),
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

private func dailyGaps(days: ClosedRange<Int>) -> [SeriesPoint] {
    days.map { SeriesPoint(group: $0 == days.lowerBound ? "30" : "1", date: day($0, hour: 1), value: 1) }
}

private func day(_ index: Int, hour: Int = 0) -> Date {
    TestDate.reference.addingTimeInterval(TimeInterval(index) * .day + TimeInterval(hour) * .hour)
}
