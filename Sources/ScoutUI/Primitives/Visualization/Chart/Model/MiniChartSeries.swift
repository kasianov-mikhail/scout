//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout

struct MiniChartSeries {
    static let sliceCount = 7

    let values: [Int]
}

extension MiniChartSeries {
    enum Aggregation {
        case total
        case latest
    }

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
    static let empty = MiniChartSeries(values: Array(repeating: .zero, count: sliceCount))

    var isEmpty: Bool {
        values.allSatisfy { $0 == .zero }
    }
}
