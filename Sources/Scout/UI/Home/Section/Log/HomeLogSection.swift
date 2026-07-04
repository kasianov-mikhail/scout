//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeLogSection: View {
    @Environment(\.database) var database
    @AppStorage("scout_home_log_period") private var period: Period = .today
    @StateObject private var provider = HomeLogProvider()

    var body: some View {
        Header(title: "Log") {
            CompactPeriodPicker(selection: $period)
        }
        .task(id: period) {
            await provider.fetchIfNeeded(for: period, in: database)
        }

        if case .failure(let error) = provider.result(for: period) {
            ErrorView(description: Text(verbatim: error.localizedDescription)) {
                Task { await provider.fetchAgain(for: period, in: database) }
            }
            .listRowSeparator(.hidden)
        } else {
            logRows
        }
    }

    @ViewBuilder
    private var logRows: some View {
        HomeLogRow(
            title: "Events",
            image: "list.bullet",
            color: .blue,
            count: spans?.int.total { $0 != CrashObject.recordType },
            destination: { AnalyticsView() }
        )
        HomeLogRow(
            title: "Metrics",
            image: "chart.bar",
            color: .blue,
            count: spans.map { $0.int.series + $0.double.series },
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
            count: spans?.int.total { $0 == CrashObject.recordType },
            destination: { CrashListView() }
        )
    }

    private var spans: (int: MatrixSpan<Int>, double: MatrixSpan<Double>)? {
        guard let result = try? provider.result(for: period)?.get() else {
            return nil
        }

        let range = period.initialRange
        return (
            MatrixSpan(matrices: result.0, range: range),
            MatrixSpan(matrices: result.1, range: range)
        )
    }
}

#Preview {
    NavigationStack {
        List {
            HomeLogSection()
        }
        .listStyle(.plain)
    }
}
