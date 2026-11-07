//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct RetentionCohortDetailPlaceholder: View {
    let cohort: RetentionCohort
    let cohorts: [RetentionCohort]

    var body: some View {
        InsetList {
            RetentionHero(subtitle: "installs · \(cohort.weekRange)", placeholderWidth: 74)
                .listRowSeparator(.hidden)

            RetentionSection(title: "Come back on", note: "average of \(cohorts.matured.count) weeks", divider: true)
                .listRowSeparator(.hidden)

            ForEach(Array(RetentionDay.allCases.enumerated()), id: \.element) { index, day in
                dayRow(day: day, index: index)
                    .listRowSeparator(.hidden)
            }

            if !cohort.segments.isEmpty {
                RetentionSection(title: "By OS version", note: "day 7")
                    .listRowSeparator(.hidden)

                ForEach(0..<cohort.segments.count, id: \.self) { index in
                    segmentRow(index: index)
                        .listRowSeparator(.hidden)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Loading"))
    }

    private func dayRow(day: RetentionDay, index: Int) -> some View {
        let delay = 0.16 + Double(index) * 0.08

        return HStack(spacing: 8) {
            Text(verbatim: day.title)
                .font(.system(size: 15))
                .frame(width: 52, alignment: .leading)

            SkeletonBar(height: 18, delay: delay, fill: Color(.systemGray6))

            SkeletonBar(width: 74, height: 9, delay: delay)
                .frame(width: 76, alignment: .trailing)
        }
        .frame(height: 44)
        .overlay(alignment: .bottom) {
            if index < RetentionDay.allCases.count - 1 {
                DashedLine()
            }
        }
    }

    private func segmentRow(index: Int) -> some View {
        let delay = 0.56 + Double(index) * 0.08

        return HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                SkeletonBar(width: 46, height: 9, delay: delay)
                SkeletonBar(width: 120, height: 6, delay: delay)
            }

            Spacer(minLength: 0)

            SkeletonBar(width: 74, height: 9, delay: delay)
                .frame(width: 76, alignment: .trailing)
        }
        .padding(.vertical, 6)
        .frame(minHeight: 52)
        .overlay(alignment: .bottom) {
            if index < cohort.segments.count - 1 {
                DashedLine()
            }
        }
    }
}

#Preview("Retention cohort loading") {
    NavigationStack {
        RetentionCohortDetailPlaceholder(cohort: RetentionCohort.samples[0], cohorts: .samples)
            .navigationTitle(en: "Week of \(RetentionCohort.samples[0].label)")
            .inlineNavigationTitle()
    }
}
