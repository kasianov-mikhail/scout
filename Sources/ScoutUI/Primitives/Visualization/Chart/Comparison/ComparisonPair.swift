//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct ComparisonPair<T: ChartNumeric>: Identifiable {
    let date: Date
    let bin: Range<Date>
    let value: T
    let reference: T?

    var id: Date { date }
}

extension ComparisonPair {
    var barStart: Date { slotDate(at: ChartGeometry.barStart) }

    var barEnd: Date { slotDate(at: ChartGeometry.barEnd) }

    var binCenter: Date { slotDate(at: 0.5) }

    private func slotDate(at fraction: Double) -> Date {
        let length = bin.upperBound.timeIntervalSince(bin.lowerBound)
        return bin.lowerBound.addingTimeInterval(length * fraction)
    }
}

extension Collection {
    func paired<T>(with reference: [ChartPoint<T>], unit: Calendar.Component) -> [ComparisonPair<T>] where Element == ChartPoint<T> {
        let values = Dictionary(reference.map { ($0.date, $0.value) }, uniquingKeysWith: +)
        return map { point in
            ComparisonPair(
                date: point.date,
                bin: binRange(of: point.date, unit: unit),
                value: point.value,
                reference: values[point.date]
            )
        }
    }

    func xDomain<T>() -> ClosedRange<Date> where Element == ComparisonPair<T> {
        guard let first = map(\.bin.lowerBound).min(), let last = map(\.bin.upperBound).max() else {
            return Date().startOfDay...Date().startOfDay.addingDay()
        }
        return first...last
    }
}
