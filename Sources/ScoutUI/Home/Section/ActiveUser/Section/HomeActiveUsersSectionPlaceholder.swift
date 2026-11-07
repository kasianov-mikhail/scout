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
                ForEach([ActiveUsers.Kind.dau, .sessions, .devices]) { kind in
                    metric(kind: kind)
                }
            }

            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)

            SkeletonBar(height: 72, delay: 0.56, fill: Color(.systemGray6))
                .padding(.top, 14)

            AxisLabelRow(
                start: DateFormatter.monthDay.string(from: start),
                middle: DateFormatter.monthDay.string(from: middle),
                end: "today",
                topInset: 4,
                design: .default
            )

            SkeletonBar(width: 194, height: 8, delay: 0.64)
                .padding(.top, 10)
                .padding(.bottom, 6)
        }
        .listRowSeparator(.hidden)
    }

    private func metric(kind: ActiveUsers.Kind) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(verbatim: kind.title.uppercased())
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color(.systemGray))

            SkeletonBar(width: 74, height: 17, delay: 0.4)
                .frame(height: 34, alignment: .leading)

            SkeletonBar(width: 46, height: 8, delay: 0.48)
                .frame(height: 15, alignment: .leading)
        }
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) {
            if kind == .dau {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 2)
                    .padding(.trailing, 12)
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
