//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts

typealias ChartData<T: ChartTimeScale, V: ChartNumeric> = [T: [ChartPoint<V>]]

typealias ChartNumeric = MatrixValue & Plottable

extension StatModel {
    func points<V: ChartNumeric>(from data: ChartData<T, V>?) -> [ChartPoint<V>]? {
        data?[period]?.filter {
            range.contains($0.date)
        }
    }
}
