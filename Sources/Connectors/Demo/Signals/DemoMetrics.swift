//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct DemoMetrics {
    static let endpoints = [
        "GET /v1/sessions",
        "POST /v1/events",
        "GET /v1/releases",
        "POST /v1/metrics/records",
        "GET /v1/metrics/series",
    ]

    static let timers = ["api_response_time", "frame_render_time"]
    static let recorders = ["payload_size_bytes", "row_count"]
    static let counters = ["api_requests", "cache_hits", "login_attempts"]

    let samples: [DemoSample]

    init(clock: DemoClock) {
        var random = DemoRandom(seed: 0x0FF1_CE_5EED)
        var samples: [DemoSample] = []

        func moments(spanDays: Int, perDay: Int, _ body: (Date) -> Void) {
            for day in stride(from: spanDays, through: 0, by: -1) {
                for slot in 0..<perDay {
                    let offset = TimeInterval(slot) * (24 * 3600 / TimeInterval(perDay))
                    let date = min(
                        clock.daysAgo(day).addingTimeInterval(offset + random.double(in: 0...3600)),
                        clock.now.addingTimeInterval(-60)
                    )
                    body(date)
                }
            }
        }

        func telemetry(_ names: [String], category: String, values: MetricSeriesQuery.Values, perDay: Int, _ value: (inout DemoRandom) -> Double) {
            for name in names {
                moments(spanDays: 60, perDay: perDay) { date in
                    samples.append(
                        DemoSample(
                            name: name,
                            category: category,
                            source: .metric,
                            date: date,
                            values: values,
                            value: value(&random)
                        )
                    )
                }
            }
        }

        telemetry(Self.counters, category: Telemetry.Export.counter.rawValue, values: .int, perDay: 6) {
            Double($0.int(in: 0...40))
        }
        telemetry(["bytes_downloaded_mb"], category: Telemetry.Export.floatingCounter.rawValue, values: .double, perDay: 6) {
            $0.double(in: 0...12)
        }
        telemetry(["memory_usage_mb", "active_connections"], category: Telemetry.Export.meter.rawValue, values: .double, perDay: 6) {
            $0.double(in: 120...480)
        }
        telemetry(Self.recorders, category: Telemetry.Export.recorder.rawValue, values: .int, perDay: 6) {
            Double($0.int(in: 200...9000))
        }
        telemetry(Self.timers, category: Telemetry.Export.timer.rawValue, values: .double, perDay: 6) {
            $0.double(in: 0.04...0.32)
        }

        for name in Self.counters + ["bytes_downloaded_mb"] {
            for day in stride(from: 40, through: 0, by: -20) {
                samples.append(
                    DemoSample(
                        name: name,
                        category: ResetMarker.category,
                        source: .metric,
                        date: clock.momentDaysAgo(day),
                        value: Double(random.int(in: 1...3))
                    )
                )
            }
        }

        for endpoint in Self.endpoints {
            samples += Self.histogram(
                name: endpoint,
                categories: LatencyBuckets.categories,
                center: 0.45,
                scale: 180,
                clock: clock,
                random: &random
            )
            samples += Self.statuses(endpoint: endpoint, clock: clock, random: &random)
        }

        for name in Self.timers {
            samples += Self.histogram(
                name: name,
                categories: LatencyBuckets.categories,
                center: 0.38,
                scale: 140,
                clock: clock,
                random: &random
            )
        }
        for name in Self.recorders {
            samples += Self.histogram(
                name: name,
                categories: RecorderBuckets.categories,
                center: 0.55,
                scale: 140,
                clock: clock,
                random: &random
            )
        }

        self.samples = samples
    }

    private static func histogram(name: String, categories: [String], center ratio: Double, scale: Double, clock: DemoClock, random: inout DemoRandom) -> [DemoSample] {
        var samples: [DemoSample] = []
        let center = Double(categories.count) * ratio

        for day in stride(from: 56, through: 0, by: -1) {
            let shift = sin(Double(day) * 0.9) * 0.45 + random.double(in: -0.25...0.25)

            for (index, category) in categories.enumerated() {
                let weight = exp(-pow(Double(index) - center - shift, 2) / 3)

                samples.append(
                    DemoSample(
                        name: name,
                        category: category,
                        source: .metric,
                        date: clock.momentDaysAgo(day),
                        value: (weight * scale * random.double(in: 0.85...1.15)).rounded()
                    )
                )
            }
        }
        return samples
    }

    private static func statuses(endpoint: String, clock: DemoClock, random: inout DemoRandom) -> [DemoSample] {
        var samples: [DemoSample] = []

        for (index, category) in StatusBuckets.categories.enumerated() {
            let weight = [0.94, 0.03, 0.025, 0.005][min(index, 3)]

            for day in stride(from: 56, through: 0, by: -7) {
                samples.append(
                    DemoSample(
                        name: endpoint,
                        category: category,
                        source: .metric,
                        date: clock.momentDaysAgo(day),
                        value: (weight * 600).rounded() + Double(random.int(in: 0...2))
                    )
                )
            }
        }
        return samples
    }
}
