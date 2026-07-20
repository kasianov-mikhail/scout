//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct TelemetryExportTests {
    @Test("Init with counter name creates counter")
    func initCounter() throws {
        let telemetry = try Telemetry(name: "counter", value: 5.0)
        #expect(telemetry.export == .counter)
    }

    @Test("Init with floating_counter name creates floatingCounter")
    func initFloatingCounter() throws {
        let telemetry = try Telemetry(name: "floating_counter", value: 3.14)
        #expect(telemetry.export == .floatingCounter)
    }

    @Test("Init with meter name creates meter")
    func initMeter() throws {
        let telemetry = try Telemetry(name: "meter", value: 1.0)
        #expect(telemetry.export == .meter)
    }

    @Test("Init with recorder name creates recorder")
    func initRecorder() throws {
        let telemetry = try Telemetry(name: "recorder", value: 42.0)
        #expect(telemetry.export == .recorder)
    }

    @Test("Init with timer name creates timer")
    func initTimer() throws {
        let telemetry = try Telemetry(name: "timer", value: 100.0)
        #expect(telemetry.export == .timer)
    }

    @Test("Init with invalid name throws ExportError")
    func initInvalidName() {
        #expect(throws: Telemetry.ExportError.self) {
            try Telemetry(name: "invalid", value: 0.0)
        }
    }

    @Test("Export raw values match expected strings")
    func exportRawValues() {
        #expect(Telemetry.Export.counter.rawValue == "counter")
        #expect(Telemetry.Export.floatingCounter.rawValue == "floating_counter")
        #expect(Telemetry.Export.meter.rawValue == "meter")
        #expect(Telemetry.Export.recorder.rawValue == "recorder")
        #expect(Telemetry.Export.timer.rawValue == "timer")
    }

    @Test("Export allCases contains all five types")
    func exportAllCases() {
        #expect(Telemetry.Export.allCases.count == 5)
    }

    @Test("ExportError description lists all valid names")
    func exportErrorDescription() {
        let error = Telemetry.ExportError.invalidName
        let description = error.errorDescription ?? ""
        #expect(description.contains("counter"))
        #expect(description.contains("timer"))
    }
}
