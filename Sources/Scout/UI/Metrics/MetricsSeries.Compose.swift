//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension MetricsSeries {
    struct Compose {
        let matrices: [Matrix<GridCell<T>>]
        let period: Period

        init(of matrices: [Matrix<GridCell<T>>], period: Period) {
            self.matrices = matrices
            self.period = period
        }

        func callAsFunction() -> [MetricsSeries<T>] {
            Dictionary(grouping: matrices, by: \.name)
                .mapValues(toPoints)
                .compactMap(MetricsSeries.init)
                .sorted()
        }

        private func toPoints(matrices: [Matrix<GridCell<T>>]) -> [ChartPoint<T>] {
            matrices.flatMap(ChartPoint<T>.fromGridMatrix).points(in: range)
        }

        private var range: ClosedRange<Date> {
            period.range.lowerBound...period.range.upperBound
        }
    }
}
