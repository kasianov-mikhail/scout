//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

private let launchStep = 100
private let memoryStep = 50

package enum PerformanceMetric: String, CaseIterable, Sendable {
    case launchTime = "launch_time"
    case hangTime = "hang_time"
    case foregroundTime = "foreground_time"
    case peakMemory = "peak_memory"
}

struct MetricKitPerformance: Sendable {
    let launches: [Bucket]
    let hangs: [Bucket]
    let foregroundSeconds: Double
    let peakMemoryMegabytes: Double?

    struct Bucket: Sendable {
        let start: Double
        let end: Double
        let count: Int

        fileprivate var midpoint: Double {
            (start + end) / 2
        }
    }
}

extension MetricKitPerformance {
    var readings: [DailyMetricReading] {
        var readings = launches.counts(step: launchStep).sorted { $0.key < $1.key }.map {
            DailyMetricReading(name: PerformanceMetric.launchTime.rawValue, category: String($0.key), value: $0.value)
        }

        let hangMilliseconds = Int(hangs.total.rounded())
        if hangMilliseconds > 0 {
            readings.append(DailyMetricReading(name: PerformanceMetric.hangTime.rawValue, category: nil, value: hangMilliseconds))
        }

        let foreground = Int(foregroundSeconds.rounded())
        if foreground > 0 {
            readings.append(DailyMetricReading(name: PerformanceMetric.foregroundTime.rawValue, category: nil, value: foreground))
        }

        if let peakMemoryMegabytes {
            let bucket = Int(peakMemoryMegabytes) / memoryStep * memoryStep
            readings.append(DailyMetricReading(name: PerformanceMetric.peakMemory.rawValue, category: String(bucket), value: 1))
        }

        return readings
    }
}

extension [MetricKitPerformance.Bucket] {
    fileprivate var total: Double {
        reduce(0) { $0 + $1.midpoint * Double($1.count) }
    }

    fileprivate func counts(step: Int) -> [Int: Int] {
        var counts: [Int: Int] = [:]
        for bucket in self where bucket.count > 0 {
            counts[Int(bucket.midpoint) / step * step, default: 0] += bucket.count
        }
        return counts
    }
}
