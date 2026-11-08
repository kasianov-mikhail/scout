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

        return InsetList {
            MetricRangeStrip(selection: $range)
                .padding(.top, 8)
                .padding(.trailing, -16)
                .frame(minHeight: 44)

            switch kind {
            case .series(let telemetry):
                headline(telemetry)
                    .padding(.top, 12)
                    .frame(minHeight: 44)

                chartSkeleton(height: 150, delay: 0.16)
                    .padding(.top, 16)
                    .frame(minHeight: 44)

                MetricAxisLabels(labels: range.axisLabels(now: now))
                    .frame(minHeight: 44)

                MetricLegend(title: range.previousTitle, note: nil)
                    .frame(minHeight: 44)

                MetricSectionHeader(title: range.sectionTitle, trailing: trailingTitle(telemetry))
                    .frame(minHeight: 44)
            case .distribution(let telemetry):
                percentileSelector
                    .padding(.top, 4)
                    .frame(minHeight: 44)

                SkeletonBar(width: 120, height: 9, delay: 0.08)
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: 44)

                chartSkeleton(height: 150, delay: 0.16)
                    .padding(.top, 16)
                    .frame(minHeight: 44)

                MetricAxisLabels(labels: range.axisLabels(now: now))
                    .frame(minHeight: 44)

                MetricLegend(title: range.previousTitle, note: nil)
                    .frame(minHeight: 44)

                MetricSectionHeader(title: "DISTRIBUTION", trailing: distributionCaption(telemetry))
                    .frame(minHeight: 44)

                chartSkeleton(height: 126, delay: 0.24)
                    .padding(.top, 8)
                    .frame(minHeight: 44)

                MetricSectionHeader(title: range.sectionTitle, trailing: trailingTitle(telemetry))
                    .frame(minHeight: 44)
            }

            ForEach(dates.indices, id: \.self) { index in
                row(index: index, dates: dates, now: now)
                    .frame(minHeight: 44)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Loading"))
    }

    private func headline(_ telemetry: Telemetry.Export) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                SkeletonBar(width: 74, height: 24, delay: 0.08)

                if telemetry == .meter {
                    SkeletonBar(width: 74, height: 11, delay: 0.08)
                } else {
                    Text(verbatim: range.totalTitle)
                        .font(.system(size: 15))
                        .foregroundStyle(Color(.systemGray))
                }
            }

            SkeletonBar(width: 120, height: 9, delay: 0.08)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var percentileSelector: some View {
        HStack(spacing: 12) {
            ForEach(MetricQuantile.allCases) { quantile in
                VStack(alignment: .leading, spacing: 2) {
                    Text(verbatim: quantile.title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color(.systemGray))

                    SkeletonBar(width: 74, height: 20, delay: 0.08)

                    SkeletonBar(width: 28, height: 9, delay: 0.08)
                }
                .padding(.top, 10)
                .padding(.bottom, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)
        }
    }

    private func chartSkeleton(height: CGFloat, delay: Double) -> some View {
        SkeletonBar(height: height, delay: delay, cornerRadius: 4, fill: Color(.systemGray6))
    }

    private func row(index: Int, dates: [Date], now: Date) -> some View {
        let date = dates[index]
        let delay = 0.24 + Double(index) * 0.08

        return HStack(spacing: 8) {
            Text(verbatim: range.rowLabel(date: date))
                .font(.system(size: 13, design: .monospaced))
                .monospacedDigit()
                .foregroundStyle(Color(.systemGray))
                .frame(width: 56, alignment: .leading)

            HStack(spacing: 6) {
                SkeletonBar(height: 8, delay: delay, cornerRadius: 2)
                    .frame(maxWidth: .infinity)

                if range.isCurrent(date: date, now: now) {
                    Text(verbatim: "so far")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(.systemGray))
                        .frame(width: 34, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            SkeletonBar(width: 28, height: 10, delay: delay)
                .frame(width: 56, alignment: .trailing)

            SkeletonBar(width: 28, height: 9, delay: delay)
                .frame(width: 48, alignment: .trailing)
        }
        .frame(height: 40)
        .overlay(alignment: .bottom) {
            if index < dates.count - 1 {
                DashedLine()
            }
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
        MetricDetailPlaceholder(kind: .series(.counter), range: .constant(.today))
            .monospacedNavigationTitle(en: "checkout.completed")
    }
}

#Preview("Timer loading") {
    NavigationStack {
        MetricDetailPlaceholder(kind: .distribution(.timer), range: .constant(.today))
            .monospacedNavigationTitle(en: "http.request.duration")
    }
}
