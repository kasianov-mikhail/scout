//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import ScoutCore
@testable import ScoutTestSupport
@testable import ScoutUI

struct ChartComparisonTests {
    @Test("Previous domain precedes the current one") func testPreviousDomain() {
        let extent = ChartExtent(period: Period.week)

        #expect(extent.previousDomain.upperBound == extent.domain.lowerBound)
        #expect(extent.previousDomain.lowerBound == extent.domain.lowerBound.addingWeek(-1))
    }

    @Test("Reference segment aligns previous counts to current buckets") func testReferenceSegment() {
        let extent = ChartExtent(period: Period.week)
        let points = makePoints(in: extent.domain, count: 2) + makePoints(in: extent.previousDomain, count: 5)

        let segment = extent.segment(from: points)
        let reference = extent.referenceSegment(from: points, alignedTo: segment)

        #expect(reference.count == segment.count)
        #expect(reference.map(\.date) == segment.map(\.date))
        #expect(reference.allSatisfy { $0.count == 5 })
        #expect(segment.allSatisfy { $0.count == 2 })
    }

    @Test("Reference segment pairs buckets by offset across month lengths") func testMonthLengthMismatch() {
        let domain = Date(year: 2026, month: 5, day: 10)..<Date(year: 2026, month: 6, day: 10)
        let extent = ChartExtent(period: Period.month, domain: domain)
        let points = makePoints(in: extent.domain, count: 2) + makePoints(in: extent.previousDomain, count: 5)

        let segment = extent.segment(from: points)
        let reference = extent.referenceSegment(from: points, alignedTo: segment)

        #expect(segment.count == 31)
        #expect(reference.count == 30)
        #expect(reference.map(\.date) == segment.prefix(30).map(\.date))
        #expect(reference.allSatisfy { $0.count == 5 })
    }

    @Test("Reference segment is zero without previous data") func testEmptyReference() {
        let extent = ChartExtent(period: Period.week)
        let points = makePoints(in: extent.domain, count: 3)

        let segment = extent.segment(from: points)
        let reference = extent.referenceSegment(from: points, alignedTo: segment)

        #expect(reference.count == segment.count)
        #expect(reference.allSatisfy { $0.count == 0 })
    }

    func makePoints(in range: Range<Date>, count: Int) -> [ChartPoint<Int>] {
        var points: [ChartPoint<Int>] = []
        var date = range.lowerBound

        while date < range.upperBound {
            points.append(ChartPoint(date: date, count: count))
            date.addDay()
        }

        return points
    }
}
