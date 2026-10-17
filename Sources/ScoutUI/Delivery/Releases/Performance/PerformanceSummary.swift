//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct PerformanceSummary: Equatable {
    var launchHistogram = LaunchHistogram()
    var memoryHistogram = MemoryHistogram()
    var hangMilliseconds = 0
    var foregroundSeconds = 0
}

extension PerformanceSummary {
    init(series: [MetricSeries], range: Range<Date>) {
        self.init()

        for item in series {
            guard let metric = PerformanceMetric(rawValue: item.name) else {
                continue
            }

            let points: [ChartPoint<Int>] = item.chartPoints()
            let count = points.filter { range.contains($0.date) }.map(\.value).reduce(0, +)
            let category = item.category ?? ""

            switch metric {
            case .launchTime:
                if let index = LaunchHistogram.bucketIndex(of: category) {
                    launchHistogram.add(count: count, at: index)
                }
            case .peakMemory:
                if let index = MemoryHistogram.bucketIndex(of: category) {
                    memoryHistogram.add(count: count, at: index)
                }
            case .hangTime:
                hangMilliseconds += count
            case .foregroundTime:
                foregroundSeconds += count
            }
        }
    }

    var isEmpty: Bool {
        launchHistogram.total == 0 && memoryHistogram.total == 0 && foregroundSeconds == 0
    }

    var launchTime: Double? {
        launchHistogram.percentile(0.5)
    }

    var hangRate: Double? {
        foregroundSeconds > 0 ? Double(hangMilliseconds) / 1_000 / (Double(foregroundSeconds) / 3_600) : nil
    }

    var peakMemory: Double? {
        memoryHistogram.percentile(0.5)
    }
}

extension PerformanceSummary {
    static var sample: PerformanceSummary {
        var summary = PerformanceSummary(hangMilliseconds: 5_400, foregroundSeconds: 36_000)
        for (index, count) in [3: 40, 4: 120, 5: 60, 7: 15, 12: 4] {
            summary.launchHistogram.add(count: count, at: index)
        }
        for (index, count) in [3: 20, 4: 55, 5: 18, 8: 3] {
            summary.memoryHistogram.add(count: count, at: index)
        }
        return summary
    }
}
