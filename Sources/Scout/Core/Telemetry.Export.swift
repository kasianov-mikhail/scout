//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

/// Export/import of `Telemetry` to stable string identifiers.
extension Telemetry {

    /// Stable string names used for serialization.
    enum Export: String, CaseIterable {
        case counter = "counter"
        case floatingCounter = "floating_counter"
        case meterSet = "meter_set"
        case meterIncrement = "meter_increment"
        case meterDecrement = "meter_decrement"
        case recorder = "recorder"
        case timer = "timer"

        var recordType: String {
            switch self {
            case .counter, .timer:
                "DateIntMatrix"
            case .floatingCounter, .meterSet, .meterIncrement, .meterDecrement, .recorder:
                "DateDoubleMatrix"
            }
        }
    }

    /// Errors that can occur during import from string names.
    enum ExportError: Error, CustomStringConvertible {
        case invalidName

        var description: String {
            "Invalid telemetry name. Expected one of: "
                + Export.allCases.map(\.rawValue).joined(separator: ", ")
        }
    }

    /// Deserializes telemetry from an exported name and numeric value.
    ///
    /// - Parameters:
    ///   - name: One of `Export` raw values.
    ///   - value: Associated numeric payload.
    /// - Throws: `ExportError.invalidName` if `name` is unknown.
    ///
    init(name: String, value: Double) throws(ExportError) {
        guard let type = Export(rawValue: name) else {
            throw .invalidName
        }

        switch type {
        case .counter:
            self = .counter(Int(value))
        case .floatingCounter:
            self = .floatingCounter(value)
        case .meterSet:
            self = .meter(.set(value))
        case .meterIncrement:
            self = .meter(.increment(value))
        case .meterDecrement:
            self = .meter(.decrement(value))
        case .recorder:
            self = .recorder(value)
        case .timer:
            self = .timer(value)
        }
    }

    /// Export identifier for this telemetry instance.
    var export: Export {
        switch self {
        case .counter:
            return .counter
        case .floatingCounter:
            return .floatingCounter
        case .meter(.set):
            return .meterSet
        case .meter(.increment):
            return .meterIncrement
        case .meter(.decrement):
            return .meterDecrement
        case .recorder:
            return .recorder
        case .timer:
            return .timer
        }
    }
}
