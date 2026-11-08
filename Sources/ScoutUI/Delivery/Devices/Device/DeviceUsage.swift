//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct DeviceUsage {
    let counts: [[Int]]

    init(counts: [[Int]]) {
        self.counts = counts
    }

    init(sessions: [Session]) {
        var counts = [[Int]](repeating: [Int](repeating: 0, count: 24), count: 7)

        for date in sessions.compactMap(\.startDate) {
            let day = Calendar.utc.component(.weekday, from: date) - 1
            let hour = Calendar.utc.component(.hour, from: date)
            counts[day][hour] += 1
        }

        self.init(counts: counts)
    }

    var maxCount: Int {
        counts.flatMap { $0 }.max() ?? 0
    }

    var busiestWindow: String? {
        let totals = (0..<24).map { hour in
            counts.map { $0[hour] }.reduce(0, +)
        }
        guard totals.contains(where: { $0 > 0 }) else {
            return nil
        }

        var bestStart = 0
        var bestScore = 0

        for hour in 0..<24 {
            let score = totals[hour] * 3 + totals[(hour + 1) % 24] * 2 + totals[(hour + 2) % 24]
            if score >= bestScore {
                bestScore = score
                bestStart = hour
            }
        }

        let end = (bestStart + 3) % 24
        return String(format: "%02d:00–%02d:00", bestStart, end)
    }
}
