//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension Collection where Element: ChartSeries {
    func bucket(on period: some ChartTimeScale) -> [Element] {
        bucket(in: period.initialRange, component: period.pointComponent)
    }

    func bucket(in range: Range<Date>, component: Calendar.Component) -> [Element] {
        var result: [Element] = []
        var date = range.upperBound

        while date > range.lowerBound {
            let i = -result.count - 1
            let newDate = range.upperBound.adding(component, value: i)
            let points = filter {
                newDate..<date ~= $0.date
            }
            result.append(Element(date: newDate, value: points.total))
            date = newDate
        }

        return result
    }
}
