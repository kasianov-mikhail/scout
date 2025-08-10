//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Metrics

struct TelemetryFactory: MetricsFactory {
    func makeCounter(label: String, dimensions: [(String, String)]) -> CounterHandler {
        CKTelemetryHandler(label: label, dimensions: dimensions)
    }

    func makeFloatingPointCounter(label: String, dimensions: [(String, String)])
        -> FloatingPointCounterHandler
    {
        CKTelemetryHandler(label: label, dimensions: dimensions)
    }

    func makeMeter(label: String, dimensions: [(String, String)]) -> MeterHandler {
        return NoOpMeter()
    }

    func makeRecorder(label: String, dimensions: [(String, String)], aggregate: Bool)
        -> RecorderHandler
    {
        return NoOpRecorder()
    }

    func makeTimer(label: String, dimensions: [(String, String)]) -> TimerHandler {
        CKTelemetryHandler(label: label, dimensions: dimensions)
    }

    func destroyCounter(_ handler: CounterHandler) {

    }

    func destroyMeter(_ handler: MeterHandler) {

    }

    func destroyRecorder(_ handler: RecorderHandler) {

    }

    func destroyTimer(_ handler: TimerHandler) {

    }
}
