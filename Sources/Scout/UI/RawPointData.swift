//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct RawPointData {
    let range: ClosedRange<Date>
    let points: [ChartPoint]
}

extension RawPointData {
    func group(by component: Calendar.Component) -> [ChartPoint] {
        var result: [ChartPoint] = []
        var date = range.lowerBound

        while date < range.upperBound {
            let next = date.adding(component)

            let count = points.filter { item in
                (date..<next).contains(item.date)
            }.reduce(0) {
                $0 + $1.count
            }

            result.append(ChartPoint(date: date, count: count))
            date = next
        }

        return result
    }
}
