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
        .task {
            await provider.fetchIfNeeded(in: database)
        }

        HomeLogRow(
            title: "Events",
            image: "list.bullet",
            color: .blue,
            count: intSpan?.total { $0 != CrashObject.recordType },
            destination: { AnalyticsView() }
        )
        HomeLogRow(
            title: "Metrics",
            image: "chart.bar",
            color: .blue,
            count: metricsCount,
            destination: { MetricsList() }
        )
        HomeLogRow(
            title: "Crashes",
            image: "exclamationmark.triangle",
            color: .red,
            count: intSpan?.total { $0 == CrashObject.recordType },
            destination: { CrashListView() }
        )
    }

    private var intSpan: MatrixSpan<Int>? {
        guard let result = try? provider.result?.get() else {
            return nil
        }
        return MatrixSpan(matrices: result.0, range: period.initialRange)
    }

    private var metricsCount: Int? {
        guard let result = try? provider.result?.get() else {
            return nil
        }

        let int = MatrixSpan(matrices: result.0, range: period.initialRange)
        let double = MatrixSpan(matrices: result.1, range: period.initialRange)

        return int.series + double.series
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        List {
            HomeLogSection()
        }
        .listStyle(.plain)
    }
}
