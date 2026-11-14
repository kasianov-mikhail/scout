//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import SwiftUI

struct HomeActiveUsersSectionEmpty: View {
    let start: Date
    let end: Date
    let onShowAll: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Header(title: "Active Users", showsSeparator: true) {
                HomeSectionExpandButton(label: "Show all active users", action: onShowAll)
            }

            HStack(alignment: .top, spacing: 0) {
                ForEach(ActiveUsers.Kind.allCases) { kind in
                    metric(kind: kind)
                }
            }
            .background(alignment: .bottom) {
                Separator()
            }

            chart
                .padding(.top, .space12)

            Text(verbatim: "No sessions in the last 30 days")
                .font(.scoutCaption)
                .foregroundStyle(Color.textMuted)
                .padding(.top, .space10)
                .padding(.bottom, .space6)
        }
    }

    private func metric(kind: ActiveUsers.Kind) -> some View {
        VStack(alignment: .leading, spacing: .space2) {
            Text(verbatim: kind.title.uppercased())
                .font(.scoutCaptionStrong)

            EmptyBar(width: 83, height: 28, cornerRadius: .radiusBadge)
                .frame(height: 34, alignment: .leading)

            EmptyBar(width: 48, height: 10)
                .frame(height: 15, alignment: .leading)
        }
        .padding(.vertical, .space10)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var chart: some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom, spacing: .space2) {
                ForEach(Array(Self.heights.enumerated()), id: \.offset) { _, height in
                    EmptyBar(height: height, cornerRadius: .radiusBar)
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 72, alignment: .bottom)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color.surfaceBarIdle)
                    .frame(height: 0.5)
            }

            AxisLabelRow(
                start: DateFormatter.monthDay.string(from: start),
                middle: DateFormatter.monthDay.string(from: middle),
                end: "today",
                topInset: 6,
                design: .monospaced
            )
        }
    }

    private static let heights: [CGFloat] = [
        40, 46, 44, 48, 42, 50, 47, 52, 49, 45,
        51, 54, 50, 48, 53, 56, 52, 49, 55, 58,
        54, 51, 57, 60, 56, 53, 58, 62, 59, 64,
    ]

    private var middle: Date {
        start.addingTimeInterval(end.timeIntervalSince(start) / 2)
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                HomeActiveUsersSectionEmpty(start: HomeSnapshot.date.addingDay(-29), end: HomeSnapshot.date) {}
            }
            .padding(.horizontal, .gutter)
        }
        .scrollIndicators(.hidden)
    }
}
