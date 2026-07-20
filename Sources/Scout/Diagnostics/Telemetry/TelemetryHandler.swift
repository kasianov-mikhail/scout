//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Metrics

protocol TelemetryPersisting {
    var label: String { get }
    var sync: Synchronize { get }
    var session: Protected<UUID> { get }
}

final class TelemetryHandler: NSObject, TelemetryPersisting {
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

extension TelemetryHandler: RecorderHandler {
    func record(_ value: Int64) {
        logRecorder(value: Double(value))
    }

    func record(_ value: Double) {
        logRecorder(value: value)
    }
}

final class MeterHandlerImpl: NSObject, TelemetryPersisting {
    let label: String
    let sync: Synchronize
    let session: Protected<UUID>
    let value = Protected<Double>(0)

    init(label: String, sync: @escaping Synchronize, session: Protected<UUID>) {
        self.label = label
        self.sync = sync
        self.session = session
    }
}

extension MeterHandlerImpl: MeterHandler {
    func set(_ value: Int64) {
        set(Double(value))
    }

    func set(_ value: Double) {
        logMeter(value: self.value.mutate { $0 = value })
    }

    func increment(by amount: Double) {
        logMeter(value: value.mutate { $0 += amount })
    }

    func decrement(by amount: Double) {
        logMeter(value: value.mutate { $0 -= amount })
    }
}
