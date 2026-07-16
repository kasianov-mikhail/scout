//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeLogSection: View {
    @Environment(\.database) var database

    let period: Period

    @ObservedObject var log: HomeLogProvider
    @ObservedObject var devices: DevicesProvider

    @Binding var path: [HomeDestination]

    var body: some View {
        Header(title: "Log") {
            AllButton { path.append(.log) }
        }
        .task(id: period) {
            log.period = period
            await log.fetchIfNeeded(in: database)
        }

        let report = report

        ForEach(Array(LogCategory.allCases.enumerated()), id: \.element) { index, category in
            Row {
                Image(systemName: category.systemImage)
                    .foregroundColor(category.color)
                    .frame(width: 24)
                Text(verbatim: category.title)
                Spacer()
                RedactedText(count: report?.summary(for: category).count)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(minWidth: RowSummary.countWidth, alignment: .trailing)
            } destination: {
                LogDestination(category: category)
            }
        }
    }

    private var report: LogReport? {
        guard let series = try? log.result?.get() else {
            return nil
        }
        return LogReport(
            series: series,
            visits: (try? devices.result?.get().visits) ?? [],
            period: period
        )
    }
}

#Preview {
    @MainActor func makeLog() -> HomeLogProvider {
        let provider = HomeLogProvider()

        for period in Period.allCases {
            provider.period = period
            provider.result = .success(HomeLogProvider.sample(for: period))
        }

        provider.period = .today
        return provider
    }

    let devices = DevicesProvider()
    devices.result = .success(.sample)

    return NavigationStack {
        List {
            HomeLogSection(
                period: .today,
                log: makeLog(),
                devices: devices,
                path: .constant([])
            )
        }
        .listStyle(.plain)
    }
}
