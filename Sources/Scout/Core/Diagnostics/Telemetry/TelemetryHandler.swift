//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Metrics

final class TelemetryHandler: NSObject {
    let label: String
    let dimensions: [(String, String)]
    let sync: Synchronize
    let session: Protected<UUID>

    init(label: String, dimensions: [(String, String)], sync: @escaping Synchronize, session: Protected<UUID>) {
        self.label = label
        self.dimensions = dimensions
        self.sync = sync
        self.session = session
    }

    func reset() {}
}

extension TelemetryHandler: CounterHandler {
    func increment(by value: Int64) {
        if let category = StatusBuckets.category(in: dimensions) {
            logMetrics(category: category, value: Int(value))
        } else {
            logMetrics(telemetry: .counter, value: Int(value))
        }
    }
}

extension TelemetryHandler: FloatingPointCounterHandler {
    func increment(by value: Double) {
        logMetrics(telemetry: .floatingCounter, value: value)
    }
}

extension TelemetryHandler: TimerHandler {
    func recordNanoseconds(_ duration: Int64) {
        logTimer(seconds: Double(duration) / 1_000_000_000)
    }
}
