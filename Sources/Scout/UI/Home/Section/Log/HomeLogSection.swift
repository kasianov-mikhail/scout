//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeLogSection: View {
    @Environment(\.database) var database
    @StateObject var log = HomeLogProvider()
    @StateObject var devices = DevicesProvider()

    var body: some View {
        Header(title: "Log") {
            CompactPeriodPicker(selection: $log.period)
        }
        .task(id: log.period) {
            await log.fetchIfNeeded(in: database)
        }

        let logSpans = logSpans

        HomeLogRow(
            title: "Events",
            image: "list.bullet",
            color: .blue,
            count: logSpans?.int.total { $0 != CrashEntry.recordType && $0 != HangEntry.recordType },
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
            title: "Devices",
            image: "iphone",
            color: .blue,
            count: deviceCount,
            destination: { DevicesView() }
        )
        .task {
            await devices.fetchIfNeeded(in: database)
        }

        HomeLogRow(
            title: "Crashes",
            image: "exclamationmark.triangle",
            color: .red,
            count: logSpans?.int.total { $0 == CrashEntry.recordType },
            destination: { CrashListView() }
        )

        HomeLogRow(
            title: "Hangs",
            image: "hourglass",
            color: .orange,
            count: logSpans?.int.total { $0 == HangEntry.recordType },
            destination: { HangListView() }
        )
    }

    private var logSpans: (int: MatrixSpan<Int>, double: MatrixSpan<Double>)? {
        guard let result = try? log.result?.get() else {
            return nil
        }

        return (
            MatrixSpan(matrices: result.0, range: log.period.initialRange),
            MatrixSpan(matrices: result.1, range: log.period.initialRange)
        )
    }

    private var deviceCount: Int? {
        try? devices.result?.get().count
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

    let devices = DevicesProvider()
    devices.result = .success(.samples)

    return NavigationStack {
        List {
            HomeLogSection(log: makeProvider(), devices: devices)
        }
        .listStyle(.plain)
    }
}
