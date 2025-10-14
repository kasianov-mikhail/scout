//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

struct ActivityCompose {
    let matrices: [PeriodMatrix]
    let period: ActivityPeriod

    init(of matrices: [PeriodMatrix], period: ActivityPeriod) {
        self.matrices = matrices
        self.period = period
    }

    func callAsFunction() -> [ChartPoint<Int>] {
        matrices
            .flatMap(toPoints)
            .bucket(on: period)
            .sorted()
    }

    private func toPoints(matrix: PeriodMatrix) -> [ChartPoint<Int>] {
        matrix.cells
            .filter { $0.period == period }
            .map { $0.point(baseDate: matrix.date) }
    }
}
