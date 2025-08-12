//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Metrics

/// A telemetry handler that logs metrics to the console.
///
/// This handler is used for debugging purposes and does not send data to any external service.
/// It implements the `CounterHandler`, `FloatingPointCounterHandler`, and `TimerHandler`
/// protocols to handle different types of metrics.
///
final class CKTelemetryHandler: NSObject {

    let label: String
    let dimensions: [(String, String)]

    init(label: String, dimensions: [(String, String)]) {
        self.label = label
        self.dimensions = dimensions
    }

    func reset() {}
}

extension CKTelemetryHandler: CounterHandler {
    func increment(by: Int64) {
        logMetrics(label, telemetry: .counter, value: by)
    }
}

extension CKTelemetryHandler: FloatingPointCounterHandler {
    func increment(by: Double) {
        logMetrics(label, telemetry: .floatingCounter, value: by)
    }
}

extension CKTelemetryHandler: TimerHandler {
    func recordNanoseconds(_ duration: Int64) {
        logMetrics(label, telemetry: .timer, value: duration)
    }
}
