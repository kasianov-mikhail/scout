//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Metrics

struct TelemetryFactory: MetricsFactory {
    let sync: Synchronize
    let session: Protected<UUID>

    func makeCounter(label: String, dimensions: [(String, String)]) -> CounterHandler {
        TelemetryHandler(label: label, dimensions: dimensions, sync: sync, session: session)
    }

    func makeFloatingPointCounter(label: String, dimensions: [(String, String)]) -> FloatingPointCounterHandler {
        TelemetryHandler(label: label, dimensions: dimensions, sync: sync, session: session)
    }

    func makeMeter(label: String, dimensions: [(String, String)]) -> MeterHandler {
        MeterHandlerImpl(label: label, sync: sync, session: session)
    }

    func makeRecorder(label: String, dimensions: [(String, String)], aggregate: Bool) -> RecorderHandler {
        TelemetryHandler(label: label, dimensions: dimensions, sync: sync, session: session)
    }

    func makeTimer(label: String, dimensions: [(String, String)]) -> TimerHandler {
        TelemetryHandler(label: label, dimensions: dimensions, sync: sync, session: session)
    }

    func destroyCounter(_ handler: CounterHandler) {}

    func destroyMeter(_ handler: MeterHandler) {}

    func destroyRecorder(_ handler: RecorderHandler) {}

    func destroyTimer(_ handler: TimerHandler) {}
}
