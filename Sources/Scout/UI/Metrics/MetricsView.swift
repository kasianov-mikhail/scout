//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

enum MetricsType: CaseIterable, Identifiable {
    case intCounter
    case doubleCounter
    case timer

    var id: Self { self }

    var title: String {
        switch self {
        case .intCounter:
            "Int Counter"
        case .doubleCounter:
            "Double Counter"
        case .timer:
            "Timer"
        }
    }

    var shortTitle: String {
        switch self {
        case .intCounter:
            "Int"
        case .doubleCounter:
            "Double"
        case .timer:
            "Timer"
        }
    }
}

struct MetricsView: View {
    @ObservedObject var metrics: MetricsProvider
    @State private var metricsType: MetricsType = .intCounter

    var body: some View {
        Group {
            Picker("Metrics Type", selection: $metricsType) {
                ForEach(MetricsType.allCases) { type in
                    Text(type.shortTitle.uppercased())
                }
            }
            .padding(.horizontal)
            .pickerStyle(.segmented)

            if let data = metrics.data {
                if data.isEmpty {
                    Placeholder(text: "No results").frame(maxHeight: .infinity)
                } else {
                    list(data: data)
                }
            } else {
                ProgressView().frame(maxHeight: .infinity)
            }
        }
        .navigationTitle("Metrics")
    }

    func list(data: [String]) -> some View {
        return List(data, id: \.self) { metric in
            Row {
                Text(metric)
                    .monospaced()
                    .font(.system(size: 17))
                    .lineLimit(1)
                Spacer()
            } destination: {
                EmptyView()
            }
        }
        .listStyle(.plain)
        .frame(maxHeight: .infinity)
    }
}

#Preview {
    NavigationStack {
        let metrics = MetricsProvider()
        metrics.data = [
            "CPU Usage",
            "Memory Allocated",
            "Disk Writes",
            "Network Throughput",
            "Cache Hits",
            "Database Queries",
            "API Latency",
            "Page Load Time",
            "Frame Rate",
            "Error Count",
            "Active Users",
            "Session Duration",
            "Background Tasks",
            "Power Consumption",
            "Thread Count",
        ]
        return MetricsView(metrics: metrics)
    }
}
