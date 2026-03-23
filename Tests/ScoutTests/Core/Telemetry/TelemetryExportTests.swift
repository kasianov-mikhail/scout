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
    // MARK: - Init from name and value

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

    @Test("Init with meter_set name creates meter set")
    func initMeterSet() throws {
        let telemetry = try Telemetry(name: "meter_set", value: 1.0)
        #expect(telemetry.export == .meterSet)
    }

    @Test("Init with meter_increment name creates meter increment")
    func initMeterIncrement() throws {
        let telemetry = try Telemetry(name: "meter_increment", value: 2.0)
        #expect(telemetry.export == .meterIncrement)
    }

    @Test("Init with meter_decrement name creates meter decrement")
    func initMeterDecrement() throws {
        let telemetry = try Telemetry(name: "meter_decrement", value: 1.0)
        #expect(telemetry.export == .meterDecrement)
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

    // MARK: - Export property

    @Test("Export raw values match expected strings")
    func exportRawValues() {
        #expect(Telemetry.Export.counter.rawValue == "counter")
        #expect(Telemetry.Export.floatingCounter.rawValue == "floating_counter")
        #expect(Telemetry.Export.meterSet.rawValue == "meter_set")
        #expect(Telemetry.Export.meterIncrement.rawValue == "meter_increment")
        #expect(Telemetry.Export.meterDecrement.rawValue == "meter_decrement")
        #expect(Telemetry.Export.recorder.rawValue == "recorder")
        #expect(Telemetry.Export.timer.rawValue == "timer")
    }

    @Test("Export allCases contains all seven types")
    func exportAllCases() {
        #expect(Telemetry.Export.allCases.count == 7)
    }

    // MARK: - ExportError

    @Test("ExportError description lists all valid names")
    func exportErrorDescription() {
        let error = Telemetry.ExportError.invalidName
        let description = error.errorDescription ?? ""
        #expect(description.contains("counter"))
        #expect(description.contains("timer"))
    }
}
