//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct MetricTile: Identifiable {
    let name: String
    let telemetry: Telemetry.Export
    let value: Double
    let series: [Double]

    var id: String { "\(telemetry.rawValue).\(name)" }

    var suffix: String {
        switch telemetry {
        case .counter, .floatingCounter:
            "total"
        case .timer, .recorder:
            "p50"
        case .meter:
            "latest"
        }
    }

    var valueLabel: String {
        MetricValueFormat(telemetry: telemetry).label(value, compact: true)
    }

    var displayName: String {
        name.replacingOccurrences(of: ".", with: ".\u{200B}")
    }
}
