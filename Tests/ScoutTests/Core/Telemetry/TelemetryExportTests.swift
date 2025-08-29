//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import Scout

@Suite("Telemetry Export")
struct TelemetryExportTests {

    @Test("Counter export")
    func counterExport() {
        let telemetry = Telemetry.counter(42)
        #expect(telemetry.export == .counter)
    }

    @Test("Floating counter export")
    func floatingCounterExport() {
        let telemetry = Telemetry.floatingCounter(3.14)
        #expect(telemetry.export == .floatingCounter)
    }

    @Test("Meter set export")
    func meterSetExport() {
        let telemetry = Telemetry.meter(.set(100.0))
        #expect(telemetry.export == .meterSet)
    }

    @Test("Meter increment export")
    func meterIncrementExport() {
        let telemetry = Telemetry.meter(.increment(50.0))
        #expect(telemetry.export == .meterIncrement)
    }

    @Test("Meter decrement export")
    func meterDecrementExport() {
        let telemetry = Telemetry.meter(.decrement(25.0))
        #expect(telemetry.export == .meterDecrement)
    }

    @Test("Recorder export")
    func recorderExport() {
        let telemetry = Telemetry.recorder(123.45)
        #expect(telemetry.export == .recorder)
    }

    @Test("Timer export")
    func timerExport() {
        let telemetry = Telemetry.timer(0.5)
        #expect(telemetry.export == .timer)
    }

    @Test("Counter from name")
    func counterFromName() throws {
        let telemetry = try Telemetry(name: "counter", value: 42.0)
        guard case .counter(let count) = telemetry else {
            Issue.record("Not counter")
            return
        }
        #expect(count == 42)
    }

    @Test("Floating counter from name")
    func floatingCounterFromName() throws {
        let telemetry = try Telemetry(name: "floating_counter", value: 3.14)
        guard case .floatingCounter(let count) = telemetry else {
            Issue.record("Not floating counter")
            return
        }
        #expect(count == 3.14)
    }

    @Test("Meter set from name")
    func meterSetFromName() throws {
        let telemetry = try Telemetry(name: "meter_set", value: 100.0)
        guard case .meter(.set(let value)) = telemetry else {
            Issue.record("Not meter set")
            return
        }
        #expect(value == 100.0)
    }

    @Test("Meter increment from name")
    func meterIncrementFromName() throws {
        let telemetry = try Telemetry(name: "meter_increment", value: 50.0)
        guard case .meter(.increment(let value)) = telemetry else {
            Issue.record("Not meter increment")
            return
        }
        #expect(value == 50.0)
    }

    @Test("Meter decrement from name")
    func meterDecrementFromName() throws {
        let telemetry = try Telemetry(name: "meter_decrement", value: 25.0)
        guard case .meter(.decrement(let value)) = telemetry else {
            Issue.record("Not meter decrement")
            return
        }
        #expect(value == 25.0)
    }

    @Test("Recorder from name")
    func recorderFromName() throws {
        let telemetry = try Telemetry(name: "recorder", value: 123.45)
        guard case .recorder(let value) = telemetry else {
            Issue.record("Not recorder")
            return
        }
        #expect(value == 123.45)
    }

    @Test("Timer from name")
    func timerFromName() throws {
        let telemetry = try Telemetry(name: "timer", value: 0.5)
        guard case .timer(let value) = telemetry else {
            Issue.record("Not timer")
            return
        }
        #expect(value == 0.5)
    }

    @Test("Invalid name throws")
    func invalidNameThrows() {
        #expect(throws: Telemetry.ExportError.invalidName) {
            try Telemetry(name: "invalid_name", value: 1.0)
        }
    }

    @Test("Empty name throws")
    func emptyNameThrows() {
        #expect(throws: Telemetry.ExportError.invalidName) {
            try Telemetry(name: "", value: 1.0)
        }
    }

    @Test("Counter zero value")
    func counterZeroValue() throws {
        let telemetry = try Telemetry(name: "counter", value: 0.0)
        guard case .counter(let count) = telemetry else {
            Issue.record("Not counter")
            return
        }
        #expect(count == 0)
    }

    @Test("Counter negative value")
    func counterNegativeValue() throws {
        let telemetry = try Telemetry(name: "counter", value: -5.0)
        guard case .counter(let count) = telemetry else {
            Issue.record("Not counter")
            return
        }
        #expect(count == -5)
    }

    @Test("Floating counter integer value")
    func floatingCounterIntegerValue() throws {
        let telemetry = try Telemetry(name: "floating_counter", value: 42.0)
        guard case .floatingCounter(let count) = telemetry else {
            Issue.record("Not floating counter")
            return
        }
        #expect(count == 42.0)
    }

    @Test("Error description contains names")
    func errorDescriptionContainsNames() {
        let error = Telemetry.ExportError.invalidName
        let description = error.description
        #expect(description.contains("counter"))
        #expect(description.contains("floating_counter"))
        #expect(description.contains("meter_set"))
        #expect(description.contains("meter_increment"))
        #expect(description.contains("meter_decrement"))
        #expect(description.contains("recorder"))
        #expect(description.contains("timer"))
    }

    @Test("Counter fractional value truncates")
    func counterFractionalValueTruncates() throws {
        let telemetry = try Telemetry(name: "counter", value: 42.7)
        guard case .counter(let count) = telemetry else {
            Issue.record("Not counter")
            return
        }
        #expect(count == 42)
    }

    @Test("Export raw values")
    func exportRawValues() {
        #expect(Telemetry.Export.counter.rawValue == "counter")
        #expect(Telemetry.Export.floatingCounter.rawValue == "floating_counter")
        #expect(Telemetry.Export.meterSet.rawValue == "meter_set")
        #expect(Telemetry.Export.meterIncrement.rawValue == "meter_increment")
        #expect(Telemetry.Export.meterDecrement.rawValue == "meter_decrement")
        #expect(Telemetry.Export.recorder.rawValue == "recorder")
        #expect(Telemetry.Export.timer.rawValue == "timer")
    }

    @Test("Export all cases")
    func exportAllCases() {
        let allCases = Telemetry.Export.allCases
        #expect(allCases.count == 7)
        #expect(allCases.contains(.counter))
        #expect(allCases.contains(.floatingCounter))
        #expect(allCases.contains(.meterSet))
        #expect(allCases.contains(.meterIncrement))
        #expect(allCases.contains(.meterDecrement))
        #expect(allCases.contains(.recorder))
        #expect(allCases.contains(.timer))
    }
}
