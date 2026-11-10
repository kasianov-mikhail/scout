//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct RetentionDayTabs: View {
    let overview: RetentionOverview?
    @Binding var day: RetentionDay

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(RetentionDay.tabs.enumerated()), id: \.element) { index, item in
                Button {
                    day = item
                } label: {
                    cell(item, isFirst: index == 0, isLast: index == RetentionDay.tabs.count - 1)
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(item == day ? .isSelected : [])
            }
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)
        }
        .hapticFeedback(.selection, trigger: day)
    }

    private func cell(_ item: RetentionDay, isFirst: Bool, isLast: Bool) -> some View {
        let metric = overview?.metric(day: item)
        let isSelected = item == day

        return VStack(alignment: .leading, spacing: 3) {
            Text(verbatim: item.title)
                .font(isSelected ? .system(size: 13, weight: .semibold) : .weight450(size: 13))
                .foregroundStyle(isSelected ? Color.primary : Color(.systemGray))

            if let metric {
                Text(verbatim: metric.rateLabel)
                    .font(.system(size: 24, weight: .bold))
                    .monospacedDigit()
                    .frame(height: 26, alignment: .leading)

                Text(verbatim: metric.pointsLabel)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(metric.isRising ? Color.trendPositive : Color(.systemGray))
            } else {
                SkeletonBar(width: 46, height: 14, delay: 0.16)
                    .frame(height: 26, alignment: .leading)

                SkeletonBar(width: 28, height: 6, delay: 0.16)
                    .frame(height: 14, alignment: .leading)
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 14)
        .padding(.leading, isFirst ? 0 : 10)
        .padding(.trailing, isLast ? 0 : 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .trailing) {
            if !isLast {
                Rectangle()
                    .fill(Color.separator)
                    .frame(width: 0.5)
            }
        }
        .overlay(alignment: .bottom) {
            if isSelected {
                Rectangle()
                    .fill(metric == nil ? Color(.systemGray5) : Color.green)
                    .frame(height: 2)
                    .padding(.horizontal, 10)
            }
        }
    }
}

#Preview {
    InsetList {
        RetentionDayTabs(overview: RetentionOverview(cohorts: .samples), day: .constant(.day7))
            .frame(minHeight: 44)
        RetentionDayTabs(overview: nil, day: .constant(.day7))
            .frame(minHeight: 44)
    }
}
