//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

protocol HasCount {
    associatedtype Count: AdditiveArithmetic
    var count: Count { get }
}

extension Collection where Element: HasCount {
    var total: Element.Count {
        reduce(.zero) { $0 + $1.count }
    }
}

protocol ChartSeries: HasCount {
    var date: Date { get }

    init(date: Date, count: Count)
}

extension Collection where Element: ChartSeries {
    func bucket(on period: some ChartTimeScale) -> [Element] {
        bucket(in: period.initialRange, component: period.pointComponent)
    }

    func latest(in range: Range<Date>) -> Element.Count? {
        filter { range.contains($0.date) }
            .max { $0.date < $1.date }?
            .count
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
            result.append(Element(date: newDate, count: points.total))
            date = newDate
        }

        return result
    }
}
