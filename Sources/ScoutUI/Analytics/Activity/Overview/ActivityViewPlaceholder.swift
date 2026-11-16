//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ActivityViewPlaceholder: View {
    @Binding var range: ActivityRange

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            RangeStrip(selection: $range, ranges: ActivityRange.allCases, title: \.title)
                .padding(.top, .space8)
                .padding(.leading, .gutter)

            metrics
                .padding(.top, .space4)
                .padding(.horizontal, .gutter)

            chart
                .padding(.top, .space16)
                .padding(.horizontal, .gutter)

            stickiness
                .padding(.top, .space12)
                .padding(.horizontal, .gutter)

            Section(title: "Per day", bottomGap: 0) {
                Text(verbatim: "vs day before")
                    .font(.scoutCaption)
                    .foregroundStyle(Color.textMuted)
            } content: {
                ForEach(0..<8, id: \.self) { index in
                    row(index: index)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Loading"))
    }

    private var metrics: some View {
        ReadoutTabStrip(
            values: ActivityPeriod.allCases,
            isSelected: { _ in false },
            isLoading: true,
            spacing: .space12,
            onSelect: nil
        ) { period, _ in
            skeletonMetric(period)
        }
    }

    private func skeletonMetric(_ period: ActivityPeriod) -> some View {
        VStack(alignment: .leading, spacing: .space2) {
            Text(verbatim: period.rawValue)
                .font(.scoutCaptionStrong)
                .foregroundStyle(Color.textMuted)

            SkeletonBar(width: 74, height: 20, delay: 0.08)
                .frame(height: 33)

            SkeletonBar(width: 28, height: 6, delay: 0.08)
                .frame(height: 15)
        }
        .padding(.top, .space10)
        .padding(.bottom, .space12)
    }

    private var chart: some View {
        VStack(spacing: 0) {
            SkeletonBar(height: 96, delay: 0.16, cornerRadius: .radiusBadge, fill: Color.surfaceGrey)

            axis
        }
    }

    private var axis: some View {
        HStack(spacing: 0) {
            SkeletonBar(width: 34, height: 8, delay: 0.2)

            Spacer()

            SkeletonBar(width: 34, height: 8, delay: 0.2)

            Spacer()

            SkeletonBar(width: 34, height: 8, delay: 0.2)
        }
        .frame(height: 12)
        .padding(.top, 6)
    }

    private var stickiness: some View {
        HStack(spacing: .space6) {
            SkeletonBar(width: 74, height: 9, delay: 0.24)
                .frame(height: 16, alignment: .leading)

            SkeletonBar(width: 28, height: 9, delay: 0.24)
            SkeletonBar(width: 194, height: 9, delay: 0.24)
        }
        .padding(.bottom, .space16)
    }

    private func row(index: Int) -> some View {
        let delay = 0.32 + Double(index) * 0.08

        return HStack(spacing: .space8) {
            SkeletonBar(width: 46, height: 9, delay: delay)
                .frame(width: 64, alignment: .leading)

            SkeletonBar(height: 8, delay: delay, cornerRadius: .radiusBar, fill: Color.surfaceGrey)

            SkeletonBar(width: 46, height: 9, delay: delay)
                .frame(width: 52, alignment: .trailing)

            SkeletonBar(width: 28, height: 9, delay: delay)
                .frame(width: 52, alignment: .trailing)
        }
        .frame(height: .rowTable)
        .overlay(alignment: .bottom) {
            if index < 7 {
                DashedLine()
            }
        }
    }
}

#Preview("Activity loading") {
    NavigationStack {
        ScrollView {
            ActivityViewPlaceholder(range: .constant(.month))
        }
        .scrollIndicators(.hidden)
        .navigationTitle(en: "Active users")
        .inlineNavigationTitle()
    }
}
