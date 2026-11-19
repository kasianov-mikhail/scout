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

    private var legend: some View {
        SkeletonBar(width: 74, height: 8, delay: 0.2)
            .frame(height: 14, alignment: .leading)
            .padding(.top, .space10)
            .padding(.bottom, .space16)
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
