//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct MetricsSeries<T: ChartNumeric>: Identifiable {
    let name: String
    let points: [ChartPoint<T>]

    var id: String { name }
    var title: String { "\(name) – \(points.total) points" }
}

extension MetricsSeries {
    static func fromMatrices(_ matrices: [Matrix<GridCell<T>>]) -> [MetricsSeries<T>] {
        Dictionary(grouping: matrices, by: \.name)
            .mapValues(toPoints)
            .map(MetricsSeries.init)
            .sorted()
    }

    static func toPoints(matrices: [Matrix<GridCell<T>>]) -> [ChartPoint<T>] {
        matrices.flatMap(ChartPoint<T>.fromGridMatrix)
    }
}

extension MetricsSeries: Comparable {
    static func < (lhs: MetricsSeries<T>, rhs: MetricsSeries<T>) -> Bool {
        lhs.points.total > rhs.points.total
    }
}
