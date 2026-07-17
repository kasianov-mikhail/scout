//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Charts
import SwiftUI

struct RetentionHeroChartView: View {
    @ObservedObject var provider: RetentionProvider

    var body: some View {
        ProviderView(provider: provider) { cohorts in
            if cohorts.count > 0 {
                RetentionHeroChart(cohorts: cohorts)
            } else {
                Placeholder(
                    text: "No cohorts",
                    systemImage: "person.2",
                    description: "Retention appears once installs start returning"
                )
            }
        }
        .navigationTitle(en: "Retention")
    }
}

private struct RetentionHeroChart: View {
    let cohorts: [RetentionCohort]

    private var stats: [RetentionCohort.DayStat] {
        RetentionCohort.stats(for: cohorts)
    }

    var body: some View {
        List {
            VStack(alignment: .leading, spacing: 4) {
                Text(verbatim: "Average Retention").font(.headline)
                Text(verbatim: "Across \(cohorts.count) weekly cohorts").font(.caption).foregroundStyle(.secondary)

                Chart(stats) { stat in
                    AreaMark(
                        x: .value("Day", stat.day),
                        yStart: .value("Low", stat.low),
                        yEnd: .value("High", stat.high)
                    )
                    .foregroundStyle(Color.green.opacity(0.15))
                    .interpolationMethod(.monotone)

                    LineMark(
                        x: .value("Day", stat.day),
                        y: .value("Average", stat.average)
                    )
                    .foregroundStyle(.green)
                    .lineStyle(StrokeStyle(lineWidth: 2.5))
                    .interpolationMethod(.monotone)

                    PointMark(
                        x: .value("Day", stat.day),
                        y: .value("Average", stat.average)
                    )
                    .foregroundStyle(.green)
                    .symbolSize(30)
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        if let rate = value.as(Double.self) {
                            AxisValueLabel(
                                rate.formatted(.retentionRate))
                        }
                    }
                }
                .aspectRatio(1.618, contentMode: .fit)
                .padding(.top, 8)
            }
            .listRowSeparator(.hidden)

            Header(title: "By Cohort")

            ForEach(cohorts.reversed()) { cohort in
                NavigationLink {
                    RetentionCohortDetailView(cohort: cohort, cohorts: cohorts)
                } label: {
                    HStack {
                        Text(verbatim: "Week of \(cohort.label)").font(.subheadline)
                        Spacer()
                        Text(verbatim: "\(cohort.size)").font(.caption).foregroundStyle(.secondary)

                        if let day7 = RetentionCohort.rate(cohort.retention, onDay: 7) {
                            Text(
                                verbatim:
                                    "D7 \(day7.formatted(.retentionRate))"
                            )
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.green)
                            .frame(width: 72, alignment: .trailing)
                        } else {
                            Text(verbatim: "—")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                                .frame(width: 72, alignment: .trailing)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}

#Preview("RetentionHeroChartView") {
    let provider = RetentionProvider()
    provider.result = .success(.samples)

    return NavigationStack {
        RetentionHeroChartView(provider: provider)
    }
}
