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
        ReadoutTabStrip(
            values: ActivityPeriod.allCases,
            isSelected: { $0 == selection },
            isLoading: false,
            spacing: .space12,
            onSelect: { selection = $0 },
            indicator: { _ in
                Rectangle()
                    .fill(Color.fillSuccess)
                    .frame(height: 2)
            }
        ) { period, isActive in
            cell(period: period, isActive: isActive)
        }
    }

    private func cell(period: ActivityPeriod, isActive: Bool) -> some View {
        let metric = series.summary(period: period)

        return VStack(alignment: .leading, spacing: .space2) {
            Text(verbatim: period.rawValue)
                .font(.scoutCaptionStrong)
                .foregroundStyle(isActive ? Color.textPrimary : Color.textMuted)

            Text(verbatim: metric.valueLabel)
                .font(.scoutNumberL)
                .monospacedDigit()
                .foregroundStyle(isActive ? Color.textPrimary : Color.inactiveValue)
                .frame(height: 33)

            Text(verbatim: metric.deltaLabel(precision: 1))
                .font(.scoutCaption)
                .foregroundStyle(metric.isRising ? Color.trendPositive : Color.textMuted)
        }
        .padding(.top, .space10)
        .padding(.bottom, .space12)
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ActivityMetricTabs(
                    series: ActivitySeries(
                        points: ActivityPoint.samples,
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
