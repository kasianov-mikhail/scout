//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

private let categories = Set(MetricsList.Scope.allCases.map(\.telemetry.rawValue))

struct MatrixSpan<T: ChartNumeric> {
    let matrices: [GridMatrix<T>]
    let range: Range<Date>

    func total(where isIncluded: (String) -> Bool) -> T {
        matrices
            .filter { $0.category == nil && isIncluded($0.name) }
            .flatMap(\.points)
            .filter { range.contains($0.date) }
            .total
    }

    var series: Int {
        matrices
            .reduce(into: Set<[String]>()) { keys, matrix in
                guard let category = matrix.category, categories.contains(category) else {
                    return
                }
                if matrix.cells.contains(where: { range.contains($0.point(baseDate: matrix.date).date) }) {
                    keys.insert([category, matrix.name])
                }
            }
            .count
    }
}
