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
        ReadoutTabStrip(
            values: RetentionDay.tabs,
            isSelected: { $0 == day },
            isLoading: overview == nil,
            spacing: 0,
            showsDividers: true,
            sitsOnSectionGap: true,
            onSelect: { day = $0 },
            indicator: { _ in
                let shape: AnyShape =
                    if #available(iOS 17.0, macOS 14.0, *) {
                        AnyShape(UnevenRoundedRectangle(topLeadingRadius: 1, topTrailingRadius: 1))
                    } else {
                        AnyShape(Rectangle())
                    }

                Rectangle()
                    .fill(Color.fillSuccess)
                    .frame(height: .ruleThick)
                    .clipShape(shape)
                    .padding(.horizontal, .space10)
            }
        ) { item, isActive in
            cell(item, isActive: isActive)
        }
        .hapticFeedback(.selection, trigger: day)
    }

    private func cell(_ item: RetentionDay, isActive: Bool) -> some View {
        let metric = overview?.metric(day: item)

        return VStack(alignment: .leading, spacing: .space2) {
            Text(verbatim: item.title)
                .font(isActive ? .scoutCaptionStrong : .scoutCaption)
                .foregroundStyle(isActive ? Color.textPrimary : Color.textMuted)

            if let metric {
                Text(verbatim: metric.rateLabel)
                    .font(.scoutNumberM)
                    .monospacedDigit()
                    .frame(height: 26)

                Text(verbatim: metric.pointsLabel)
                    .font(.scoutFootnoteStrong)
                    .foregroundStyle(metric.isRising ? Color.trendPositive : Color.textMuted)
                    .frame(height: 14)
            } else {
                SkeletonBar(width: 46, height: 14, delay: 0.16)
                    .frame(height: 26)

                SkeletonBar(width: 28, height: 6, delay: 0.16)
                    .frame(height: 14)
            }
        }
        .padding(.top, .space12)
        .padding(.bottom, 17)
    }
}

#Preview {
    ScrollView {
        LazyVStack(alignment: .leading, spacing: 0) {
            RetentionDayTabs(overview: RetentionOverview(cohorts: .samples), day: .constant(.day7))
                .padding(.horizontal, .gutter)
                .zIndex(1)

            SectionGap()

            RetentionDayTabs(overview: nil, day: .constant(.day7))
                .padding(.horizontal, .gutter)
        }
    }
    .scrollIndicators(.hidden)
}
