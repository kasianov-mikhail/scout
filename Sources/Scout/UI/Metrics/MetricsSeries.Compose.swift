//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension MetricsSeries {
    struct Compose {
        let matrices: [GridMatrix<T>]
        let period: Period

        init(of matrices: [GridMatrix<T>], period: Period) {
            self.matrices = matrices
            self.period = period
        }

        func callAsFunction() -> [MetricsSeries<T>] {
            Dictionary(grouping: matrices, by: \.name)
                .mapValues(toPoints)
                .compactMap(MetricsSeries.init)
                .sorted()
        }

        private func toPoints(matrices: [GridMatrix<T>]) -> [ChartPoint<T>] {
            let points = matrices.flatMap(\.chartPoints)
            let extent = ChartExtent(period: period)
            let segment = extent.segment(from: points)
            return segment
        }
    }
}
