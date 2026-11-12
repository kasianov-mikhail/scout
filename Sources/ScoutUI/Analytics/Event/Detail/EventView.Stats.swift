//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

extension EventView {
    struct StatSection: View {
        @Environment(\.database) private var database
        @ObservedObject var stat: StatProvider

        var body: some View {
            SectionHeader(title: "Stats") {
                Text(verbatim: "average per day")
                    .font(.scoutCaption)
                    .foregroundStyle(Color.textMuted)
            }

            switch stat.result {
            case .success(let points):
                let stats = EventStats(points: points)

                statRow(.today) {
                    TodayRow(stats: stats)
                }
                ForEach(stats.rows) { row in
                    statRow(row.period) {
                        PeriodRow(row: row, usualFraction: stats.usualFraction)
                    }
                }
                StatLegend(usual: EventStats.rateLabel(stats.usual))
            case .failure(let error):
                ErrorRow(description: error.localizedDescription) {
                    await stat.fetchAgain(in: database)
                }
                .overlay(alignment: .bottom) {
                    Separator()
                }
            case nil:
                TodayRow(stats: nil)
                ForEach(Array([Period.yesterday, .week, .month, .year].enumerated()), id: \.element) { index, period in
                    PeriodPlaceholder(period: period, delay: 0.8 + Double(index) * 0.08)
                }
                StatLegendPlaceholder()
            }
        }

        private func statRow(_ period: Period, @ViewBuilder content makeContent: () -> some View) -> some View {
            let content = makeContent()

            return NavigationLink {
                StatView(showList: true, extent: ChartExtent(period: period), stat: stat)
                    .navigationTitle(en: "Stats")
                    .largeNavigationTitle()
            } label: {
                content
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: .rowTable)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                EventView.StatSection(stat: StatProvider(.success(.samples), subject: .event("event_name")))
                EventView.StatSection(stat: StatProvider(subject: .event("event_name")))
            }
            .padding(.horizontal, .gutter)
        }
        .scrollIndicators(.hidden)
    }
}
