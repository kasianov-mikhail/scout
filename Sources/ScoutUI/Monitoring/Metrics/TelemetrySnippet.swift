//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout

extension Telemetry.Export {
    var snippet: String {
        switch self {
        case .counter:
            """
            Counter(
                label: "api_calls"
            )
            .increment()
            """
        case .floatingCounter:
            """
            FloatingPointCounter(
                label: "mb"
            )
            .increment(by: 1.5)
            """
        case .meter:
            """
            Meter(
                label: "queue_depth"
            )
            .set(12)
            """
        case .recorder:
            """
            Recorder(
                label: "payload_size"
            )
            .record(1024)
            """
        case .timer:
            """
            Timer(
                label: "request_duration"
            )
            .recordSeconds(0.42)
            """
        }
    }
}
