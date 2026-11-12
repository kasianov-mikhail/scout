//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import SwiftUI

struct TelemetryItem: Identifiable {
    enum Kind: Hashable {
        case events
        case crashes
        case metrics
        case hangs
        case network
        case resources

        var title: String {
            switch self {
            case .events: "Events"
            case .crashes: "Crashes"
            case .metrics: "Metrics"
            case .hangs: "Hangs"
            case .network: "Network"
            case .resources: "Resources"
            }
        }

        var systemImage: String {
            switch self {
            case .events: "list.bullet"
            case .crashes: "exclamationmark.triangle"
            case .metrics: "chart.bar"
            case .hangs: "hourglass"
            case .network: "globe"
            case .resources: "speedometer"
            }
        }

        var color: Color {
            switch self {
            case .events, .metrics: .blue
            case .crashes: .red
            case .hangs: .orange
            case .network: .teal
            case .resources: .indigo
            }
        }
    }

    let kind: Kind
    let value: Int
    let caption: String

    var id: Kind { kind }

    var valueLabel: String {
        value.formatted(.number.locale(Locale(identifier: "en_US")))
    }
}

extension [TelemetryItem] {
    var hasValues: Bool {
        contains { $0.value > 0 }
    }
}

extension TelemetryItem {
    static let sample: [TelemetryItem] = [
        TelemetryItem(kind: .events, value: 48, caption: "41 yesterday"),
        TelemetryItem(kind: .crashes, value: 3, caption: "2 groups"),
        TelemetryItem(kind: .metrics, value: 140, caption: "5 kinds"),
        TelemetryItem(kind: .hangs, value: 6, caption: "max 8.2 s"),
        TelemetryItem(kind: .network, value: 212, caption: "p99 840 ms"),
        TelemetryItem(kind: .resources, value: 2, caption: "in 365 days"),
    ]
}
