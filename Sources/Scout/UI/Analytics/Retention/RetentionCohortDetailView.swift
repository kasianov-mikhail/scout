//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Charts
import SwiftUI

struct RetentionCohortDetailView: View {
    let cohort: RetentionCohort
    let cohorts: [RetentionCohort]

    private var average: [RetentionCohort.DayStat] {
        RetentionCohort.stats(for: cohorts)
    }

    var body: some View {
        List {
            VStack(alignment: .leading, spacing: 4) {
                Text(verbatim: "\(cohort.size) installs").font(.caption).foregroundStyle(.secondary)

                Chart {
                    ForEach(average) { stat in
                        LineMark(
                            x: .value("Day", stat.day),
                            y: .value("Average", stat.average),
                            series: .value("Series", "Average")
                        )
                        .foregroundStyle(Color(.systemGray4))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [4, 3]))
                        .interpolationMethod(.monotone)
                    }

                    ForEach(Array(zip(RetentionCohort.dayOffsets, cohort.retention)), id: \.0) { day, rate in
                        if let rate {
                            LineMark(
                                x: .value("Day", day),
                                y: .value("Retention", rate),
                                series: .value("Series", "Cohort")
                            )
                            .foregroundStyle(.green)
                            .lineStyle(StrokeStyle(lineWidth: 2.5))
                            .interpolationMethod(.monotone)

                            PointMark(
                                x: .value("Day", day),
                                y: .value("Retention", rate)
                            )
                            .foregroundStyle(.green)
                            .symbolSize(30)
                        }
                    }
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

                legend
            }
            .listRowSeparator(.hidden)

            Header(title: "By OS Version")

            ForEach(cohort.segments) { segment in
                NavigationLink {
                    RetentionSegmentDetailView(segment: segment, cohort: cohort)
                } label: {
                    HStack {
                        Text(verbatim: segment.name).font(.subheadline)
                        Spacer()

                        HStack(spacing: 14) {
                            stat(day: 7, retention: segment.retention)
                            stat(day: 30, retention: segment.retention)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(en: "Week of \(cohort.label)")
    }

    private var legend: some View {
        HStack(spacing: 16) {
            RetentionLegendItem(color: .green, dashed: false, title: "This cohort")
            RetentionLegendItem(color: Color(.systemGray4), dashed: true, title: "Average")
        }
    }

    private func stat(day: Int, retention: [Double?]) -> some View {
        VStack(spacing: 2) {
            Text(verbatim: "D\(day)").font(.caption2).foregroundStyle(.secondary)
            Text(
                verbatim: RetentionCohort.rate(retention, onDay: day).map {
                    $0.formatted(.retentionRate)
                } ?? "—"
            )
            .font(.caption.weight(.semibold))
        }
        .frame(width: 40)
    }
}

#Preview("RetentionCohortDetailView") {
    NavigationStack {
        RetentionCohortDetailView(cohort: RetentionCohort.samples[0], cohorts: .samples)
    }
}
