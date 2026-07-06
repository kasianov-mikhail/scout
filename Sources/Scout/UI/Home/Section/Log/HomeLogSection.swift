//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeLogSection: View {
    @AppStorage("scout_home_log_period") private var period: Period = .today
    @StateObject private var provider: HomeLogProvider

    init(provider: HomeLogProvider = HomeLogProvider()) {
        self._provider = StateObject(wrappedValue: provider)
    }

    var body: some View {
        Header(title: "Log") {
            CompactPeriodPicker(selection: $period)
        }

        let logSpans = logSpans

        HomeLogRow(
            title: "Events",
            image: "list.bullet",
            color: .blue,
            count: logSpans?.int.total { $0 != CrashObject.recordType },
            destination: { AnalyticsView() }
        )

        HomeLogRow(
            title: "Metrics",
            image: "chart.bar",
            color: .blue,
            count: logSpans.map { $0.int.series + $0.double.series },
            destination: { MetricsList() }
        )

        Row {
            Image(systemName: "network")
                .foregroundColor(.blue)
                .frame(width: 24)
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
    }

    private var logSpans: (int: MatrixSpan<Int>, double: MatrixSpan<Double>)? {
        guard let result = try? provider.result(for: period)?.get() else {
            return nil
        }
        return (
            MatrixSpan(matrices: result.0, range: period.initialRange),
            MatrixSpan(matrices: result.1, range: period.initialRange)
        )
    }
}

#Preview {
    NavigationStack {
        List {
            HomeLogSection(provider: .fixture())
        }
        .listStyle(.plain)
    }
}
