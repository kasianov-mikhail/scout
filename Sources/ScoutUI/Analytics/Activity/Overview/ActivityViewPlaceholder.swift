//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ActivityViewPlaceholder: View {
    @Binding var range: ActivityRange
    let metric: ActivityPeriod

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            RangeStrip(selection: $range, ranges: ActivityRange.allCases, title: \.title)
                .padding(.top, .space8)
                .padding(.trailing, -16)

            metrics
                .padding(.top, .space4)

            chart
                .padding(.top, .space16)

            stickiness
                .padding(.top, .space12)

            ActivityRowsHeader()

            ForEach(0..<8, id: \.self) { index in
                row(index: index)
            }
        }
        .padding(.horizontal, .gutter)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Loading"))
    }

    private var metrics: some View {
        HStack(alignment: .top, spacing: .space12) {
            ForEach(ActivityPeriod.allCases) { period in
                VStack(alignment: .leading, spacing: .space2) {
                    Text(verbatim: period.rawValue)
                        .font(.scoutCaptionStrong)
                        .foregroundStyle(period == metric ? Color.textPrimary : Color.fillLevel)

                    SkeletonBar(width: 74, height: 20, delay: 0.08)
                        .frame(height: 33, alignment: .leading)

                    SkeletonBar(width: 28, height: 6, delay: 0.08)
                        .frame(height: 15, alignment: .leading)
                }
                .padding(.top, .space10)
                .padding(.bottom, .space12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(alignment: .bottom) {
                    if period == metric {
                        Rectangle()
                            .fill(Color.surfaceSkeleton)
                            .frame(height: 2)
                    }
                }
            }
        }
        .background(alignment: .bottom) {
            Separator()
        }
    }

    private var chart: some View {
        let axis = range.axis(now: Date())

        return VStack(spacing: 0) {
            SkeletonBar(height: 96, delay: 0.16, cornerRadius: .radiusBadge, fill: Color.surfaceGrey)

            AxisLabelRow(
                start: axis.start,
                middle: axis.middle,
                end: axis.end,
                topInset: 6,
                design: .monospaced
            )
        }
    }

    private var stickiness: some View {
        HStack(spacing: .space6) {
            Text(verbatim: "Stickiness")

            SkeletonBar(width: 28, height: 9, delay: 0.24)
            SkeletonBar(width: 194, height: 9, delay: 0.24)
        }
        .font(.scoutCaption)
        .foregroundStyle(Color.textMuted)
        .padding(.bottom, .space12)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)
        }
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
            ActivityViewPlaceholder(range: .constant(.month), metric: .daily)
        }
        .scrollIndicators(.hidden)
        .navigationTitle(en: "Active users")
        .inlineNavigationTitle()
    }
}
