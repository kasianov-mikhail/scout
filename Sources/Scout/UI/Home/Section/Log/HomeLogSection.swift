//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeLogSection: View {
    @Environment(\.database) var database
    @StateObject var provider = HomeLogProvider()

    var body: some View {
        Header(title: "Log") {
            CompactPeriodPicker(selection: $provider.period)
        }
        .task(id: provider.period) {
            await provider.fetchIfNeeded(in: database)
        }

        let logSpans = logSpans

        HomeLogRow(
            title: "Events",
            image: "list.bullet",
            color: .blue,
            count: logSpans?.int.total { $0 != CrashObject.recordType && $0 != HangObject.recordType },
            destination: { AnalyticsView() }
        )

        HomeLogRow(
            title: "Metrics",
            image: "chart.bar",
            color: .blue,
            count: logSpans.map { $0.int.series + $0.double.series },
            destination: { MetricsList().navigationTitle(en: "Metrics") }
        )

        Row {
            Image(systemName: "network").foregroundColor(.blue).frame(width: 24)
            Text(verbatim: "Network")
            Spacer()
        } destination: {
            NetworkView()
        }

        HomeLogRow(
            title: "Crashes",
            image: "exclamationmark.triangle",
            color: .red,
            count: logSpans?.int.total { $0 == CrashObject.recordType },
            destination: { CrashListView() }
        )

        HomeLogRow(
            title: "Hangs",
            image: "hourglass",
            color: .orange,
            count: logSpans?.int.total { $0 == HangObject.recordType },
            destination: { HangListView() }
        )
    }

    private var logSpans: (int: MatrixSpan<Int>, double: MatrixSpan<Double>)? {
        guard let result = try? provider.result?.get() else {
            return nil
        }

        return (
            MatrixSpan(matrices: result.0, range: provider.period.initialRange),
            MatrixSpan(matrices: result.1, range: provider.period.initialRange)
        )
    }
}

#Preview {
    @MainActor func makeProvider() -> HomeLogProvider {
        let provider = HomeLogProvider()
        let initialPeriod = provider.period

        for period in Period.allCases {
            provider.period = period
            provider.result = .success(HomeLogProvider.sample(for: period))
        }

        provider.period = initialPeriod
        return provider
    }

    return NavigationStack {
        List {
            HomeLogSection(provider: makeProvider())
        }
        .listStyle(.plain)
    }
}
