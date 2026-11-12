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
            content(weeks: weeks)
        } else {
            HomeRetentionSectionPlaceholder()
        }
    }

    private func content(weeks: [RetentionWeek]) -> some View {
        let maxInstalls = weeks.maxInstalls

        return VStack(alignment: .leading, spacing: 0) {
            header

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
                .padding(.top, 4)
                .padding(.bottom, 6)
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            Text(verbatim: "RETENTION")
                .font(.callout.weight(.bold))

            Spacer()

            Text(verbatim: "kept on day 7")
                .font(.weight450(size: 13))
                .foregroundStyle(Color(.systemGray))
        }
        .padding(.top, 12)
        .frame(height: 70)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)
        }
    }

    private var footer: some View {
        Text(verbatim: "Gray: installs that week · green: kept")
            .font(.weight450(size: 13))
            .foregroundStyle(Color(.systemGray))
    }
}

private struct RetentionRowContent: View {
    let week: RetentionWeek
    let maxInstalls: Int
    let showsDivider: Bool

    var body: some View {
        HStack(spacing: 10) {
            Text(verbatim: DateFormatter.monthDay.string(from: week.start))
                .font(.weight450(size: 15))
                .frame(width: 56, alignment: .leading)

            RetentionBar(week: week, maxInstalls: maxInstalls)
                .frame(maxWidth: .infinity)

            value
                .frame(width: 84, alignment: .trailing)
        }
        .frame(height: 40)
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
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color.positive)

                Text(verbatim: " · \(Int((rate * 100).rounded()))%")
                    .foregroundStyle(Color(.systemGray))
            }
            .font(.weight450(size: 13, design: .monospaced))
        } else {
            Text(verbatim: week.pendingLabel ?? "—")
                .font(.weight450(size: 13, design: .monospaced))
                .foregroundStyle(Color.pending)
        }
    }
}

#Preview {
    NavigationStack {
        InsetList {
            HomeRetentionSection(weeks: .samples) {}
            HomeRetentionSection(weeks: nil) {}
        }
    }
}
