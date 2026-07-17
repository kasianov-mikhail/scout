//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension [ActivityPoint] {
    func points(on period: ActivityPeriod) -> [ChartPoint<Int>] {
        compactMap { point in
            let count =
                switch period {
                case .daily:
                    point.dau
                case .weekly:
                    point.wau
                case .monthly:
                    point.mau
                }
            guard count > 0 else {
                return nil
            }
            return ChartPoint(date: Date(millisecondsSince1970: point.date), count: count)
        }
    }
}
