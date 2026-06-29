//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

func crashTrend(of crashes: [Crash], in range: Range<Date>) -> [Int] {
    let slices = MiniChartSeries.sliceCount
    let span = range.upperBound.timeIntervalSince(range.lowerBound)

    guard span > 0 else {
        return Array(repeating: 0, count: slices)
    }

    let step = span / Double(slices)
    var values = Array(repeating: 0, count: slices)

    for crash in crashes {
        guard let date = crash.date, range.contains(date) else {
            continue
        }
        let index = min(slices - 1, Int(date.timeIntervalSince(range.lowerBound) / step))
        values[index] += 1
    }

    return values
}
