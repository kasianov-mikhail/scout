//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

/// The points of a Home row's period compressed into a fixed number of
/// equal time slices, ready to be drawn as an inline mini-chart.
///
struct MiniChartSeries {
    /// Number of slices a mini-chart compresses its period into.
    static let sliceCount = 7

    /// One aggregated value per slice, oldest first.
    let values: [Int]
}

extension MiniChartSeries {
    /// How the points of one slice collapse into its single value.
    enum Aggregation {
        /// Sum of all counts — for additive series like event totals.
        case total

        /// Count of the newest point — for level series like active users.
        case latest
    }

    /// Splits `range` into `sliceCount` equal time slices and aggregates
    /// the points that fall into each one.
    ///
    /// Points outside `range` are ignored; a point exactly on a slice
    /// boundary belongs to the later slice.
    ///
    init(points: [ChartPoint<Int>], range: Range<Date>, aggregation: Aggregation) {
        let step = range.upperBound.timeIntervalSince(range.lowerBound) / Double(Self.sliceCount)

        guard step > 0 else {
            values = Array(repeating: .zero, count: Self.sliceCount)
            return
        }

        var slices = [[ChartPoint<Int>]](repeating: [], count: Self.sliceCount)

        for point in points where range.contains(point.date) {
            let index = Int(point.date.timeIntervalSince(range.lowerBound) / step)
            slices[min(index, Self.sliceCount - 1)].append(point)
        }

        values = slices.map { slice in
            switch aggregation {
            case .total:
                slice.total
            case .latest:
                slice.max()?.count ?? .zero
            }
        }
    }
}

extension MiniChartSeries {
    /// A gentle wave drawn under redaction while the real series loads.
    static let placeholder = MiniChartSeries(values: [3, 5, 4, 6, 5, 7, 6])

    /// No slices at all: a chart with nothing but its gridlines.
    static let empty = MiniChartSeries(values: [])
}
