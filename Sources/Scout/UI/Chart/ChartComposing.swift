//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import Foundation

/// A protocol for matrix cells that can be transformed back into chart-ready points by
/// recalculating their actual `Date` from matrix context.
///
/// In essence:
/// - The matrix stores a base "week date" (e.g., the start of the week).
/// - After applying a revert/unflatten transformation, each cell must recompute its actual
///   timestamp relative to that base using other matrix properties (such as day/row/column).
///
/// How it works:
/// - Conforming cells provide `secondsSinceBase`, the time offset from the matrix’s base week date.
/// - The offset is combined with the matrix’s stored base date to derive the final `Date`,
///   enabling stable reconstruction of time series data after transformations.
///
protocol ChartComposing: CellProtocol {
    var secondsSinceBase: Int { get }
}

// MARK: - Conformers

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
