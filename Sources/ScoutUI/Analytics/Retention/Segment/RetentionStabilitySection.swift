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
                .padding(.leading, 12)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)
        }
    }

    private func stat(value: RetentionIncidentValue) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(verbatim: value.rateLabel)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(value.color)

                Text(verbatim: value.countLabel)
                    .font(.book(size: 13))
                    .foregroundStyle(Color(.systemGray))
            }
            .frame(height: 31)

            Text(verbatim: value.subtitle)
                .font(.book(size: 13))
                .foregroundStyle(Color(.systemGray))
        }
        .padding(.vertical, 12)
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
        .padding(.horizontal, 16)
    }
    .scrollIndicators(.hidden)
}
