//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Metrics

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
    func increment(by value: Int64) {
        logMetrics(label, telemetry: .counter, value: Int(value))
    }
}

extension CKTelemetryHandler: FloatingPointCounterHandler {
    func increment(by value: Double) {
        logMetrics(label, telemetry: .floatingCounter, value: value)
    }
}

extension CKTelemetryHandler: TimerHandler {
    func recordNanoseconds(_ duration: Int64) {
        logMetrics(label, telemetry: .timer, value: Int(duration))
    }
}
