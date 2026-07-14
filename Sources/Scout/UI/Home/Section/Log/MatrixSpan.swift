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

    func points(where isIncluded: (String) -> Bool) -> [ChartPoint<T>] {
        points { $0.category == nil && isIncluded($0.name) }
    }

    func points(inCategories categories: Set<String>) -> [ChartPoint<T>] {
        points { $0.category.map(categories.contains) ?? false }
    }

    private func points(matching isIncluded: (GridMatrix<T>) -> Bool) -> [ChartPoint<T>] {
        matrices
            .filter(isIncluded)
            .flatMap(\.points)
            .filter { range.contains($0.date) }
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
