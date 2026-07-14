//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

enum LogCategory: String, CaseIterable, Identifiable {
    case events
    case metrics
    case network
    case devices
    case crashes
    case hangs

    var id: Self { self }

    var title: String {
        switch self {
        case .events:
            "Events"
        case .metrics:
            "Metrics"
        case .network:
            "Network"
        case .devices:
            "Devices"
        case .crashes:
            "Crashes"
        case .hangs:
            "Hangs"
        }
    }

    var systemImage: String {
        switch self {
        case .events:
            "list.bullet"
        case .metrics:
            "chart.bar"
        case .network:
            "network"
        case .devices:
            "iphone"
        case .crashes:
            "exclamationmark.triangle"
        case .hangs:
            "hourglass"
        }
    }

    var color: Color {
        switch self {
        case .events, .metrics:
            .blue
        case .network:
            .teal
        case .devices:
            .cyan
        case .crashes:
            .red
        case .hangs:
            .orange
        }
    }
}

struct LogDestination: View {
    let category: LogCategory

    var body: some View {
        switch category {
        case .events:
            AnalyticsView()
        case .metrics:
            MetricsList().navigationTitle(en: "Metrics")
        case .network:
            NetworkView()
        case .devices:
            DevicesView()
        case .crashes:
            CrashListView()
        case .hangs:
            HangListView()
        }
    }
}
