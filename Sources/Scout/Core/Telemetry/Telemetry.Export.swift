//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

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

    enum ExportError: LocalizedError {
        case invalidName

        var errorDescription: String? {
            "Invalid telemetry name. Expected one of: "
                + Export.allCases.map(\.rawValue).joined(separator: ", ")
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
            .counter
        case .floatingCounter:
            .floatingCounter
        case .meter(.set):
            .meterSet
        case .meter(.increment):
            .meterIncrement
        case .meter(.decrement):
            .meterDecrement
        case .recorder:
            .recorder
        case .timer:
            .timer
        }
    }
}
