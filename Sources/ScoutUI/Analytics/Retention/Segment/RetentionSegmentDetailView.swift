//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Charts
import Scout
import SwiftUI

struct RetentionSegmentDetailView: View {
    let segment: RetentionSegment
    let cohort: RetentionCohort

    var body: some View {
        InsetList {
            VStack(alignment: .leading, spacing: 4) {
                Text(verbatim: "\(segment.size) installs · week of \(cohort.label)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Chart {
                    ForEach(Array(zip(RetentionCohort.dayOffsets, cohort.retention)), id: \.0) { day, rate in
                        if let rate {
                            LineMark(
                                x: .value("Day", day),
                                y: .value("Cohort", rate),
                                series: .value("Series", "Cohort")
                            )
                            .foregroundStyle(Color(.systemGray4))
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [4, 3]))
                            .interpolationMethod(.monotone)
                        }
                    }

                    ForEach(Array(zip(RetentionCohort.dayOffsets, segment.retention)), id: \.0) { day, rate in
                        if let rate {
                            LineMark(
                                x: .value("Day", day),
                                y: .value("Segment", rate),
                                series: .value("Series", "Segment")
                            )
                            .foregroundStyle(.orange)
                            .lineStyle(StrokeStyle(lineWidth: 2.5))
                            .interpolationMethod(.monotone)

                            PointMark(
                                x: .value("Day", day),
                                y: .value("Segment", rate)
                            )
                            .foregroundStyle(.orange)
                            .symbolSize(30)
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        if let rate = value.as(Double.self) {
                            AxisValueLabel(rate.formatted(.retentionRate))
                        }
                    }
                }
                .aspectRatio(1.618, contentMode: .fit)
                .padding(.top, 8)

                legend

                if let comparison = RetentionComparison(segment: segment, cohort: cohort) {
                    Text(verbatim: comparison.text).font(.caption).foregroundStyle(.secondary)
                }
            }
            .padding(.top)
            .listRowSeparator(.hidden)

            Header(title: "Stability")

            HStack(spacing: 24) {
                RetentionStabilityStat(incident: .crash, count: segment.crashes, size: segment.size)
                RetentionStabilityStat(incident: .hang, count: segment.hangs, size: segment.size)
            }
            .padding(.top, 8)
            .listRowSeparator(.hidden, edges: .bottom)
        }
        .navigationTitle(en: segment.name)
    }

    private var legend: some View {
        HStack(spacing: 16) {
            RetentionLegendItem(color: .orange, dashed: false, title: segment.name)
            RetentionLegendItem(color: Color(.systemGray4), dashed: true, title: "Cohort")
        }
    }
}

#Preview("RetentionSegmentDetailView") {
    let cohort = RetentionCohort.samples[0]

    NavigationStack {
        RetentionSegmentDetailView(segment: cohort.segments[2], cohort: cohort)
    }
}
