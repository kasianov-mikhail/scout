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
    let sync: Synchronize

    init(label: String, dimensions: [(String, String)], sync: @escaping Synchronize) {
        self.label = label
        self.dimensions = dimensions
        self.sync = sync
    }

    func reset() {}
}

extension CKTelemetryHandler: CounterHandler {
    func increment(by value: Int64) {
        logMetrics(telemetry: .counter, value: Int(value))
    }
}

extension CKTelemetryHandler: FloatingPointCounterHandler {
    func increment(by value: Double) {
        logMetrics(telemetry: .floatingCounter, value: value)
    }
}

extension CKTelemetryHandler: TimerHandler {
    func recordNanoseconds(_ duration: Int64) {
        logTimer(seconds: Double(duration) / 1_000_000_000)
    }
}
