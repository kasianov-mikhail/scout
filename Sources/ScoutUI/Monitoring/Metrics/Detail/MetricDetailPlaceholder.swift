//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import SwiftUI

struct MetricDetailPlaceholder: View {
    enum Kind {
        case series(Telemetry.Export)
        case distribution(Telemetry.Export)
    }

    let kind: Kind

    @Binding var range: MetricRange

    var body: some View {
        let now = Date()
        let dates = placeholderRows(now: now)

        return LazyVStack(alignment: .leading, spacing: 0) {
            MetricRangeStrip(selection: $range)
                .padding(.top, .space8)
                .padding(.leading, .gutter)

            switch kind {
            case .series(let telemetry):
                headline(telemetry)
                    .padding(.top, .space12)
                    .padding(.horizontal, .gutter)

                chartSkeleton(height: 150, delay: 0.16)
                    .padding(.top, .space16)
                    .padding(.horizontal, .gutter)

                axis(now: now)
                    .padding(.horizontal, .gutter)

                legend
                    .padding(.horizontal, .gutter)

                Section(title: range.sectionTitle, note: trailingTitle(telemetry)) {
                    rows(dates: dates, now: now)
                }
            case .distribution(let telemetry):
                percentileSelector
                    .padding(.top, .space4)
                    .padding(.horizontal, .gutter)

                SkeletonBar(width: 120, height: 9, delay: 0.08)
                    .padding(.top, .space8)
                    .padding(.horizontal, .gutter)
                    .frame(maxWidth: .infinity, alignment: .leading)

                chartSkeleton(height: 150, delay: 0.16)
                    .padding(.top, .space16)
                    .padding(.horizontal, .gutter)

                axis(now: now)
                    .padding(.horizontal, .gutter)

                legend
                    .padding(.horizontal, .gutter)

                Section(title: "Distribution", note: distributionCaption(telemetry), bottomGap: .space8) {
                    chartSkeleton(height: 126, delay: 0.24)
                        .padding(.top, .space8)
                }

                Section(title: range.sectionTitle, note: trailingTitle(telemetry)) {
                    rows(dates: dates, now: now)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Loading"))
    }

    private func headline(_ telemetry: Telemetry.Export) -> some View {
        VStack(alignment: .leading, spacing: .space2) {
            HStack(alignment: .firstTextBaseline, spacing: .space8) {
                SkeletonBar(width: 74, height: 24, delay: 0.08)

                if telemetry == .meter {
                    SkeletonBar(width: 74, height: 11, delay: 0.08)
                } else {
                    SkeletonBar(width: 74, height: 9, delay: 0.08)
                        .frame(height: 18, alignment: .leading)
                }
            }

            SkeletonBar(width: 120, height: 9, delay: 0.08)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func axis(now: Date) -> some View {
        HStack(spacing: 0) {
            ForEach(Array(range.axisLabels(now: now).enumerated()), id: \.offset) { index, _ in
                if index > 0 {
                    Spacer(minLength: 0)
                }

                SkeletonBar(width: 30, height: 8, delay: 0.16)
            }
        }
        .frame(height: 12)
        .padding(.top, .space4)
    }

    private var legend: some View {
        SkeletonBar(width: 74, height: 8, delay: 0.2)
            .frame(height: 14, alignment: .leading)
            .padding(.top, .space10)
            .padding(.bottom, .space16)
    }

    private var percentileSelector: some View {
        ReadoutTabStrip(
            values: MetricQuantile.allCases,
            isSelected: { _ in false },
            isLoading: true,
            spacing: .space12,
            onSelect: nil
        ) { quantile, _ in
            skeletonQuantile(quantile)
        }
    }

    private func skeletonQuantile(_ quantile: MetricQuantile) -> some View {
        VStack(alignment: .leading, spacing: .space2) {
            Text(verbatim: quantile.title)
                .font(.scoutCaptionStrong)
                .foregroundStyle(Color.textMuted)

            SkeletonBar(width: 74, height: 20, delay: 0.08)

            SkeletonBar(width: 28, height: 9, delay: 0.08)
        }
        .padding(.top, .space10)
        .padding(.bottom, .space12)
    }

    private func chartSkeleton(height: CGFloat, delay: Double) -> some View {
        SkeletonBar(height: height, delay: delay, cornerRadius: .radiusBadge, fill: Color.surfaceGrey)
    }

    private func row(index: Int, dates: [Date], now: Date) -> some View {
        let date = dates[index]
        let delay = 0.24 + Double(index) * 0.08

        return HStack(spacing: .space8) {
            SkeletonBar(width: 40, height: 9, delay: delay)
                .frame(width: 56, alignment: .leading)

            HStack(spacing: .space6) {
                SkeletonBar(height: 8, delay: delay, cornerRadius: .radiusBar)
                    .frame(maxWidth: .infinity)

                if range.isCurrent(date: date, now: now) {
                    SkeletonBar(width: 24, height: 7, delay: delay)
                        .frame(width: 34, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            SkeletonBar(width: 28, height: 10, delay: delay)
                .frame(width: 56, alignment: .trailing)

            SkeletonBar(width: 28, height: 9, delay: delay)
                .frame(width: 48, alignment: .trailing)
        }
        .frame(height: .rowTable)
        .overlay(alignment: .bottom) {
            if index < dates.count - 1 {
                DashedLine()
            }
        }
    }

    private func rows(dates: [Date], now: Date) -> some View {
        ForEach(dates.indices, id: \.self) { index in
            row(index: index, dates: dates, now: now)
        }
    }

    private func placeholderRows(now: Date) -> [Date] {
        let buckets = range.buckets(now: now).filter { !range.isFuture(date: $0.lowerBound, now: now) }
        return buckets.suffix(6).reversed().map(\.lowerBound)
    }

    private func trailingTitle(_ telemetry: Telemetry.Export) -> String {
        switch telemetry {
        case .meter:
            "peak \(range.comparisonTitle)"
        case .timer:
            "p90 \(range.comparisonTitle)"
        case .recorder:
            "p50 \(range.comparisonTitle)"
        case .counter, .floatingCounter:
            range.comparisonTitle
        }
    }

    private func distributionCaption(_ telemetry: Telemetry.Export) -> String {
        range.caption(unit: telemetry == .timer ? "ms" : nil)
    }
}

#Preview("Counter loading") {
    NavigationStack {
        ScrollView {
            MetricDetailPlaceholder(kind: .series(.counter), range: .constant(.today))
        }
        .scrollIndicators(.hidden)
        .monospacedNavigationTitle(en: "checkout.completed")
    }
}

#Preview("Timer loading") {
    NavigationStack {
        ScrollView {
            MetricDetailPlaceholder(kind: .distribution(.timer), range: .constant(.today))
        }
        .scrollIndicators(.hidden)
        .monospacedNavigationTitle(en: "http.request.duration")
    }
}
