//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Metrics
import Testing

@testable import Scout

struct TelemetryFactoryTests {
    let factory = TelemetryFactory()

    @Test("makeCounter returns CKTelemetryHandler")
    func makeCounter() {
        let handler = factory.makeCounter(label: "test", dimensions: [])
        #expect(handler is CKTelemetryHandler)
    }

    @Test("makeFloatingPointCounter returns CKTelemetryHandler")
    func makeFloatingPointCounter() {
        let handler = factory.makeFloatingPointCounter(label: "test", dimensions: [])
        #expect(handler is CKTelemetryHandler)
    }

    @Test("makeTimer returns CKTelemetryHandler")
    func makeTimer() {
        let handler = factory.makeTimer(label: "test", dimensions: [])
        #expect(handler is CKTelemetryHandler)
    }

    @Test("makeMeter returns Idle handler")
    func makeMeter() {
        let handler = factory.makeMeter(label: "test", dimensions: [])
        #expect(handler is CKTelemetryHandler.Idle)
    }

    @Test("makeRecorder returns Idle handler")
    func makeRecorder() {
        let handler = factory.makeRecorder(label: "test", dimensions: [], aggregate: false)
        #expect(handler is CKTelemetryHandler.Idle)
    }

    @Test("makeCounter preserves label and dimensions")
    func counterPreservesLabel() {
        let dims = [("env", "prod"), ("version", "1.0")]
        let handler = factory.makeCounter(label: "api_calls", dimensions: dims)
        let telemetry = handler as? CKTelemetryHandler
        #expect(telemetry?.label == "api_calls")
        #expect(telemetry?.dimensions.count == 2)
        #expect(telemetry?.dimensions[0].0 == "env")
        #expect(telemetry?.dimensions[0].1 == "prod")
    }

    @Test("makeTimer preserves label")
    func timerPreservesLabel() {
        let handler = factory.makeTimer(label: "response_time", dimensions: [])
        let telemetry = handler as? CKTelemetryHandler
        #expect(telemetry?.label == "response_time")
    }
}
