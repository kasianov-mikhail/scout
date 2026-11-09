//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import ScoutUI
@testable import Support

@Suite("Chart series bucket")
struct ChartSeriesBucketTests {
    private let start = Date(year: 2026, month: 6, day: 1)

    private var range: Range<Date> {
        start..<start.adding(.hour, value: 3)
    }

    private var points: [ChartPoint<Int>] {
        [point(hours: 0.1, value: 3), point(hours: 0.9, value: 5), point(hours: 2.5, value: 7)]
    }

    private func point(hours: Double, value: Int) -> ChartPoint<Int> {
        ChartPoint(date: start.addingTimeInterval(hours * .hour), value: value)
    }

    @Test("An empty source yields one zero bucket per component")
    func emptySource() {
        let buckets = [ChartPoint<Int>]().bucket(in: range, component: .hour)

        #expect(buckets.map(\.value) == [0, 0, 0])
        #expect(buckets.map(\.date) == [start.adding(.hour, value: 2), start.adding(.hour), start])
    }

    @Test("Buckets run from the newest to the oldest")
    func newestFirst() {
        let buckets = [point(hours: 0, value: 1), point(hours: 2.5, value: 2)].bucket(in: range, component: .hour)

        #expect(buckets.map(\.value) == [2, 0, 1])
        #expect(buckets.first?.date == start.adding(.hour, value: 2))
    }

    @Test("A point on the lower bound lands in the last bucket")
    func lowerBoundPoint() {
        let buckets = [point(hours: 0, value: 4)].bucket(in: range, component: .hour)

        #expect(buckets.map(\.value) == [0, 0, 4])
        #expect(buckets.last?.date == start)
    }

    @Test("A point on the upper bound is dropped")
    func upperBoundPoint() {
        let buckets = [point(hours: 3, value: 9)].bucket(in: range, component: .hour)

        #expect(buckets.map(\.value) == [0, 0, 0])
    }

    @Test("A point just below the upper bound lands in the first bucket")
    func belowUpperBoundPoint() {
        let buckets = [point(hours: 2.9, value: 9)].bucket(in: range, component: .hour)

        #expect(buckets.map(\.value) == [9, 0, 0])
    }

    @Test("Points of one bucket sum by default")
    func totalFold() {
        #expect(points.bucket(in: range, component: .hour).map(\.value) == [7, 0, 8])
    }

    @Test("The peak fold keeps the highest point of each bucket")
    func peakFold() {
        #expect(points.bucket(in: range, component: .hour, fold: .peak).map(\.value) == [7, 0, 5])
    }

    @Test("A time scale drives the range and the point component")
    func scaleBucket() {
        let scale = ScaleStub(horizonDate: start.adding(.day), rangeComponent: .day, pointComponent: .hour)
        let buckets = [point(hours: 0.5, value: 6)].bucket(on: scale)

        #expect(buckets.count == 24)
        #expect(buckets.last?.value == 6)
        #expect(buckets.dropLast().allSatisfy { $0.value == 0 })
    }
}
