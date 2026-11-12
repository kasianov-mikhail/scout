//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct RetentionSegmentDetailView: View {
    let segment: RetentionSegment
    let cohort: RetentionCohort
    let cohorts: [RetentionCohort]

    var body: some View {
        let detail = RetentionSegmentDetail(segment: segment, cohort: cohort, cohorts: cohorts, now: Date())

        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                RetentionHero(value: detail.installsLabel, subtitle: detail.subtitle)

                RetentionSection(title: "Come back on", note: "whole week", divider: true)

                ForEach(Array(detail.days.enumerated()), id: \.element.id) { index, day in
                    RetentionDayRow(value: day, showsDivider: index < detail.days.count - 1)
                }

                RetentionSection(title: "Stability")

                RetentionStabilitySection(crash: detail.crash, hang: detail.hang)

                if !detail.weeks.isEmpty {
                    RetentionSection(title: "\(segment.name) by week", note: "day 7")

                    ForEach(Array(detail.weeks.enumerated()), id: \.element.id) { index, week in
                        RetentionSegmentWeekRow(week: week, showsDivider: index < detail.weeks.count - 1)
                    }

                    Color.clear
                        .frame(height: 24)
                }
            }
            .padding(.horizontal, 16)
        }
        .scrollIndicators(.hidden)
        .navigationTitle(en: segment.name)
        .inlineNavigationTitle()
    }
}

private struct RetentionSegmentWeekRow: View {
    let week: RetentionSegmentWeek
    let showsDivider: Bool

    var body: some View {
        HStack(spacing: 8) {
            Text(verbatim: week.dateLabel)
                .font(week.isCurrent ? .system(size: 15, weight: .semibold) : .weight450(size: 15))
                .frame(width: 64, alignment: .leading)

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(.systemGray5))

                    LeftRoundedRectangle(cornerRadius: 3)
                        .fill(week.isCurrent ? Color.green : Color(.systemGray2))
                        .frame(width: proxy.size.width * week.fraction)
                }
            }
            .frame(height: 10)

            RetentionValueLabel(kept: week.keptLabel, rate: week.rateLabel, pending: nil)
                .frame(width: 76, alignment: .trailing)
        }
        .frame(height: 40)
        .overlay(alignment: .bottom) {
            if showsDivider {
                DashedLine()
            }
        }
    }
}

#Preview("RetentionSegmentDetailView") {
    let cohort = RetentionCohort.samples[0]

    NavigationStack {
        RetentionSegmentDetailView(segment: cohort.segments[2], cohort: cohort, cohorts: .samples)
    }
}
