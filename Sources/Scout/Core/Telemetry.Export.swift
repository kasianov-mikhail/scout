//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

/// Extension to `Telemetry` that provides export functionality for serialization and deserialization.
///
extension Telemetry {

    /// Defines the string representations used for exporting telemetry data.
    ///
    /// This enum maps each telemetry type to a unique string identifier that can be
    /// used for serialization, network transmission, or storage purposes.
    ///
    enum Export: String, CaseIterable {
        /// Integer counter export identifier.
        case counter = "counter"

        /// Floating-point counter export identifier.
        case floatingCounter = "floating_counter"

        /// Meter set operation export identifier.
        case meterSet = "meter_set"

        /// Meter increment operation export identifier.
        case meterIncrement = "meter_increment"

        /// Meter decrement operation export identifier.
        case meterDecrement = "meter_decrement"

        /// Recorder export identifier.
        case recorder = "recorder"

        /// Timer export identifier.
        case timer = "timer"
    }

    /// Errors that can occur during telemetry export operations.
    enum ExportError: Error, CustomStringConvertible {

        /// Indicates an invalid telemetry name was provided during initialization.
        case invalidName

        var description: String {
            switch self {
            case .invalidName:
                let exportNames = Export.allCases.map { $0.rawValue }.joined(separator: ", ")
                return "Invalid telemetry name. Expected one of: \(exportNames)."
            }
        }
    }

    /// Initializes a telemetry instance from an exported name and value.
    ///
    /// This initializer is used for deserializing telemetry data from external sources
    /// such as configuration files, network messages, or databases.
    ///
    /// - Parameters:
    ///   - name: The exported string name of the telemetry type.
    ///   - value: The numeric value associated with the telemetry event.
    ///
    /// - Throws: `ExportError.invalidName` if the provided name doesn't match any known export type.
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

    /// Returns the export identifier for the current telemetry instance.
    ///
    /// This computed property provides the string representation that can be used
    /// for serializing the telemetry data to external formats.
    ///
    /// - Returns: The `Export` enum case corresponding to this telemetry type.
    ///
    var export: Export {
        switch self {
        case .counter:
            return .counter
        case .floatingCounter:
            return .floatingCounter
        case .meter(let meter):
            switch meter {
            case .set:
                return .meterSet
            case .increment:
                return .meterIncrement
            case .decrement:
                return .meterDecrement
            }
        case .recorder:
            return .recorder
        case .timer:
            return .timer
        }
    }
}
