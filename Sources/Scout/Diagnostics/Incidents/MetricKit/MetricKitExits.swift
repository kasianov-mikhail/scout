//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

struct MetricKitExits: Sendable {
    let counts: [ExitReason: Int]
}

extension MetricKitExits {
    init(foreground: [ExitReason: Int], background: [ExitReason: Int]) {
        self.init(counts: foreground.merging(background, uniquingKeysWith: +).filter { $0.value > 0 })
    }

    var readings: [DailyMetricReading] {
        counts.sorted { $0.key.rawValue < $1.key.rawValue }.map {
            DailyMetricReading(name: ExitReason.metricName, category: $0.key.rawValue, value: $0.value)
        }
    }
}
