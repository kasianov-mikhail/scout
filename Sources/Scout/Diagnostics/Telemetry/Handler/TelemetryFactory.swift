//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Metrics

struct TelemetryFactory: MetricsFactory {
    let runtime: Runtime

    func makeCounter(label: String, dimensions: [(String, String)]) -> CounterHandler {
        TelemetryHandler(label: label, dimensions: dimensions, runtime: runtime)
    }

    func makeFloatingPointCounter(label: String, dimensions: [(String, String)]) -> FloatingPointCounterHandler {
        TelemetryHandler(label: label, dimensions: dimensions, runtime: runtime)
    }

    func makeMeter(label: String, dimensions: [(String, String)]) -> MeterHandler {
        GaugeHandler(label: label, runtime: runtime)
    }

    func makeRecorder(label: String, dimensions: [(String, String)], aggregate: Bool) -> RecorderHandler {
        guard aggregate else { return GaugeHandler(label: label, runtime: runtime) }
        return TelemetryHandler(label: label, dimensions: dimensions, runtime: runtime)
    }

    func makeTimer(label: String, dimensions: [(String, String)]) -> TimerHandler {
        TelemetryHandler(label: label, dimensions: dimensions, runtime: runtime)
    }

    func destroyCounter(_ handler: CounterHandler) {}

    func destroyMeter(_ handler: MeterHandler) {}

    func destroyRecorder(_ handler: RecorderHandler) {}

    func destroyTimer(_ handler: TimerHandler) {}
}
