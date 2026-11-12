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

    @StateObject var provider: HomeLogProvider

    private let columns = [
        GridItem(.flexible(), spacing: .space24),
        GridItem(.flexible(), spacing: .space24),
    ]

    init(period: Period, provider: HomeLogProvider? = nil) {
        _period = State(initialValue: period)
        _provider = StateObject(wrappedValue: provider ?? HomeLogProvider(period: period))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: .space24) {
                SegmentStrip(selection: $period, distribution: .justified, title: \.shortTitle)

                if let error = provider.error {
                    ErrorView(description: error.localizedDescription) {
                        await provider.fetchAgain(in: database)
                    }
                } else {
                    LazyVGrid(columns: columns, spacing: .space24) {
                        ForEach(LogCategory.allCases) { category in
                            NavigationLink {
                                LogDestination(category: category)
                            } label: {
                                TrendCard(category: category, trend: provider.report?[category] ?? .loading)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.space16)
        }
        .scrollIndicators(.hidden)
        .task(id: period) {
            provider.period = period
            await provider.fetchIfNeeded(in: database)
        }
        .navigationTitle(en: "Log")
    }
}

extension TrendCard {
    fileprivate init(category: LogCategory, trend: Trend) {
        self.init(
            title: category.title,
            color: category.color,
            trend: trend,
            risesAreBad: category.risesAreBad
        )
    }
}

#Preview {
    NavigationStack {
        LogView(
            period: .week,
            provider: HomeLogProvider(acrossAllPeriods: .sample(for: .week))
        )
    }
}
