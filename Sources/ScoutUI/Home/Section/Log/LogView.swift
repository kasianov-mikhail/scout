//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct LogView: View {
    @Environment(\.database) var database

    @State var period: Period

    @ObservedObject var log: HomeLogProvider

    private let columns = [
        GridItem(.flexible(), spacing: 24),
        GridItem(.flexible(), spacing: 24),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                SegmentStrip(selection: $period, distribution: .justified, title: \.shortTitle)

                if let error = log.error {
                    ErrorView(description: error.localizedDescription) {
                        await log.fetchAgain(in: database)
                    }
                } else {
                    LazyVGrid(columns: columns, spacing: 36) {
                        ForEach(LogCategory.allCases) { category in
                            NavigationLink {
                                LogDestination(category: category)
                            } label: {
                                TrendCard(
                                    title: category.title,
                                    color: category.color,
                                    trend: log.report?[category] ?? .loading,
                                    risesAreBad: category.risesAreBad
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(16)
        }
        .task(id: period) {
            log.period = period
            await log.fetchIfNeeded(in: database)
        }
        .refreshOnPull([log])
        .navigationTitle(en: "Log")
    }
}

#Preview {
    NavigationStack {
        LogView(
            period: .week,
            log: .init(acrossAllPeriods: .sample(for: .week))
        )
    }
}
