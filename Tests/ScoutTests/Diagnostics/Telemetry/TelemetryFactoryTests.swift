//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Metrics
import Testing

@testable import Scout

struct TelemetryFactoryTests {
    let factory = TelemetryFactory(sync: {}, session: Protected(UUID()))

    @Test("makeCounter returns TelemetryHandler")
    func makeCounter() {
        let handler = factory.makeCounter(label: "test", dimensions: [])
        #expect(handler is TelemetryHandler)
    }

    @Test("makeFloatingPointCounter returns TelemetryHandler")
    func makeFloatingPointCounter() {
        let handler = factory.makeFloatingPointCounter(label: "test", dimensions: [])
        #expect(handler is TelemetryHandler)
    }

    @Test("makeTimer returns TelemetryHandler")
    func makeTimer() {
        let handler = factory.makeTimer(label: "test", dimensions: [])
        #expect(handler is TelemetryHandler)
    }

    @Test("makeMeter returns Idle handler")
    func makeMeter() {
        let handler = factory.makeMeter(label: "test", dimensions: [])
        #expect(handler is TelemetryHandler.Idle)
    }

    @Test("makeRecorder returns TelemetryHandler")
    func makeRecorder() {
        let handler = factory.makeRecorder(label: "test", dimensions: [], aggregate: false)
        #expect(handler is TelemetryHandler)
    }

    @Test("makeCounter preserves label and dimensions")
    func counterPreservesLabel() {
        let dims = [("env", "prod"), ("version", "1.0")]
        let handler = factory.makeCounter(label: "api_calls", dimensions: dims)
        let telemetry = handler as? TelemetryHandler
        #expect(telemetry?.label == "api_calls")
        #expect(telemetry?.dimensions.count == 2)
        #expect(telemetry?.dimensions[0].0 == "env")
        #expect(telemetry?.dimensions[0].1 == "prod")
    }

    @Test("makeTimer preserves label")
    func timerPreservesLabel() {
        let handler = factory.makeTimer(label: "response_time", dimensions: [])
        let telemetry = handler as? TelemetryHandler
        #expect(telemetry?.label == "response_time")
    }
}
