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
        HStack(alignment: .top, spacing: 12) {
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

        return VStack(alignment: .leading, spacing: 2) {
            Text(verbatim: period.rawValue)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(isSelected ? Color.primary : Color(.systemGray))

            Text(verbatim: metric.valueLabel)
                .font(.system(size: 28, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(isSelected ? Color.primary : Color.inactiveValue)
                .frame(height: 33, alignment: .leading)

            Text(verbatim: metric.deltaLabel(precision: 1))
                .font(.book(size: 13))
                .foregroundStyle(metric.isRising ? Color.trendPositive : Color(.systemGray))
        }
        .padding(.top, 10)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) {
            if isSelected {
                Rectangle()
                    .fill(Color.green)
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
            .padding(.horizontal, 16)
        }
        .scrollIndicators(.hidden)
    }
}
