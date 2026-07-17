//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension MetricSeries {
    func chartPoints<T: ChartNumeric>() -> [ChartPoint<T>] {
        points.map { point in
            ChartPoint(
                date: Date(millisecondsSince1970: point.date),
                count: T(point.value.doubleValue)
            )
        }
    }
}
