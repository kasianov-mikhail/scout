//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct RetentionCohortDetailView: View {
    let cohort: RetentionCohort
    let cohorts: [RetentionCohort]

    var body: some View {
        let detail = RetentionCohortDetail(cohort: cohort, cohorts: cohorts, now: Date())

        InsetList {
            RetentionHero(value: detail.installsLabel, subtitle: detail.subtitle)
                .frame(minHeight: 44)

            RetentionSection(title: "Come back on", note: detail.averageNote, divider: true)

            ForEach(Array(detail.days.enumerated()), id: \.element.id) { index, day in
                RetentionDayRow(value: day, showsDivider: index < detail.days.count - 1)
                    .frame(minHeight: 44)
            }

            if !detail.segments.isEmpty {
                RetentionSection(title: "By OS version", note: "day 7")

                ForEach(Array(detail.segments.enumerated()), id: \.element.id) { index, segment in
                    Row {
                        RetentionSegmentRow(value: segment, showsDivider: index < detail.segments.count - 1)
                    } destination: {
                        RetentionSegmentDetailView(segment: segment.segment, cohort: cohort, cohorts: cohorts)
                    }
                }
            }
        }
        .navigationTitle(en: "Week of \(cohort.label)")
        .inlineNavigationTitle()
    }
}

private struct RetentionSegmentRow: View {
    let value: RetentionSegmentValue
    let showsDivider: Bool

    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: value.name)
                    .font(.system(size: 15))

                HStack(spacing: 0) {
                    Text(verbatim: "\(value.installsLabel) · ")
                        .foregroundStyle(Color(.systemGray))

                    Text(verbatim: value.crashRateLabel)
                        .foregroundStyle(Color.crashText)

                    Text(verbatim: " crashed")
                        .foregroundStyle(Color(.systemGray))
                }
                .font(.system(size: 12))
            }

            Spacer(minLength: 0)

            RetentionValueLabel(kept: value.keptLabel, rate: value.rateLabel, pending: value.pendingLabel)
                .frame(width: 76, alignment: .trailing)
        }
        .padding(.vertical, 6)
        .frame(minHeight: 52)
        .overlay(alignment: .bottom) {
            if showsDivider {
                DashedLine()
            }
        }
    }
}

#Preview("RetentionCohortDetailView") {
    NavigationStack {
        RetentionCohortDetailView(cohort: RetentionCohort.samples[0], cohorts: .samples)
    }
}
