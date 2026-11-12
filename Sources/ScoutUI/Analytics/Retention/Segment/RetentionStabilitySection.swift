//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct RetentionStabilitySection: View {
    let crash: RetentionIncidentValue
    let hang: RetentionIncidentValue

    var body: some View {
        HStack(spacing: 0) {
            stat(value: crash)
                .overlay(alignment: .trailing) {
                    Separator(axis: .vertical)
                }

            stat(value: hang)
                .padding(.leading, .space12)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)
        }
    }

    private func stat(value: RetentionIncidentValue) -> some View {
        VStack(alignment: .leading, spacing: .space2) {
            HStack(alignment: .firstTextBaseline, spacing: .space6) {
                Text(verbatim: value.rateLabel)
                    .font(.scoutNumberL)
                    .foregroundStyle(value.color)

                Text(verbatim: value.countLabel)
                    .font(.scoutCaption)
                    .foregroundStyle(Color.textMuted)
            }
            .frame(height: 31)

            Text(verbatim: value.subtitle)
                .font(.scoutCaption)
                .foregroundStyle(Color.textMuted)
        }
        .padding(.vertical, .space12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    let cohort = RetentionCohort.samples[0]
    let segment = cohort.segments[2]
    let detail = RetentionSegmentDetail(segment: segment, cohort: cohort, cohorts: .samples, now: Date())

    ScrollView {
        LazyVStack(alignment: .leading, spacing: 0) {
            RetentionStabilitySection(crash: detail.crash, hang: detail.hang)
        }
        .padding(.horizontal, .gutter)
    }
    .scrollIndicators(.hidden)
}
