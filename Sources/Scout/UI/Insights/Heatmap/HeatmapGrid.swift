//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct HeatmapGrid {
    let counts: [[Int]]

    static let dayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    init(counts: [[Int]]) {
        self.counts = counts
    }

    init(points: [ChartPoint<Int>], range: Range<Date>, calendar: Calendar) {
        var counts = [[Int]](repeating: [Int](repeating: 0, count: 24), count: 7)

        for point in points where range.contains(point.date) {
            let weekday = calendar.component(.weekday, from: point.date)
            let hour = calendar.component(.hour, from: point.date)
            counts[(weekday + 5) % 7][hour] += point.count
        }

        self.init(counts: counts)
    }

    func blockCount(day: Int, block: Int, hours: Int) -> Int {
        counts[day][block * hours..<(block + 1) * hours].reduce(0, +)
    }

    func maxBlockCount(hours: Int) -> Int {
        (0..<7).flatMap { day in
            (0..<24 / hours).map { blockCount(day: day, block: $0, hours: hours) }
        }
        .max() ?? 0
    }
}

extension HeatmapGrid {
    static func recentRange(weeks: Int, now: Date = Date()) -> Range<Date> {
        let end = now.startOfDay.addingDay()
        return end.addingWeek(-weeks)..<end
    }
}

extension HeatmapGrid {
    static var sample: HeatmapGrid {
        HeatmapGrid(counts: (0..<7).map { day in (0..<24).map { sampleCount(day: day, hour: $0) } })
    }

    private static func sampleCount(day: Int, hour: Int) -> Int {
        let weekday = day < 5 ? 1.0 : 0.45
        let time = Double(hour)
        let daytime = exp(-pow(time - 10, 2) / 18)
        let evening = 0.7 * exp(-pow(time - 20, 2) / 10)
        let noise = Double((day * 31 + hour * 17) % 7) / 50
        return max(0, Int(((daytime + evening) * weekday + noise - 0.07) * 40))
    }
}
