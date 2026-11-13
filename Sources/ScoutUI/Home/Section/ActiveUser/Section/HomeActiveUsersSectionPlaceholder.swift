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
        VStack(alignment: .leading, spacing: 0) {
            Header(title: "Active Users")

            HStack(alignment: .top, spacing: 0) {
                ForEach(ActiveUsers.Kind.allCases) { kind in
                    metric(kind: kind)
                }
            }
            .background(alignment: .bottom) {
                Separator()
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
    }

    private func metric(kind: ActiveUsers.Kind) -> some View {
        VStack(alignment: .leading, spacing: .space2) {
            Text(verbatim: kind.title.uppercased())
                .font(.scoutCaptionStrong)
                .foregroundStyle(Color.homeCaption)

            SkeletonBar(width: 74, height: 17, delay: 0.4)
                .frame(height: 34, alignment: .leading)

            SkeletonBar(width: 46, height: 8, delay: 0.48)
                .frame(height: 15, alignment: .leading)
        }
        .padding(.vertical, .space10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) {
            if kind == .dau {
                Rectangle()
                    .fill(Color.surfaceSkeleton)
                    .frame(height: 2)
                    .padding(.trailing, .space12)
            }
        }
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
