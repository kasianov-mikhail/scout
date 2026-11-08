//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension MetricTile: Fixture {
    static var samples: [MetricTile] {
        [
            MetricTile(name: "checkout.completed", telemetry: .counter, value: 1_284, series: [12, 18, 16, 25, 48, 62, 74, 68, 82, 90, 96, 104]),
            MetricTile(name: "image_cache.miss", telemetry: .counter, value: 42_100, series: [30, 24, 38, 32, 44, 52, 48, 60, 56, 68, 74, 82]),
            MetricTile(name: "push.received", telemetry: .counter, value: 9_812, series: [20, 26, 22, 30, 34, 42, 38, 46, 52, 58, 54, 64]),
            MetricTile(name: "feed.refresh", telemetry: .counter, value: 3_402, series: [8, 12, 10, 16, 22, 18, 26, 30, 28, 36, 40, 44]),
            MetricTile(name: "revenue.usd", telemetry: .floatingCounter, value: 18_400, series: [4, 6, 8, 7, 12, 14, 16, 15, 20, 22, 26, 28]),
            MetricTile(name: "http.request.duration", telemetry: .timer, value: 0.081, series: [0.09, 0.08, 0.07, 0.06, 0.075, 0.085, 0.09, 0.08, 0.07, 0.065, 0.07, 0.081]),
            MetricTile(name: "app.cold_start", telemetry: .timer, value: 0.612, series: [0.7, 0.66, 0.68, 0.62, 0.64, 0.6, 0.65, 0.61, 0.63, 0.6, 0.62, 0.612]),
            MetricTile(name: "db.query.feed_load", telemetry: .recorder, value: 38, series: [30, 34, 32, 36, 40, 38, 42, 36, 34, 38, 40, 38]),
            MetricTile(name: "feed.items_per_page", telemetry: .recorder, value: 24, series: [20, 22, 21, 23, 25, 24, 26, 23, 22, 24, 25, 24]),
            MetricTile(name: "payload.size_bytes", telemetry: .recorder, value: 18_000, series: [12_000, 14_000, 15_000, 13_000, 16_000, 17_000, 16_500, 18_000, 17_500, 18_200, 17_800, 18_000]),
            MetricTile(name: "memory.footprint_mb", telemetry: .meter, value: 214, series: [180, 186, 190, 196, 200, 205, 208, 210, 212, 214, 213, 214]),
            MetricTile(name: "queue.pending_uploads", telemetry: .meter, value: 3, series: [5, 4, 6, 3, 4, 2, 3, 5, 4, 3, 2, 3]),
        ]
    }
}
