//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension ChartExtent {
    var previousDomain: Range<Date> {
        domain.moved(by: period.rangeComponent, value: -1)
    }

    func referenceSegment<U: ChartNumeric>(from points: [ChartPoint<U>], alignedTo segment: [ChartPoint<U>]) -> [ChartPoint<U>] {
        zip(segment, previousSegment(from: points)).map { ChartPoint(date: $0.date, value: $1.value) }
    }

    func canCompare<U: ChartNumeric>(points: [ChartPoint<U>], segment: [ChartPoint<U>]) -> Bool {
        segment.total != .zero || previousSegment(from: points).total != .zero
    }

    private func previousSegment<U: ChartNumeric>(from points: [ChartPoint<U>]) -> [ChartPoint<U>] {
        points.bucket(in: previousDomain, component: period.pointComponent, fold: fold)
    }
}
