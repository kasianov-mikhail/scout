//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct HomeActiveUsersSectionPlaceholder: View {
    var body: some View {
        Section(title: "Active Users", bottomGap: .space10) {
            ReadoutTabStrip(
                values: ActiveUsers.Kind.allCases,
                isSelected: { _ in false },
                isLoading: true,
                spacing: 0,
                onSelect: nil
            ) { kind, _ in
                metric(kind: kind)
            }

            SkeletonBar(height: 72, delay: 0.56, fill: Color.surfaceGrey)
                .padding(.top, .space12)

            AxisLabelRow(
                start: DateFormatter.monthDay.string(from: start),
                middle: DateFormatter.monthDay.string(from: middle),
                end: "today",
                topInset: 6,
                design: .monospaced
            )

            SkeletonBar(width: 194, height: 8, delay: 0.64)
                .frame(height: 18, alignment: .leading)
                .padding(.top, .space10)
                .padding(.bottom, .space6)
        }
        .placeholder()
    }

    private func metric(kind: ActiveUsers.Kind) -> some View {
        VStack(alignment: .leading, spacing: .space2) {
            Text(verbatim: kind.title.uppercased())
                .font(.scoutCaptionStrong)
                .foregroundStyle(Color.textMuted)

            SkeletonBar(width: 74, height: 17, delay: 0.4)
                .frame(height: 34)

            SkeletonBar(width: 46, height: 8, delay: 0.48)
                .frame(height: 15)
        }
        .padding(.vertical, .space10)
    }

    private var end: Date {
        Date().startOfDay
    }

    private var start: Date {
        end.addingDay(-29)
    }

    private var middle: Date {
        start.addingTimeInterval(end.timeIntervalSince(start) / 2)
    }
}
