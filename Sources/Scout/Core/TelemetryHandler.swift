//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Metrics

/// A CloudKit-specific telemetry handler that routes metric updates
/// to the `logMetrics` function for persistence and analysis.
///
/// This class implements various metric protocols (`CounterHandler`,
/// `FloatingPointCounterHandler`, `TimerHandler`) but does not support reset.
///
final class CKTelemetryHandler: NSObject {

    let label: String
    let dimensions: [(String, String)]

    init(label: String, dimensions: [(String, String)]) {
        self.label = label
        self.dimensions = dimensions
    }

    func reset() {
        // No-op for resetting metrics.
    }
}

// MARK: - Metrics Protocols

extension CKTelemetryHandler: CounterHandler {

    /// Increments an integer counter metric.
    func increment(by: Int64) {
        logMetrics(
            label,
            telemetry: .counter,
            value: Double(by),
        )
    }
}

extension CKTelemetryHandler: FloatingPointCounterHandler {

    /// Increments a floating-point counter metric.
    func increment(by: Double) {
        logMetrics(
            label,
            telemetry: .floatingCounter,
            value: by,
        )
    }
}

extension CKTelemetryHandler: TimerHandler {

    /// Records a timer metric in nanoseconds.
    func recordNanoseconds(_ duration: Int64) {
        logMetrics(
            label,
            telemetry: .timer,
            value: Double(duration),
        )
    }
}
