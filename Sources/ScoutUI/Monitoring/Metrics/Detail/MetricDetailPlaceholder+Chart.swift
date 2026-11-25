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
    func axis(now: Date) -> some View {
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

    var percentileSelector: some View {
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
                .matchingLineHeight(.scoutNumberL)

            SkeletonBar(width: 28, height: 9, delay: 0.08)
                .matchingLineHeight(.scoutCaption)
        }
        .padding(.top, .space10)
        .padding(.bottom, .space12)
    }

    func chartSkeleton(height: CGFloat, delay: Double) -> some View {
        SkeletonBar(height: height, delay: delay, cornerRadius: .radiusBadge)
    }
}
