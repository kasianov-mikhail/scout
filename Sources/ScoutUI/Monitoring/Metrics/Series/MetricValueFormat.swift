//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

enum MetricValueFormat {
    case counter
    case floating
    case meter
    case timer
    case recorder
}

extension MetricValueFormat {
    init(telemetry: Telemetry.Export) {
        switch telemetry {
        case .counter:
            self = .counter
        case .floatingCounter:
            self = .floating
        case .meter:
            self = .meter
        case .timer:
            self = .timer
        case .recorder:
            self = .recorder
        }
    }

    func label(_ value: Double, compact: Bool = false) -> String {
        switch self {
        case .counter:
            Self.integer(value, compact: compact)
        case .timer:
            TimeInterval(value).duration
        case .floating, .meter, .recorder:
            Self.decimal(value, compact: compact)
        }
    }

    private static func integer(_ value: Double, compact: Bool) -> String {
        let rounded = Int(value.rounded())
        if compact, abs(rounded) >= 10_000 {
            return rounded.compact
        }
        return rounded.formatted(.number.locale(Locale(identifier: "en_US")))
    }

    private static func decimal(_ value: Double, compact: Bool) -> String {
        if compact, abs(value) >= 10_000 {
            return value.compact
        }
        if value.rounded() == value {
            return Int(value).formatted(.number.locale(Locale(identifier: "en_US")))
        }
        return value.decimal
    }
}
