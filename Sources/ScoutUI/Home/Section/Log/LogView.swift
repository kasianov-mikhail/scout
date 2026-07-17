//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ScoutCore
import SwiftUI

struct LogView: View {
    @Environment(\.database) var database

    @State var period: Period

    @ObservedObject var log: HomeLogProvider
    @ObservedObject var devices: DevicesProvider

    private let columns = [
        GridItem(.flexible(), spacing: 24),
        GridItem(.flexible(), spacing: 24),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                SegmentStrip(selection: $period, distribution: .justified, title: \.shortTitle)

                LazyVGrid(columns: columns, spacing: 36) {
                    ForEach(LogCategory.allCases) { category in
                        NavigationLink {
                            LogDestination(category: category)
                        } label: {
                            MetricCard(
                                title: category.title,
                                color: category.color,
                                summary: report?.summary(for: category) ?? .loading
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
        }
        .task(id: period) {
            log.period = period
            await log.fetchIfNeeded(in: database)
        }
        .navigationTitle(en: "Log")
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
    let log = HomeLogProvider()
    log.period = .week
    log.result = .success(HomeLogProvider.sample(for: .week))

    let devices = DevicesProvider()
    devices.result = .success(.sample)

    return NavigationStack {
        LogView(period: .week, log: log, devices: devices)
    }
}
