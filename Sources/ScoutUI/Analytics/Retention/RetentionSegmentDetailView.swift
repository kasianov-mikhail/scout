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

    private var crashMultiplier: Double {
        let others = cohort.segments.filter { $0.name != segment.name }
        let baseline = others.map(\.crashRate).reduce(0, +) / Double(max(others.count, 1))
        guard baseline > 0 else { return 1 }
        return segment.crashRate / baseline
    }

    var body: some View {
        List {
            VStack(alignment: .leading, spacing: 4) {
                Text(verbatim: "Week of \(cohort.label)").font(.caption).foregroundStyle(.secondary)

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

            Header(title: "Stability")

            HStack(spacing: 24) {
                stabilityStat(title: "Crashes", value: segment.crashRate, color: .red)
                stabilityStat(title: "Hangs", value: segment.hangRate, color: .orange)
            }
            .listRowSeparator(.hidden)

            if crashMultiplier > 1.2 {
                Text(
                    verbatim:
                        "\(crashMultiplier.formatted(numberFormatStyle))× the crash rate of other versions in this cohort"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .navigationTitle(en: segment.name)
    }

    private var legend: some View {
        HStack(spacing: 16) {
            RetentionLegendItem(color: .orange, dashed: false, title: segment.name)
            RetentionLegendItem(color: Color(.systemGray4), dashed: true, title: "Cohort")
        }
    }

    private func stabilityStat(title: String, value: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(verbatim: title.uppercased()).font(.caption2).foregroundStyle(.secondary)
            Text(verbatim: "\(value.formatted(numberFormatStyle))%")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private let numberFormatStyle = FloatingPointFormatStyle<Double>(locale: Locale(identifier: "en_US"))
    .precision(.fractionLength(1))

#Preview("RetentionSegmentDetailView") {
    let cohort = RetentionCohort.samples[0]

    NavigationStack {
        RetentionSegmentDetailView(segment: cohort.segments[2], cohort: cohort)
    }
}
