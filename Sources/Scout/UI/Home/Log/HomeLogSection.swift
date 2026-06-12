//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

/// The Log section of the Home screen: a header with a compact period
/// picker and a row per log destination, each counting its entries within
/// the selected period.
///
struct HomeLogSection: View {
    @Environment(\.database) var database

    @State private var period = Period.today

    @StateObject private var provider = HomeLogProvider()

    var body: some View {
        Header(title: "Log") {
            CompactPeriodPicker(selection: $period)
        }
        .task {
            await provider.fetchIfNeeded(in: database)
        }

        row(title: "Events", systemImage: "list.bullet", color: .blue, count: summary?.eventCount(in: range)) {
            AnalyticsView()
        }
        row(title: "Metrics", systemImage: "chart.bar", color: .blue, count: summary?.metricCount(in: range)) {
            MetricsList().navigationTitle(en: "Metrics")
        }
        row(title: "Crashes", systemImage: "exclamationmark.triangle", color: .red, count: summary?.crashCount(in: range)) {
            CrashListView()
        }
    }

    /// All fetched matrices; `nil` while the provider is still loading.
    private var summary: HomeLogSummary? {
        try? provider.result?.get()
    }

    private var range: Range<Date> {
        period.initialRange
    }

    private func row(title: String, systemImage: String, color: Color, count: Int?, @ViewBuilder destination: @escaping () -> some View) -> some View {
        Row {
            Image(systemName: systemImage)
                .foregroundColor(color)
                .frame(width: 24)
            Text(verbatim: title)
            Spacer()
            RedactedText(count: count)
                .foregroundStyle(color)
                .frame(minWidth: RowSummary.countWidth, alignment: .trailing)
        } destination: {
            destination()
        }
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
