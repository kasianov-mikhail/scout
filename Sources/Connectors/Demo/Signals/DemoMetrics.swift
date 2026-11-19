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
}
