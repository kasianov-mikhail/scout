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

    func referenceSegment<U: ChartNumeric>(from points: [ChartPoint<U>], alignedTo segment: [ChartPoint<U>], now: Date = Date()) -> [ChartPoint<U>] {
        zip(segment, previousSegment(from: points)).compactMap { current, previous in
            guard binRange(of: current.date, unit: unit).upperBound <= now else {
                return nil
            }
            return ChartPoint(date: current.date, value: previous.value)
        }
    }

    func canCompare<U: ChartNumeric>(points: [ChartPoint<U>], segment: [ChartPoint<U>]) -> Bool {
        guard Date().trailingYear.lowerBound <= previousDomain.lowerBound else {
            return false
        }
        return segment.total != .zero || previousSegment(from: points).total != .zero
    }

    private func previousSegment<U: ChartNumeric>(from points: [ChartPoint<U>]) -> [ChartPoint<U>] {
        points.bucket(
            in: previousDomain,
            component: period.pointComponent,
            fold: fold
        )
    }
}
