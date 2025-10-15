//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

func activityCompose(of matrices: [PeriodMatrix], period: ActivityPeriod) -> [ChartPoint<Int>] {
    matrices
        .flatMap { $0.points(on: period) }
        .bucket(on: period)
        .sorted()
}

extension PeriodMatrix {
    fileprivate func points(on period: ActivityPeriod) -> [ChartPoint<Int>] {
        cells
            .filter { $0.period == period }
            .map { $0.point(baseDate: date) }
    }
}
