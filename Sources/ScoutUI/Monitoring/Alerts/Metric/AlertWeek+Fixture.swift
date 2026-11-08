//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension AlertWeek: Fixture {
    static var samples: [AlertWeek] {
        [sample, crashFreeSample]
    }

    static var sample: AlertWeek {
        let end = Date().startOfDay
        var values = (0..<216).map { 8 + Double($0 % 7) }

        for index in [128, 146] {
            values[index] = 40
        }
        for index in [76, 106, 174, 186, 204] {
            values[index] = 25
        }

        return AlertWeek(start: end.addingDay(-9), values: values, end: end)
    }

    static var crashFreeSample: AlertWeek {
        let end = Date().startOfDay
        var values = [Double](repeating: 0.998, count: 216)

        for index in [60, 61, 62, 80, 81, 100, 120] {
            values[index] = 0.99
        }

        return AlertWeek(start: end.addingDay(-9), values: values, end: end)
    }
}
