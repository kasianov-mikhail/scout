//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Metrics

final class GaugeHandler: NSObject, TelemetryPersisting {
    let label: String
    let runtime: Runtime
    let value = Protected<Double>(0)

    init(label: String, runtime: Runtime) {
        self.label = label
        self.runtime = runtime
    }
}

extension GaugeHandler: MeterHandler {
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

extension GaugeHandler: RecorderHandler {
    func record(_ value: Int64) {
        set(value)
    }

    func record(_ value: Double) {
        set(value)
    }
}
