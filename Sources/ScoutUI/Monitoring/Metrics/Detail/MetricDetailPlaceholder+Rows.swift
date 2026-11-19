//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import SwiftUI

extension MetricDetailPlaceholder {
    func rows(dates: [Date], now: Date) -> some View {
        ForEach(dates.indices, id: \.self) { index in
            row(index: index, dates: dates, now: now)
        }
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

    func placeholderRows(now: Date) -> [Date] {
        let buckets = range.buckets(now: now).filter { !range.isFuture(date: $0.lowerBound, now: now) }
        return buckets.suffix(6).reversed().map(\.lowerBound)
    }

    func trailingTitle(_ telemetry: Telemetry.Export) -> String {
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

    func distributionCaption(_ telemetry: Telemetry.Export) -> String {
        range.caption(unit: telemetry == .timer ? "ms" : nil)
    }
}
