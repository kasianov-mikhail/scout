//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
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
                            TrendCard(
                                title: category.title,
                                color: category.color,
                                trend: log.report?.trend(for: category) ?? .loading
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
            log.visits = visits
            await log.fetchIfNeeded(in: database)
        }
        .onChange(of: visits) { log.visits = $0 }
        .navigationTitle(en: "Log")
    }

    private var visits: [DeviceVisit] {
        (try? devices.result?.get().visits) ?? []
    }
}

#Preview {
    NavigationStack {
        LogView(
            period: .week,
            log: .init().holding(acrossAllPeriods: MetricSeries.samples(for: .week)),
            devices: .init().holding(.sample)
        )
    }
}
