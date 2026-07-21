//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Telemetry {
    package enum Export: String, CaseIterable {
        case counter = "counter"
        case floatingCounter = "floating_counter"
        case meter = "meter"
        case recorder = "recorder"
        case timer = "timer"

        package var hasResets: Bool {
            self == .counter || self == .floatingCounter
        }
    }

    enum ExportError: LocalizedError {
        case invalidName

        var errorDescription: String? {
            "Invalid telemetry name. Expected one of: " + Export.allCases.map(\.rawValue).joined(separator: ", ")
        }
    }

    init(name: String, value: Double) throws {
        guard let type = Export(rawValue: name) else {
            throw ExportError.invalidName
        }

        switch type {
        case .counter:
            self = .counter(Int(value))
        case .floatingCounter:
            self = .floatingCounter(value)
        case .meter:
            self = .meter(value)
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
        case .meter:
            .meter
        case .recorder:
            .recorder
        case .timer:
            .timer
        }
    }
}
