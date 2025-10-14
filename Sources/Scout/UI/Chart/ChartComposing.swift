//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import Foundation

protocol ChartComposing: CellProtocol {
    var secondsSinceBase: Int { get }
}

extension PeriodCell: ChartComposing {
    var secondsSinceBase: Int {
        (day - 1) * 86_400
    }
}

extension GridCell: ChartComposing {
    var secondsSinceBase: Int {
        (row - 1) * 86_400 + column * 3_600
    }
}

// MARK: - Chart Point Mapping

extension Matrix where T: ChartComposing, T.Scalar: ChartNumeric {
    var points: [ChartPoint<T.Scalar>] {
        cells.map { $0.point(baseDate: date) }
    }
}

extension ChartComposing where Scalar: ChartNumeric {
    func point(baseDate: Date) -> ChartPoint<Scalar> {
        ChartPoint(
            date: baseDate.addingTimeInterval(TimeInterval(secondsSinceBase)),
            count: value
        )
    }
}
