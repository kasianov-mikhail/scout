//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import SwiftUI

struct HomeRetentionSection: View {
    let weeks: [RetentionWeek]?
    let onSelect: () -> Void

    var body: some View {
        if let weeks {
            if weeks.isEmpty {
                HomeRetentionSectionEmpty(now: Date())
            } else {
                content(weeks: weeks)
            }
        } else {
            HomeRetentionSectionPlaceholder()
        }
    }

    private func content(weeks: [RetentionWeek]) -> some View {
        let maxInstalls = weeks.maxInstalls

        return VStack(alignment: .leading, spacing: 0) {
            HomeRetentionHeader()

            ForEach(Array(weeks.enumerated()), id: \.element.id) { index, week in
                Button(action: onSelect) {
                    RetentionRowContent(
                        week: week,
                        maxInstalls: maxInstalls,
                        showsDivider: index < weeks.count - 1
                    )
                }
                .buttonStyle(.plain)
            }

            footer
                .padding(.top, .space4)
                .padding(.bottom, .space6)
        }
    }

    private var footer: some View {
        Text(verbatim: "Gray: installs that week · green: kept")
            .homeText(.caption)
    }
}

struct HomeRetentionHeader: View {
    @Environment(\.homeTypography) private var typography

    var body: some View {
        Header(title: "Retention", showsSeparator: true, font: typography.font(.section)) {
            Text(verbatim: "kept on day 7")
                .homeText(.caption)
        }
    }
}

private struct RetentionRowContent: View {
    let week: RetentionWeek
    let maxInstalls: Int
    let showsDivider: Bool

    var body: some View {
        HStack(spacing: .space10) {
            Text(verbatim: DateFormatter.monthDay.string(from: week.start))
                .homeText(.row)
                .frame(width: 56, alignment: .leading)

            RetentionBar(week: week, maxInstalls: maxInstalls)
                .frame(maxWidth: .infinity)

            value
                .frame(width: 84, alignment: .trailing)
        }
        .frame(height: .rowTable)
        .contentShape(Rectangle())
        .overlay(alignment: .bottom) {
            if showsDivider {
                Rectangle()
                    .fill(Color.separator)
                    .frame(height: 0.5)
            }
        }
    }

    @ViewBuilder
    private var value: some View {
        if let kept = week.kept, let rate = week.rate {
            HStack(spacing: 0) {
                Text(verbatim: "\(kept)")
                    .homeText(.monoValue)

                Text(verbatim: " · \(Int((rate * 100).rounded()))%")
                    .homeText(.monoDim)
            }
        } else {
            Text(verbatim: week.pendingLabel ?? "—")
                .homeText(.monoOff)
        }
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                HomeRetentionSection(weeks: .samples) {}
                HomeRetentionSection(weeks: nil) {}
            }
            .padding(.horizontal, .gutter)
        }
        .scrollIndicators(.hidden)
    }
}
