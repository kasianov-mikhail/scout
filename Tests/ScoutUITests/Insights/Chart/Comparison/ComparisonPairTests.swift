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

struct ComparisonPairTests {
    @Test("Pairing matches reference counts to segment dates") func testPairing() {
        let segment = makeSegment(days: 3, count: 2)
        let reference = [
            ChartPoint(date: segment[0].date, count: 7),
            ChartPoint(date: segment[1].date, count: 4),
        ]

        let pairs = segment.paired(with: reference, unit: .day)

        #expect(pairs.map(\.date) == segment.map(\.date))
        #expect(pairs.map(\.count) == [2, 2, 2])
        #expect(pairs.map(\.reference) == [7, 4, nil])
        #expect(pairs.allSatisfy { $0.bin.contains($0.date) })
    }

    @Test("Pairing sums reference points sharing a date") func testDuplicateReferenceDates() {
        let segment = makeSegment(days: 1, count: 2)
        let reference = [
            ChartPoint(date: segment[0].date, count: 3),
            ChartPoint(date: segment[0].date, count: 4),
        ]

        let pairs = segment.paired(with: reference, unit: .day)

        #expect(pairs.map(\.reference) == [7])
    }

    @Test("Domain spans the full bucket bands") func testXDomain() {
        let pairs = makeSegment(days: 3, count: 1).paired(with: [], unit: .day)

        let domain = pairs.xDomain()

        #expect(domain.lowerBound == pairs.map(\.bin.lowerBound).min())
        #expect(domain.upperBound == pairs.map(\.bin.upperBound).max())
    }

    @Test("Empty domain falls back to a single day band") func testEmptyXDomain() {
        let domain = [ComparisonPair<Int>]().xDomain()

        #expect(domain.upperBound == domain.lowerBound.addingDay())
    }

    @Test("Bar edges split the bucket slot by the bar ratio") func testBarGeometry() {
        let pair = makeSegment(days: 1, count: 1).paired(with: [], unit: .day)[0]
        let length = pair.bin.upperBound.timeIntervalSince(pair.bin.lowerBound)

        #expect(abs(pair.barStart.timeIntervalSince(pair.bin.lowerBound) - length * ChartGeometry.barStart) < 0.001)
        #expect(abs(pair.barEnd.timeIntervalSince(pair.bin.lowerBound) - length * ChartGeometry.barEnd) < 0.001)
        #expect(abs(pair.binCenter.timeIntervalSince(pair.bin.lowerBound) - length / 2) < 0.001)
        #expect(abs(pair.barEnd.timeIntervalSince(pair.barStart) - length * ChartGeometry.barRatio) < 0.001)
    }

    func makeSegment(days: Int, count: Int) -> [ChartPoint<Int>] {
        let base = Date(year: 2026, month: 6, day: 1, hour: 12)
        return (0..<days).map { ChartPoint(date: base.addingDay($0), count: count) }
    }
}
