//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import SwiftUI

struct HomeRetentionSection: View {
    private enum Destination: Hashable {
        case retention
    }

    let weeks: [RetentionWeek]
    let retention: RetentionProvider

    @Binding private var path: NavigationPath

    init(weeks: [RetentionWeek], retention: RetentionProvider, path: Binding<NavigationPath>) {
        self.weeks = weeks
        self.retention = retention
        self._path = path
    }

    var body: some View {
        section.navigationDestination(for: Destination.self) { _ in
            RetentionView(provider: retention)
        }
    }

    private var section: some View {
        Group {
            if weeks.isEmpty {
                Empty(now: Date())
            } else {
                content(weeks: weeks)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: showRetention)
    }

    private func showRetention() {
        path.append(Destination.retention)
    }

    private func content(weeks: [RetentionWeek]) -> some View {
        let maxInstalls = weeks.maxInstalls

        return Section(title: "Retention", note: "kept on day 7", bottomGap: .space10) {
            ForEach(Array(weeks.enumerated()), id: \.element.id) { index, week in
                Button(action: showRetention) {
                    RetentionRowContent(
                        week: week,
                        maxInstalls: maxInstalls,
                        showsDivider: index < weeks.count - 1
                    )
                }
                .buttonStyle(.solid)
            }

            footer
                .padding(.top, .space4)
                .padding(.bottom, .space6)
        }
    }

    private var footer: some View {
        Text(verbatim: "Gray: installs that week · green: kept")
            .font(.scoutCaption)
            .foregroundStyle(Color.textMuted)
    }
}

private struct RetentionRowContent: View {
    let week: RetentionWeek
    let maxInstalls: Int
    let showsDivider: Bool

    var body: some View {
        HStack(spacing: .space10) {
            Text(verbatim: DateFormatter.monthDay.string(from: week.start))
                .font(.scoutRow)
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
                Separator.dashed
            }
        }
    }

    @ViewBuilder
    private var value: some View {
        if let kept = week.kept, let rate = week.rate {
            HStack(spacing: 0) {
                Text(verbatim: "\(kept)")
                    .font(.scoutValueStrong)
                    .foregroundStyle(Color.positive)

                Text(verbatim: " · \(Int((rate * 100).rounded()))%")
                    .foregroundStyle(Color.textMuted)
            }
            .font(.scoutValue)
        } else {
            Text(verbatim: week.pendingLabel ?? "—")
                .font(.scoutValue)
                .foregroundStyle(Color.pending)
        }
    }
}

@available(iOS 17.0, macOS 14.0, *)
#Preview {
    @Previewable @State var path = NavigationPath()

    NavigationStack(path: $path) {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HomeRetentionSection(
                    weeks: .samples,
                    retention: RetentionProvider(.success(.samples)),
                    path: $path
                )
                HomeRetentionSection.Placeholder()
            }
        }
        .scrollIndicators(.hidden)
    }
}
