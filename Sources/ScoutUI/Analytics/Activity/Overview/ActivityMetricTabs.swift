//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct ActivityMetricTabs: View {
    let series: ActivitySeries
    @Binding var selection: ActivityPeriod

    var body: some View {
        HStack(alignment: .top, spacing: .space12) {
            ForEach(ActivityPeriod.allCases) { period in
                Button {
                    selection = period
                } label: {
                    cell(period: period)
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(period == selection ? .isSelected : [])
            }
        }
        .background(alignment: .bottom) {
            Separator()
        }
    }

    private func cell(period: ActivityPeriod) -> some View {
        let metric = series.summary(period: period)
        let isSelected = period == selection

        return VStack(alignment: .leading, spacing: .space2) {
            Text(verbatim: period.rawValue)
                .font(.scoutCaptionStrong)
                .foregroundStyle(isSelected ? Color.textPrimary : Color.textMuted)

            Text(verbatim: metric.valueLabel)
                .font(.scoutNumberL)
                .monospacedDigit()
                .foregroundStyle(isSelected ? Color.textPrimary : Color.inactiveValue)
                .frame(height: 33, alignment: .leading)

            Text(verbatim: metric.deltaLabel(precision: 1))
                .font(.scoutCaption)
                .foregroundStyle(metric.isRising ? Color.trendPositive : Color.textMuted)
        }
        .padding(.top, .space10)
        .padding(.bottom, .space12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) {
            if isSelected {
                Rectangle()
                    .fill(Color.fillSuccess)
                    .frame(height: 2)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ActivityMetricTabs(
                    series: ActivitySeries(
                        points: ActivityPoint.samples,
                        range: .month,
                        metric: .daily,
                        now: Date()
                    ),
                    selection: .constant(.daily)
                )
            }
            .padding(.horizontal, .gutter)
        }
        .scrollIndicators(.hidden)
    }
}
