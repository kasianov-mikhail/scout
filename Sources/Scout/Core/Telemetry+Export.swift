//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

extension Telemetry {

    enum Export: String, CaseIterable {
        case counter = "counter"
        case floatingCounter = "floating_counter"
        case meterSet = "meter_set"
        case meterIncrement = "meter_increment"
        case meterDecrement = "meter_decrement"
        case recorder = "recorder"
        case timer = "timer"
    }

    enum ExportError: Error, CustomStringConvertible {
        case invalidName

        var description: String {
            switch self {
            case .invalidName:
                let exportNames = Export.allCases.map { $0.rawValue }.joined(separator: ", ")
                return "Invalid telemetry name. Expected one of: \(exportNames)."
            }
        }
    }

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
