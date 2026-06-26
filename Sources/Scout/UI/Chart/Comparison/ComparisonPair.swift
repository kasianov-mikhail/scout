//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// Horizontal portion of each bucket slot occupied by a bar, derived from
/// `chartBarRatio` and applied through `barStart`/`barEnd`, so the marks and
/// the `ReferenceOverlay` place bar edges identically.
///
let barSlot: ClosedRange<Double> = (0.5 - chartBarRatio / 2)...(0.5 + chartBarRatio / 2)

/// One bucket of the comparison: the current value and the previous-period
/// value it is compared against, both on the current bucket's date.
///
/// `reference` is nil when the previous window has no counterpart bucket —
/// calendar months differ in length, so the oldest buckets of a longer
/// current window have nothing to compare against.
///
struct ComparisonPair<T: ChartNumeric>: Identifiable {
    let date: Date
    let bin: Range<Date>
    let count: T
    let reference: T?

    var id: Date { date }
}

extension ComparisonPair {
    /// Date of the bar's leading edge within the bucket slot.
    var barStart: Date { slotDate(at: barSlot.lowerBound) }

    /// Date of the bar's trailing edge within the bucket slot.
    var barEnd: Date { slotDate(at: barSlot.upperBound) }

    /// Date at the center of the bucket slot.
    var binCenter: Date { slotDate(at: 0.5) }

    /// The date lying at `fraction` of the way across the bucket slot.
    private func slotDate(at fraction: Double) -> Date {
        let length = bin.upperBound.timeIntervalSince(bin.lowerBound)
        return bin.lowerBound.addingTimeInterval(length * fraction)
    }
}

extension Collection {
    /// Pairs each bucket of the current segment with the reference value
    /// sitting on the same date; buckets missing from `reference` get a nil
    /// reference and draw no comparison marks.
    ///
    func paired<T>(with reference: [ChartPoint<T>], unit: Calendar.Component) -> [ComparisonPair<T>] where Element == ChartPoint<T> {
        let counts = Dictionary(reference.map { ($0.date, $0.count) }, uniquingKeysWith: +)
        return map { point in
            ComparisonPair(
                date: point.date,
                bin: binRange(of: point.date, unit: unit),
                count: point.count,
                reference: counts[point.date]
            )
        }
    }

    /// Full bucket bands, so the edge bars are inset from the plot edges the
    /// same way binned `BarMark` charts are.
    ///
    func xDomain<T>() -> ClosedRange<Date> where Element == ComparisonPair<T> {
        guard let first = map(\.bin.lowerBound).min(), let last = map(\.bin.upperBound).max() else {
            return Date().startOfDay...Date().startOfDay.addingDay()
        }
        return first...last
    }
}
